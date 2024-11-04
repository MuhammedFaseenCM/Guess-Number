import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:guess_number/controllers/initial_binding.dart';
import 'package:guess_number/controllers/theme_controller.dart';
import 'package:guess_number/theme/app_theme.dart';
import 'package:guess_number/screens/game_screen.dart';

void main() async {
  await GetStorage.init();
  Get.put(ThemeController());
  runApp(const GuessNumber());
}

class GuessNumber extends StatelessWidget {
  const GuessNumber({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Guess Number',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: Get.find<ThemeController>().theme,
      initialBinding: InitialBinding(),
      home: const GameScreen(),
    );
  }
}