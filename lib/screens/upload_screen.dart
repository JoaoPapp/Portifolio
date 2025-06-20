import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portifolio/screens/document_details_screen.dart';
import 'package:portifolio/screens/signers_selection_screen.dart';
import '../controllers/auth_controller.dart';
import '../controllers/document_controller.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  // Função auxiliar para retornar um ícone baseado no status
  IconData _getIconForStatus(String? status) {
    switch (status) {
      case 'em_andamento':
        return Icons.hourglass_top_rounded;
      case 'concluido':
        return Icons.check_circle_outline_rounded;
      case 'cancelado':
        return Icons.cancel_outlined;
      default:
        return Icons.description_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find();
    final DocumentController docController = Get.find();

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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meus Documentos'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              authController.signOut();
            },
          ),
        ],
      ),
      // O Obx torna a UI reativa às mudanças nos controllers
      body: Obx(() {
        // Mostra um indicador de progresso enquanto os documentos carregam pela primeira vez
        if (docController.isLoading.value && docController.documents.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        // Mostra uma mensagem se a lista de documentos estiver vazia
        if (docController.documents.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.folder_off_outlined,
                  size: 80,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Nenhum documento encontrado.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        // Constrói a lista de documentos
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: docController.documents.length,
          itemBuilder: (context, index) {
            final document = docController.documents[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              child: ListTile(
                leading: Icon(
                  _getIconForStatus(document.status),
                  color: Colors.blue,
                  size: 40,
                ),
                title: Text(
                  document.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  "Status: ${document.status ?? 'Não definido'}",
                  style: const TextStyle(color: Colors.black54),
                ),
                onTap: () {
                  // Ação ao clicar em um documento (ex: ver detalhes)
                  Get.to(() => DocumentDetailsScreen(document: document));
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: pickFile,
        label: const Text('Novo Documento'),
        icon: const Icon(Icons.add),
        tooltip: 'Iniciar Novo Documento',
      ),
    );
  }
}
