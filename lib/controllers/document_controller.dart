import 'package:get/get.dart';
import '../models/document.dart';
import '../services/api_service.dart';

class DocumentController extends GetxController {
  final ApiService api;

  var documents = <Document>[].obs;
  var isLoading = false.obs;
  var errorMessage = RxnString();

  DocumentController(this.api);

  @override
  void onInit() {
    super.onInit();
  }

  Future<void> loadDocuments() async {
    try {
      isLoading(true);
      errorMessage.value = null;
      var result = await api.fetchDocuments();
      documents.assignAll(result);
    } catch (e) {
      errorMessage.value = "Falha ao carregar documentos.";
    } finally {
      isLoading(false);
    }
  }
}
