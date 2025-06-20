import 'dart:io'; // Importe o dart:io para usar o tipo File
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class DocumentController extends GetxController {
  final ApiService api;
  DocumentController(this.api);

  var documents = <Document>[].obs;
  var isLoading = false.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    // ... (o onInit continua o mesmo)
  }

  void loadDocumentsFromFirestore(String userId) {
    // ... (esta função continua a mesma)
  }

  // >>> FUNÇÃO ATUALIZADA PARA O NOVO FLUXO <<<
  Future<void> createDocumentWorkflow({
    required File documentFile, // Agora recebe o arquivo
    required List<Map<String, String>> signersInfo, required String documentName,
  }) async {
    try {
      isLoading(true);
      final user = Get.find<AuthController>().user.value;
      if (user == null) throw Exception("Usuário não autenticado.");

      // 1. CHAMA A API DO AUTENTIQUE PARA ENVIAR O DOCUMENTO E OS E-MAILS
      final String? autentiqueDocId = await api.sendDocumentToAutentique(
        documentFile: documentFile,
        signers: signersInfo,
      );

      if (autentiqueDocId == null) {
        throw Exception(
          "Não foi possível obter o ID do documento do Autentique.",
        );
      }

      // 2. SALVA UM REGISTRO NO SEU FIRESTORE PARA CONTROLE INTERNO
      List<Map<String, dynamic>> signersListForFirestore =
          signersInfo
              .map(
                (s) => {
                  'name': s['name']!,
                  'email': s['email']!,
                  'status': 'pendente',
                },
              )
              .toList();

      final documentData = {
        'name': documentFile.path.split('/').last,
        'ownerId': user.uid,
        'status': 'em_andamento',
        'createdAt': Timestamp.now(),
        'autentiqueId':
            autentiqueDocId, // Guarda o ID do Autentique para referência
        'signers': signersListForFirestore,
      };

      await FirebaseFirestore.instance
          .collection('documents')
          .add(documentData);

      Get.snackbar(
        "Sucesso!",
        "Documento enviado! Os signatários receberão um e-mail em breve.",
      );
    } catch (e) {
      Get.snackbar("Erro", "Falha ao iniciar o fluxo: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }
}
