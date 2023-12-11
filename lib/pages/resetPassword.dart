import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';

class ResetPassword extends StatefulWidget {
  const ResetPassword({super.key});

  @override
  State<ResetPassword> createState() => _ResetPasswordState();
}

class _ResetPasswordState extends State<ResetPassword> {
  final oldpwd = TextEditingController();
  final newpwd = TextEditingController();
  final cfmpwd = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? errorMessage;

  void changePassword() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      setState(() {
        errorMessage = null;
      });
    
      if (user != null) {
        AuthCredential credential = EmailAuthProvider.credential(
          email: user.email!,
          password: oldpwd.text,
        );

        await user.reauthenticateWithCredential(credential);

        await user.updatePassword(newpwd.text);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password updated successfully!'),
            duration: Duration(seconds: 3),
            width: 250.0,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Incorrect Old Password';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      drawer: !Responsive.isDesktop(context) ? const CustomDrawer() : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: CustomDrawer(),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(children: [
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Reset Password',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Divider(
                              thickness: 0.1,
                              color: Colors.black,
                            ),
                            Form(
                              key: _formKey,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 400,
                                      child: CustomTextField(
                                        controller: oldpwd,
                                        hiding: true,
                                        hintText: 'Enter your old password',
                                        errorText: errorMessage,
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please enter your old password';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 400,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          CustomTextField(
                                            controller: newpwd,
                                            hiding: true,
                                            hintText: 'Enter your new password',
                                            onChanged: (value) {
                                              setState(() {});
                                            },
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your new password';
                                              } else if (!RegExp(
                                                      r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{8,}$')
                                                  .hasMatch(value)) {
                                                return 'Incorrect Password Format.';
                                              }
                                              return null;
                                            },
                                          ),
                                          const SizedBox(
                                            height: 15,
                                          ),
                                          PasswordStrengthIndicator(
                                            password: newpwd.text,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: SizedBox(
                                      width: 400,
                                      child: CustomTextField(
                                        controller: cfmpwd,
                                        hiding: true,
                                        hintText: 'Confirm your new password',
                                        validator: (value) {
                                          if (value!.isEmpty) {
                                            return 'Please confirm your new password';
                                          } else if (value != newpwd.text) {
                                            return 'Password does not match';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(250, 15, 0, 0),
                              child: CustomButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    changePassword();
                                  }
                                },
                                text: 'Reset Password',
                                width: 150,
                              ),
                            ),
                          ]))
                ]),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }
}
