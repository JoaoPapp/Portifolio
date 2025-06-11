import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/document.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';

class DocumentController extends GetxController {
  // A ApiService é injetada para uso futuro com o Autentique
  final ApiService api;
  DocumentController(this.api);

  var documents = <Document>[].obs;
  var isLoading = false.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    // Ouve as mudanças no estado de autenticação para carregar/limpar os documentos.
    ever(Get.find<AuthController>().user, (user) {
      if (user != null) {
        loadDocumentsFromFirestore(user.uid);
      } else {
        documents.clear();
      }
    });
  }

  /// Busca dados do FIRESTORE em tempo real.
  void loadDocumentsFromFirestore(String userId) {
    isLoading(true);
    FirebaseFirestore.instance
        .collection('documents')
        .where(
          'ownerId',
          isEqualTo: userId,
        ) // Mostra apenas os docs do usuário logado
        .orderBy('createdAt', descending: true)
        .snapshots() // Ouve as mudanças em tempo real
        .listen(
          (snapshot) {
            // Mapeia os documentos do Firestore para a sua lista reativa
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

  /// Cria um novo fluxo de assinatura no Firestore
  Future<void> createDocumentWorkflow({
    required String documentName,
    required List<Map<String, String>> signersInfo,
  }) async {
    try {
      isLoading(true);
      final user = Get.find<AuthController>().user.value;
      if (user == null) {
        throw Exception("Usuário não autenticado.");
      }

      List<Map<String, dynamic>> signersListForFirestore = [];
      for (int i = 0; i < signersInfo.length; i++) {
        signersListForFirestore.add({
          'name': signersInfo[i]['name']!,
          'email': signersInfo[i]['email']!,
          'status': 'pendente',
          'order': i + 1,
        });
      }

      final documentData = {
        'name': documentName,
        'ownerId': user.uid,
        'status': 'em_andamento',
        'createdAt': Timestamp.now(),
        'storagePath': 'documentos/${user.uid}/$documentName',
        'signers': signersListForFirestore,
      };

      await FirebaseFirestore.instance
          .collection('documents')
          .add(documentData);
      Get.snackbar("Sucesso!", "Novo fluxo de assinatura criado.");
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Falha ao criar o fluxo de assinatura: ${e.toString()}",
      );
    } finally {
      isLoading(false);
    }
  }
}
