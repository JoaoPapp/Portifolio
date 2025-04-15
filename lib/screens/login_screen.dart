
import 'package:flutter/material.dart';
import 'upload_screen.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  void _simulateGovLogin(BuildContext context) {
    // Simulação do login Gov.br
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const UploadScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login - FlowSign')),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _simulateGovLogin(context),
          child: const Text('Entrar com Gov.br'),
        ),
      ),
    );
  }
}
    