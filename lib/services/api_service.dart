import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  late GraphQLClient _client;

  ApiService() {
    final String? apiToken = dotenv.env['AUTENTIQUE_API_KEY'];
    final HttpLink httpLink = HttpLink(
      'https://api.autentique.com.br/v2/graphql',
    );
    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $apiToken',
    );
    final Link link = authLink.concat(httpLink);
    _client = GraphQLClient(cache: GraphQLCache(), link: link);
  }

  Future<String?> getSignedDocumentUrl(String autentiqueId) async {
    const String query = r'''
      query GetDocument($id: ID!) {
        document(id: $id) {
          file_signed
        }
      }
    ''';

    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {'id': autentiqueId},
      fetchPolicy: FetchPolicy.networkOnly,
    );

    try {
      final QueryResult result = await _client.query(options);

      if (result.hasException) {
        print(
          "Erro ao buscar URL do documento: ${result.exception.toString()}",
        );
        throw result.exception!;
      }

      final String? downloadUrl = result.data?['document']?['file_signed'];
      return downloadUrl;
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
      final http.StreamedResponse response = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final String responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(responseBody);
        if (jsonResponse.containsKey('errors')) {
          print(
            "Erro retornado pela API Autentique: ${jsonResponse['errors']}",
          );
          throw Exception("Erro da API: ${jsonResponse['errors']}");
        }
        final String? docId = jsonResponse['data']?['createDocument']?['id'];
        print("Documento enviado ao Autentique com sucesso. ID: $docId");
        return docId;
      } else {
        print(
          "Falha no envio do documento. Status: ${response.statusCode}, Corpo: $responseBody",
        );
        throw Exception(
          'Falha ao enviar documento. Status: ${response.statusCode}',
        );
      }
    } on TimeoutException catch (e) {
      print("Erro de Timeout: A requisição demorou mais de 30 segundos. $e");
      rethrow;
    } catch (e) {
      print("Exceção geral na chamada da API: $e");
      rethrow;
    }
  }
}
