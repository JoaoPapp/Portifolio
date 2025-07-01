import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:portifolio/controllers/auth_controller.dart';
import 'package:portifolio/screens/login_screen.dart';

class FakeAuthController extends GetxController implements AuthController {
  @override
  RxBool isLoading = false.obs;

  @override
  RxnString errorMessage = RxnString();

  @override
  Rxn<auth.User> user = Rxn<auth.User>();

  bool signInCalled = false;
  Map<String, String> signInArgs = {};

  @override
  Future<void> signIn({required String email, required String password}) async {
    signInCalled = true;
    signInArgs = {'email': email, 'password': password};
    return Future.value();
  }

  @override
  Future<void> createAccount({
    required String fullName,
    required String cpf,
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

  group('Testes da Tela de Login', () {
    testWidgets(
      'Deve exibir os componentes principais da tela ao ser carregada',
      (WidgetTester tester) async {
        await tester.pumpWidget(const GetMaterialApp(home: LoginScreen()));
        expect(find.text('Bem-vindo ao FlowSign'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Email'), findsOneWidget);
        expect(find.widgetWithText(TextField, 'Senha'), findsOneWidget);
        expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
      },
    );

    testWidgets('Deve chamar o método signIn ao clicar no botão Entrar', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const GetMaterialApp(home: LoginScreen()));

      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Senha');
      final loginButton = find.widgetWithText(ElevatedButton, 'Entrar');

      await tester.enterText(emailField, 'teste@teste.com');
      await tester.enterText(passwordField, '123456');
      await tester.tap(loginButton);

      expect(fakeAuthController.signInCalled, isTrue);
      expect(fakeAuthController.signInArgs['email'], 'teste@teste.com');
      expect(fakeAuthController.signInArgs['password'], '123456');
    });
  });
}
