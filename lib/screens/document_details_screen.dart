import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portifolio/controllers/document_controller.dart';
import 'package:portifolio/models/document.dart';

class DocumentDetailsScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailsScreen({required this.document, super.key});

  Icon _getIconForSignerStatus(String status) {
    switch (status.toLowerCase()) {
      case 'assinado':
        return const Icon(Icons.check_circle, color: Colors.green);
      case 'pendente':
        return const Icon(Icons.hourglass_empty, color: Colors.orange);
      case 'recusado':
        return const Icon(Icons.cancel, color: Colors.red);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    final DocumentController docController = Get.find();

    return Scaffold(
      appBar: AppBar(title: Text(document.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status Geral: ${document.status ?? 'N/A'}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            const Text(
              'Signatários',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Divider(),
            Expanded(
              child: ListView.builder(
                itemCount: document.signers.length,
                itemBuilder: (context, index) {
                  final signer = document.signers[index];
                  final name = signer['name'] ?? 'Nome não informado';
                  final email = signer['email'] ?? 'Email não informado';
                  final status = signer['status'] ?? 'desconhecido';

                  return Card(
                    child: ListTile(
                      leading: _getIconForSignerStatus(status),
                      title: Text(name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(email),
                          Text(
                            'Status: $status',
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            if (document.status == 'concluido')
              Padding(
                padding: const EdgeInsets.only(top: 24.0, bottom: 8.0),
                child: Obx(
                  () => ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    onPressed:
                        docController.isLoading.value
                            ? null
                            : () =>
                                docController.downloadSignedDocument(document),
                    icon:
                        docController.isLoading.value
                            ? Container(
                              width: 24,
                              height: 24,
                              padding: const EdgeInsets.all(2.0),
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : const Icon(Icons.download_rounded),
                    label: Text(
                      docController.isLoading.value
                          ? 'Buscando...'
                          : 'Baixar Documento Assinado',
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
