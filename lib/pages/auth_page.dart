import 'package:assingment_auth_devcamp_firebase/pages/login_or_register_page.dart';
import 'package:assingment_auth_devcamp_firebase/widgets/flutter_devcamp_ui.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred'),
            );
          } else if (snapshot.hasData) {
            return FlutterDevCampUI();
          } else {
            return LoginOrRegisterPage();
          }
        },
      ),
    );
  }
}