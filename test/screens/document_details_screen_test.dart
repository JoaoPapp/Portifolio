import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portifolio/controllers/document_controller.dart';
import 'package:portifolio/models/document.dart';
import 'package:portifolio/screens/document_details_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockDocumentController extends GetxController
    with Mock
    implements DocumentController {}

void main() {
  late MockDocumentController mockDocumentController;

  final inProgressDocument = Document(
    id: '1',
    name: 'Documento em Andamento.pdf',
    status: 'em_andamento',
    autentiqueId: 'auth_123',
    signers: [
      {
        'name': 'Signatário 1',
        'email': 'signer1@test.com',
        'status': 'assinado',
      },
      {
        'name': 'Signatário 2',
        'email': 'signer2@test.com',
        'status': 'pendente',
      },
    ],
    createdAt: Timestamp.now(),
  );

  final completedDocument = Document(
    id: '2',
    name: 'Documento Concluído.pdf',
    status: 'concluido',
    autentiqueId: 'auth_456',
    signers: [
      {
        'name': 'Signatário A',
        'email': 'signerA@test.com',
        'status': 'assinado',
      },
      {
        'name': 'Signatário B',
        'email': 'signerB@test.com',
        'status': 'assinado',
      },
    ],
    createdAt: Timestamp.now(),
  );

  setUp(() {
    mockDocumentController = MockDocumentController();
    when(() => mockDocumentController.isLoading).thenReturn(false.obs);
    Get.put<DocumentController>(mockDocumentController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestableWidget(Document document) {
    return GetMaterialApp(home: DocumentDetailsScreen(document: document));
  }

  group('Testes da Tela de Detalhes do Documento', () {
    testWidgets('Deve exibir os detalhes de um documento em andamento', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(inProgressDocument));
      expect(find.text(inProgressDocument.name), findsOneWidget);
      expect(
        find.text('Status Geral: ${inProgressDocument.status}'),
        findsOneWidget,
      );
      expect(find.text('Signatário 1'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      expect(find.text('Signatário 2'), findsOneWidget);
      expect(find.byIcon(Icons.hourglass_empty), findsOneWidget);
      expect(find.text('Baixar Documento Assinado'), findsNothing);
    });

    testWidgets('Deve exibir o botão de download para um documento concluído', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget(completedDocument));
      expect(find.text(completedDocument.name), findsOneWidget);
      expect(find.text('Baixar Documento Assinado'), findsOneWidget);
    });

    testWidgets('Deve chamar downloadSignedDocument ao clicar no botão', (
      WidgetTester tester,
    ) async {
      when(
        () => mockDocumentController.downloadSignedDocument(completedDocument),
      ).thenAnswer((_) async {});

      await tester.pumpWidget(buildTestableWidget(completedDocument));

      await tester.tap(find.text('Baixar Documento Assinado'));

      verify(
        () => mockDocumentController.downloadSignedDocument(completedDocument),
      ).called(1);
    });

    testWidgets(
      'Deve mostrar indicador de loading no botão durante o download',
      (WidgetTester tester) async {
        when(() => mockDocumentController.isLoading).thenReturn(true.obs);

        await tester.pumpWidget(buildTestableWidget(completedDocument));

        expect(find.text('Buscando...'), findsOneWidget);
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );
  });
}
