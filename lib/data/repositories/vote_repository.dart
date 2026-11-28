import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/vote_model.dart';

class VoteRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  VoteRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  // Saves or replaces the user's vote for one category.
  //
  // targetType examples:
  // "datetime"
  // "place"
  Future<void> saveVote({
    required String gatheringId,
    required String userId,
    required String targetId,
    required String targetType,
  }) async {
    final voteId = '${gatheringId}_${userId}_$targetType';

    final vote = Vote(
      id: voteId,
      gatheringId: gatheringId,
      userId: userId,
      targetId: targetId,
      targetType: targetType,
    );

    await _firestore.runTransaction((transaction) async {
      await _checkVotingAccess(transaction, gatheringId, userId, targetType);
      transaction.set(_firestore.collection('votes').doc(voteId), {
        'id': vote.id,
        'gatheringId': vote.gatheringId,
        'userId': vote.userId,
        'targetId': vote.targetId,
        'targetType': vote.targetType,
        'createdAt': FieldValue.serverTimestamp(),
      });
    });
  }

  // Gets all votes for a gathering.
  // You can optionally filter by "datetime" or "place".
  Future<List<Vote>> getVotes(String gatheringId, {String? targetType}) async {
    Query<Map<String, dynamic>> query = _firestore
        .collection('votes')
        .where('gatheringId', isEqualTo: gatheringId);

    if (targetType != null) {
      query = query.where('targetType', isEqualTo: targetType);
    }

    final snapshot = await query.get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Vote(
        id: data['id']?.toString() ?? doc.id,
        gatheringId: data['gatheringId']?.toString() ?? '',
        userId: data['userId']?.toString() ?? '',
        targetId: data['targetId']?.toString() ?? '',
        targetType: data['targetType']?.toString() ?? '',
      );
    }).toList();
  }

  // Live votes for one gathering and category.
  Stream<List<Vote>> watchVotes(
    String gatheringId, {
    required String targetType,
  }) {
    return _firestore
        .collection('votes')
        .where('gatheringId', isEqualTo: gatheringId)
        .where('targetType', isEqualTo: targetType)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            return Vote(
              id: doc.id,
              gatheringId: data['gatheringId'] as String,
              userId: data['userId'] as String,
              targetId: data['targetId'] as String,
              targetType: data['targetType'] as String,
            );
          }).toList(),
        );
  }

  // Deletes the user's vote for a category.
  Future<void> deleteVote({
    required String gatheringId,
    required String userId,
    required String targetType,
  }) async {
    final voteId = '${gatheringId}_${userId}_$targetType';

    await _firestore.runTransaction((transaction) async {
      await _checkVotingAccess(transaction, gatheringId, userId, targetType);
      transaction.delete(_firestore.collection('votes').doc(voteId));
    });
  }

  // Reading membership and closure in the same transaction as the vote prevents
  // a delayed save/remove from racing with the inviter's finalization.
  Future<void> _checkVotingAccess(
    Transaction transaction,
    String gatheringId,
    String userId,
    String targetType,
  ) async {
    if (_auth.currentUser?.uid != userId) {
      throw StateError('You can only update your own vote.');
    }
    final document = await transaction.get(
      _firestore.collection('gatherings').doc(gatheringId),
    );
    final data = document.data();
    if (data == null) throw StateError('Gathering not found.');
    final members = List<String>.from(data['participantIds'] ?? []);
    if (!members.contains(userId)) {
      throw StateError('You are no longer participating in this gathering.');
    }
    if (targetType == 'datetime' && data['votingEnded'] == true) {
      throw StateError('Date voting has ended.');
    }
    if (targetType == 'place' && data['votingEnded'] != true) {
      throw StateError('Place voting starts after date voting ends.');
    }
  }

  // Counts how many votes each option received.
  Future<Map<String, int>> countVotes({
    required String gatheringId,
    required String targetType,
  }) async {
    final votes = await getVotes(gatheringId, targetType: targetType);

    final counts = <String, int>{};

    for (final vote in votes) {
      counts[vote.targetId] = (counts[vote.targetId] ?? 0) + 1;
    }

    return counts;
  }

  // Returns the option with the highest number of votes.
  Future<String?> getWinningOption({
    required String gatheringId,
    required String targetType,
  }) async {
    final counts = await countVotes(
      gatheringId: gatheringId,
      targetType: targetType,
    );

    if (counts.isEmpty) return null;

    String winnerId = counts.keys.first;

    for (final optionId in counts.keys) {
      if (counts[optionId]! > counts[winnerId]!) {
        winnerId = optionId;
      }
    }

    return winnerId;
  }
}
