import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:confetti/confetti.dart';
import 'package:guess_number/controllers/theme_controller.dart';
import 'package:guess_number/screens/game_controller.dart';
import 'package:guess_number/utils/constants.dart';
import 'package:guess_number/widgets/difficulty_selector.dart';
import 'package:guess_number/widgets/high_score_display.dart';
import 'package:guess_number/widgets/input_section.dart';
import 'package:guess_number/widgets/message_display.dart';

class GameScreen extends GetView<GameController> {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: context.theme.primaryColor,
            elevation: 0,
            title: Text(
              'Number Guessing',
              style: AppTextStyles.title.copyWith(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: GetBuilder<ThemeController>(
                  builder: (themeController) => Icon(
                    themeController.isDarkMode
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                ),
                onPressed: () => Get.find<ThemeController>().toggleTheme(),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () => controller.startNewGame(),
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: Get.isDarkMode
                    ? [darkPrimaryColor.withOpacity(0.1), darkBackgroundColor]
                    : [primaryColor.withOpacity(0.1), backgroundColor],
              ),
            ),
            child: SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(AppPadding.medium),
                  child: Column(
                    children: [
                      Obx(() => DifficultySelector(
                            currentDifficulty: controller.difficulty.value,
                            onDifficultyChanged: controller.changeDifficulty,
                            isDark: Get.isDarkMode,
                          )),
                      const SizedBox(height: AppPadding.medium),
                      Obx(() => MessageDisplay(
                            message: controller.message.value,
                            isDark: Get.isDarkMode,
                            bounceAnimation: controller.bounceAnimation,
                            shakeAnimation: controller.shakeAnimation,
                          )),
                      const SizedBox(height: AppPadding.medium),
                      Obx(() => InputSection(
                            controller: controller.textController,
                            isDark: Get.isDarkMode,
                            isEnabled: !controller.gameOver.value,
                            onSubmitted: controller.checkGuess,
                          )),
                      const SizedBox(height: AppPadding.medium),
                      Obx(() => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.medium,
                              vertical: AppPadding.small,
                            ),
                            decoration: AppDecorations.badge(Get.isDarkMode),
                            child: Text(
                              'Attempts: ${controller.attempts}',
                              style: AppTextStyles.subtitle.copyWith(
                                color: Get.isDarkMode
                                    ? Colors.white
                                    : primaryColor,
                              ),
                            ),
                          )),
                      const SizedBox(height: AppPadding.medium),
                      Obx(() => HighScoreDisplay(
                            highScores: controller.highScores,
                            isDark: Get.isDarkMode,
                          )),
                      const SizedBox(height: AppPadding.large),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: Obx(
            () => controller.hintsRemaining.value > 0 &&
                    !controller.gameOver.value
                ? FloatingActionButton(
                    onPressed: controller.isLoadingHints.value
                        ? null
                        : () => controller.getHint(
                            controller.textController.text),
                    backgroundColor: controller.isLoadingHints.value
                        ? Colors.grey
                        : (Get.isDarkMode
                            ? darkPrimaryColor
                            : primaryColor),
                    child: controller.isLoadingHints.value
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.lightbulb_outline),
                  )
                : const SizedBox.shrink(),
          ),
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: controller.confettiController,
            blastDirection: pi / 2,
            maxBlastForce: 5,
            minBlastForce: 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.2,
            colors: const [
              Colors.green,
              Colors.blue,
              Colors.pink,
              Colors.orange,
              Colors.purple
            ],
          ),
        ),
      ],
    );
  }
}