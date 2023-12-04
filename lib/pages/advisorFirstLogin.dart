import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/pages/home.dart';
import 'package:intl/intl.dart';

class AdvisorFirstLogin extends StatefulWidget {
  const AdvisorFirstLogin({Key? key, required this.userEmail})
      : super(key: key);
  final String userEmail;

  @override
  State<AdvisorFirstLogin> createState() => _AdvisorFirstLoginState();
}

class _AdvisorFirstLoginState extends State<AdvisorFirstLogin> {
  final name = TextEditingController();
  final id = TextEditingController();
  final password = TextEditingController();
  final cfmPassword = TextEditingController();
  final dob = TextEditingController();
  final ic = TextEditingController();
  final contact = TextEditingController();
  final department = TextEditingController();
  String selectedGender = 'M';
  String selectedDepartment = 'Faculty of Computing and Information Technology';
  List<String> departmentItems = [
    'Faculty of Computing and Information Technology',
    'Faculty of Applied Science',
    'Faculty of Accountancy, Finance and Business'
  ];
  String? idErrorText;
  String? icErrorText;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  Future<void> getData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot data = await firestore
        .collection('user')
        .where('email', isEqualTo: widget.userEmail)
        .limit(1)
        .get();

    if (data.docs.isNotEmpty) {
      name.text = data.docs.first['name'];
      id.text = data.docs.first.id;
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> signUp() async {
    final DocumentReference advisorRef =
        FirebaseFirestore.instance.collection('user').doc(id.text);

    final DocumentSnapshot advisorSnapshot = await advisorRef.get();
    idErrorText = null;
    icErrorText = null;
    if (advisorSnapshot.exists) {
      idErrorText = 'Advisor ID ${id.text} already exits';
    } else {
      final QuerySnapshot icQuery = await FirebaseFirestore.instance
          .collection('user')
          .where('ic', isEqualTo: ic.text)
          .get();

      if (icQuery.docs.isNotEmpty) {
        icErrorText = 'IC No. ${ic.text} already exits';
      } else {
        try {
          CollectionReference users =
              FirebaseFirestore.instance.collection('user');

          QuerySnapshot userQuery =
              await users.where('email', isEqualTo: widget.userEmail).get();

          if (userQuery.docs.isNotEmpty) {
            DocumentReference userDocRef = userQuery.docs.first.reference;
            UserCredential userCredential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: widget.userEmail,
              password: 'tarumt12345',
            );

            await userCredential.user!.updatePassword(password.text);

            await userDocRef.set(
              {
                'name': name.text,
                'id': id.text,
                'gender': selectedGender,
                'department': selectedDepartment,
                'dob': Timestamp.fromDate(
                    DateFormat('dd-MM-yyyy').parse(dob.text)),
                'ic': ic.text,
                'contact': contact.text,
              },
              SetOptions(merge: true),
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const Home(),
              ),
            ).then((_) => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Your personal details has been registered.'),
                    width: 225.0,
                    behavior: SnackBarBehavior.floating,
                    duration: Duration(seconds: 3),
                  ),
                ));
          }
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Failed to register your personal details. Please try again later'),
              width: 225.0,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
    }
  }

  void initState() {
    super.initState();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : Container(
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
                        height: 120,
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
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
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
                                  Text(
                                    'Register',
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontSize: 24,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 200,
                                          child: Text(
                                            'Name:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
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
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 200,
                                          child: Text(
                                            'Advisor ID:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomTextField(
                                            controller: id,
                                            hintText: 'Enter your advisor ID',
                                            errorText: idErrorText,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your advisor ID';
                                              } else if (!RegExp(r'^A\d{3}$')
                                                  .hasMatch(value)) {
                                                return 'Invalid advisor ID. Format: A001';
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 200,
                                          child: Text(
                                            'Password:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomTextField(
                                            controller: password,
                                            hintText: 'Enter your password',
                                            hiding: true,
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
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 200,
                                          child: Text(
                                            'Confirm Password:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomTextField(
                                            controller: cfmPassword,
                                            hintText: 'Confirm your password',
                                            hiding: true,
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please confirm your new password';
                                              } else if (value !=
                                                  password.text) {
                                                return 'Password does not match';
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 200,
                                          child: Text(
                                            'Gender:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Radio<String>(
                                                      value: 'M',
                                                      groupValue:
                                                          selectedGender,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedGender =
                                                              value!;
                                                        });
                                                      },
                                                    ),
                                                    const Text('Male'),
                                                  ],
                                                ),
                                              ),
                                              Expanded(
                                                child: Row(
                                                  children: [
                                                    Radio<String>(
                                                      value: 'F',
                                                      groupValue:
                                                          selectedGender,
                                                      onChanged: (value) {
                                                        setState(() {
                                                          selectedGender =
                                                              value!;
                                                        });
                                                      },
                                                    ),
                                                    const Text('Female'),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 200,
                                          child: Text(
                                            'Date of Birth:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 4,
                                          child: CustomTextField(
                                            controller: dob,
                                            hintText:
                                                'Enter your date of birth',
                                            suffixIcon: IconButton(
                                                icon: const Icon(Icons
                                                    .calendar_today_rounded),
                                                onPressed: () async {
                                                  DateTime? pickedDate =
                                                      await showDatePicker(
                                                    context: context,
                                                    initialDate: DateTime(2000),
                                                    firstDate: DateTime(1900),
                                                    lastDate: DateTime(2010),
                                                  );

                                                  if (pickedDate != null) {
                                                    setState(() {
                                                      dob.text = DateFormat(
                                                              'dd-MM-yyyy')
                                                          .format(pickedDate);
                                                    });
                                                  }
                                                }),
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your date of birth.';
                                              }
                                              return null;
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 200,
                                          child: Text(
                                            'IC:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomTextField(
                                            controller: ic,
                                            hintText: 'Enter your IC',
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your IC No. (Format: 123456-12-1234)';
                                              } else if (!RegExp(
                                                      r'^[0-9]{6}-[0-9]{2}-[0-9]{4}$')
                                                  .hasMatch(value)) {
                                                return 'Invalid IC number. Format: 123456-12-1234';
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 200,
                                          child: Text(
                                            'Contact No:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                          child: CustomTextField(
                                            controller: contact,
                                            hintText:
                                                'Enter your contact No. (Format: +60123456789)',
                                            prefixText: '+60',
                                            validator: (value) {
                                              if (value!.isEmpty) {
                                                return 'Please enter your contact No.';
                                              } else if (!RegExp(
                                                      r'^\+60[0-9]{9}$')
                                                  .hasMatch('+60$value')) {
                                                return 'Invalid Malaysian phone number. Format: +60123456789';
                                              }
                                              return null;
                                            },
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Row(
                                      children: [
                                        const SizedBox(
                                          width: 200,
                                          child: Text(
                                            'Programme:',
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        Expanded(
                                            flex: 4,
                                            child: CustomDDL<String>(
                                              onChanged: (String? newValue) {
                                                setState(() {
                                                  selectedDepartment =
                                                      newValue!;
                                                });
                                              },
                                              controller: department,
                                              hintText:
                                                  'Select your department',
                                              value: selectedDepartment,
                                              dropdownItems: departmentItems
                                                  .map((department) {
                                                return DropdownMenuItem<String>(
                                                  value: department,
                                                  child: Text(department,
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                );
                                              }).toList(),
                                            )),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 25),
                                  CustomButton(
                                    text: 'Sign up',
                                    onPressed: () {
                                      if (_formKey.currentState!.validate()) {
                                        signUp();
                                      }
                                    },
                                    width: 400,
                                  ),
                                  const SizedBox(height: 25),
                                ],
                              ),
                            )),
                      ),
                      const SizedBox(height: 25),
                    ],
                  ),
                ))));
  }
}
