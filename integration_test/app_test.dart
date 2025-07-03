import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:portifolio/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Teste de Integração do Fluxo Principal', () {
    testWidgets('Deve fazer login e exibir a tela de documentos', (
      WidgetTester tester,
    ) async {
      app.main();
      await tester.pumpAndSettle();

      final emailField = find.widgetWithText(TextField, 'Email');
      final passwordField = find.widgetWithText(TextField, 'Senha');
      final loginButton = find.widgetWithText(ElevatedButton, 'Entrar');

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      await tester.enterText(emailField, 'usuario.teste@email.com');
      await tester.enterText(passwordField, 'senha123456');

      await tester.tap(loginButton);

      await tester.pumpAndSettle(const Duration(seconds: 10));

      expect(find.text('Meus Documentos'), findsOneWidget);

      final noDocumentsFinder = find.text('Nenhum documento encontrado.');
      final documentsListFinder = find.byType(ListView);

      expect(
        (tester.any(noDocumentsFinder) || tester.any(documentsListFinder)),
        isTrue,
        reason:
            'A tela de documentos deve exibir a lista ou a mensagem de "nenhum documento"',
      );

      final logoutButton = find.byIcon(Icons.logout);
      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();

      expect(find.text('Bem-vindo ao FlowSign'), findsOneWidget);
    });
  });
}
