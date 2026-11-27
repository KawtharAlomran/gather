
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';

import '../../models/gathering_model.dart';
import 'preference_repository.dart';

// Defines the operations for managing gatherings.
abstract class GatheringRepository {
  Future<List<Gathering>> getGatherings();

  Future<Gathering?> getGatheringById(String gatheringId);

  Future<Gathering> createGathering(Gathering gathering);

  Future<Gathering> updateGathering(Gathering gathering);

  Future<void> deleteGathering(String gatheringId);

  Future<Gathering> createGatheringWithInvitations({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required double minBudget,
    required double maxBudget,
    required List<String> activities,
    required List<String> inviteeIds,
  });
}

// --------------------------------------------------
// Mock Gathering Repository
// Temporary implementation for older screens.
// --------------------------------------------------

class MockGatheringRepository implements GatheringRepository {
  List<Gathering>? _gatherings;

  // Load gatherings from JSON once per repository instance.
  Future<void> _loadGatherings() async {
    if (_gatherings != null) return;

    final jsonString = await rootBundle.loadString(
      'lib/data/gatherings.json',
    );

    final List<dynamic> jsonData = jsonDecode(jsonString);

    _gatherings = jsonData
        .map(
          (item) => Gathering.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  @override
  Future<List<Gathering>> getGatherings() async {
    await _loadGatherings();
    return List.unmodifiable(_gatherings!);
  }

  @override
  Future<Gathering?> getGatheringById(
    String gatheringId,
  ) async {
    await _loadGatherings();

    for (final gathering in _gatherings!) {
      if (gathering.id == gatheringId) {
        return gathering;
      }
    }

    return null;
  }

  @override
  Future<Gathering> createGathering(
    Gathering gathering,
  ) async {
    await _loadGatherings();

    final exists = _gatherings!.any(
      (item) => item.id == gathering.id,
    );

    if (exists) {
      throw StateError(
        'Gathering already exists: ${gathering.id}',
      );
    }

    _gatherings!.add(gathering);

    return gathering;
  }

  @override
  Future<Gathering> updateGathering(
    Gathering gathering,
  ) async {
    await _loadGatherings();

    final index = _gatherings!.indexWhere(
      (item) => item.id == gathering.id,
    );

    if (index == -1) {
      throw StateError(
        'Gathering not found: ${gathering.id}',
      );
    }

    _gatherings![index] = gathering;

    return gathering;
  }

  @override
  Future<void> deleteGathering(
    String gatheringId,
  ) async {
    await _loadGatherings();

    final index = _gatherings!.indexWhere(
      (item) => item.id == gatheringId,
    );

    if (index == -1) {
      throw StateError(
        'Gathering not found: $gatheringId',
      );
    }

    _gatherings!.removeAt(index);
  }

  @override
  Future<Gathering> createGatheringWithInvitations({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required double minBudget,
    required double maxBudget,
    required List<String> activities,
    required List<String> inviteeIds,
  }) {
    throw UnsupportedError(
      'Mock repository does not support sending invitations.',
    );
  }
}

// --------------------------------------------------
// Firestore Gathering Repository
// Main implementation using Firebase.
// --------------------------------------------------

class FirestoreGatheringRepository implements GatheringRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FirestoreGatheringRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>> get _gatherings =>
      _firestore.collection('gatherings');

  CollectionReference<Map<String, dynamic>> get _invitations =>
      _firestore.collection('invitations');

  // Get the currently authenticated user's UID.
  String get _currentUserId {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not authenticated.');
    }

    return user.uid;
  }

  // Get gatherings where the current user is a participant.
  @override
  Future<List<Gathering>> getGatherings() async {
    final snapshot = await _gatherings
        .where(
          'participantIds',
          arrayContains: _currentUserId,
        )
        .get();

    return snapshot.docs.map((document) {
      return Gathering.fromJson({
        ...document.data(),
        'id': document.id,
      });
    }).toList();
  }

  // Get a gathering by its Firestore document ID.
  @override
  Future<Gathering?> getGatheringById(
    String gatheringId,
  ) async {
    final document = await _gatherings
        .doc(gatheringId)
        .get();

    if (!document.exists || document.data() == null) {
      return null;
    }

    return Gathering.fromJson({
      ...document.data()!,
      'id': document.id,
    });
  }

  // Create a gathering using an existing ID.
  @override
  Future<Gathering> createGathering(
    Gathering gathering,
  ) async {
    final user = _auth.currentUser;

    if (user == null) {
      throw StateError('User is not authenticated.');
    }

    final documentRef = _gatherings.doc(gathering.id);

    // Prevent accidentally overwriting an existing gathering.
    await _firestore.runTransaction((transaction) async {
      final existing = await transaction.get(documentRef);

      if (existing.exists) {
        throw StateError('Gathering already exists.');
      }

      transaction.set(documentRef, {
        ...gathering.toFirestore(),
        'creatorId': user.uid,
        'participantIds': [user.uid],
        'status': 'planning',
        'createdAt': FieldValue.serverTimestamp(),
      });
    });

    return gathering.copyWith(
      participantIds: [user.uid],
    );
  }

  // Update gathering details.
  @override
  Future<Gathering> updateGathering(
    Gathering gathering,
  ) async {
    final userId = _currentUserId;
    final documentRef = _gatherings.doc(gathering.id);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(documentRef);

      if (!snapshot.exists) {
        throw StateError('Gathering not found.');
      }

      if (snapshot.data()?['creatorId'] != userId) {
        throw StateError(
          'Only the organizer can update this gathering.',
        );
      }

      transaction.update(documentRef, {
        'title': gathering.title,
        'startDate': formatGatheringDate(gathering.startDate),
        'endDate': formatGatheringDate(gathering.endDate),
        'minBudget': gathering.minBudget,
        'maxBudget': gathering.maxBudget,
        'activities': gathering.activities,
      });
    });

    return gathering;
  }

  // Deletion needs coordinated cleanup of related invitations.
  @override
  Future<void> deleteGathering(
    String gatheringId,
  ) async {
    throw UnsupportedError(
      'Gathering deletion is not implemented yet.',
    );
  }

  // Create a gathering and send invitations in one batch.
  @override
  Future<Gathering> createGatheringWithInvitations({
    required String title,
    required DateTime startDate,
    required DateTime endDate,
    required double minBudget,
    required double maxBudget,
    required List<String> activities,
    required List<String> inviteeIds,
  }) async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      throw StateError('Please sign in first.');
    }

    final organizerId = currentUser.uid;
    final gatheringTitle = title.trim();

    // Validate gathering details.
    if (gatheringTitle.isEmpty) {
      throw ArgumentError('Gathering title cannot be empty.');
    }

    if (endDate.isBefore(startDate)) {
      throw ArgumentError(
        'End date cannot be before start date.',
      );
    }

    if (minBudget < 0 || maxBudget < minBudget) {
      throw ArgumentError('Invalid budget range.');
    }

    // Remove duplicate invitees and the organizer.
    final recipients = inviteeIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty && id != organizerId)
        .toSet();

    // Keep batch size manageable.
    if (recipients.length > 100) {
      throw ArgumentError(
        'Maximum 100 invitees per gathering.',
      );
    }

    // Generate a unique gathering document ID.
    final gatheringRef = _gatherings.doc();

    final batch = _firestore.batch();

    // Save gathering details.
    batch.set(gatheringRef, {
      'title': gatheringTitle,
      'creatorId': organizerId,
      'participantIds': [organizerId],
      'status': 'planning',
      'startDate': formatGatheringDate(startDate),
      'endDate': formatGatheringDate(endDate),
      'minBudget': minBudget,
      'maxBudget': maxBudget,
      'activities': List<String>.from(activities),
      'votingEnded': false,
    });

    // Create a pending invitation for each recipient.
    for (final recipientId in recipients) {
      final invitationId =
          '${gatheringRef.id}_$recipientId';

      final invitationRef = _invitations.doc(
        invitationId,
      );
      final organizerDocument = await _firestore
    .collection('users')
    .doc(organizerId)
    .get();

    final organizerData = organizerDocument.data();

    final organizerName = [
      organizerData?['firstName'],
      organizerData?['lastName'],
    ]
        .whereType<String>()
        .where((name) => name.trim().isNotEmpty)
        .join(' ');

      batch.set(invitationRef, {
        'gatheringId': gatheringRef.id,
        'inviterId': organizerId,
        'inviteeId': recipientId,
        'inviterName': organizerName,
        'gatheringTitle': gatheringTitle,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    // Save the gathering and invitations atomically.
    await batch.commit();

    return Gathering(
      id: gatheringRef.id,
      title: gatheringTitle,
      creatorEmail: currentUser.email ?? '',
      participantIds: [organizerId],
      startDate: startDate,
      endDate: endDate,
      minBudget: minBudget,
      maxBudget: maxBudget,
      activities: List<String>.from(activities),
    );
  }
}

// --------------------------------------------------
// Existing Home Page functions
// --------------------------------------------------


// Existing function used by Home Page.
Future<void> leaveGathering(String gatheringId) async {
  final user = FirebaseAuth.instance.currentUser;

  if (user == null) {
    throw StateError('User is not authenticated.');
  }

  await FirebaseFirestore.instance
      .collection('gatherings')
      .doc(gatheringId)
      .update({
        'participantIds': FieldValue.arrayRemove([user.uid]),
      });
}

// Load gathering details and derive vote counts from the votes collection.
Future<List<GatheringModel>> loadGatherings() async {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) throw StateError('Sign in to Gather to see your gatherings.');
  final snapshot = await FirebaseFirestore.instance.collection('gatherings')
      .where('participantIds', arrayContains: user.uid).get();
  return Future.wait(snapshot.docs.map((doc) => _hydrateGathering(doc, user.uid)));
}

Future<GatheringModel> _hydrateGathering(
    QueryDocumentSnapshot<Map<String, dynamic>> doc, String uid) async {
  final data = doc.data();
  final creatorId = data['creatorId'];
  if (creatorId is String && creatorId.isNotEmpty) {
    try {
      final profile = await FirebaseFirestore.instance.collection('user_directory').doc(creatorId).get();
      final name = profile.data()?['displayName'];
      if (name is String && name.trim().isNotEmpty) data['createdBy'] = name;
    } on FirebaseException {
      // A private or missing directory profile must not block Home.
    }
  }
  data['createdBy'] ??= creatorId == uid ? 'You' : 'Name unavailable';
  final base = GatheringModel.fromJson({...data, 'id': doc.id});
  final options = await loadDateOptions(base);
  final gathering = GatheringModel.fromJson({...data, 'id': doc.id,
    'dateOptions': options.map((o) => {...o.toJson(), 'label': o.label}).toList(),
  });
  final votes = await FirebaseFirestore.instance.collection('votes')
      .where('gatheringId', isEqualTo: doc.id)
      .where('targetType', isEqualTo: 'datetime').get();
  applyDateVotes(gathering, votes.docs.map((doc) => doc.data()), uid);
  return gathering;
}

// Count current participants who submitted a date vote, once per person.
void applyDateVotes(GatheringModel gathering, Iterable<Map<String, dynamic>> votes, String uid) {
  final members = gathering.participantIds.toSet();
  final byUser = <String, String>{};
  for (final vote in votes) {
    final voter = vote['userId'];
    final target = vote['targetId'];
    if (voter is String && target is String && members.contains(voter) && target.isNotEmpty) {
      byUser[voter] = target;
    }
  }
  for (final option in gathering.dateOptions) {
    option.votes = byUser.values.where((target) => target == option.id).length;
  }
  gathering.selectedOptionId = byUser[uid];
  gathering.setDateVoterCount(byUser.length);
}

Stream<int> watchPlanningProgress(GatheringModel gathering) {
  final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
  return FirebaseFirestore.instance.collection('votes')
      .where('gatheringId', isEqualTo: gathering.id)
      .where('targetType', isEqualTo: 'datetime').snapshots().map((snapshot) {
    applyDateVotes(gathering, snapshot.docs.map((doc) => doc.data()), uid);
    return gathering.planningProgress;
  });
}
