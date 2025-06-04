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
  const FlowSignApp({Key? key}) : super(key: key);

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

        // Forçamos a LoginScreen como a tela inicial:
        home: const LoginScreen(),

        // Rotas nomeadas para navegação posterior
        routes: {
          '/login': (_) => const LoginScreen(),
          '/upload': (_) => const UploadScreen(),
        },
      ),
    );
  }
}
