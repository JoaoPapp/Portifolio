
import 'package:flutter/material.dart';

class DocumentViewScreen extends StatelessWidget {
  const DocumentViewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Visualizar Documento')),
      body: Center(
        child: Text('Tela para visualizar e fazer download do documento'),
      ),
    );
  }
}
    