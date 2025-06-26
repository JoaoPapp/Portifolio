import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

class ApiService {
  late GraphQLClient _client;

  ApiService() {
    final HttpLink httpLink = HttpLink(
      'https://api.autentique.com.br/v2/graphql',
      defaultHeaders: {'Content-Type': 'multipart/form-data'},
    );
    final String? apiToken = dotenv.env['AUTENTIQUE_API_KEY'];
    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $apiToken',
    );
    final Link link = authLink.concat(httpLink);
    _client = GraphQLClient(cache: GraphQLCache(), link: link);
  }

  /// Envia um documento para o Autentique, que gerenciará o fluxo sequencial de assinaturas.
  Future<String?> sendDocumentToAutentique({
    required File documentFile,
    required List<Map<String, String>> signers,
  }) async {
    const String mutation = """
      mutation CreateDocument(\$document: DocumentInput!, \$signers: [SignerInput!]!, \$file: Upload!) {
        createDocument(document: \$document, signers: \$signers, file: \$file) { id }
      }
    """;

    final byteStream = http.ByteStream(documentFile.openRead());
    final length = await documentFile.length();
    final fileName = documentFile.path.split('/').last;
    final multipartFile = http.MultipartFile(
      'file',
      byteStream,
      length,
      filename: fileName,
    );

    // >>>>> MUDANÇA IMPORTANTE AQUI <<<<<
    // Adicionamos 'sortable: true' para instruir o Autentique a seguir a ordem da lista.
    final documentInput = {'name': fileName, 'sortable': true};

    final signersInput =
        signers
            .map(
              (s) => {'email': s['email'], 'name': s['name'], 'action': 'SIGN'},
            )
            .toList();

    final MutationOptions options = MutationOptions(
      document: gql(mutation),
      variables: {
        'document': documentInput,
        'signers': signersInput,
        'file': multipartFile,
      },
    );

    final QueryResult result = await _client.mutate(options);

    if (result.hasException) {
      print("Erro ao enviar para o Autentique: ${result.exception.toString()}");
      throw result.exception!;
    }

    final String? docId = result.data?['createDocument']?['id'];
    print("Documento enviado ao Autentique para fluxo sequencial. ID: $docId");
    return docId;
  }
}
