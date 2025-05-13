import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'providers/document_provider.dart';
import 'screens/upload_screen.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FlowSignApp());
}

class FlowSignApp extends StatelessWidget {
  const FlowSignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DocumentProvider(ApiService())),
        // aqui você pode registrar outros providers
      ],
      child: MaterialApp(
        title: 'FlowSign',
        theme: ThemeData(primarySwatch: Colors.blue),

        // Definindo UploadScreen como tela inicial:
        initialRoute: '/upload',

        routes: {
          '/upload': (ctx) => const UploadScreen(),
          '/login': (ctx) => const LoginScreen(),
        },
      ),
    );
  }
}
