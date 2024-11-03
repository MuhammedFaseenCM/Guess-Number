import 'package:flutter/material.dart';
import 'package:guess_number/services/hint_service.dart';

class HintManager {
  final HintService _hintService;
  final List<String> _preloadedHints = [];
  bool _isLoading = false;

  HintManager({required String apiKey}) : _hintService = HintService(apiKey: apiKey);

  Future<void> preloadHints({
    required int targetNumber,
    required int maxNumber,
    required String difficulty,
  }) async {
    if (_isLoading) return;
    _isLoading = true;
    _preloadedHints.clear();

    try {
      // Preload 3 hints with different variations
      final futures = [
        _hintService.getHint(
          targetNumber: targetNumber,
          maxNumber: maxNumber,
          currentGuess: 0,
          difficulty: difficulty,
          hintsRemaining: 3,
          attempts: 0,
        ),
        _hintService.getHint(
          targetNumber: targetNumber,
          maxNumber: maxNumber,
          currentGuess: 0,
          difficulty: difficulty,
          hintsRemaining: 2,
          attempts: 2,
        ),
        _hintService.getHint(
          targetNumber: targetNumber,
          maxNumber: maxNumber,
          currentGuess: 0,
          difficulty: difficulty,
          hintsRemaining: 1,
          attempts: 4,
        ),
      ];

      final hints = await Future.wait(futures);
      _preloadedHints.addAll(hints);
    } catch (e) {
      debugPrint('Error preloading hints: $e');
      // Add fallback hints
      _addFallbackHints(targetNumber, maxNumber);
    } finally {
      _isLoading = false;
    }
  }

  void _addFallbackHints(int targetNumber, int maxNumber) {
    String hint1, hint2, hint3;

    // First hint - range based
    if (targetNumber <= maxNumber / 3) {
      hint1 = 'The number is in the lower third of the range';
    } else if (targetNumber <= (maxNumber * 2 / 3)) {
      hint1 = 'The number is in the middle third of the range';
    } else {
      hint1 = 'The number is in the upper third of the range';
    }

    // Second hint - divisibility
    if (targetNumber % 2 == 0) {
      hint2 = 'The number is even';
    } else {
      hint2 = 'The number is odd';
    }
    if (targetNumber % 5 == 0) {
      hint2 += ' and divisible by 5';
    }

    // Third hint - closer range
    int lowerBound = ((targetNumber - 10) / 10).floor() * 10;
    int upperBound = ((targetNumber + 10) / 10).ceil() * 10;
    hint3 = 'The number is between $lowerBound and $upperBound';

    _preloadedHints.addAll([hint1, hint2, hint3]);
  }

  String? getNextHint(int targetNumber, int currentGuess) {
    if (_preloadedHints.isEmpty) return null;
    
    // Update the last hint if there's a current guess
    if (currentGuess > 0 && _preloadedHints.isNotEmpty) {
      _preloadedHints[_preloadedHints.length - 1] = 
        'The number is ${currentGuess > targetNumber ? 'lower' : 'higher'} than $currentGuess';
    }
    
    return _preloadedHints.removeAt(0);
  }

  bool get hasHints => _preloadedHints.isNotEmpty;
  bool get isLoading => _isLoading;
}