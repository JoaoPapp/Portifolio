import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';
import 'config/initial_bindings.dart';
import 'screens/login_screen.dart';
import 'screens/upload_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp();
  runApp(const FlowSignApp());
}

class FlowSignApp extends StatelessWidget {
  const FlowSignApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FlowSign',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialBinding: InitialBindings(),
      home: const LoginScreen(),
      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/upload', page: () => const UploadScreen()),
      ],
    );
  }
}
