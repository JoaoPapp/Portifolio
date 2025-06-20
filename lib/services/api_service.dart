import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:gql_dio_link/gql_dio_link.dart';

class ApiService {
  late GraphQLClient _client;

  ApiService() {
    final dio.Dio dioClient = dio.Dio();

    final DioLink dioLink = DioLink(
      'https://api.autentique.com.br/v2/graphql',
      client: dioClient,
    );

    final String? apiToken = dotenv.env['AUTENTIQUE_API_KEY'];
    final AuthLink authLink = AuthLink(
      getToken: () async => 'Bearer $apiToken',
    );

    final Link link = authLink.concat(dioLink);

    _client = GraphQLClient(
      cache: GraphQLCache(),
      link: link,
      // >>>>>>>> A MUDANÇA ESTÁ AQUI <<<<<<<<<<
      // Define a política padrão para todas as mutações: nunca usar o cache.
      defaultPolicies: DefaultPolicies(
        mutate: Policies(fetch: FetchPolicy.noCache),
      ),
    );
  }

  Future<String?> sendDocumentToAutentique({
    required File documentFile,
    required List<Map<String, String>> signers,
  }) async {
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

    final dio.MultipartFile multipartFile = await dio.MultipartFile.fromFile(
      documentFile.path,
      filename: documentFile.path.split('/').last,
    );

    final documentInput = {'name': documentFile.path.split('/').last};

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
      // Não precisamos mais da política aqui, pois já é a padrão
    );

    final QueryResult result = await _client.mutate(options);

    if (result.hasException) {
      print("Erro ao enviar para o Autentique: ${result.exception.toString()}");
      throw Exception(
        "Falha na comunicação com o Autentique: ${result.exception.toString()}",
      );
    }

    final String? docId = result.data?['createDocument']?['id'];
    print("Documento enviado com sucesso para o Autentique. ID: $docId");
    return docId;
  }
}
