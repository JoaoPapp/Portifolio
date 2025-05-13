import 'dart:io';
import 'package:dio/dio.dart';
import 'package:portifolio/models/user.dart';
import '../models/document.dart';

class ApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'https://sua-api'));

  /// Busca todos os documentos disponíveis
  Future<List<Document>> fetchDocuments() async {
    final resp = await _dio.get('/documents');
    return (resp.data as List<dynamic>)
        .map((json) => Document.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Realiza upload de um documento e lista de IDs de usuários a assinar
  Future<void> uploadDocument(File pdf, List<String> signerIds) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(
        pdf.path,
        filename: pdf.uri.pathSegments.last,
      ),
      'signers': signerIds,
    });
    await _dio.post('/documents', data: form);
  }

  /// Chama o endpoint que inicia o processo de assinatura via Gov.br
  Future<String> startGovBrFlow(String documentId, String signerId) async {
    final resp = await _dio.post('/documents/$documentId/sign/$signerId');
    return resp.data['govBrUrl'] as String;
  }

  /// Confirma a assinatura de um usuário com o token obtido do Gov.br
  Future<void> markAsSigned(
    String documentId,
    String signerId,
    String token,
  ) async {
    await _dio.post(
      '/documents/$documentId/confirm-sign',
      data: {'signerId': signerId, 'token': token},
    );
  }

  /// >>>>>>>>>>>>>>>>>>>>>
  /// Busca todos os usuários para seleção de signatários
  Future<List<User>> fetchUsers() async {
    final resp = await _dio.get('/users');
    return (resp.data as List<dynamic>)
        .map((json) => User.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
