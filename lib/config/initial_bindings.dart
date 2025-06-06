import 'package:get/get.dart';
import '../services/api_service.dart';
import '../controllers/auth_controller.dart';
import '../controllers/document_controller.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ApiService>(() => ApiService());
    Get.lazyPut<DocumentController>(() => DocumentController(Get.find()));
    Get.put<AuthController>(AuthController(), permanent: true);
  }
}