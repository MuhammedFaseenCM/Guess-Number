import 'package:flutter/material.dart';
import 'package:guess_number/utils/constants.dart';

class GameControls extends StatelessWidget {
  final bool isDark;
  final bool gameOver;
  final int attempts;
  final VoidCallback onPlayAgain;
  final VoidCallback onGuess;

  const GameControls({
    super.key,
    required this.isDark,
    required this.gameOver,
    required this.attempts,
    required this.onPlayAgain,
    required this.onGuess,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: gameOver ? onPlayAgain : onGuess,
          style: ElevatedButton.styleFrom(
            backgroundColor: isDark ? darkPrimaryColor : primaryColor,
            minimumSize: const Size(200, 45),
          ),
          child: Text(
            gameOver ? 'Play Again' : 'Guess',
            style: AppTextStyles.button.copyWith(color: Colors.white),
          ),
        ),
        const SizedBox(height: AppPadding.small),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.medium,
            vertical: AppPadding.small,
          ),
          decoration: AppDecorations.badge(isDark),
          child: Text(
            'Attempts: $attempts',
            style: AppTextStyles.subtitle.copyWith(
              color: isDark ? Colors.white : primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}