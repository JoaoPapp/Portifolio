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

  Stream<List<Document>>? _documentsStream;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();

    // >>>>> INÍCIO DA MUDANÇA <<<<<

    // 1. Escuta por MUDANÇAS futuras no estado de login (login/logout)
    ever(authController.user, (firebaseUser) {
      if (firebaseUser == null) {
        documents.clear();
      } else {
        _listenToDocuments(firebaseUser.uid);
      }
    });

    // 2. Verifica o ESTADO ATUAL do usuário ao iniciar o controller
    // Isso resolve o problema de o usuário já estar logado quando o app abre.
    if (authController.user.value != null) {
      _listenToDocuments(authController.user.value!.uid);
    }

    // >>>>> FIM DA MUDANÇA <<<<<
  }

  void _listenToDocuments(String userId) {
    isLoading(true);
    _documentsStream = FirebaseFirestore.instance
        .collection('documents')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Document.fromFirestore(doc)).toList(),
        );

    documents.bindStream(_documentsStream!);
    isLoading(false);
  }

  // A função createDocumentWorkflow continua exatamente a mesma
  Future<void> createDocumentWorkflow({
    required File documentFile,
    required List<Map<String, String>> signersInfo,
    required String documentName,
  }) async {
    try {
      isLoading(true);
      final user = Get.find<AuthController>().user.value;
      if (user == null) throw Exception("Usuário não autenticado.");

      final String? autentiqueDocId = await api.sendDocumentToAutentique(
        documentFile: documentFile,
        signers: signersInfo,
      );

      if (autentiqueDocId == null) {
        throw Exception(
          "Não foi possível obter o ID do documento do Autentique.",
        );
      }

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
}
