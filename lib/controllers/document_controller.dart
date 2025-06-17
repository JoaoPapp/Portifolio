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
        loadDocumentsFromFirestore(user.uid);
      } else {
        documents.clear();
      }
    });
  }

  void loadDocumentsFromFirestore(String userId) {
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

  // >>>>>>>>>>>>> FUNÇÃO ATUALIZADA <<<<<<<<<<<<<<<<<
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

      // 1. Salva o documento na coleção 'documents'
      final newDocumentRef = await FirebaseFirestore.instance
          .collection('documents')
          .add(documentData);
      print(
        "Documento de fluxo salvo no Firestore com ID: ${newDocumentRef.id}",
      );

      // 2. >>> INÍCIO DA LÓGICA DE ENVIO DE E-MAIL QUE FALTAVA <<<
      // Para cada signatário, cria um documento na coleção 'mail'
      for (var signer in signersInfo) {
        await FirebaseFirestore.instance.collection('mail').add({
          'to': [signer['email']],
          'message': {
            'subject':
                'FlowSign: Convite para assinar o documento "$documentName"',
            'html': """
              <h1>Olá, ${signer['name']}!</h1>
              <p>Você foi convidado(a) para assinar o documento "$documentName".</p>
              <p>Por favor, clique no link abaixo para visualizar e assinar.</p>
              <p><a href="https://seu-app.com/sign?docId=${newDocumentRef.id}&signerEmail=${signer['email']}">Assinar o Documento</a></p>
              <p>Obrigado!</p>
            """,
          },
        });
        print(
          "Pedido de e-mail para ${signer['email']} criado na coleção 'mail'.",
        );
      }
      // >>> FIM DA LÓGICA DE ENVIO DE E-MAIL <<<

      isLoading(false);
      Get.snackbar(
        "Sucesso!",
        "Fluxo de assinatura criado e convites enviados.",
      );
    } catch (e) {
      isLoading(false);
      Get.snackbar("Erro", "Falha ao criar o fluxo: ${e.toString()}");
    }
  }
}
