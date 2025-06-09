import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:portifolio/models/document.dart';
import 'package:portifolio/models/user.dart'; // Mantive seu modelo User
import 'package:dio/dio.dart' as dio;

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

    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
    );
  }

  // >>>>>>>>>>>>> INÍCIO DA NOVA FUNÇÃO <<<<<<<<<<<<<<<<<
  /// Busca todos os contatos (usuários) salvos na sua conta Autentique
  Future<List<User>> fetchUsers() async {
    // Consulta GraphQL para listar contatos.
    // NOTA: A API do Autentique pode chamar de "contacts". Estou assumindo
    // os campos 'name' e 'email' para compatibilidade com seu modelo 'User'.
    final String query = """
      query ListContacts {
        contacts(limit: 100) {
          data {
            id
            name
            email
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

    final List<dynamic> contactsJson = result.data?['contacts']?['data'] ?? [];
    
    // Mapeia a resposta para a sua lista de User
    return contactsJson.map((json) => User.fromJson(json)).toList();
  }
  // >>>>>>>>>>>>> FIM DA NOVA FUNÇÃO <<<<<<<<<<<<<<<<<


  /// Busca todos os documentos disponíveis
  Future<List<Document>> fetchDocuments() async {
    final String query = """
      query ListDocuments {
        documents(limit: 50) {
          data {
            id
            name
            signatures {
              public_id
              name
              email
              created_at
              signed_at
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

    final List<dynamic> documentsJson = result.data?['documents']?['data'] ?? [];
    return documentsJson.map((json) => Document.fromJson(json)).toList();
  }

  /// Realiza upload de um documento para criar na Autentique
  Future<void> uploadDocument(File pdf, String documentName) async {
    final String mutation = """
      mutation CreateDocument(\$file: Upload!, \$document: DocumentInput!) {
        createDocument(file: \$file, document: \$document) {
          id
          name
        }
      }
    """;

    final dio.MultipartFile multipartFile = await dio.MultipartFile.fromFile(
      pdf.path,
      filename: pdf.path.split('/').last,
    );

    final Map<String, dynamic> variables = {
      'file': multipartFile,
      'document': {
        'name': documentName,
      }
    };

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: variables,
    );
    
    final QueryResult result = await _client.mutate(options);

    if (result.hasException) {
      print(result.exception.toString());
      throw result.exception!;
    }
    
    print('Documento criado: ${result.data?['createDocument']?['name']}');
  }
}