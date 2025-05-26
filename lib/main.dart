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

  // 1️⃣ Carrega as variáveis de ambiente de .env
  await dotenv.load(fileName: '.env');

  // 2️⃣ Inicia o Firebase
  await Firebase.initializeApp();

  runApp(const FlowSignApp());
}

class FlowSignApp extends StatelessWidget {
  const FlowSignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // provider do seu workflow de documentos
        ChangeNotifierProvider(create: (_) => DocumentProvider(ApiService())),
        // provider que escuta o estado de autenticação
        StreamProvider<User?>.value(
          initialData: null,
          value: FirebaseAuth.instance.authStateChanges(),
        ),
      ],
      child: MaterialApp(
        title: 'FlowSign',
        theme: ThemeData(primarySwatch: Colors.blue),
        // nada de initialRoute nem home fixo: deixamos o AuthGate decidir
        home: const AuthGate(),
        routes: {
          '/login': (_) => const LoginScreen(),
          '/upload': (_) => const UploadScreen(),
        },
      ),
    );
  }
}

/// Se o usuário estiver autenticado (FirebaseAuth), segue para UploadScreen;
/// caso contrário, mostra a LoginScreen.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<User?>();
    if (user == null) {
      return const LoginScreen();
    } else {
      return const UploadScreen();
    }
  }
}
