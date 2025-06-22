import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:dio/dio.dart' as dio;
import 'package:gql_dio_link/gql_dio_link.dart';
import 'package:http_parser/http_parser.dart'; // Import necessário para MediaType
import 'package:mime/mime.dart'; // Import do novo pacote

class ApiService {
  late GraphQLClient _client;

  ApiService() {
    // Configura o cliente Dio com timeouts mais longos
    final dio.Dio dioClient = dio.Dio(
      dio.BaseOptions(
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
      ),
    );

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

    // >>> INÍCIO DA MUDANÇA: Identificação do tipo de arquivo <<<
    final String filename = documentFile.path.split('/').last;
    // Tenta descobrir o tipo do arquivo (ex: 'application/pdf') pelo nome
    final String? mimeType = lookupMimeType(documentFile.path);

    final dio.MultipartFile multipartFile = await dio.MultipartFile.fromFile(
      documentFile.path,
      filename: filename,
      // Define o ContentType, o que torna o upload mais robusto
      contentType: mimeType != null ? MediaType.parse(mimeType) : null,
    );
    // >>> FIM DA MUDANÇA <<<

    final documentInput = {'name': filename};

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
      throw Exception(
        "Falha na comunicação com o Autentique: ${result.exception.toString()}",
      );
    }

    final String? docId = result.data?['createDocument']?['id'];
    print("Documento enviado com sucesso para o Autentique. ID: $docId");
    return docId;
  }
}
