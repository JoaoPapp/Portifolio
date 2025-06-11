import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portifolio/screens/signers_selection_screen.dart';
import '../controllers/auth_controller.dart';
import '../services/api_service.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final ApiService apiService = Get.find();

    Future<void> pickFile() async {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'docx'],
      );
      if (result != null && result.files.single.path != null) {
        final pickedFile = File(result.files.single.path!);
        Get.to(() => SignersSelectionScreen(file: pickedFile));
      }
    }

    // Função de teste atualizada para buscar DOCUMENTOS
    Future<void> testAutentiqueApi() async {
      print("--- Testando a API do Autentique... ---");
      try {
        final documents = await apiService.fetchDocuments();
        print("✅ SUCESSO! Documentos encontrados na API: ${documents.length}");
        for (var doc in documents) {
          print(" - Documento: ${doc.name}");
        }
        Get.snackbar(
          "Sucesso!",
          "Conexão com a API do Autentique funcionando! ${documents.length} documentos encontrados.",
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      } catch (e) {
        print("❌ ERRO ao conectar com a API do Autentique: ${e.toString()}");
        Get.snackbar(
          "Erro na API",
          "Não foi possível conectar com a API do Autentique. Verifique o console.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('FlowSign'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => authController.signOut(),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: pickFile,
                icon: const Icon(Icons.upload_file),
                label: const Text('Iniciar Novo Documento'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: testAutentiqueApi,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                child: const Text('Testar Conexão com Autentique'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
