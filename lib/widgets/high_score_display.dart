import 'package:flutter/material.dart';
import 'package:guess_number/models/difficulty.dart';
import 'package:guess_number/utils/constants.dart';

class HighScoreDisplay extends StatelessWidget {
  final Map<Difficulty, int> highScores;
  final bool isDark;

  const HighScoreDisplay({
    super.key,
    required this.highScores,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppPadding.medium),
      decoration: AppDecorations.card(isDark),
      child: Column(
        children: [
          Text(
            '🏆 High Scores',
            style: AppTextStyles.title.copyWith(
              color: isDark ? Colors.white : primaryColor,
            ),
          ),
          const SizedBox(height: AppPadding.small),
          ...Difficulty.values.map((difficulty) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  difficulty.displayName,
                  style: AppTextStyles.subtitle.copyWith(
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.small,
                    vertical: 4,
                  ),
                  decoration: AppDecorations.badge(isDark),
                  child: Text(
                    '${highScores[difficulty] == 0 ? '-' : highScores[difficulty]}',
                    style: AppTextStyles.score.copyWith(
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}