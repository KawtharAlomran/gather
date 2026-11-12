import 'dart:convert';
import 'package:flutter/services.dart';

import '../../models/attendee_model.dart';

Future<List<AttendeeModel>> loadAttendees(String gatheringId) async {
  final source = await rootBundle.loadString('lib/data/attendance.json');

  return (jsonDecode(source) as List)
      .map((e) => AttendeeModel.fromJson(e as Map<String, dynamic>))
      .where((e) => e.gatheringId == gatheringId)
      .toList();
}
