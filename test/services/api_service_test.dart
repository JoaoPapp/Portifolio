import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:portifolio/services/api_service.dart';

class MockGraphQLClient extends Mock implements GraphQLClient {}

class MockHttpClient extends Mock implements http.Client {}

class FakeQueryOptions extends Fake implements QueryOptions {}

class FakeBaseRequest extends Fake implements http.BaseRequest {}

void main() {
  late ApiService apiService;
  late MockGraphQLClient mockGraphQLClient;
  late MockHttpClient mockHttpClient;
  late File fakeFile;

  setUpAll(() {
    dotenv.testLoad(fileInput: 'AUTENTIQUE_API_KEY=fake_token');
    registerFallbackValue(FakeQueryOptions());
    registerFallbackValue(FakeBaseRequest());

    fakeFile = File('fake.pdf');
  });

  setUp(() {
    mockGraphQLClient = MockGraphQLClient();
    mockHttpClient = MockHttpClient();
    fakeFile.createSync();
  });

  tearDown(() {
    if (fakeFile.existsSync()) {
      fakeFile.deleteSync();
    }
  });

  group('Testes de Unidade do ApiService', () {
    group('getSignedDocumentUrl (GraphQL Query)', () {
      test('deve retornar a URL quando a query for bem-sucedida', () async {
        final successfulResult = QueryResult(
          source: QueryResultSource.network,
          data: {
            'document': {
              'files': {'signed': 'http://example.com/success.pdf'},
            },
          },
          options: QueryOptions(document: gql('query {}')),
        );

        when(
          () => mockGraphQLClient.query(any()),
        ).thenAnswer((_) async => successfulResult);

        apiService = ApiService(clientForTest: mockGraphQLClient);
        final url = await apiService.getSignedDocumentUrl('any_id');

        expect(url, 'http://example.com/success.pdf');
      });

      test('deve lançar uma exceção quando a query falhar', () async {
        final failedResult = QueryResult(
          source: QueryResultSource.network,
          exception: OperationException(
            graphqlErrors: [GraphQLError(message: 'Erro!')],
          ),
          options: QueryOptions(document: gql('query {}')),
        );
        when(
          () => mockGraphQLClient.query(any()),
        ).thenAnswer((_) async => failedResult);

        apiService = ApiService(clientForTest: mockGraphQLClient);
        expect(
          () => apiService.getSignedDocumentUrl('any_id'),
          throwsA(isA<OperationException>()),
        );
      });
    });

    group('sendDocumentToAutentique (HTTP Upload)', () {
      test(
        'deve retornar o ID do documento quando o upload for bem-sucedido',
        () async {
          final successfulResponse = http.StreamedResponse(
            Stream.value(
              utf8.encode(
                json.encode({
                  'data': {
                    'createDocument': {'id': 'doc_id_123'},
                  },
                }),
              ),
            ),
            200,
          );

          when(
            () => mockHttpClient.send(any()),
          ).thenAnswer((_) async => successfulResponse);

          apiService = ApiService(httpClientForTest: mockHttpClient);
          final docId = await apiService.sendDocumentToAutentique(
            documentFile: fakeFile,
            signers: [],
          );

          expect(docId, 'doc_id_123');
        },
      );

      test(
        'deve lançar uma exceção quando o upload falhar (status code != 200)',
        () async {
          final failedResponse = http.StreamedResponse(Stream.value([]), 500);
          when(
            () => mockHttpClient.send(any()),
          ).thenAnswer((_) async => failedResponse);

          apiService = ApiService(httpClientForTest: mockHttpClient);
          expect(
            () => apiService.sendDocumentToAutentique(
              documentFile: fakeFile,
              signers: [],
            ),
            throwsA(isA<Exception>()),
          );
        },
      );
    });
  });
}
