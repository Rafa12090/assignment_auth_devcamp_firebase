import 'package:assingment_auth_devcamp_firebase/pages/profile_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: signUserOut,
            icon: Icon(Icons.logout),
          ),
          SizedBox(width: 10),
          IconButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
            }, 
            icon: Icon(
              Icons.person,
            ),
          ),
        ],
      ),
      body: Center(child: Text('Logged in as ${user.email}!')),
    );
  }
}