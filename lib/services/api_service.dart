import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dio/dio.dart' as dio; // dio é usado para o upload do arquivo
import '../models/user.dart';

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

  /// Envia um documento e seus signatários para a API do Autentique para iniciar o processo.
  Future<String?> sendDocumentToAutentique({
    required File documentFile,
    required List<Map<String, String>> signers,
  }) async {
    // A "mutation" do GraphQL para criar um documento.
    // A estrutura exata dos inputs pode variar, consulte a documentação do Autentique.
    const String mutation = """
      mutation CreateDocument(\$document: DocumentInput!, \$signers: [SignerInput!]!, \$file: Upload!) {
        createDocument(
          document: \$document,
          signers: \$signers,
          file: \$file
        ) {
          id
          name
        }
      }
    """;

    // Preparando os dados para a API
    final dio.MultipartFile multipartFile = await dio.MultipartFile.fromFile(
      documentFile.path,
      filename: documentFile.path.split('/').last,
    );

    final documentInput = {'name': documentFile.path.split('/').last};

    // Mapeia a lista de signatários para o formato que a API do Autentique espera
    final signersInput =
        signers
            .map(
              (s) => {
                'email': s['email'],
                'name': s['name'],
                'action': 'SIGN', // Define a ação como "assinar"
              },
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

    // Retorna o ID do documento criado no Autentique
    final String? docId = result.data?['createDocument']?['id'];
    print("Documento enviado com sucesso para o Autentique. ID: $docId");
    return docId;
  }
}
