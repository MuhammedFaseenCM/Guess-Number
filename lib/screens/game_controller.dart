import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:confetti/confetti.dart';
import 'package:guess_number/models/difficulty.dart';
import 'package:guess_number/services/hint_manager.dart';
import 'package:guess_number/services/storage_service.dart';
import 'package:guess_number/utils/api_key.dart';

class GameController extends GetxController with GetTickerProviderStateMixin {
  final StorageService _storage = Get.find<StorageService>();
  final AudioPlayer _audioPlayer = AudioPlayer();
  final textController = TextEditingController();
  late HintManager _hintManager;
  late ConfettiController confettiController;

  // Observable variables
  final RxInt attempts = 0.obs;
  final RxInt targetNumber = 0.obs;
  final RxString message = ''.obs;
  final RxBool gameOver = false.obs;
  final Rx<Difficulty> difficulty = Difficulty.easy.obs;
  final RxInt hintsRemaining = 3.obs;
  final RxMap<Difficulty, int> highScores = <Difficulty, int>{}.obs;
  final RxBool isLoadingHints = false.obs;

  // Animation controllers
  late AnimationController bounceController;
  late AnimationController shakeController;
  late Animation<double> bounceAnimation;
  late Animation<Offset> shakeAnimation;

  @override
  void onInit() {
    super.onInit();
    _setupControllers();
    _loadHighScores();
    _initHintManager();
    startNewGame();
  }

  void _setupControllers() {
    confettiController = ConfettiController(duration: const Duration(seconds: 3));

    bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: bounceController, curve: Curves.elasticOut),
    );

    shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    shakeAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.1, 0),
    ).animate(
      CurvedAnimation(parent: shakeController, curve: Curves.elasticIn),
    );
  }

  void _initHintManager() {
    _hintManager = HintManager(apiKey: googleApiKey);
  }

  void _loadHighScores() {
    highScores.value = _storage.getAllHighScores();
  }

  void startNewGame() {
    targetNumber.value = Random().nextInt(difficulty.value.maxNumber) + 1;
    message.value = 'Guess a number between 1 and ${difficulty.value.maxNumber}';
    attempts.value = 0;
    gameOver.value = false;
    hintsRemaining.value = 3;
    textController.clear();
    isLoadingHints.value = true;

    // Preload hints
    _hintManager
        .preloadHints(
      targetNumber: targetNumber.value,
      maxNumber: difficulty.value.maxNumber,
      difficulty: difficulty.value.name,
    )
        .then((_) {
      isLoadingHints.value = false;
    });
  }

  void changeDifficulty(Difficulty newDifficulty) {
    difficulty.value = newDifficulty;
    startNewGame();
  }

  Future<void> checkGuess(String guess) async {
    if (guess.isEmpty || gameOver.value) return;

    int? userGuess = int.tryParse(guess);
    if (userGuess == null) {
      message.value = 'Please enter a valid number';
      return;
    }

    if (userGuess < 1 || userGuess > difficulty.value.maxNumber) {
      message.value = 'Number must be between 1 and ${difficulty.value.maxNumber}';
      return;
    }

    attempts.value++;
    int difference = (userGuess - targetNumber.value).abs();
    double percentageOff = (difference / difficulty.value.maxNumber) * 100;

    if (userGuess == targetNumber.value) {
      message.value = 'Congratulations! You got it in ${attempts.value} attempts! 🎉';
      gameOver.value = true;
      bounceController.forward().then((_) => bounceController.reverse());
      confettiController.play();
      _playSound('win');
      _saveHighScore(attempts.value);
      HapticFeedback.heavyImpact();
    } else {
      if (difference <= 2) {
        message.value = 'You\'re burning hot! 🔥 So close!';
        _playSound('very_close');
      } else if (difference <= 5) {
        message.value = 'Getting very warm! 🌡️ Almost there!';
        _playSound('close');
      } else if (percentageOff <= 10) {
        message.value = userGuess < targetNumber.value
            ? 'Go higher! You\'re on the right track! 📈'
            : 'Go lower! You\'re getting closer! 📉';
        _playSound('wrong');
      } else if (percentageOff <= 25) {
        message.value = userGuess < targetNumber.value
            ? 'Try a higher number! 👆'
            : 'Try a lower number! 👇';
        _playSound('wrong');
      } else {
        message.value = 'You\'re way off! ❄️ Try again!';
        _playSound('far');
      }
      shakeController.forward().then((_) => shakeController.reverse());
      HapticFeedback.mediumImpact();
    }

    textController.clear();
  }

  Future<void> _saveHighScore(int score) async {
    await _storage.saveHighScore(difficulty.value, score);
    _loadHighScores();
  }

  Future<void> getHint(String currentGuess) async {
    if (hintsRemaining.value > 0 && !gameOver.value) {
      hintsRemaining.value--;
      attempts.value += 2;

      final hint = _hintManager.getNextHint(
        targetNumber.value,
        int.tryParse(currentGuess) ?? 0,
      );

      if (hint != null) {
        message.value =
            'HINT: $hint\n(${hintsRemaining.value} hints remaining, +2 attempts penalty)';
        HapticFeedback.mediumImpact();
      } else {
        _getBasicHint(currentGuess);
      }
    } else {
      _handleHintError();
    }
  }

  void _getBasicHint(String currentGuess) {
    int userGuess = int.tryParse(currentGuess) ?? 0;
    String hint;

    if (userGuess == 0) {
      if (targetNumber.value <= difficulty.value.maxNumber / 3) {
        hint = 'The number is in the lower third of the range';
      } else if (targetNumber.value <= (difficulty.value.maxNumber * 2 / 3)) {
        hint = 'The number is in the middle third of the range';
      } else {
        hint = 'The number is in the upper third of the range';
      }
    } else {
      int difference = (targetNumber.value - userGuess).abs();
      String direction = targetNumber.value > userGuess ? 'higher' : 'lower';

      if (difference <= 5) {
        hint = 'Very close! The number is $direction by 1-5 numbers 🔥';
      } else if (difference <= 10) {
        hint = 'Almost there! The number is $direction by 6-10 numbers';
      } else {
        List<String> properties = [];
        if (targetNumber.value % 2 == 0) {
          properties.add('even');
        } else {
          properties.add('odd');
        }
        if (targetNumber.value % 5 == 0) {
          properties.add('divisible by 5');
        }
        hint = properties.isNotEmpty
            ? 'The number is ${properties.join(' and ')} and $direction than your guess'
            : 'The number is $direction than your guess';
      }
    }

    message.value =
        'HINT: $hint\n(${hintsRemaining.value} hints remaining, +2 attempts penalty)';
  }

  void _handleHintError() {
    if (hintsRemaining.value <= 0) {
      message.value = 'No hints remaining! Try to solve it yourself 🎯';
      HapticFeedback.heavyImpact();
      _playSound('error');
    } else if (gameOver.value) {
      message.value = 'Game is over! Start a new game to use hints 🎮';
      HapticFeedback.mediumImpact();
    }

    Get.snackbar(
      hintsRemaining.value <= 0 ? 'No Hints Left' : 'Hint Error',
      hintsRemaining.value <= 0
          ? 'You\'ve used all your hints! Each game gives you 3 hints.'
          : 'Unable to get hint. Please try again.',
      icon: Icon(
        hintsRemaining.value <= 0 ? Icons.lightbulb_outline : Icons.error_outline,
        color: Colors.white,
      ),
      backgroundColor: hintsRemaining.value <= 0 ? Colors.orange : Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
      snackPosition: SnackPosition.BOTTOM,
      mainButton: hintsRemaining.value <= 0
          ? TextButton(
              onPressed: startNewGame,
              child: const Text(
                'New Game',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }

  Future<void> _playSound(String soundType) async {
    try {
      switch (soundType) {
        case 'win':
          await _audioPlayer.setSource(AssetSource('sounds/win.mp3'));
          break;
        case 'very_close':
          await _audioPlayer.setSource(AssetSource('sounds/very_close.mp3'));
          break;
        case 'close':
          await _audioPlayer.setSource(AssetSource('sounds/close.mp3'));
          break;
        case 'wrong':
          await _audioPlayer.setSource(AssetSource('sounds/wrong.mp3'));
          break;
        case 'far':
          await _audioPlayer.setSource(AssetSource('sounds/far.mp3'));
          break;
        case 'error':
          await _audioPlayer.setSource(AssetSource('sounds/error.mp3'));
          break;
      }
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void onClose() {
    textController.dispose();
    _audioPlayer.dispose();
    bounceController.dispose();
    shakeController.dispose();
    confettiController.dispose();
    super.onClose();
  }
}