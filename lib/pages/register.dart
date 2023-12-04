import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/pages/login.dart';
import 'package:intl/intl.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final name = TextEditingController();
  final email = TextEditingController();
  final id = TextEditingController();
  final password = TextEditingController();
  final cfmPassword = TextEditingController();
  final dob = TextEditingController();
  final ic = TextEditingController();
  final contact = TextEditingController();
  final programme = TextEditingController();
  final faculty = TextEditingController();
  String selectedGender = 'M';
  String selectedProgramme = 'Diploma in Computer Science';
  String selectedFaculty = 'Faculty of Computing and Information Technology';
  List<String> programmeItems = [
    'Diploma in Computer Science',
    'Diploma in Information Technology',
    'Diploma in Information Systems',
    'Bachelor of Software Engineering (Hons)',
    'Bachelor of Computer Science (Hons) in Data Science',
    'Bachelor of Information Technology (Hons) in Internet Technology',
  ];
  String? idErrorText;
  String? icErrorText;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> signUp() async {
    final DocumentReference studentRef =
        FirebaseFirestore.instance.collection('user').doc(id.text);

    final DocumentSnapshot studentSnapshot = await studentRef.get();
    idErrorText = null;
    icErrorText = null;
    if (studentSnapshot.exists) {
      idErrorText = 'Student ID ${id.text} already exits';
    } else {
      final QuerySnapshot icQuery = await FirebaseFirestore.instance
          .collection('user')
          .where('ic', isEqualTo: ic.text)
          .get();

      if (icQuery.docs.isNotEmpty) {
        icErrorText = 'IC No. ${ic.text} already exits';
      } else {
        try {
          final newStudent =
              FirebaseFirestore.instance.collection('user').doc(id.text);
          FirebaseApp app = await Firebase.initializeApp(
              name: 'Default', options: Firebase.app().options);
          UserCredential userCredential =
              await FirebaseAuth.instanceFor(app: app)
                  .createUserWithEmailAndPassword(
                      email: email.text, password: password.text);

          await app.delete();
          User? user = userCredential.user;

          if (user != null) {
            newStudent.set({
              'name': name.text,
              'email': email.text,
              'password': password.text,
              'id': id.text,
              'gender': selectedGender,
              'programme': selectedProgramme,
              'faculty': selectedFaculty,
              'dob':
                  Timestamp.fromDate(DateFormat('dd-MM-yyyy').parse(dob.text)),
              'ic': ic.text,
              'contact': contact.text,
            });
          }
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const Login(),
            ),
          );
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Your account has been registered.'),
              width: 225.0,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        } catch (error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                  'Failed to register your account. Please try again later'),
              width: 225.0,
              behavior: SnackBarBehavior.floating,
              duration: Duration(seconds: 3),
            ),
          );
        }
      }
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
                  Container(
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
                            const SizedBox(height: 15),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Student ID:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: id,
                                      hintText: 'Enter your student ID',
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter your student ID';
                                        } else if (!RegExp(
                                                r'^\d{2}[A-Z]{3}\d{5}$')
                                            .hasMatch(value)) {
                                          return 'Invalid student ID. Format: 12ABC12345';
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Email:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                    child: CustomTextField(
                                      controller: email,
                                      hintText: 'Enter your email',
                                      errorText: idErrorText,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter your email';
                                        } else if (!EmailValidator.validate(
                                            value)) {
                                          return 'Invalid email';
                                        }
                                        return null;
                                      },
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
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
                                  )
                                ],
                              ),
                            ),
                            Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12.0, vertical: 8.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                        color: Colors.grey,
                                        width: 1.0,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: PasswordStrengthIndicator(
                                        password: password.text,
                                      ),
                                    ))),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
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
                                        } else if (value != password.text) {
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
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
                                                groupValue: selectedGender,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedGender = value!;
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
                                                groupValue: selectedGender,
                                                onChanged: (value) {
                                                  setState(() {
                                                    selectedGender = value!;
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
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
                                      hintText: 'Enter your date of birth',
                                      suffixIcon: IconButton(
                                          icon: const Icon(
                                              Icons.calendar_today_rounded),
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
                                                dob.text =
                                                    DateFormat('dd-MM-yyyy')
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
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
                                      hintText:
                                          'Enter your IC No. (Format: 123456-12-1234)',
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter your IC No.';
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
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
                                        } else if (!RegExp(r'^\+60[0-9]{9}$')
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
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
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
                                            selectedProgramme = newValue!;
                                          });
                                        },
                                        controller: programme,
                                        hintText: 'Select your programme',
                                        value: selectedProgramme,
                                        dropdownItems: programmeItems
                                            .map<DropdownMenuItem<String>>(
                                                (programme) {
                                          return DropdownMenuItem<String>(
                                            value: programme,
                                            child: Text(programme,
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          );
                                        }).toList(),
                                      )),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 8.0),
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 200,
                                    child: Text(
                                      'Faculty:',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Expanded(
                                      flex: 4,
                                      child: CustomDDL<String>(
                                        controller: faculty,
                                        hintText: 'Select your faculty',
                                        value: selectedFaculty,
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedFaculty = newValue!;
                                            getProgrammesForFaculty(
                                                selectedFaculty);
                                          });
                                        },
                                        dropdownItems: const [
                                          DropdownMenuItem<String>(
                                            value:
                                                'Faculty of Computing and Information Technology',
                                            child: Text(
                                                'Faculty of Computing and Information Technology',
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          DropdownMenuItem<String>(
                                            value: 'Faculty of Applied Science',
                                            child: Text(
                                                'Faculty of Applied Science',
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                          DropdownMenuItem<String>(
                                            value:
                                                'Faculty of Accountancy, Finance and Business',
                                            child: Text(
                                                'Faculty of Accountancy, Finance and Business',
                                                overflow:
                                                    TextOverflow.ellipsis),
                                          ),
                                        ],
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
                  const SizedBox(
                    height: 25,
                  ),
                ],
              ),
            ))));
  }

  void getProgrammesForFaculty(String faculty) {
    switch (faculty) {
      case 'Faculty of Computing and Information Technology':
        selectedProgramme = 'Diploma in Computer Science';
        programmeItems = [
          'Diploma in Computer Science',
          'Diploma in Information Technology',
          'Diploma in Information Systems',
          'Bachelor of Software Engineering (Hons)',
          'Bachelor of Computer Science (Hons) in Data Science',
          'Bachelor of Information Technology (Hons) in Internet Technology',
        ];
      case 'Faculty of Applied Science':
        selectedProgramme = 'Diploma in Science';
        programmeItems = [
          'Diploma in Science',
          'Diploma in Sports and Exercise Science',
          'Diploma in Food Science',
          'Bachelor of Science (Hons) in Food Science',
          'Bachelor of Science (Hons) in Analytical Chemistry',
          'Bachelor of Science (Hons) in Nutrition',
        ];
      case 'Faculty of Accountancy, Finance and Business':
        selectedProgramme = 'Diploma in Accounting';
        programmeItems = [
          'Diploma in Accounting',
          'Diploma in Banking and Finance',
          'Diploma in E-Marketing',
          'Bachelor of Accounting (Hons)',
          'Bachelor of Banking and Finance (Hons)',
          'Bachelor of Business (Hons) in Entrepreneurship'
        ];
      default:
        break;
    }
  }
}
