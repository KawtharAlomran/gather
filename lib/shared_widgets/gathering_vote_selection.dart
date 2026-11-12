import 'package:flutter/material.dart';
import '../models/gathering_model.dart';
import 'app_button.dart';
import 'app_card.dart';

/// Reusable voting options for an invitee. The parent handles saving.
class GatheringVoteSelection extends StatelessWidget {
  final List<DateOptionModel> options;
  final String? selectedOptionId;
  final ValueChanged<String?> onSelected;
  final VoidCallback? onSave;
  final int totalVotes;

  const GatheringVoteSelection({
    super.key,
    required this.options,
    required this.selectedOptionId,
    required this.onSelected,
    required this.onSave,
    required this.totalVotes,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(children: [
            Expanded(child: Text('Vote: Best Date', style: theme.textTheme.titleMedium)),
            Text('$totalVotes votes cast', style: theme.textTheme.bodySmall),
          ]),
          const SizedBox(height: 12),
          for (final option in options) ...[
            InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () => onSelected(option.id),
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selectedOptionId == option.id
                        ? theme.colorScheme.primary
                        : theme.dividerColor,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(children: [
                  Radio<String>(
                    value: option.id,
                    groupValue: selectedOptionId,
                    onChanged: onSelected,
                  ),
                  Expanded(child: Text(option.label)),
                  Text('${option.votes} votes', style: theme.textTheme.bodySmall),
                ]),
              ),
            ),
          ],
          AppButton(text: 'Save Vote', onPressed: onSave),
        ],
      ),
    );
  }
}
