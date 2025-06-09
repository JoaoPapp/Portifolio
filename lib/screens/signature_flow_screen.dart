import 'dart:io';
import 'package:flutter/material.dart';
import 'package:portifolio/models/user.dart';

class SignatureFlowScreen extends StatefulWidget {
  /// O PDF que foi escolhido
  final File pdfFile;

  /// A lista de usuários que vão assinar
  final List<User> signers;

  const SignatureFlowScreen({
    required this.pdfFile,
    required this.signers,
    super.key,
  });

  @override
  State<SignatureFlowScreen> createState() => _SignatureFlowScreenState();
}

class _SignatureFlowScreenState extends State<SignatureFlowScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final signer = widget.signers[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text('Assinar: ${widget.pdfFile.uri.pathSegments.last}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Text(
                'Assinante atual:\n${signer.name}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () {
                // Quando terminar de assinar:
                setState(() {
                  _currentIndex++;
                  if (_currentIndex >= widget.signers.length) {
                    // Todos assinaram: volta à lista ou fecha
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                });
              },
              child: Text(
                _currentIndex + 1 < widget.signers.length
                    ? 'Avançar para ${widget.signers[_currentIndex + 1].name}'
                    : 'Finalizar',
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(48),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
