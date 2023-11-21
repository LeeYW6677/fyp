import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/society.dart';

class RegisterAdvisor extends StatefulWidget {
  const RegisterAdvisor({
    super.key,
  });

  @override
  State<RegisterAdvisor> createState() => _RegisterAdvisorState();
}

class _RegisterAdvisorState extends State<RegisterAdvisor> {
  final name = TextEditingController();
  final id = TextEditingController();
  final email = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? idErrorText;
  String? emailErrorText;

  Future<void> registerAdvisor() async {
    final DocumentReference advisorIdRef =
        FirebaseFirestore.instance.collection('user').doc(id.text);

    final DocumentSnapshot advisorIdSnapshot = await advisorIdRef.get();

    if (advisorIdSnapshot.exists) {
      idErrorText = 'Advisor ID ${id.text} already exits';
    } else {
      idErrorText = null;
      emailErrorText = null;
      try {
        final newAdvisor =
            FirebaseFirestore.instance.collection('user').doc(id.text);
        final authResult =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text,
          password: 'tarumt12345',
        );

        final user = authResult.user;
        if (user != null) {
          newAdvisor.set({
            'name': name.text,
            'email': email.text,
            'id': id.text,
            'ic': '',
          });
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content:
                Text('Advisor with ID ${id.text} registered successfully.'),
            width: 225.0,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      } catch (error) {
        emailErrorText = 'Advisor ID ${id.text} already exits';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      drawer: !Responsive.isDesktop(context)
          ? const CustomDrawer(
              index: 1,
            )
          : null,
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: CustomDrawer(
                  index: 2,
                ),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(children: [
                  const NavigationMenu(
                    buttonTexts: ['Society', 'Register'],
                    destination: [Society(), RegisterAdvisor()],
                  ),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Register Member',
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
                              child: Column(children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Expanded(
                                              flex: 1,
                                              child: Text(
                                                'Name',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: CustomTextField(
                                                controller: name,
                                                hintText: 'Enter your name',
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter your name';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 1, child: SizedBox()),
                                            Expanded(
                                                flex: 4, child: SizedBox()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Expanded(
                                              flex: 1,
                                              child: Text(
                                                'Advisor ID',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: CustomTextField(
                                                controller: id,
                                                errorText: idErrorText,
                                                hintText:
                                                    'Enter your advisor ID',
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter your advisor ID';
                                                  } else if (!RegExp(r'^A\d{3}$').hasMatch(value)) {
                                                    return 'Invalid advisor ID. Format: A001';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 1, child: SizedBox()),
                                            Expanded(
                                                flex: 4, child: SizedBox()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            const Expanded(
                                              flex: 1,
                                              child: Text(
                                                'Email',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: CustomTextField(
                                                controller: email,
                                                hintText: 'Enter your email',
                                                errorText: emailErrorText,
                                                validator: (value) {
                                                  if (value!.isEmpty) {
                                                    return 'Please enter your email';
                                                  } else if (!EmailValidator
                                                      .validate(value)) {
                                                    return 'Invalid email';
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    const Expanded(
                                      child: Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                                flex: 1, child: SizedBox()),
                                            Expanded(
                                                flex: 4, child: SizedBox()),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ]),
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        CustomButton(
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              registerAdvisor();
                                            }
                                          },
                                          text: 'Register',
                                          width: 150,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 1, child: SizedBox()),
                                        Expanded(flex: 4, child: SizedBox()),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
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
