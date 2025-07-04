// integration_test/app_test.dart

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

      await tester.pumpUntilFound(find.text('Bem-vindo ao FlowSign'));

      final emailField = find.byKey(const Key('login_email_field'));
      final passwordField = find.byKey(const Key('login_password_field'));
      final loginButton = find.widgetWithText(ElevatedButton, 'Entrar');

      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      await tester.enterText(emailField, 'teste@flows-ign.com');
      await tester.enterText(passwordField, 'testando123');

      await tester.tap(loginButton);

      await tester.pumpAndSettle(const Duration(seconds: 5));

      expect(find.text('Meus Documentos'), findsOneWidget);

      final noDocumentsFinder = find.text('Nenhum documento encontrado.');
      final documentsListFinder = find.byType(ListView);

      expect(
        (tester.any(noDocumentsFinder) || tester.any(documentsListFinder)),
        isTrue,
        reason:
            'A tela de documentos deve exibir a lista ou a mensagem de "nenhum documento"',
      );
    });

    testWidgets(
      'Deve exibir uma mensagem de erro ao tentar fazer login com credenciais inválidas',
      (WidgetTester tester) async {
        app.main();
        await tester.pumpUntilFound(find.text('Bem-vindo ao FlowSign'));

        final emailField = find.byKey(const Key('login_email_field'));
        final passwordField = find.byKey(const Key('login_password_field'));
        final loginButton = find.widgetWithText(ElevatedButton, 'Entrar');

        await tester.enterText(emailField, 'teste@flows-ign.com');
        await tester.enterText(passwordField, 'senha-errada-propositalmente');

        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        expect(find.text('Email ou senha inválidos.'), findsOneWidget);

        expect(find.text('Meus Documentos'), findsNothing);
      },
    );
  });
}

extension PumpUntilFound on WidgetTester {
  Future<void> pumpUntilFound(
    Finder finder, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    bool found = false;
    final end = DateTime.now().add(timeout);

    while (found == false && DateTime.now().isBefore(end)) {
      await pump();
      found = any(finder);
    }
    if (!found) {
      throw 'Widget não encontrado após ${timeout.inSeconds} segundos.';
    }
  }
}
