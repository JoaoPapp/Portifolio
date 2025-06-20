import 'package:flutter/material.dart';
import 'package:portifolio/models/document.dart';

class DocumentDetailsScreen extends StatelessWidget {
  final Document document;

  const DocumentDetailsScreen({required this.document, super.key});

  // Função auxiliar para retornar um ícone baseado no status do signatário
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
                  // O 'signer' aqui é um Map<String, dynamic>
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
          ],
        ),
      ),
    );
  }
}
