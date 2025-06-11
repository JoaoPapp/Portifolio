import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:portifolio/models/document.dart';
import 'package:portifolio/models/user.dart';
import 'package:dio/dio.dart' as dio;
import 'package:cloud_firestore/cloud_firestore.dart';

class ApiService {
  late GraphQLClient _client;

  ApiService() {
    final HttpLink httpLink = HttpLink(
      'https://api.autentique.com.br/v2/graphql',
    );
    final String? apiToken = dotenv.env['AUTENTIQUE_API_KEY'];
    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $apiToken',
    );
    final Link link = authLink.concat(httpLink);

    _client = GraphQLClient(cache: GraphQLCache(), link: link);
  }

  /// Busca os documentos da API do Autentique
  Future<List<Document>> fetchDocuments() async {
    const String query = """
      query ListAllDocuments {
        documents(limit: 10, page: 1) {
          data {
            id
            name
            created_at
            signatures {
              public_id
              name
              email
            }
          }
        }
      }
    """;

    final QueryOptions options = QueryOptions(document: gql(query));
    final QueryResult result = await _client.query(options);

    if (result.hasException) {
      print(result.exception.toString());
      throw result.exception!;
    }

    final List<dynamic> documentsJson =
        result.data?['documents']?['data'] ?? [];
    return documentsJson.map((json) => Document.fromJson(json)).toList();
  }

  // Mantemos a função para buscar usuários do nosso próprio Firestore
  Future<List<User>> fetchUsers() async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').get();
      if (snapshot.docs.isEmpty) return [];

      final users =
          snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return User.fromJson(data);
          }).toList();

      return users;
    } catch (e) {
      print("!!! ERRO ao buscar usuários do Firestore: ${e.toString()}");
      return [];
    }
  }
}
