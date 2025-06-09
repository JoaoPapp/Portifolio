import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import necessário
import '../models/document.dart';
import '../services/api_service.dart';
import 'auth_controller.dart'; // Import necessário para pegar o usuário logado

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

  // >>>>>>>>>> INÍCIO DA NOVA FUNÇÃO <<<<<<<<<<
  /// Cria um novo fluxo de assinatura no Firestore
  Future<void> createDocumentWorkflow({
    required String documentName,
    required List<Map<String, String>> signersInfo, // Recebe uma lista de signatários
  }) async {
    try {
      isLoading(true); // Ativa o loading

      // Pega o ID do usuário logado a partir do AuthController
      final user = Get.find<AuthController>().user.value;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      // 1. Transforma a lista de informações dos signatários para o formato do Firestore
      List<Map<String, dynamic>> signersListForFirestore = [];
      for (int i = 0; i < signersInfo.length; i++) {
        signersListForFirestore.add({
          'name': signersInfo[i]['name']!,
          'email': signersInfo[i]['email']!,
          'status': 'pendente', // Status inicial para cada signatário
          'order': i + 1,       // A ordem sequencial da assinatura
        });
      }

      // 2. Monta o documento principal com o campo 'signers' como uma LISTA (Array)
      final documentData = {
        'name': documentName,
        'ownerId': user.uid,
        'status': 'em_andamento', // Status geral do documento
        'createdAt': Timestamp.now(),
        'storagePath': 'documentos/${user.uid}/$documentName', // Exemplo de caminho
        'signers': signersListForFirestore, // Atribuindo a lista aqui
      };
      
      // 3. Salva o novo documento na coleção 'documents' do Firestore
      await FirebaseFirestore.instance.collection('documents').add(documentData);

      Get.snackbar("Sucesso!", "Novo fluxo de assinatura criado.");

    } catch (e) {
      Get.snackbar("Erro", "Falha ao criar o fluxo de assinatura: ${e.toString()}");
    } finally {
      isLoading(false); // Desativa o loading
    }
  }
}