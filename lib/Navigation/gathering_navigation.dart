import 'package:flutter/material.dart';

import '../models/gathering_model.dart';
import '../Pages/gathering_details_screen.dart';
import '../Pages/invitee_gather_details_screen.dart';
import '../Pages/confirmed_gathering_page.dart';

/// Opens the correct gathering details page based on the current user's role.
Future<void> openGatheringDetails({
  required BuildContext context,
  required GatheringModel gathering,
  required String currentUserId,
  required VoidCallback onPlaceVoting,
  required VoidCallback onUpdatePreferences,
  ValueChanged<GatheringModel>? onChanged,
  Future<void> Function(GatheringModel)? onLeaveGathering,
}) async {
  await Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => (gathering.status == 'confirmed' || gathering.dateTime != null)
          ? ConfirmedGatheringPage(gathering: gathering, onLeaveGathering: onLeaveGathering)
          : gathering.creatorId == currentUserId
          ? CreatorGatheringPage(
              gathering: gathering,
              onPlaceVoting: onPlaceVoting,
              onUpdatePreferences: onUpdatePreferences,
              onChanged: onChanged,
              onLeaveGathering: onLeaveGathering,
              attendeeNames: gathering.attendeeNames,
            )
          : InviteeGatheringPage(
              gathering: gathering,
              onPlaceVoting: onPlaceVoting,
              onLeaveGathering: onLeaveGathering,
              attendeeNames: gathering.attendeeNames,
            ),
    ),
  );
}
