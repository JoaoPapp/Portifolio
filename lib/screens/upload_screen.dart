
import 'package:flutter/material.dart';
import 'signature_flow_screen.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  void _startSignatureFlow(BuildContext context) {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignatureFlowScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload de Documento - FlowSign')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _startSignatureFlow(context),
          child: const Text('Iniciar Fluxo de Assinatura'),
        ),
      ),
    );
  }
}
    