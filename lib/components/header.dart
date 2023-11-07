import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/reponsive.dart';

class Header extends StatelessWidget implements PreferredSizeWidget{
  const Header({Key? key}) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(50);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.grey[900],
      title: Row(
        children: [
          if (Responsive.isDesktop(context))
            Image.asset('lib/Images/logo.png', width: 75, height: 75),
          const SizedBox(width: 8),
          const Text('Society Management System'),
        ],
      ),
      actions: [
        if (!Responsive.isMobile(context))
          const Center(
            child: Text('Welcome,\nLee Yin Wei', textAlign: TextAlign.center),
          ),
        const SizedBox(width: 15),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.person),
        ),
        const SizedBox(width: 15),
        IconButton(
          onPressed: () {
            FirebaseAuth.instance.signOut();
          },
          icon: const Icon(Icons.logout),
        ),
        const SizedBox(width: 30),
      ],
    );
  }
}