import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:cpf_cnpj_validator/cpf_validator.dart';
import '../controllers/document_controller.dart';

class SignerInfo {
  final String name;
  final String cpf;
  final String email;

  SignerInfo({required this.name, required this.cpf, required this.email});
}

class SignersSelectionScreen extends StatefulWidget {
  final File file;
  const SignersSelectionScreen({required this.file, super.key});

  @override
  State<SignersSelectionScreen> createState() => _SignersSelectionScreenState();
}

class _SignersSelectionScreenState extends State<SignersSelectionScreen> {
  final List<SignerInfo> _signers = [];
  final DocumentController docController = Get.find();
  final _cpfMaskFormatter = MaskTextInputFormatter(
    mask: '###.###.###-##',
    filter: {"#": RegExp(r'[0-9]')},
  );

  Future<void> _showAddSignerDialog() async {
    final nameController = TextEditingController();
    final cpfController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Adicionar Novo Signatário'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome Completo',
                    ),
                    validator:
                        (value) =>
                            (value?.isEmpty ?? true)
                                ? 'Campo obrigatório'
                                : null,
                  ),
                  TextFormField(
                    controller: cpfController,
                    decoration: const InputDecoration(labelText: 'CPF'),
                    keyboardType: TextInputType.number,
                    inputFormatters: [_cpfMaskFormatter],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Campo obrigatório';
                      }
                      if (!CPFValidator.isValid(
                        _cpfMaskFormatter.getUnmaskedText(),
                      )) {
                        return 'CPF inválido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: emailController,
                    decoration: const InputDecoration(labelText: 'Email'),
                    keyboardType: TextInputType.emailAddress,
                    validator:
                        (value) =>
                            (value?.isEmpty ?? true)
                                ? 'Campo obrigatório'
                                : null,
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text('Adicionar'),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  setState(() {
                    _signers.add(
                      SignerInfo(
                        name: nameController.text,
                        cpf: _cpfMaskFormatter.getUnmaskedText(),
                        email: emailController.text,
                      ),
                    );
                  });
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha os Signatários')),
      body: Column(
        children: [
          Expanded(
            child:
                _signers.isEmpty
                    ? const Center(
                      child: Text(
                        'Nenhum signatário adicionado.\nClique no botão + para começar.',
                        textAlign: TextAlign.center,
                      ),
                    )
                    : ListView.builder(
                      itemCount: _signers.length,
                      itemBuilder: (context, index) {
                        final signer = _signers[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(signer.name),
                            subtitle: Text(signer.email),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() {
                                  _signers.removeAt(index);
                                });
                              },
                            ),
                          ),
                        );
                      },
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed:
                    _signers.isEmpty || docController.isLoading.value
                        ? null
                        : () {
                          final signersData =
                              _signers
                                  .map(
                                    (s) => {
                                      'name': s.name,
                                      'cpf': s.cpf,
                                      'email': s.email,
                                    },
                                  )
                                  .toList();

                          docController.createDocumentWorkflow(
                            documentFile: widget.file,
                            documentName: widget.file.path.split('/').last,
                            signersInfo: signersData,
                          );
                        },
                child:
                    docController.isLoading.value
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Enviar para Assinatura'),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSignerDialog,
        tooltip: 'Adicionar Signatário',
        child: const Icon(Icons.add),
      ),
    );
  }
}
