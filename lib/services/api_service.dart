import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  late final GraphQLClient _graphQLClient;
  late final http.Client _httpClient;

  ApiService({GraphQLClient? clientForTest, http.Client? httpClientForTest}) {
    _httpClient = httpClientForTest ?? http.Client();

    if (clientForTest != null) {
      _graphQLClient = clientForTest;
    } else {
      final String? apiToken = dotenv.env['AUTENTIQUE_API_KEY'];
      final HttpLink httpLink = HttpLink(
        'https://api.autentique.com.br/v2/graphql',
        httpClient: _httpClient,
      );
      final AuthLink authLink = AuthLink(
        getToken: () async => 'Bearer $apiToken',
      );
      final Link link = authLink.concat(httpLink);
      _graphQLClient = GraphQLClient(cache: GraphQLCache(), link: link);
    }
  }

  Future<String?> getSignedDocumentUrl(String autentiqueId) async {
    const String query = r'''
      query GetDocument($id: UUID!) {
        document(id: $id) {
          files {
            signed
          }
        }
      }
    ''';
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {'id': autentiqueId},
      fetchPolicy: FetchPolicy.networkOnly,
    );
    try {
      final QueryResult result = await _graphQLClient.query(options);
      if (result.hasException) {
        throw result.exception!;
      }
      return result.data?['document']?['files']?['signed'];
    } catch (e) {
      print("Exceção ao buscar URL: $e");
      rethrow;
    }
  }

  Future<String?> sendDocumentToAutentique({
    required File documentFile,
    required List<Map<String, String>> signers,
  }) async {
    const String mutation = """
      mutation CreateDocument(\$document: DocumentInput!, \$signers: [SignerInput!]!, \$file: Upload!) {
        createDocument(document: \$document, signers: \$signers, file: \$file) { id }
      }
    """;
    final String? apiToken = dotenv.env['AUTENTIQUE_API_KEY'];
    final url = Uri.parse('https://api.autentique.com.br/v2/graphql');

    final request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $apiToken';

    final documentInput = {
      'name': documentFile.path.split('/').last,
      'sortable': true,
    };
    final signersInput =
        signers
            .map(
              (s) => {'email': s['email'], 'name': s['name'], 'action': 'SIGN'},
            )
            .toList();
    final Map<String, dynamic> variables = {
      'document': documentInput,
      'signers': signersInput,
      'file': null,
    };
    final Map<String, dynamic> operations = {
      'query': mutation,
      'variables': variables,
    };
    final Map<String, String> fields = {
      'operations': json.encode(operations),
      'map': '{"0": ["variables.file"]}',
    };
    request.fields.addAll(fields);

    final http.MultipartFile multipartFile = await http.MultipartFile.fromPath(
      '0',
      documentFile.path,
      contentType: MediaType('application', 'octet-stream'),
    );
    request.files.add(multipartFile);

    try {
      final http.StreamedResponse response = await _httpClient
          .send(request)
          .timeout(const Duration(seconds: 30));
      final String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(responseBody);
        if (jsonResponse.containsKey('errors')) {
          throw Exception("Erro da API: ${jsonResponse['errors']}");
        }
        return jsonResponse['data']?['createDocument']?['id'];
      } else {
        throw Exception(
          'Falha ao enviar documento. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print("Erro de Timeout: $e");
      rethrow;
    } catch (e) {
      print("Exceção geral na chamada da API: $e");
      rethrow;
    }
  }
}
