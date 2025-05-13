import 'dart:io';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import 'signature_flow_screen.dart';

class SignersSelectionScreen extends StatefulWidget {
  final File file;
  const SignersSelectionScreen({required this.file, super.key});

  @override
  State<SignersSelectionScreen> createState() => _SignersSelectionScreenState();
}

class _SignersSelectionScreenState extends State<SignersSelectionScreen> {
  final ApiService api = ApiService();
  List<User> _contacts = [];
  Set<String> _selectedIds = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final users = await api.fetchUsers(); // endpoint GET /users
    setState(() {
      _contacts = users;
      _loading = false;
    });
  }

  void _toggleSigner(String id) {
    setState(() {
      if (_selectedIds.contains(id))
        _selectedIds.remove(id);
      else
        _selectedIds.add(id);
    });
  }

  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escolha os Signatários')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: _contacts.length,
                    itemBuilder: (_, i) {
                      final u = _contacts[i];
                      final sel = _selectedIds.contains(u.id);
                      return CheckboxListTile(
                        value: sel,
                        title: Text(u.name),
                        subtitle: Text(u.email),
                        onChanged: (_) => _toggleSigner(u.id),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () {
                            // Filtra a lista de User pelo id
                            final chosen = _contacts
                                .where((u) => _selectedIds.contains(u.id))
                                .toList();
                            Navigator.of(ctx).push(
                              MaterialPageRoute(
                                builder: (_) => SignatureFlowScreen(
                                  pdfFile: widget.file,
                                  signers: chosen,
                                ),
                              ),
                            );
                          },
                    child: const Text('Enviar para Assinatura'),
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
