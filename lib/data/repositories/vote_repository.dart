import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/vote_model.dart';

class VoteRepository {
  final FirebaseFirestore _firestore =
      FirebaseFirestore.instance;

  Future<void> addVote(Vote vote) async {
    await _firestore.collection('votes').doc(vote.id).set({
      'id': vote.id,
      'gatheringId': vote.gatheringId,
      'userId': vote.userId,
      'targetId': vote.targetId,
      'targetType': vote.targetType,
    });
  }

  Future<List<Vote>> getVotes(String gatheringId) async {
    final snapshot = await _firestore
        .collection('votes')
        .where('gatheringId', isEqualTo: gatheringId)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data();

      return Vote(
        id: data['id'] as String,
        gatheringId: data['gatheringId'] as String,
        userId: data['userId'] as String,
        targetId: data['targetId'] as String,
        targetType: data['targetType'] as String,
      );
    }).toList();
  }

  Future<void> deleteVote(String voteId) async {
    await _firestore.collection('votes').doc(voteId).delete();
  }
}