import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <-- LINHA CORRIGIDA
import 'firebase_options.dart'; // Verifique a nota abaixo sobre este arquivo

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: const Text('Teste de Login Firebase')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Use um email e senha DE TESTE, NUNCA USADOS ANTES
                      final email =
                          "test-${DateTime.now().millisecondsSinceEpoch}@test.com";
                      final password = "password123";
                      print("--- Tentando criar usuário: $email ---");
                      final cred = await FirebaseAuth.instance
                          .createUserWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                      print("✅ SUCESSO ao criar usuário: ${cred.user?.uid}");
                    } catch (e) {
                      print("❌ ERRO ao criar usuário: ${e.toString()}");
                    }
                  },
                  child: const Text('Criar Novo Usuário de Teste'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    try {
                      // Use o email e senha do seu usuário principal
                      final email = "joao_pp02@hotmail.com";
                      final password =
                          "sua_senha_aqui"; // <<-- COLOQUE SUA SENHA AQUI
                      print("--- Tentando fazer login como: $email ---");
                      final cred = await FirebaseAuth.instance
                          .signInWithEmailAndPassword(
                            email: email,
                            password: password,
                          );
                      print("✅ SUCESSO ao fazer login: ${cred.user?.uid}");
                    } catch (e) {
                      print("❌ ERRO ao fazer login: ${e.toString()}");
                    }
                  },
                  child: const Text('Tentar Fazer Login'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
