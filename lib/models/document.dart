import 'package:portifolio/models/user.dart';

class Document {
  final String id;
  final String name;
  final String url;
  final List<User> signers; // agora usa User em vez de Signer
  int currentSignerIndex;

  Document({
    required this.id,
    required this.name,
    required this.url,
    required this.signers,
    this.currentSignerIndex = 0,
  });

  /// Construtor de fábrica para converter JSON em Document
  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'] as String,
      name: json['name'] as String,
      url: json['url'] as String,
      currentSignerIndex: json['currentSignerIndex'] as int? ?? 0,
      signers: (json['signers'] as List<dynamic>)
          .map((u) => User.fromJson(u as Map<String, dynamic>))
          .toList(),
    );
  }

  /// Converte para JSON:
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'url': url,
    'currentSignerIndex': currentSignerIndex,
    'signers': signers.map((u) => u.toJson()).toList(),
  };

  /// Retorna o próximo usuário a assinar ou null se nenhum
  User? get nextSigner =>
      currentSignerIndex < signers.length ? signers[currentSignerIndex] : null;
}
