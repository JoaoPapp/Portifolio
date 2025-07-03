import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mocktail/mocktail.dart';
import 'package:portifolio/controllers/auth_controller.dart';
import 'package:portifolio/controllers/document_controller.dart';
import 'package:portifolio/models/document.dart';
import 'package:portifolio/screens/document_details_screen.dart';
import 'package:portifolio/screens/upload_screen.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class FakeRoute extends Fake implements Route<dynamic> {}

class FakeAuthController extends GetxController implements AuthController {
  @override
  RxBool isLoading = false.obs;
  @override
  RxnString errorMessage = RxnString();
  @override
  final Rxn<auth.User> user = Rxn<auth.User>();
  @override
  Future<void> createAccount({
    required String fullName,
    required String cpf,
    required String email,
    required String password,
  }) async {}
  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}
  @override
  Future<void> signOut() async {}
}

class FakeDocumentController extends GetxController
    implements DocumentController {
  @override
  var documents = <Document>[].obs;
  @override
  var isLoading = false.obs;
  @override
  var errorMessage = RxnString();
  @override
  get api => throw UnimplementedError();
  @override
  void listenToDocuments(String userId) {}
  @override
  Future<void> createDocumentWorkflow({
    required dynamic documentFile,
    required List<Map<String, String>> signersInfo,
    required String documentName,
  }) async {}
  @override
  Future<void> downloadSignedDocument(Document document) async {}
  @override
  Future<void> markDocumentAsSignedBy(
    Document document,
    String signerEmail,
  ) async {}
}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeRoute());
  });

  late FakeAuthController fakeAuthController;
  late FakeDocumentController fakeDocumentController;
  late MockNavigatorObserver mockObserver;

  final testDocument = Document(
    id: '1',
    name: 'Contrato de Teste.pdf',
    status: 'em_andamento',
    signers: [],
    createdAt: Timestamp.now(),
  );

  setUp(() {
    fakeAuthController = FakeAuthController();
    fakeDocumentController = FakeDocumentController();
    mockObserver = MockNavigatorObserver();

    Get.put<AuthController>(fakeAuthController);
    Get.put<DocumentController>(fakeDocumentController);
  });

  tearDown(() {
    Get.reset();
  });

  Widget buildTestableWidget() {
    return GetMaterialApp(
      home: const UploadScreen(),
      navigatorObservers: [mockObserver],
      getPages: [
        GetPage(
          name: '/details',
          page: () => DocumentDetailsScreen(document: testDocument),
        ),
      ],
    );
  }

  group('Testes da Tela de Upload', () {
    testWidgets(
      'Deve exibir o indicador de carregamento quando isLoading é true',
      (WidgetTester tester) async {
        fakeDocumentController.isLoading.value = true;
        await tester.pumpWidget(buildTestableWidget());
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      },
    );

    testWidgets(
      'Deve exibir a mensagem de "nenhum documento" quando a lista está vazia',
      (WidgetTester tester) async {
        fakeDocumentController.documents.value = [];
        fakeDocumentController.isLoading.value = false;
        await tester.pumpWidget(buildTestableWidget());
        expect(find.text('Nenhum documento encontrado.'), findsOneWidget);
        expect(find.byIcon(Icons.folder_off_outlined), findsOneWidget);
      },
    );

    testWidgets('Deve exibir a lista de documentos quando ela não está vazia', (
      WidgetTester tester,
    ) async {
      fakeDocumentController.documents.value = [testDocument];
      fakeDocumentController.isLoading.value = false;
      await tester.pumpWidget(buildTestableWidget());
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text(testDocument.name), findsOneWidget);
      expect(
        find.text("Status: ${testDocument.status ?? 'Não definido'}"),
        findsOneWidget,
      );
    });

    testWidgets(
      'Deve navegar para DocumentDetailsScreen ao tocar em um documento',
      (WidgetTester tester) async {
        fakeDocumentController.documents.value = [testDocument];
        await tester.pumpWidget(buildTestableWidget());

        await tester.tap(find.byType(ListTile));
        await tester.pumpAndSettle();

        verify(() => mockObserver.didPush(any(), any()));
      },
    );

    testWidgets('Deve ter o botão de "Novo Documento" (FAB)', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(buildTestableWidget());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Novo Documento'), findsOneWidget);
    });
  });
}
