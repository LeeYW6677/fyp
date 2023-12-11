import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:email_validator/email_validator.dart';
import 'package:fyp/pages/advisorFirstLogin.dart';
import 'package:fyp/pages/forgotPassword1.dart';
import 'package:fyp/pages/register.dart';
import 'package:fyp/pages/society.dart';
import 'package:fyp/pages/studentSociety.dart';
import 'package:localstorage/localstorage.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final email = TextEditingController();
  final password = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocalStorage storage = LocalStorage('user');

  String? errorMessage;
  String? role;

  void signUserIn() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      setState(() {
        errorMessage = null;
      });
      QuerySnapshot userQuery = await FirebaseFirestore.instance
          .collection('user')
          .where('email', isEqualTo: email.text)
          .get();
      if (userQuery.docs.isNotEmpty) {
        if (userQuery.docs.first['status']) {
          await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email.text,
            password: password.text,
          );
          if (userQuery.docs.first.id.startsWith('A')) {
            role = 'advisor';
            if (userQuery.docs.first['ic'] == '') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      AdvisorFirstLogin(userEmail: email.text),
                ),
              );
              return;
            }
          } else if (userQuery.docs.first.id.startsWith('B')) {
            role = 'branch head';
          } else {
            role = 'student';
          }

          Navigator.pop(context);
          storage.setItem('name', userQuery.docs.first['name']);
          storage.setItem('id', userQuery.docs.first.id);
          storage.setItem('role', role);
          if (role == 'branch head') {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const Society(),
              ),
              (route) => false,
            );
          } else {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const StudentSociety(),
              ),
              (route) => false,
            );
          }
        } else {
          Navigator.pop(context);
          setState(() {
            errorMessage = 'Your account has been disabled.';
          });
        }
      }else{
        Navigator.pop(context);
        setState(() {
            errorMessage = 'Invalid login credentials';
          });
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      setState(() {
        if (e.code == 'invalid-login-credentials') {
          errorMessage = 'Invalid login credentials';
        } else {
          errorMessage = 'An error has occurred. Please try again later.';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('lib/Images/tarumtbg.png'),
            fit: BoxFit.fitWidth,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
            child: Center(
          child: Column(
            children: [
              const SizedBox(height: 50),
              Image.asset(
                'lib/Images/tarumt.png',
                height: 100,
              ),
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Container(
                  width: 650,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                      color: Colors.grey,
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 25),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'TAR ',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: 'UMT',
                              style: TextStyle(
                                color: Colors.blue,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text: ' Society Management System',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 24,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 25),
                      Text(
                        'Login Page',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 24,
                        ),
                      ),
                      const SizedBox(height: 25),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: CustomTextField(
                                controller: email,
                                hintText: 'Enter your email',
                                hiding: false,
                                icon: const Icon(Icons.email),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your email';
                                  } else if (!EmailValidator.validate(value)) {
                                    return 'Invalid email';
                                  }
                                  return null;
                                },
                                errorText: errorMessage,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 24.0),
                              child: CustomTextField(
                                controller: password,
                                hintText: 'Enter your password',
                                hiding: true,
                                icon: const Icon(Icons.lock),
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 25.0, vertical: 15.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const ForgotPassword();
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                'Forgot Password?',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      CustomButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            signUserIn();
                          }
                        },
                        text: 'Sign in',
                        fontSize: 16,
                        width: 400,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Don\'t have an account?'),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const Register();
                                    },
                                  ),
                                );
                              },
                              child: const Text(
                                'Register now',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 25),
            ],
          ),
        )),
      ),
    );
  }
}
