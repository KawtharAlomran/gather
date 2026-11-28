import '../../models/gathering_model.dart';
import '../../models/vote_model.dart';

class DateVotingResult {
  final DateOptionModel winner;
  final List<String> participantIds;
  const DateVotingResult(this.winner, this.participantIds);
}

DateVotingResult calculateDateVotingResult({
  required List<DateOptionModel> options,
  required Iterable<Vote> votes,
  required Set<String> participantIds,
  required Set<String> acceptedInviteeIds,
  required String creatorId,
}) {
  final optionIds = options.where((option) => option.timePeriod != null).map((option) => option.id).toSet();
  final byUser = <String, String>{};
  for (final vote in votes) {
    if (vote.targetType == 'datetime' &&
        participantIds.contains(vote.userId) &&
        (vote.userId == creatorId ||
            acceptedInviteeIds.contains(vote.userId)) &&
        optionIds.contains(vote.targetId)) {
      byUser[vote.userId] = vote.targetId;
    }
  }
  if (byUser.isEmpty) {
    throw StateError(
      'At least one valid date vote is needed before ending voting.',
    );
  }
  final counts = <String, int>{};
  for (final id in byUser.values) {
    counts[id] = (counts[id] ?? 0) + 1;
  }
  int periodRank(DateOptionModel option) => switch (option.timePeriod) {
    'Morning' => 0,
    'Afternoon' => 1,
    'Evening' => 2,
    _ => 3,
  };
  final ranked =
      options.where((option) => counts.containsKey(option.id)).toList()
        ..sort((a, b) {
          final byCount = counts[b.id]!.compareTo(counts[a.id]!);
          if (byCount != 0) return byCount;
          final byDate = a.dateTime.compareTo(b.dateTime);
          if (byDate != 0) return byDate;
          final byPeriod = periodRank(a).compareTo(periodRank(b));
          return byPeriod != 0 ? byPeriod : a.id.compareTo(b.id);
        });
  return DateVotingResult(ranked.first, {creatorId, ...byUser.keys}.toList());
}
