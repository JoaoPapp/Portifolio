import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import '../models/document.dart';
import '../services/api_service.dart';
import 'auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher_string.dart';

class DocumentController extends GetxController {
  final ApiService api;
  DocumentController(this.api);

  var documents = <Document>[].obs;
  var isLoading = false.obs;
  var errorMessage = RxnString();

  StreamSubscription<List<Document>>? _documentsSubscription;

  @override
  void onInit() {
    super.onInit();
    final authController = Get.find<AuthController>();

    ever(authController.user, (firebaseUser) {
      if (firebaseUser == null) {
        _documentsSubscription?.cancel();
        documents.clear();
      } else {
        listenToDocuments(firebaseUser.uid);
      }
    });

    if (authController.user.value != null) {
      listenToDocuments(authController.user.value!.uid);
    }
  }

  @override
  void onClose() {
    _documentsSubscription?.cancel();
    super.onClose();
  }

  void listenToDocuments(String userId) {
    isLoading(true);
    _documentsSubscription?.cancel();
    final stream = FirebaseFirestore.instance
        .collection('documents')
        .where('ownerId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Document.fromFirestore(doc)).toList(),
        );
    _documentsSubscription = stream.listen(
      (docList) {
        documents.value = docList;
        if (isLoading.value) {
          isLoading(false);
        }
      },
      onError: (error) {
        print("Erro ao escutar documentos: $error");
        isLoading(false);
        errorMessage.value = "Falha ao carregar documentos.";
      },
    );
  }

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

      Get.back();
      Get.snackbar(
        "Sucesso!",
        "Documento enviado! Os signatários receberão um e-mail em breve.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        "Erro",
        "Falha ao iniciar o fluxo: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> downloadSignedDocument(Document document) async {
    final autentiqueId = document.autentiqueId;
    if (autentiqueId == null) {
      Get.snackbar("Erro", "ID do documento não encontrado para o download.");
      return;
    }

    isLoading(true);
    try {
      final String? downloadUrl = await api.getSignedDocumentUrl(autentiqueId);
      if (downloadUrl != null && await canLaunchUrlString(downloadUrl)) {
        await launchUrlString(downloadUrl);
      } else {
        throw Exception("Não foi possível obter ou abrir a URL de download.");
      }
    } catch (e) {
      Get.snackbar(
        "Erro no Download",
        "Não foi possível baixar o documento: ${e.toString()}",
      );
    } finally {
      isLoading(false);
    }
  }

  Future<void> markDocumentAsSignedBy(
    Document document,
    String signerEmail,
  ) async {
    try {
      isLoading(true);

      final signerIndex = document.signers.indexWhere(
        (signer) => signer['email'] == signerEmail,
      );

      if (signerIndex == -1) {
        throw Exception("Signatário não encontrado no documento.");
      }

      List<dynamic> updatedSigners = List.from(document.signers);
      updatedSigners[signerIndex]['status'] = 'assinado';

      bool allSigned = updatedSigners.every((s) => s['status'] == 'assinado');
      String newDocumentStatus = allSigned ? 'concluido' : 'em_andamento';

      await FirebaseFirestore.instance
          .collection('documents')
          .doc(document.id)
          .update({'signers': updatedSigners, 'status': newDocumentStatus});

      Get.snackbar("Sucesso!", "Documento assinado com sucesso!");

      if (allSigned) {
        Get.offAllNamed('/upload');
      }
    } catch (e) {
      Get.snackbar("Erro", "Falha ao registrar assinatura: ${e.toString()}");
    } finally {
      isLoading(false);
    }
  }
}
