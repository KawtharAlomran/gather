import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/gathering_model.dart';
import '../../models/vote_model.dart';
import 'date_voting_result.dart';
import 'preference_repository.dart';

class DateVotingRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final Future<List<DateOptionModel>> Function(GatheringModel) _loadOptions;

  DateVotingRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    Future<List<DateOptionModel>> Function(GatheringModel)? loadOptions,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _loadOptions = loadOptions ?? loadDateOptions;

  Future<GatheringModel> endVoting(String gatheringId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw StateError('Please sign in first.');
    final ref = _firestore.collection('gatherings').doc(gatheringId);
    final initial = await ref.get();
    if (!initial.exists) throw StateError('Gathering not found.');
    final initialData = initial.data()!;
    if (initialData['creatorId'] != uid) {
      throw StateError('Only the inviter can end date voting.');
    }
    if (initialData['votingEnded'] == true &&
        initialData['selectedDate'] != null) {
      return GatheringModel.fromJson({...initialData, 'id': gatheringId});
    }
    final options = await _loadOptions(
      GatheringModel.fromJson({...initialData, 'id': gatheringId}),
    );
    final invitations = await _firestore
        .collection('invitations')
        .where('gatheringId', isEqualTo: gatheringId)
        .get();

    return _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(ref);
      if (!snapshot.exists) throw StateError('Gathering not found.');
      final data = snapshot.data()!;
      if (data['creatorId'] != uid) {
        throw StateError('Only the inviter can end date voting.');
      }
      if (data['votingEnded'] == true && data['selectedDate'] != null) {
        return GatheringModel.fromJson({...data, 'id': gatheringId});
      }
      final members = (gatheringParticipantIds(data) ?? []).toSet();
      final invitationSnapshots = <DocumentSnapshot<Map<String, dynamic>>>[];
      for (final invitation in invitations.docs) {
        invitationSnapshots.add(await transaction.get(invitation.reference));
      }
      final accepted = invitationSnapshots
          .where((doc) => doc.data()?['status'] == 'accepted')
          .map((doc) => doc.data()?['inviteeId'])
          .whereType<String>()
          .toSet();
      final votes = <Vote>[];
      for (final member in members) {
        final vote = await transaction.get(
          _firestore
              .collection('votes')
              .doc('${gatheringId}_${member}_datetime'),
        );
        final value = vote.data();
        if (value == null ||
            value['gatheringId'] != gatheringId ||
            value['userId'] != member ||
            value['targetType'] != 'datetime')
          continue;
        votes.add(
          Vote(
            id: vote.id,
            gatheringId: gatheringId,
            userId: member,
            targetId: value['targetId']?.toString() ?? '',
            targetType: 'datetime',
          ),
        );
      }
      final result = calculateDateVotingResult(
        options: options,
        votes: votes,
        participantIds: members,
        acceptedInviteeIds: accepted,
        creatorId: uid,
      );
      final period = result.winner.timePeriod;
      if (period == null) throw StateError('Winning option has no valid time period.');
      final update = <String, dynamic>{
        'votingEnded': true,
        'selectedDate': result.winner.dateTime.toUtc().toIso8601String(),
        'selectedTimePeriod': period,
        'winningDateOptionId': result.winner.id,
        'participantIds': result.participantIds,
        // Freeze the choices so later preference edits cannot change the result.
        'dateOptions': options
            .map((o) => {...o.toJson(), 'label': o.label})
            .toList(),
      };
      transaction.update(ref, {
        ...update,
        'dateVotingEndedAt': FieldValue.serverTimestamp(),
      });
      for (final invitation in invitationSnapshots) {
        final value = invitation.data();
        if (value == null) continue;
        final status = value['status'];
        if (status == 'pending' ||
            (status == 'accepted' &&
                !result.participantIds.contains(value['inviteeId']))) {
          transaction.update(invitation.reference, {
            'status': 'excluded',
            'exclusionReason': status == 'pending'
                ? 'invitation_not_accepted'
                : 'no_date_vote',
          });
        }
      }
      return GatheringModel.fromJson({...data, ...update, 'id': gatheringId});
    });
  }
}
