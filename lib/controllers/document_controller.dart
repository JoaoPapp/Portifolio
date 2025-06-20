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

  // >>> NOVO: STREAM DE DOCUMENTOS <<<
  Stream<List<Document>>? _documentsStream;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();

    // Ouve as mudanças no status de autenticação do usuário
    ever(authController.user, (firebaseUser) {
      if (firebaseUser == null) {
        // Se o usuário deslogar, limpa a lista de documentos
        documents.clear();
      } else {
        // Se o usuário logar, busca os documentos dele em tempo real
        _listenToDocuments(firebaseUser.uid);
      }
    });
  }

  // >>> NOVO: MÉTODO PARA OUVIR AS MUDANÇAS EM TEMPO REAL <<<
  void _listenToDocuments(String userId) {
    isLoading(true);
    _documentsStream = FirebaseFirestore.instance
        .collection('documents')
        .where(
          'ownerId',
          isEqualTo: userId,
        ) // Filtra apenas os documentos do usuário logado
        .orderBy('createdAt', descending: true) // Ordena pelos mais recentes
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Document.fromFirestore(doc)).toList(),
        );

    // O bindStream atualiza a lista 'documents' automaticamente
    documents.bindStream(_documentsStream!);
    isLoading(false);
  }

  // Função para criar o documento (continua a mesma)
  Future<void> createDocumentWorkflow({
    required File documentFile,
    required List<Map<String, String>> signersInfo,
    required String documentName,
  }) async {
    // ... (o resto da função createDocumentWorkflow não muda)
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
                  'status': 'pendente', // Status inicial
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
