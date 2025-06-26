import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/document_controller.dart';

// Um modelo simples para guardar os dados do signatário na tela
class SignerInfo {
  final String name;
  final String cpf;
  final String email;

  SignerInfo({required this.name, required this.cpf, required this.email});
}

class SignersSelectionScreen extends StatefulWidget {
  final File file; // O arquivo PDF/DOCX que veio da tela anterior
  const SignersSelectionScreen({required this.file, super.key});

  @override
  State<SignersSelectionScreen> createState() => _SignersSelectionScreenState();
}

class _SignersSelectionScreenState extends State<SignersSelectionScreen> {
  // Lista local para guardar os signatários que o usuário adicionar
  final List<SignerInfo> _signers = [];
  final DocumentController docController = Get.find();

  // Função para mostrar o pop-up (dialog) de adicionar signatário
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
                    validator:
                        (value) =>
                            (value?.isEmpty ?? true)
                                ? 'Campo obrigatório'
                                : null,
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
                        cpf: cpfController.text,
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
          // Lista dos signatários já adicionados
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
          // Botão para enviar para assinatura
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                ),
                onPressed:
                    _signers.isEmpty || docController.isLoading.value
                        ? null // Desabilita o botão se a lista estiver vazia ou carregando
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

                          // >>>>> AQUI ESTÁ A CHAMADA CORRIGIDA <<<<<
                          // Agora todos os parâmetros necessários estão sendo enviados.
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
      // Botão flutuante para adicionar novos signatários
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddSignerDialog,
        tooltip: 'Adicionar Signatário',
        child: const Icon(Icons.add),
      ),
    );
  }
}
