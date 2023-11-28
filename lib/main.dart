import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/pages/home.dart';
import 'package:fyp/pages/login.dart';
import 'package:fyp/functions/firebase_options.dart';
import 'package:fyp/pages/schedule.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.web,
  );
  runApp(const SocietyManagementSystem());
}

class SocietyManagementSystem extends StatefulWidget {
  const SocietyManagementSystem({Key? key}) : super(key: key);

  @override
  _SocietyManagementSystemState createState() => _SocietyManagementSystemState();
}

class _SocietyManagementSystemState extends State<SocietyManagementSystem> {
  User? user;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      scrollBehavior: CustomScrollBehavior(),
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light().copyWith(
        scrollbarTheme: const ScrollbarThemeData().copyWith(
          thumbColor: MaterialStateProperty.all(Colors.grey[500]),
          thumbVisibility: MaterialStateProperty.all<bool>(true),
        ),
      ),
      home: user != null ? Schedule(selectedEvent: 'E001',) : const Login(),
    );
  }
}

class CustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
      };
}
