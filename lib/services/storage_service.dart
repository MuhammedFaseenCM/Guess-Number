import 'package:get_storage/get_storage.dart';
import 'package:guess_number/models/difficulty.dart';

class StorageService {
  final GetStorage _box = GetStorage();

  // Keys
  static const String _highScorePrefix = 'highScore_';
  static const String _themeKey = 'isDarkMode';

  // High Scores
  Future<void> saveHighScore(Difficulty difficulty, int score) async {
    String key = '$_highScorePrefix${difficulty.name}';
    int currentHighScore = getHighScore(difficulty);
    if (currentHighScore == 0 || score < currentHighScore) {
      await _box.write(key, score);
    }
  }

  int getHighScore(Difficulty difficulty) {
    String key = '$_highScorePrefix${difficulty.name}';
    return _box.read(key) ?? 0;
  }

  Map<Difficulty, int> getAllHighScores() {
    return {
      for (var difficulty in Difficulty.values)
        difficulty: getHighScore(difficulty),
    };
  }

  // Theme
  bool get isDarkMode => _box.read(_themeKey) ?? false;
  
  Future<void> saveThemeMode(bool isDark) async {
    await _box.write(_themeKey, isDark);
  }
}