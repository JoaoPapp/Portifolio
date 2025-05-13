import 'package:flutter/material.dart';
import '../models/document.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class DocumentProvider with ChangeNotifier {
  final ApiService api;
  List<Document> docs = [];
  bool loading = false;

  DocumentProvider(this.api);

  /// Carrega a lista de documentos da API
  Future<void> load() async {
    loading = true;
    notifyListeners();

    try {
      docs = await api.fetchDocuments();
    } finally {
      loading = false;
      notifyListeners();
    }
  }

  /// Avança o fluxo de assinatura usando o token retornado do Gov.br
  Future<void> nextSigner(Document doc, String tokenFromGovBr) async {
    final user = doc.nextSigner!;
    await api.markAsSigned(doc.id, user.id, tokenFromGovBr);

    // Atualiza localmente
    user.status = UserStatus.signed;
    doc.currentSignerIndex++;
    notifyListeners();
  }
}
