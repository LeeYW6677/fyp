import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Home extends StatelessWidget {
  Home({super.key});
  final user = FirebaseAuth.instance.currentUser!;

  void signUserOut(){
    FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: Column(
          children: [
            Text("Hello " + user.email!),

            IconButton(
              onPressed: signUserOut, 
              icon: const Icon(Icons.logout)
              ),
          ],
        )
      ),
    );
  }
}

