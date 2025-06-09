import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance; // Agora será usado

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
      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        errorMessage.value = 'Email ou senha inválidos.';
      } else {
        errorMessage.value = 'Ocorreu um erro ao fazer login.';
      }
    } catch (e) {
      errorMessage.value = 'Ocorreu um erro inesperado.';
    } finally {
      isLoading(false);
    }
  }

  // >>>>>>>>>>>>> INÍCIO DA FUNÇÃO CORRIGIDA <<<<<<<<<<<<<<<<<
  Future<void> createAccount({
    required String fullName,
    required String cpf,
    required String email,
    required String password,
  }) async {
    // Validação inicial
    if (fullName.isEmpty || cpf.isEmpty || email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Erro",
        "Todos os campos são obrigatórios.",
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      isLoading(true); // Ativa o feedback de loading

      // 1. Cria o usuário no Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);

      // 2. Salva os dados adicionais no Cloud Firestore
      if (userCredential.user != null) {
        // Usa a variável _db que antes não estava sendo utilizada
        await _db.collection("users").doc(userCredential.user!.uid).set({
          'fullName': fullName,
          'cpf': cpf,
          'email': email,
          'createdAt': Timestamp.now(),
        });
      }

      isLoading(false); // Desativa o loading
      Get.back(); // Volta para a tela de login
      Get.snackbar(
        "Sucesso!",
        "Conta criada com sucesso. Por favor, faça o login.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } on FirebaseAuthException catch (e) {
      isLoading(false);
      // Trata erros específicos do Firebase
      Get.snackbar(
        "Erro ao criar conta",
        e.message ?? "Ocorreu um erro desconhecido.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } catch (e) {
      isLoading(false);
      Get.snackbar(
        "Erro",
        "Ocorreu um erro inesperado.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  // >>>>>>>>>>>>> FIM DA FUNÇÃO CORRIGIDA <<<<<<<<<<<<<<<<<

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
