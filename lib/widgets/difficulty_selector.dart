import 'package:flutter/material.dart';
import 'package:guess_number/models/difficulty.dart';
import 'package:guess_number/utils/constants.dart';

class DifficultySelector extends StatelessWidget {
  final Difficulty currentDifficulty;
  final Function(Difficulty) onDifficultyChanged;
  final bool isDark;

  const DifficultySelector({
    super.key,
    required this.currentDifficulty,
    required this.onDifficultyChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.medium),
      decoration: AppDecorations.card(isDark),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Difficulty: ',
            style: AppTextStyles.subtitle.copyWith(
              color: isDark ? Colors.white : Colors.black,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.small),
            decoration: BoxDecoration(
              border: Border.all(
                color: (isDark ? darkPrimaryColor : primaryColor).withOpacity(0.3)
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: DropdownButton<Difficulty>(
              value: currentDifficulty,
              underline: Container(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDark ? darkPrimaryColor : primaryColor,
                size: 20,
              ),
              dropdownColor: isDark ? darkCardColor : cardColor,
              onChanged: (newValue) {
                if (newValue != null) {
                  onDifficultyChanged(newValue);
                }
              },
              items: Difficulty.values.map((difficulty) {
                return DropdownMenuItem<Difficulty>(
                  value: difficulty,
                  child: Text(
                    difficulty.displayName,
                    style: AppTextStyles.subtitle.copyWith(
                      color: isDark ? Colors.white : primaryColor,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}