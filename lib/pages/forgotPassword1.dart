import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/pages/forgotPassowrd2.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  final email = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? errorMessage;
  String? success = '';

  @override
  void dispose() {
    email.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(
            email: email.text.trim(),
          )
          .then((value) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const ForgotPassword2();
                  },
                ),
              ));
    } on FirebaseAuthException {
      setState(() {
        errorMessage = 'An error has occurred. Please try again later.';
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.arrow_back)),
                      ],
                    ),
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
                      'Forgot Password',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 25),
                    const Text(
                      'Enter your email and we will send you a password reset link',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 15),
                    Form(
                      key: _formKey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          children: [
                            CustomTextField(
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
                            const SizedBox(height: 25),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    CustomButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          passwordReset();
                        }
                      },
                      text: 'Submit',
                      fontSize: 16,
                      width: 400,
                    ),
                    const SizedBox(height: 25),
                  ],
                ),
              ),
            )
          ],
        )),
      ),
    ));
  }
}
