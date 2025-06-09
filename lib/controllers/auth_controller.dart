import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  final user = Rxn<User>();
  var isLoading = false.obs;
  // Nova variável reativa para mensagens de erro de login
  var errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    user.bindStream(_auth.authStateChanges());
  }

  // >>>>>>>>>>>>> INÍCIO DA NOVA LÓGICA DE LOGIN <<<<<<<<<<<<<<<<<
  Future<void> signIn({required String email, required String password}) async {
    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = "Email e senha são obrigatórios.";
      return;
    }

    try {
      isLoading(true);
      errorMessage.value = null; // Limpa erros antigos

      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Se o login for bem-sucedido, o `user.bindStream` no onInit
      // irá detectar a mudança e o AuthWrapper (se estiver em uso)
      // nos levará para a tela principal. Ou podemos forçar a navegação:
      Get.offAllNamed('/upload'); // Navega e limpa as telas anteriores

    } on FirebaseAuthException catch (e) {
      // Converte os códigos de erro do Firebase para mensagens amigáveis
      if (e.code == 'user-not-found' || e.code == 'wrong-password' || e.code == 'invalid-credential') {
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
  // >>>>>>>>>>>>> FIM DA NOVA LÓGICA DE LOGIN <<<<<<<<<<<<<<<<<

  // ... (resto do seu AuthController, como createAccount e signOut)
  Future<void> createAccount({
    required String fullName,
    required String cpf,
    required String email,
    required String password,
  }) async {
    // ...
  }
  
  Future<void> signOut() async {
    await _auth.signOut();
  }
}