
import 'package:flutter/material.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Status do Documento')),
      body: Center(
        child: Text('Tela para visualizar o status do documento'),
      ),
    );
  }
}
    