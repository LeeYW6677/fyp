import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/resetPassword.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final name = TextEditingController();
  final id = TextEditingController();
  final email = TextEditingController();
  final gender = TextEditingController();
  final dob = TextEditingController();
  final ic = TextEditingController();
  final contact = TextEditingController();
  final programme = TextEditingController();
  final faculty = TextEditingController();
  String? selectedGender;
  String selectedProgramme = 'Computer Science';
  String selectedFaculty = 'FOCS';
  List<String> programmeItems = [];
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();
  final GlobalKey<FormState> _formKey2 = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future<void> getData() async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot data = await firestore
        .collection('user')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (data.docs.isNotEmpty) {
      name.text = data.docs.first['name'];
      id.text = data.docs.first.id;
      email.text = data.docs.first['email'];
      String initialGender = data.docs.first['gender'];
      setState(() {
        selectedGender = initialGender;
      });
      selectedFaculty = data.docs.first['faculty'];
      getProgrammesForFaculty(selectedFaculty);
      selectedProgramme = data.docs.first['programme'];
      Timestamp timestamp = data.docs.first['dob'];
      String date = DateFormat('dd-MM-yyyy').format(timestamp.toDate());
      dob.text = date;
      ic.text = data.docs.first['ic'];
      contact.text = data.docs.first['contact'];
    }
  }

  Future<void> updateProfile(BuildContext context) async {
    User? user = FirebaseAuth.instance.currentUser;
    String? userEmail = user?.email;

    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot data = await firestore
        .collection('user')
        .where('email', isEqualTo: userEmail)
        .limit(1)
        .get();

    if (data.docs.isNotEmpty) {
      DocumentReference userDoc =
          firestore.collection('user').doc(data.docs.first.id);

      try {
        await userDoc.update({
          'name': name.text,
          'gender': selectedGender,
          'programme': selectedProgramme,
          'faculty': selectedFaculty,
          'dob': Timestamp.fromDate(DateFormat('dd-MM-yyyy').parse(dob.text)),
          'ic': ic.text,
          'contact': contact.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            width: 225.0,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to update profile. Please try again.'),
            width: 225.0,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
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
                child: Column(
                  children: [
                    const NavigationMenu(
                      buttonTexts: ['Profile'],
                      destination: [Profile()],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const Divider(
                            thickness: 0.1,
                            color: Colors.black,
                          ),
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              color: Colors.blue,
                              fontSize: 20,
                            ),
                          ),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              if (Responsive.isDesktop(context)) {
                                return Form(
                                  key: _formKey1,
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: CustomTextField(
                                                      controller: name,
                                                      hintText:
                                                          'Enter your name',
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
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Student ID',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: CustomTextField(
                                                      controller: id,
                                                      hintText:
                                                          'Enter your student ID',
                                                      enabled: false,
                                                    ),
                                                  ),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
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
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: CustomTextField(
                                                      controller: email,
                                                      hintText:
                                                          'Enter your email',
                                                      enabled: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Gender',
                                                      style: TextStyle(
                                                          fontSize: 16),
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
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    selectedGender =
                                                                        value!;
                                                                  });
                                                                },
                                                              ),
                                                              const Text(
                                                                  'Male'),
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
                                                                onChanged:
                                                                    (value) {
                                                                  setState(() {
                                                                    selectedGender =
                                                                        value!;
                                                                  });
                                                                },
                                                              ),
                                                              const Text(
                                                                  'Female'),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Date of Birth',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: CustomTextField(
                                                      controller: dob,
                                                      hintText:
                                                          'Enter your date of birth',
                                                      suffixIcon: const Icon(Icons
                                                          .calendar_today_rounded),
                                                      onTap: () async {
                                                        DateTime? pickedDate =
                                                            await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              DateTime(2000),
                                                          firstDate:
                                                              DateTime(1900),
                                                          lastDate:
                                                              DateTime(2010),
                                                        );

                                                        if (pickedDate !=
                                                            null) {
                                                          setState(() {
                                                            dob.text = DateFormat(
                                                                    'dd-MM-yyyy')
                                                                .format(
                                                                    pickedDate);
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'IC No.',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
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
                                                  ),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Contact No.',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
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
                                                            .hasMatch(
                                                                '+60$value')) {
                                                          return 'Invalid Malaysian phone number. Format: +60123456789';
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
                                            child: SizedBox(),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 50),
                                      const Row(
                                        children: [
                                          Text(
                                            'Academic Information',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Programme',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 4,
                                                      child: CustomDDL<String>(
                                                        controller: programme,
                                                        hintText:
                                                            'Select your programme',
                                                        value:
                                                            selectedProgramme,
                                                        dropdownItems:
                                                            programmeItems.map(
                                                                (programme) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: programme,
                                                            child:
                                                                Text(programme),
                                                          );
                                                        }).toList(),
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Faculty',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 4,
                                                      child: CustomDDL<String>(
                                                        controller: faculty,
                                                        hintText:
                                                            'Select your faculty',
                                                        value: selectedFaculty,
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            selectedFaculty =
                                                                newValue!;
                                                            getProgrammesForFaculty(
                                                                selectedFaculty);
                                                          });
                                                        },
                                                        dropdownItems: const [
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: 'FOCS',
                                                            child: Text('FOCS'),
                                                          ),
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: 'FOAS',
                                                            child: Text('FOAS'),
                                                          ),
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: 'FAFB',
                                                            child: Text('FAFB'),
                                                          ),
                                                        ],
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                );
                              } else {
                                return Form(
                                  key: _formKey2,
                                  child: Column(
                                    children: [
                                      Row(children: [
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
                                                    style:
                                                        TextStyle(fontSize: 16),
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
                                      ]),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Student ID',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: CustomTextField(
                                                      controller: id,
                                                      hintText:
                                                          'Enter your student ID',
                                                      enabled: false,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(children: [
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
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                                Expanded(
                                                  flex: 4,
                                                  child: CustomTextField(
                                                    controller: email,
                                                    hintText:
                                                        'Enter your email',
                                                    enabled: false,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                      Row(children: [
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
                                                    'Gender',
                                                    style:
                                                        TextStyle(fontSize: 16),
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
                                                              onChanged:
                                                                  (value) {
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
                                                              onChanged:
                                                                  (value) {
                                                                setState(() {
                                                                  selectedGender =
                                                                      value!;
                                                                });
                                                              },
                                                            ),
                                                            const Text(
                                                                'Female'),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ]),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Date of Birth',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: CustomTextField(
                                                      controller: dob,
                                                      hintText:
                                                          'Enter your date of birth',
                                                      suffixIcon: const Icon(Icons
                                                          .calendar_today_rounded),
                                                      onTap: () async {
                                                        DateTime? pickedDate =
                                                            await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              DateTime(2000),
                                                          firstDate:
                                                              DateTime(1900),
                                                          lastDate:
                                                              DateTime(2010),
                                                        );

                                                        if (pickedDate !=
                                                            null) {
                                                          dob.text = DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .format(
                                                                  pickedDate);
                                                        }
                                                      },
                                                    ),
                                                  ),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'IC No.',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
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
                                                  ),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Contact No.',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
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
                                                            .hasMatch(
                                                                '+60$value')) {
                                                          return 'Invalid Malaysian phone number. Format: +60123456789';
                                                        }
                                                        return null;
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 50),
                                      const Row(
                                        children: [
                                          Text(
                                            'Academic Information',
                                            style: TextStyle(
                                              color: Colors.blue,
                                              fontSize: 20,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Programme',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 4,
                                                      child: CustomDDL<String>(
                                                        controller: programme,
                                                        hintText:
                                                            'Select your programme',
                                                        value:
                                                            selectedProgramme,  
                                                        dropdownItems:
                                                            programmeItems.map(
                                                                (programme) {
                                                          return DropdownMenuItem<
                                                              String>(
                                                            value: programme,
                                                            child:
                                                                Text(programme),
                                                          );
                                                        }).toList(),
                                                      )),
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
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Faculty',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                      flex: 4,
                                                      child: CustomDDL<String>(
                                                        controller: faculty,
                                                        hintText:
                                                            'Select your faculty',
                                                        value: selectedFaculty,
                                                        onChanged:
                                                            (String? newValue) {
                                                          setState(() {
                                                            selectedFaculty =
                                                                newValue!;
                                                            getProgrammesForFaculty(
                                                                selectedFaculty);
                                                          });
                                                        },
                                                        dropdownItems: const [
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: 'FOCS',
                                                            child: Text('FOCS'),
                                                          ),
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: 'FOAS',
                                                            child: Text('FOAS'),
                                                          ),
                                                          DropdownMenuItem<
                                                              String>(
                                                            value: 'FAFB',
                                                            child: Text('FAFB'),
                                                          ),
                                                        ],
                                                      )),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              }
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 30, horizontal: 50),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                CustomButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) {
                                          return const ResetPassword();
                                        },
                                      ),
                                    );
                                  },
                                  text: 'Reset Password',
                                  width: 150,
                                ),
                                const SizedBox(
                                  width: 25,
                                ),
                                CustomButton(
                                  onPressed: () {
                                    if (Responsive.isDesktop(context)) {
                                      if (_formKey1.currentState!.validate()) {
                                        updateProfile(context);
                                      }
                                    } else {
                                      if (_formKey2.currentState!.validate()) {
                                        updateProfile(context);
                                      }
                                    }
                                  },
                                  text: 'Edit Profile',
                                  width: 150,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Footer(),
    );
  }

  void getProgrammesForFaculty(String faculty) {
    switch (faculty) {
      case 'FOCS':
        selectedProgramme = 'Computer Science';
        programmeItems = [
          'Computer Science',
          'Information Technology',
          'Software Engineering'
        ];
      case 'FOAS':
        selectedProgramme = 'Food Science';
        programmeItems = [
          'Food Science',
          'Sports and Exercise Science',
          'Nutrition'
        ];
      case 'FAFB':
        selectedProgramme = 'Business Administration';
        programmeItems = ['Business Administration', 'Finance', 'Marketing'];
      default:
        break;
    }
  }
}
