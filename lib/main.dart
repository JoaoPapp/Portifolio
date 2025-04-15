import 'package:flutter/material.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(const FlowSignApp());
}

class FlowSignApp extends StatelessWidget {
  const FlowSignApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowSign',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const LoginScreen(),
    );
  }
}
