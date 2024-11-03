import 'package:google_generative_ai/google_generative_ai.dart';

class HintService {
  final GenerativeModel model;

  HintService({required String apiKey}) : model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: apiKey,
  );

  Future<String> getHint({
    required int targetNumber,
    required int maxNumber,
    required int currentGuess,
    required String difficulty,
    required int hintsRemaining,
    required int attempts,
  }) async {
    final prompt = '''
    I'm thinking of a number $targetNumber in a number guessing game.
    The range is 1 to $maxNumber.
    Current guess is: ${currentGuess == 0 ? 'No guess yet' : currentGuess}
    Difficulty level: $difficulty
    Remaining hints: $hintsRemaining
    Number of attempts: $attempts

    Please provide a helpful hint that:
    1. Doesn't reveal the exact number
    2. Gets more specific with fewer hints remaining
    3. Considers the current guess if there is one
    4. Includes mathematical properties (like divisibility, prime/composite, etc.)
    5. Makes the game fun and engaging

    Give ONLY the hint text, no additional commentary.
    ''';

    try {
      final content = [Content.text(prompt)];
      final response = await model.generateContent(content);
      return response.text ?? _getBasicHint(targetNumber, currentGuess, maxNumber);
    } catch (e) {
      return _getBasicHint(targetNumber, currentGuess, maxNumber);
    }
  }

  String _getBasicHint(int targetNumber, int currentGuess, int maxNumber) {
    if (currentGuess == 0) {
      if (targetNumber <= maxNumber / 3) {
        return 'The number is in the lower third of the range';
      } else if (targetNumber <= (maxNumber * 2 / 3)) {
        return 'The number is in the middle third of the range';
      } else {
        return 'The number is in the upper third of the range';
      }
    } else {
      int difference = (targetNumber - currentGuess).abs();
      String direction = targetNumber > currentGuess ? 'higher' : 'lower';
      
      if (difference <= 5) {
        return 'Very close! The number is $direction by 1-5 numbers';
      } else if (difference <= 10) {
        return 'Almost there! The number is $direction by 6-10 numbers';
      } else if (difference <= 20) {
        return 'Getting warm! The number is $direction by 11-20 numbers';
      } else {
        return 'Still far! The number is $direction';
      }
    }
  }
}