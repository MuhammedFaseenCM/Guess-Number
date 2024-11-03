import 'package:flutter/material.dart';
import 'package:guess_number/utils/constants.dart';
import 'package:guess_number/widgets/shake_transition.dart';

class MessageDisplay extends StatelessWidget {
  final String message;
  final bool isDark;
  final Animation<double> bounceAnimation;
  final Animation<Offset> shakeAnimation;

  const MessageDisplay({
    super.key,
    required this.message,
    required this.isDark,
    required this.bounceAnimation,
    required this.shakeAnimation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppPadding.medium),
      decoration: AppDecorations.card(isDark),
      child: ScaleTransition(
        scale: bounceAnimation,
        child: ShakeTransition(
          animation: shakeAnimation,
          child: Text(
            message,
            style: AppTextStyles.message.copyWith(
              color: isDark ? Colors.white : primaryColor,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}