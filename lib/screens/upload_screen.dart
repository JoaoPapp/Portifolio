import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:portifolio/screens/signature_flow_screen.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => _UploadScreenState();
}

class _UploadScreenState extends State<UploadScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  File? _selectedFile;
  String? _fileName;

  // Mantém últimos arquivos (em memória)
  final List<File> _recentFiles = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (result != null && result.files.single.path != null) {
      final picked = File(result.files.single.path!);
      setState(() {
        _selectedFile = picked;
        _fileName = result.files.single.name;

        // adiciona ao topo da lista de recentes, evitando duplicados
        _recentFiles.removeWhere((f) => f.path == picked.path);
        _recentFiles.insert(0, picked);

        // limite de últimos 5 arquivos
        if (_recentFiles.length > 5) _recentFiles.removeLast();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('FlowSign'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Novo Documento', icon: Icon(Icons.upload_file)),
            Tab(text: 'Últimos', icon: Icon(Icons.history)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Aba 1: Escolher novo arquivo
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_fileName != null) ...[
                  Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.description),
                      title: Text(
                        _fileName!,
                        style: theme.textTheme.titleMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => setState(() {
                          _selectedFile = null;
                          _fileName = null;
                        }),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                ElevatedButton.icon(
                  onPressed: _pickFile,
                  icon: const Icon(Icons.upload_file, size: 28),
                  label: Text(
                    _fileName == null ? 'Escolher Arquivo' : 'Trocar Arquivo',
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                if (_selectedFile != null)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => SignatureFlowScreen(
                              pdfFile: _selectedFile!,
                              signers: [], // <-- lista de usuários (aqui vazia)
                            ),
                          ),
                        );
                      },
                      child: const Text('Próximo: Assinar Documento'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Aba 2: Lista de arquivos recentes
          _recentFiles.isEmpty
              ? Center(
                  child: Text(
                    'Nenhum documento recente',
                    style: theme.textTheme.titleMedium,
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _recentFiles.length,
                  itemBuilder: (_, idx) {
                    final file = _recentFiles[idx];
                    final name = file.path.split('/').last;
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: ListTile(
                        leading: const Icon(Icons.description_outlined),
                        title: Text(name),
                        trailing: IconButton(
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => SignatureFlowScreen(
                                  pdfFile: file,
                                  signers: [], // <-- também aqui
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
        ],
      ),
    );
  }
}
