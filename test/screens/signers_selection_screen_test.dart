import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portifolio/controllers/document_controller.dart';
import 'package:portifolio/screens/signers_selection_screen.dart';

class MockDocumentController extends GetxController
    with Mock
    implements DocumentController {}

class FakeFile extends Fake implements File {
  @override
  String get path => '/fake/document.pdf';
}

void main() {
  late MockDocumentController mockDocumentController;
  late File fakeFile;

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockDocumentController = MockDocumentController();
    fakeFile = FakeFile();
    when(() => mockDocumentController.isLoading).thenReturn(false.obs);
    Get.put<DocumentController>(mockDocumentController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestableWidget() {
    return GetMaterialApp(home: SignersSelectionScreen(file: fakeFile));
  }

  group('Testes da Tela de Seleção de Signatários', () {
    const String validTestCpf = '111.444.777-35';
    const String unmaskedValidTestCpf = '11144477735';

    testWidgets('Deve exibir a tela inicial sem signatários', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.text('Escolha os Signatários'), findsOneWidget);
      expect(
        find.text(
          'Nenhum signatário adicionado.\nClique no botão + para começar.',
        ),
        findsOneWidget,
      );
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(
        tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
        isNull,
      );
    });

    testWidgets('Deve abrir o diálogo para adicionar um novo signatário', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text('Adicionar Novo Signatário'), findsOneWidget);
      expect(
        find.widgetWithText(TextFormField, 'Nome Completo'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'CPF'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
    });

    testWidgets(
      'Deve adicionar um signatário à lista após preencher o diálogo',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestableWidget());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome Completo'),
          'Signatário Teste',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'CPF'),
          validTestCpf,
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'teste@email.com',
        );

        await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar'));
        await tester.pumpAndSettle();

        expect(find.text('Adicionar Novo Signatário'), findsNothing);
        expect(find.text('Signatário Teste'), findsOneWidget);
        expect(find.text('teste@email.com'), findsOneWidget);
        expect(
          tester.widget<ElevatedButton>(find.byType(ElevatedButton)).onPressed,
          isNotNull,
        );
      },
    );

    testWidgets(
      'Deve chamar createDocumentWorkflow ao clicar em "Enviar para Assinatura"',
      (WidgetTester tester) async {
        when(
          () => mockDocumentController.createDocumentWorkflow(
            documentFile: any(named: 'documentFile'),
            documentName: any(named: 'documentName'),
            signersInfo: any(named: 'signersInfo'),
          ),
        ).thenAnswer((_) async => {});

        await tester.pumpWidget(buildTestableWidget());

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Nome Completo'),
          'Signatário Teste',
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'CPF'),
          validTestCpf,
        );
        await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'),
          'teste@email.com',
        );
        await tester.tap(find.widgetWithText(ElevatedButton, 'Adicionar'));
        await tester.pumpAndSettle();

        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Enviar para Assinatura'),
        );

        verify(
          () => mockDocumentController.createDocumentWorkflow(
            documentFile: fakeFile,
            documentName: 'document.pdf',
            signersInfo: [
              {
                'name': 'Signatário Teste',
                'cpf': unmaskedValidTestCpf,
                'email': 'teste@email.com',
              },
            ],
          ),
        ).called(1);
      },
    );
  });
}
