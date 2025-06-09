import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  final user = Rxn<User>();
  var isLoading = false.obs;
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = "Email e senha são obrigatórios.";
      return;
    }
    try {
      isLoading(true);
      errorMessage.value = null;
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      Get.offAllNamed('/upload');
    } on FirebaseAuthException catch (e) {
      print(
        "!!! ERRO DE LOGIN (FirebaseAuthException): Código: ${e.code}, Mensagem: ${e.message}",
      );
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage.value = 'Email ou senha inválidos.';
      } else {
        errorMessage.value = 'Ocorreu um erro ao fazer login.';
      }
    } catch (e) {
      print("!!! ERRO DE LOGIN (Exceção Genérica): ${e.toString()}");
      errorMessage.value = 'Ocorreu um erro inesperado.';
    } finally {
      isLoading(false);
    }
  }

  Future<void> createAccount({
    required String fullName,
    required String cpf,
    required String email,
    required String password,
  }) async {
    print("--- 1. Função createAccount iniciada ---");
    print("Dados recebidos -> Nome: $fullName, CPF: $cpf, Email: $email");

    if (fullName.isEmpty || cpf.isEmpty || email.isEmpty || password.isEmpty) {
      print("!!! ERRO: Validação falhou. Pelo menos um campo está vazio.");
      Get.snackbar(
        "Erro",
        "Todos os campos são obrigatórios.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      print("--- 2. Ativando isLoading e iniciando o bloco try... ---");
      isLoading(true);

      print(
        "--- 3. Chamando 'createUserWithEmailAndPassword' no Firebase... ---",
      );
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      print(
        "--- 4. SUCESSO! Usuário criado na autenticação: ${userCredential.user?.uid} ---",
      );

      if (userCredential.user != null) {
        print("--- 5. Salvando dados adicionais no Firestore... ---");
        await _db.collection("users").doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'cpf': cpf,
          'email': email,
          'createdAt': Timestamp.now(),
        });
        print("--- 6. SUCESSO! Dados salvos no Firestore. ---");
      }

      isLoading(false);
      Get.back();
      Get.snackbar(
        "Sucesso!",
        "Conta criada com sucesso. Por favor, faça o login.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      print("--- 7. Função finalizada com SUCESSO. ---");
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      print(
        "!!! ERRO (FirebaseAuthException): Código: ${e.code} | Mensagem: ${e.message}",
      );
      Get.snackbar(
        "Erro ao criar conta",
        e.message ?? "Ocorreu um erro desconhecido.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading(false);
      print("!!! ERRO (Exceção Genérica): ${e.toString()}");
      Get.snackbar(
        "Erro",
        "Ocorreu um erro inesperado.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
