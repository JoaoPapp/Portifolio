import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:portifolio/screens/create_account_screen.dart';
import '../controllers/auth_controller.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final AuthController authController = Get.find();

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.lock_open_rounded, size: 80, color: Colors.blue),
              const SizedBox(height: 16),
              Text(
                'Bem-vindo ao FlowSign',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // --- CAMPO DE EMAIL COM A KEY ---
              TextField(
                key: const Key('login_email_field'), // A ETIQUETA ESTÁ AQUI
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),

              // --- CAMPO DE SENHA COM A KEY ---
              TextField(
                key: const Key('login_password_field'), // A ETIQUETA ESTÁ AQUI
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Senha',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              Obx(() {
                if (authController.errorMessage.value != null) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: Text(
                      authController.errorMessage.value!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                return const SizedBox.shrink();
              }),

              Obx(() {
                return ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed:
                      authController.isLoading.value
                          ? null
                          : () {
                            authController.signIn(
                              email: emailController.text.trim(),
                              password: passwordController.text,
                            );
                          },
                  child:
                      authController.isLoading.value
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('Entrar'),
                );
              }),
              const SizedBox(height: 16),

              TextButton(
                onPressed: () {
                  Get.to(() => const CreateAccountScreen());
                },
                child: const Text('Criar conta'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
