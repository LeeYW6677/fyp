import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/customTextField.dart';

class LoginPage extends StatefulWidget {
  final Function()? register;
  const LoginPage({super.key, required this.register});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final email = TextEditingController();
  final password = TextEditingController();

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
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email.text,
        password: password.text,
      );
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Dismiss the loading dialog
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Center(
            child: Text(message),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('lib/Images/tarumtbg.png'), // Adjust the image path
          fit: BoxFit.fitWidth, // You can choose how the image fits the screen
          alignment: Alignment.bottomCenter,
        ),
      ),
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
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0
              ),
            child: Container(
              height: 450,
              width: 650,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(
                  color: Colors.grey, // Border color
                  width: 1.0, // Border width
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
                  CustomTextField(
                    controller: email,
                    hintText: 'Enter your email',
                    hiding: false,
                    showIcon: true,
                    icon: const Icon(Icons.email),
                  ),
                  const SizedBox(height: 25),
                  CustomTextField(
                    controller: password,
                    hintText: 'Enter your password',
                    hiding: true,
                    showIcon: true,
                    icon: const Icon(Icons.lock),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: null,
                          child: Text(
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
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(25),
                      minimumSize: const Size(400, 0),
                    ),
                    child: const Text(
                      'Sign in',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Not a member?'),
                      const SizedBox(
                        width: 4,
                      ),
                      TextButton(
                        onPressed: (){
                          Navigator.pushNamed(context, '/newPage');
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
                  )
                ],
              ),
            ),
          )
        ],
      )),
    ));
  }
}
