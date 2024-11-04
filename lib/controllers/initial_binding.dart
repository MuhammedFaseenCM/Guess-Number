import 'package:get/get.dart';
import 'package:guess_number/controllers/theme_controller.dart';
import 'package:guess_number/screens/game_controller.dart';
import 'package:guess_number/services/storage_service.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(StorageService());
    Get.put(ThemeController());
    Get.put(GameController());
  }
}