// Centralizes navigation to the appropriate gathering details page.
// Determines whether the current user is the creator or an invitee
// and opens the corresponding page based on their role.

import 'package:flutter/material.dart';

import '../models/gathering_model.dart';
import '../Pages/gathering_details_screen.dart';
import '../Pages/invitee_gather_details_screen.dart';
import '../Pages/confirmed_gather_page.dart';

/// Opens the confirmed summary, or the role-specific page while planning.
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
      // Confirmed gatherings use their summary page regardless of creator.
      builder: (_) =>
          (gathering.status == 'confirmed' || gathering.dateTime != null)
          ? ConfirmedGatheringPage(
              gathering: gathering,
              onLeaveGathering: onLeaveGathering,
            )
          // Planning controls are shown only on the creator's page.
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
