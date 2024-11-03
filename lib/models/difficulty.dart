enum Difficulty { 
  easy, 
  medium, 
  hard 
}

extension DifficultyExtension on Difficulty {
  int get maxNumber {
    switch (this) {
      case Difficulty.easy:
        return 50;
      case Difficulty.medium:
        return 100;
      case Difficulty.hard:
        return 200;
    }
  }

  String get displayName => name.toUpperCase();
}