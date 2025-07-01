import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:portifolio/controllers/auth_controller.dart';
import 'package:portifolio/screens/create_account_screen.dart';

class FakeAuthController extends GetxController implements AuthController {
  @override
  RxBool isLoading = false.obs;

  @override
  RxnString errorMessage = RxnString();

  @override
  final Rxn<auth.User> user = Rxn<auth.User>();

  bool createAccountCalled = false;
  Map<String, String> createAccountArgs = {};

  @override
  Future<void> createAccount({
    required String fullName,
    required String cpf,
    required String email,
    required String password,
  }) async {
    createAccountCalled = true;
    createAccountArgs = {
      'fullName': fullName,
      'cpf': cpf,
      'email': email,
      'password': password,
    };
    return Future.value();
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signOut() async {}
}

void main() {
  late FakeAuthController fakeAuthController;

  setUp(() {
    fakeAuthController = FakeAuthController();
    Get.put<AuthController>(fakeAuthController);
  });

  tearDown(() {
    Get.reset();
  });

  group('Testes da Tela de Criação de Conta', () {
    testWidgets('Deve exibir todos os campos de texto e o botão', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const GetMaterialApp(home: CreateAccountScreen()),
      );

      expect(
        find.widgetWithText(TextFormField, 'Nome Completo'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextFormField, 'CPF'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Email'), findsOneWidget);
      expect(find.widgetWithText(TextFormField, 'Senha'), findsOneWidget);

      expect(
        find.widgetWithText(ElevatedButton, 'Criar Conta'),
        findsOneWidget,
      );
    });

    testWidgets(
      'Deve chamar o método createAccount ao preencher e clicar no botão',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const GetMaterialApp(home: CreateAccountScreen()),
        );

        final nameField = find.widgetWithText(TextFormField, 'Nome Completo');
        final cpfField = find.widgetWithText(TextFormField, 'CPF');
        final emailField = find.widgetWithText(TextFormField, 'Email');
        final passwordField = find.widgetWithText(TextFormField, 'Senha');
        final createButton = find.widgetWithText(ElevatedButton, 'Criar Conta');

        await tester.enterText(nameField, 'Usuario de Teste');
        await tester.enterText(cpfField, '12345678900');
        await tester.enterText(emailField, 'teste@email.com');
        await tester.enterText(passwordField, 'senha123');

        await tester.tap(createButton);

        expect(fakeAuthController.createAccountCalled, isTrue);
        expect(
          fakeAuthController.createAccountArgs['fullName'],
          'Usuario de Teste',
        );
        expect(fakeAuthController.createAccountArgs['cpf'], '12345678900');
        expect(
          fakeAuthController.createAccountArgs['email'],
          'teste@email.com',
        );
        expect(fakeAuthController.createAccountArgs['password'], 'senha123');
      },
    );
  });
}
