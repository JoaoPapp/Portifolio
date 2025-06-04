import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/api_service.dart';
import 'providers/document_provider.dart';
import 'screens/upload_screen.dart';
import 'screens/login_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Carrega as variáveis de ambiente do arquivo .env
  await dotenv.load(fileName: '.env');

  // 2) Inicializa o Firebase
  await Firebase.initializeApp();

  runApp(const FlowSignApp());
}

class FlowSignApp extends StatelessWidget {
  const FlowSignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider que gerencia o fluxo de documentos
        ChangeNotifierProvider(create: (_) => DocumentProvider(ApiService())),
        // StreamProvider que escuta mudanças de autenticação no FirebaseAuth
        StreamProvider<User?>.value(
          initialData: null,
          value: FirebaseAuth.instance.authStateChanges(),
        ),
      ],
      child: MaterialApp(
        title: 'FlowSign',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const LoginScreen(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/upload': (_) => const UploadScreen(),
        },
      ),
    );
  }
}

/// Essa classe verifica se há um usuário logado.
/// Se houver, exibe a UploadScreen; caso contrário, mostra a LoginScreen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    // 'user' virá do StreamProvider<User?> que escuta FirebaseAuth.instance.authStateChanges()
    final user = context.watch<User?>();

    if (user == null) {
      // Não está logado → exibe tela de login
      return const LoginScreen();
    } else {
      // Já logado → exibe tela de upload
      return const UploadScreen();
    }
  }
}
