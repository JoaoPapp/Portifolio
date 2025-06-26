import 'dart:io';
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
    super.onInit();
    ever(Get.find<AuthController>().user, (user) {
      if (user != null) {
        listenToDocuments(user.uid);
      } else {
        documents.clear();
      }
    });
  }

  void listenToDocuments(String userId) {
    isLoading(true);
    FirebaseFirestore.instance
        .collection('documents')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen(
          (snapshot) {
            documents.value =
                snapshot.docs
                    .map((doc) => Document.fromFirestore(doc))
                    .toList();
            isLoading(false);
          },
          onError: (error) {
            print("Erro ao carregar documentos: $error");
            errorMessage.value = "Falha ao carregar documentos.";
            isLoading(false);
          },
        );
  }

  // >>> FUNÇÃO ATUALIZADA PARA O FLUXO SEQUENCIAL <<<
  Future<void> createDocumentWorkflow({
    required File documentFile, // Adicionamos o arquivo como parâmetro
    required String documentName,
    required List<Map<String, String>> signersInfo,
  }) async {
    try {
      isLoading(true);
      final user = Get.find<AuthController>().user.value;
      if (user == null) throw Exception("Usuário não autenticado.");

      // Chama a API do Autentique para iniciar o fluxo
      final String? autentiqueDocId = await api.sendDocumentToAutentique(
        documentFile: documentFile,
        signers: signersInfo,
      );

      if (autentiqueDocId == null) {
        throw Exception(
          "Não foi possível obter o ID do documento do Autentique.",
        );
      }

      // Prepara os dados para salvar no seu Firestore
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
        'name': documentName,
        'ownerId': user.uid,
        'status': 'em_andamento',
        'createdAt': Timestamp.now(),
        'autentiqueId': autentiqueDocId,
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

  // Função para marcar como assinado (essencial para o fluxo)
  Future<void> markDocumentAsSignedBy(
    Document document,
    String signerEmail,
  ) async {
    // ...
  }
}
