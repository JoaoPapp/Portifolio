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
      // 1. Inicializa a aplicação
      app.main();

      // --- CORREÇÃO FINAL: Espera Inteligente ---
      // Em vez de uma pausa fixa, esperamos até que um widget específico
      // da tela de login (o título) esteja visível.
      // Isto sincroniza o teste com o estado real da aplicação.
      await tester.pumpUntilFound(find.text('Bem-vindo ao FlowSign'));

      // 2. Agora que temos a certeza que a tela carregou, procuramos os elementos
      final emailField = find.byKey(const Key('login_email_field'));
      final passwordField = find.byKey(const Key('login_password_field'));
      final loginButton = find.widgetWithText(ElevatedButton, 'Entrar');

      // 3. Verificações e interações
      expect(emailField, findsOneWidget);
      expect(passwordField, findsOneWidget);
      expect(loginButton, findsOneWidget);

      // IMPORTANTE: Substitua com os dados de um usuário REAL do seu Firebase
      await tester.enterText(emailField, 'teste@flows-ign.com');
      await tester.enterText(passwordField, 'testando123');

      await tester.tap(loginButton);

      // Espera a navegação e o carregamento dos documentos
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // 4. Verificações na tela de documentos
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
  });
}

// Extensão para criar o nosso comando de espera inteligente.
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
