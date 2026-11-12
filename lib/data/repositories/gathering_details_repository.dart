import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/gathering_model.dart';

// Session-level removal for mock JSON data. Asset files cannot be edited at runtime.
final Set<String> _leftGatheringIds = <String>{};

Future<void> leaveGathering(String gatheringId) async {
  _leftGatheringIds.add(gatheringId);
}

Future<List<GatheringModel>> loadGatherings() async {
  final data = await rootBundle.loadString('lib/data/gatherings.json');

  return (jsonDecode(data) as List)
      .map((item) => GatheringModel.fromJson(item as Map<String, dynamic>))
      .where((gathering) => !_leftGatheringIds.contains(gathering.id))
      .toList();
}