import 'package:cloud_firestore/cloud_firestore.dart';

class Document {
  final String id;
  final String name;
  final String? ownerId;
  final String? status;
  final List<dynamic> signers;
  final Timestamp? createdAt;

  Document({
    required this.id,
    required this.name,
    this.ownerId,
    this.status,
    required this.signers,
    this.createdAt,
  });

  factory Document.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data() ?? {};
    return Document(
      id: snapshot.id,
      name: data['name'] ?? 'Nome não definido',
      ownerId: data['ownerId'],
      status: data['status'],
      signers: data['signers'] ?? [],
      createdAt: data['createdAt'],
    );
  }

  factory Document.fromJson(Map<String, dynamic> json) {
    final createdAtString = json['created_at'] as String?;
    final createdAt =
        createdAtString != null
            ? Timestamp.fromDate(DateTime.parse(createdAtString))
            : null;

    return Document(
      id: json['id'] ?? '',
      name: json['name'] ?? 'Nome não definido',
      ownerId: null,
      status: json['status'],
      signers: json['signatures'] ?? [],
      createdAt: createdAt,
    );
  }
}
