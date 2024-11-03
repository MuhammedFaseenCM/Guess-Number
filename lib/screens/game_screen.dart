import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:guess_number/services/hint_manager.dart';
import 'package:guess_number/utils/api_key.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:confetti/confetti.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:guess_number/models/difficulty.dart';
import 'package:guess_number/services/hint_service.dart';
import 'package:guess_number/utils/constants.dart';
import 'package:guess_number/widgets/difficulty_selector.dart';
import 'package:guess_number/widgets/high_score_display.dart';
import 'package:guess_number/widgets/input_section.dart';
import 'package:guess_number/widgets/message_display.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final AudioPlayer _audioPlayer = AudioPlayer();
  late ConfettiController _confettiController;
  late HintService _hintService;
  late HintManager _hintManager;
  bool _isLoadingHints = false;

  // Game state variables
  late int _targetNumber;
  String _message = '';
  int _attempts = 0;
  bool _gameOver = false;
  Difficulty _difficulty = Difficulty.easy;
  Map<Difficulty, int> _highScores = {
    Difficulty.easy: 0,
    Difficulty.medium: 0,
    Difficulty.hard: 0,
  };

  // Feature variables
  bool _isDarkMode = false;
  int _hintsRemaining = 3;

  // Animation controllers
  late AnimationController _bounceController;
  late AnimationController _shakeController;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _hintManager =
        HintManager(apiKey: googleApiKey);
    _setupControllers();
    _loadPreferences();
    _startNewGame();
    _hintService =
        HintService(apiKey: googleApiKey);
  }

  void _setupControllers() {
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));

    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );

    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0.1, 0),
    ).animate(
      CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
    );
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _highScores = {
        Difficulty.easy: prefs.getInt('highScore_easy') ?? 0,
        Difficulty.medium: prefs.getInt('highScore_medium') ?? 0,
        Difficulty.hard: prefs.getInt('highScore_hard') ?? 0,
      };
    });
  }

  Future<void> _toggleDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = !_isDarkMode;
    });
    await prefs.setBool('isDarkMode', _isDarkMode);
  }

  void _startNewGame() {
    setState(() {
      _targetNumber = Random().nextInt(_difficulty.maxNumber) + 1;
      _message = 'Guess a number between 1 and ${_difficulty.maxNumber}';
      _attempts = 0;
      _gameOver = false;
      _hintsRemaining = 3;
      _controller.clear();
      _isLoadingHints = true;
    });

    // Preload hints
    _hintManager
        .preloadHints(
      targetNumber: _targetNumber,
      maxNumber: _difficulty.maxNumber,
      difficulty: _difficulty.name,
    )
        .then((_) {
      setState(() {
        _isLoadingHints = false;
      });
    });
  }

  Future<void> _getHint() async {
    if (_hintsRemaining > 0 && !_gameOver) {
      setState(() {
        _hintsRemaining--;
        _attempts += 2;
      });

      final hint = _hintManager.getNextHint(
          _targetNumber, int.tryParse(_controller.text) ?? 0);

      if (hint != null) {
        setState(() {
          _message =
              'HINT: $hint\n($_hintsRemaining hints remaining, +2 attempts penalty)';
        });
        HapticFeedback.mediumImpact();
      } else {
        // Fallback to basic hint if something went wrong
        _getBasicHint();
      }
    } else {
      _handleHintError();
    }
  }

  Future<void> _saveHighScore(int score) async {
    final prefs = await SharedPreferences.getInstance();
    if (_highScores[_difficulty]! == 0 || score < _highScores[_difficulty]!) {
      await prefs.setInt('highScore_${_difficulty.name}', score);
      setState(() => _highScores[_difficulty] = score);
    }
  }

  void _checkGuess(String guess) {
    if (guess.isEmpty || _gameOver) return;

    int? userGuess = int.tryParse(guess);
    if (userGuess == null) {
      setState(() => _message = 'Please enter a valid number');
      return;
    }

    if (userGuess < 1 || userGuess > _difficulty.maxNumber) {
      setState(() =>
          _message = 'Number must be between 1 and ${_difficulty.maxNumber}');
      return;
    }

    setState(() {
      _attempts++;
      int difference = (userGuess - _targetNumber).abs();

      if (userGuess == _targetNumber) {
        _message = 'Congratulations! You got it in $_attempts attempts! 🎉';
        _gameOver = true;
        _bounceController.forward().then((_) => _bounceController.reverse());
        _confettiController.play();
        _playSound('win');
        _saveHighScore(_attempts);
        HapticFeedback.heavyImpact();
      } else {
        // Calculate how close the guess is as a percentage of the maximum number
        double percentageOff = (difference / _difficulty.maxNumber) * 100;

        if (difference <= 2) {
          _message = 'You\'re burning hot! 🔥 So close!';
          _playSound('very_close');
        } else if (difference <= 5) {
          _message = 'Getting very warm! 🌡️ Almost there!';
          _playSound('close');
        } else if (percentageOff <= 10) {
          // If within 10% of the range
          if (userGuess < _targetNumber) {
            _message = 'Go higher! You\'re on the right track! 📈';
          } else {
            _message = 'Go lower! You\'re getting closer! 📉';
          }
          _playSound('wrong');
        } else if (percentageOff <= 25) {
          // If within 25% of the range
          if (userGuess < _targetNumber) {
            _message = 'Try a higher number! 👆';
          } else {
            _message = 'Try a lower number! 👇';
          }
          _playSound('wrong');
        } else {
          // If very far off
          _message = 'You\'re way off! ❄️ Try again!';
          _playSound('far');
        }

        _shakeController.forward().then((_) => _shakeController.reverse());
        HapticFeedback.mediumImpact();
      }
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            backgroundColor: isDark ? darkPrimaryColor : primaryColor,
            elevation: 0,
            title: Text(
              'Number Guessing',
              style: AppTextStyles.title.copyWith(color: Colors.white),
            ),
            actions: [
              IconButton(
                icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
                onPressed: _toggleDarkMode,
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _startNewGame,
              ),
            ],
          ),
          body: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDark
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
                      DifficultySelector(
                        currentDifficulty: _difficulty,
                        onDifficultyChanged: (difficulty) {
                          setState(() => _difficulty = difficulty);
                          _startNewGame();
                        },
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppPadding.medium),
                      MessageDisplay(
                        message: _message,
                        isDark: isDark,
                        bounceAnimation: _bounceAnimation,
                        shakeAnimation: _shakeAnimation,
                      ),
                      const SizedBox(height: AppPadding.medium),
                      InputSection(
                        controller: _controller,
                        isDark: isDark,
                        isEnabled: !_gameOver,
                        onSubmitted: _checkGuess,
                      ),
                      const SizedBox(height: AppPadding.medium),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.medium,
                          vertical: AppPadding.small,
                        ),
                        decoration: AppDecorations.badge(isDark),
                        child: Text(
                          'Attempts: $_attempts',
                          style: AppTextStyles.subtitle.copyWith(
                            color: isDark ? Colors.white : primaryColor,
                          ),
                        ),
                      ),
                      const SizedBox(height: AppPadding.medium),
                      HighScoreDisplay(
                        highScores: _highScores,
                        isDark: isDark,
                      ),
                      const SizedBox(height: AppPadding.large),
                      const SizedBox(height: AppPadding.large),
                    ],
                  ),
                ),
              ),
            ),
          ),
          floatingActionButton: _hintsRemaining > 0 && !_gameOver
              ? FloatingActionButton(
                  onPressed: _isLoadingHints ? null : _getHint,
                  backgroundColor: _isLoadingHints
                      ? Colors.grey
                      : (isDark ? darkPrimaryColor : primaryColor),
                  child: _isLoadingHints
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
              : null,
        ),
        Align(
          alignment: Alignment.topCenter,
          child: ConfettiWidget(
            confettiController: _confettiController,
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

  void _getBasicHint() {
    int currentGuess = int.tryParse(_controller.text) ?? 0;
    String hint;

    if (currentGuess == 0) {
      // If no guess has been made yet, provide a range-based hint
      if (_targetNumber <= _difficulty.maxNumber / 3) {
        hint =
            'The number is in the lower third of the range (1-${_difficulty.maxNumber ~/ 3})';
      } else if (_targetNumber <= (_difficulty.maxNumber * 2 / 3)) {
        hint =
            'The number is in the middle third of the range (${_difficulty.maxNumber ~/ 3 + 1}-${(_difficulty.maxNumber * 2 ~/ 3)})';
      } else {
        hint =
            'The number is in the upper third of the range (${(_difficulty.maxNumber * 2 ~/ 3) + 1}-${_difficulty.maxNumber})';
      }
    } else {
      // If there's a current guess, provide a more specific hint
      int difference = (_targetNumber - currentGuess).abs();
      String direction = _targetNumber > currentGuess ? 'higher' : 'lower';

      if (difference <= 5) {
        hint = 'Very close! The number is $direction by 1-5 numbers 🔥';
      } else if (difference <= 10) {
        hint = 'Almost there! The number is $direction by 6-10 numbers';
      } else if (difference <= 20) {
        hint = 'Getting warmer! The number is $direction by 11-20 numbers';
      } else {
        // Add some mathematical properties for more interesting hints
        List<String> properties = [];

        // Check divisibility
        if (_targetNumber % 2 == 0) {
          properties.add('even');
        } else {
          properties.add('odd');
        }

        if (_targetNumber % 5 == 0) {
          properties.add('divisible by 5');
        }

        if (properties.isNotEmpty) {
          hint =
              'The number is ${properties.join(' and ')} and $direction than your guess';
        } else {
          hint = 'The number is $direction than your guess by quite a bit';
        }
      }
    }

    setState(() {
      _message =
          'HINT: $hint\n($_hintsRemaining hints remaining, +2 attempts penalty)';
    });
  }

  void _handleHintError() {
    setState(() {
      if (_hintsRemaining <= 0) {
        _message = 'No hints remaining! Try to solve it yourself 🎯';
        // Add haptic feedback for error
        HapticFeedback.heavyImpact();
        // Play error sound if you have one
        _playSound('error');
      } else if (_gameOver) {
        _message = 'Game is over! Start a new game to use hints 🎮';
        HapticFeedback.mediumImpact();
      } else {
        _message = 'Cannot get hint right now. Try again later ⏳';
        HapticFeedback.mediumImpact();
      }
    });

    // Show a snackbar with more details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              _hintsRemaining <= 0
                  ? Icons.lightbulb_outline
                  : Icons.error_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _hintsRemaining <= 0
                    ? 'You\'ve used all your hints! Each game gives you 3 hints.'
                    : 'Unable to get hint. Please try again.',
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _hintsRemaining <= 0 ? Colors.orange : Colors.red,
        duration: const Duration(seconds: 3),
        action: _hintsRemaining <= 0
            ? SnackBarAction(
                label: 'New Game',
                textColor: Colors.white,
                onPressed: _startNewGame,
              )
            : null,
      ),
    );
  }

// Add this helper method to play sounds if you have them
  Future<void> _playSound(String soundType) async {
    try {
      switch (soundType) {
        case 'error':
          await _audioPlayer.setSource(AssetSource('sounds/error.mp3'));
          break;
        case 'hint':
          await _audioPlayer.setSource(AssetSource('sounds/hint.mp3'));
          break;
      }
      await _audioPlayer.resume();
    } catch (e) {
      debugPrint('Error playing sound: $e');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    _bounceController.dispose();
    _shakeController.dispose();
    _confettiController.dispose();
    super.dispose();
  }
}
