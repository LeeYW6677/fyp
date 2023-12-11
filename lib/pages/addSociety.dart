import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/society.dart';

class AddSociety extends StatefulWidget {
  const AddSociety({super.key});

  @override
  State<AddSociety> createState() => _AddSocietyState();
}

class _AddSocietyState extends State<AddSociety> {
  final name = TextEditingController();
  final advisorName = TextEditingController();
  final advisorID = TextEditingController();
  final coAdvisorID1 = TextEditingController();
  final coAdvisorID2 = TextEditingController();
  final coAdvisorName1 = TextEditingController();
  final coAdvisorName2 = TextEditingController();

  final presidentName = TextEditingController();
  final presidentID = TextEditingController();
  final secretaryName = TextEditingController();
  final secretaryID = TextEditingController();
  final treasurerName = TextEditingController();
  final treasurerID = TextEditingController();

  final vpresidentName = TextEditingController();
  final vpresidentID = TextEditingController();
  final vsecretaryName = TextEditingController();
  final vsecretaryID = TextEditingController();
  final vtreasurerName = TextEditingController();
  final vtreasurerID = TextEditingController();

  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  Future<void> onTextChanged(
      String value, TextEditingController controller) async {
    if (RegExp(r'^\d{2}[A-Z]{3}\d{5}$').hasMatch(value)) {
      DocumentSnapshot<Map<String, dynamic>> student =
          await FirebaseFirestore.instance.collection('user').doc(value).get();

      if (student.exists) {
        Map<String, dynamic> studentData = student.data()!;
        setState(() {
          controller.text = studentData['name'];
        });
      } else {
        setState(() {
          controller.text = '';
        });
      }
    } else {
      setState(() {
        controller.text = '';
      });
    }
  }

  bool hasDuplicateTextValues() {
    List<String> textValues = [
      advisorID.text,
      coAdvisorID1.text,
      coAdvisorID2.text,
      presidentID.text,
      secretaryID.text,
      treasurerID.text,
      vpresidentID.text,
      vsecretaryID.text,
      vtreasurerID.text,
    ];
    Set<String> uniqueTextValues = Set<String>.from(textValues);
    return textValues.length != uniqueTextValues.length;
  }

  Future<void> updateAdvisor(
      String id, String newPosition, String societyID) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference<Map<String, dynamic>> userReference =
          firestore.collection('user').doc(id);

      DocumentSnapshot<Map<String, dynamic>> userSnapshot =
          await userReference.get();

      if (userSnapshot.exists) {
        await userReference.update({
          'societyID': societyID,
          'position': newPosition,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<String> createSociety(String societyName) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      String todayDate = DateTime.now()
          .toLocal()
          .toString()
          .substring(0, 10)
          .replaceAll('-', '');

      String randomDigits = Random().nextInt(999).toString().padLeft(3, '0');

      String societyID = 'S$todayDate$randomDigits';

      DocumentReference<Map<String, dynamic>> societyReference =
          firestore.collection('society').doc(societyID);

      await societyReference.set({
        'societyID': societyID,
        'societyName': societyName,
      });
      return societyID;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return 'S100';
    }
  }

  Future<void> addMember(
      String societyID, String studentID, String position) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference members = firestore.collection('member');

      await members.add({
        'societyID': societyID,
        'studentID': studentID,
        'position': position,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
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
                  page: 'Society',
                ),
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
                              'Add Society',
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
                              key: _formKey1,
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Society Name',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  controller: name,
                                                  hintText:
                                                      'Enter society name',
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter society name';
                                                    }
                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (Responsive.isDesktop(context))
                                        const Expanded(
                                          child: SizedBox(),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 50),
                                  const Row(
                                    children: [
                                      Text(
                                        'Advisor Info',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Advisor',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Co-advisor',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Co-advisor',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 0.1,
                                    color: Colors.black,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
                                                const Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Advisor ID',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  screen: !Responsive.isDesktop(
                                                      context),
                                                  labelText: 'Advisor ID',
                                                  onChanged: (value) async {
                                                    if (RegExp(r'^A\d{3}')
                                                        .hasMatch(value)) {
                                                      DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          advisor =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'user')
                                                              .doc(advisorID
                                                                  .text)
                                                              .get();

                                                      if (advisor.exists) {
                                                        Map<String, dynamic>
                                                            advisorData =
                                                            advisor.data()!;
                                                        if (advisorData['ic'] !=
                                                            '') {
                                                          advisorName.text =
                                                              advisorData[
                                                                  'name'];
                                                        }
                                                      } else {
                                                        advisorName.text = '';
                                                      }
                                                    } else {
                                                      advisorName.text = '';
                                                    }
                                                  },
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter advisor ID';
                                                    } else if (!RegExp(
                                                            r'^A\d{3}')
                                                        .hasMatch(value)) {
                                                      return 'Invalid advisor ID';
                                                    }
                                                    return null;
                                                  },
                                                  controller: advisorID,
                                                  hintText: 'Enter advisor ID',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
                                                const Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Advisor ID',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  screen: !Responsive.isDesktop(
                                                      context),
                                                  labelText: 'Advisor ID',
                                                  onChanged: (value) async {
                                                    if (RegExp(r'^A\d{3}')
                                                        .hasMatch(value)) {
                                                      DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          advisor =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'user')
                                                              .doc(coAdvisorID1
                                                                  .text)
                                                              .get();

                                                      if (advisor.exists) {
                                                        Map<String, dynamic>
                                                            advisorData =
                                                            advisor.data()!;
                                                        if (advisorData['ic'] !=
                                                            '') {
                                                          coAdvisorName1.text =
                                                              advisorData[
                                                                  'name'];
                                                        }
                                                      } else {
                                                        coAdvisorName1.text =
                                                            '';
                                                      }
                                                    } else {
                                                      coAdvisorName1.text = '';
                                                    }
                                                  },
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter advisor ID';
                                                    } else if (!RegExp(
                                                            r'^A\d{3}')
                                                        .hasMatch(value)) {
                                                      return 'Invalid advisor ID';
                                                    }
                                                    return null;
                                                  },
                                                  controller: coAdvisorID1,
                                                  hintText: 'Enter advisor ID',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
                                                const Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Advisor ID',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  screen: !Responsive.isDesktop(
                                                      context),
                                                  labelText: 'Advisor ID',
                                                  onChanged: (value) async {
                                                    if (RegExp(r'^A\d{3}')
                                                        .hasMatch(value)) {
                                                      DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          advisor =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'user')
                                                              .doc(coAdvisorID2
                                                                  .text)
                                                              .get();

                                                      if (advisor.exists) {
                                                        Map<String, dynamic>
                                                            advisorData =
                                                            advisor.data()!;
                                                        if (advisorData['ic'] !=
                                                            '') {
                                                          coAdvisorName2.text =
                                                              advisorData[
                                                                  'name'];
                                                        }
                                                      } else {
                                                        coAdvisorName2.text =
                                                            '';
                                                      }
                                                    } else {
                                                      coAdvisorName2.text = '';
                                                    }
                                                  },
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter advisor ID';
                                                    } else if (!RegExp(
                                                            r'^A\d{3}')
                                                        .hasMatch(value)) {
                                                      return 'Invalid advisor ID';
                                                    }
                                                    return null;
                                                  },
                                                  controller: coAdvisorID2,
                                                  hintText: 'Enter advisor ID',
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
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
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'No Advisor Found';
                                                    }
                                                    return null;
                                                  },
                                                  enabled: false,
                                                  controller: advisorName,
                                                  hintText:
                                                      'Associated Advisor Name',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
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
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'No Advisor Found';
                                                    }
                                                    return null;
                                                  },
                                                  enabled: false,
                                                  controller: coAdvisorName1,
                                                  hintText:
                                                      'Associated Advisor Name',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
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
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'No Advisor Found';
                                                    }
                                                    return null;
                                                  },
                                                  enabled: false,
                                                  controller: coAdvisorName2,
                                                  hintText:
                                                      'Associated Advisor Name',
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
                                        'Committee Info',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              'President',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Secretary',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Treasurer',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 0.1,
                                    color: Colors.black,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
                                                const Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Student ID',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  screen: !Responsive.isDesktop(
                                                      context),
                                                  labelText: 'Student ID',
                                                  onChanged: (value) =>
                                                      onTextChanged(
                                                          value, presidentName),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter student ID';
                                                    } else if (!RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      return 'Invalid student ID';
                                                    }
                                                    return null;
                                                  },
                                                  controller: presidentID,
                                                  hintText: 'Enter student ID',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
                                                const Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Student ID',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  screen: !Responsive.isDesktop(
                                                      context),
                                                  labelText: 'Student ID',
                                                  onChanged: (value) =>
                                                      onTextChanged(
                                                          value, secretaryName),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter student ID';
                                                    } else if (!RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      return 'Invalid student ID';
                                                    }
                                                    return null;
                                                  },
                                                  controller: secretaryID,
                                                  hintText: 'Enter student ID',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
                                                const Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Student ID',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  screen: !Responsive.isDesktop(
                                                      context),
                                                  labelText: 'Student ID',
                                                  onChanged: (value) =>
                                                      onTextChanged(
                                                          value, treasurerName),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter student ID';
                                                    } else if (!RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      return 'Invalid student ID';
                                                    }
                                                    return null;
                                                  },
                                                  controller: treasurerID,
                                                  hintText: 'Enter student ID',
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
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
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'No Student Found';
                                                    }
                                                    return null;
                                                  },
                                                  enabled: false,
                                                  controller: presidentName,
                                                  hintText:
                                                      'Associated Student Name',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
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
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'No Student Found';
                                                    }
                                                    return null;
                                                  },
                                                  enabled: false,
                                                  controller: secretaryName,
                                                  hintText:
                                                      'Associated Student Name',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
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
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'No Student Found';
                                                    }
                                                    return null;
                                                  },
                                                  enabled: false,
                                                  controller: treasurerName,
                                                  hintText:
                                                      'Associated Student Name',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 50),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 8.0),
                                    child: Row(
                                      children: [
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Vice President',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Vice Secretary',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                        Expanded(
                                            flex: 1,
                                            child: Text(
                                              'Vice Treasurer',
                                              style: TextStyle(fontSize: 16),
                                            )),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 0.1,
                                    color: Colors.black,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
                                                const Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Student ID',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  screen: !Responsive.isDesktop(
                                                      context),
                                                  labelText: 'Student ID',
                                                  onChanged: (value) =>
                                                      onTextChanged(value,
                                                          vpresidentName),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter student ID';
                                                    } else if (!RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      return 'Invalid student ID';
                                                    }
                                                    return null;
                                                  },
                                                  controller: vpresidentID,
                                                  hintText: 'Enter student ID',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
                                                const Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Student ID',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  screen: !Responsive.isDesktop(
                                                      context),
                                                  labelText: 'Student ID',
                                                  onChanged: (value) =>
                                                      onTextChanged(value,
                                                          vsecretaryName),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter student ID';
                                                    } else if (!RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      return 'Invalid student ID';
                                                    }
                                                    return null;
                                                  },
                                                  controller: vsecretaryID,
                                                  hintText: 'Enter student ID',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
                                                const Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Student ID',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  ),
                                                ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  screen: !Responsive.isDesktop(
                                                      context),
                                                  labelText: 'Student ID',
                                                  onChanged: (value) =>
                                                      onTextChanged(value,
                                                          vtreasurerName),
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter student ID';
                                                    } else if (!RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      return 'Invalid student ID';
                                                    }
                                                    return null;
                                                  },
                                                  controller: vtreasurerID,
                                                  hintText: 'Enter student ID',
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
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
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
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'No Student Found';
                                                    }
                                                    return null;
                                                  },
                                                  enabled: false,
                                                  controller: vpresidentName,
                                                  hintText:
                                                      'Associated Student Name',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
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
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'No Student Found';
                                                    }
                                                    return null;
                                                  },
                                                  enabled: false,
                                                  controller: vsecretaryName,
                                                  hintText:
                                                      'Associated Student Name',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              if (Responsive.isDesktop(context))
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
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'No Student Found';
                                                    }
                                                    return null;
                                                  },
                                                  enabled: false,
                                                  controller: vtreasurerName,
                                                  hintText:
                                                      'Associated Student Name',
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0, vertical: 12.0),
                                        child: CustomButton(
                                          onPressed: () async {
                                            if (_formKey1.currentState!
                                                .validate()) {
                                              if (hasDuplicateTextValues()) {
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                    content: Text(
                                                        'Duplicate Advisor/Committee spotted. Please correct it.'),
                                                    width: 275.0,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    duration:
                                                        Duration(seconds: 3),
                                                  ),
                                                );
                                              } else {
                                                try {
                                                  bool available = true;
                                                  FirebaseFirestore firestore =
                                                      FirebaseFirestore
                                                          .instance;
                                                  List<String> ids = [
                                                    advisorID.text,
                                                    coAdvisorID1.text,
                                                    coAdvisorID2.text
                                                  ];
                                                  for (String id in ids) {
                                                    DocumentSnapshot<
                                                            Map<String,
                                                                dynamic>>
                                                        userSnapshot =
                                                        await firestore
                                                            .collection('user')
                                                            .doc(id)
                                                            .get();

                                                    if (userSnapshot[
                                                                'position'] !=
                                                            '' ||
                                                        userSnapshot[
                                                                'societyID'] !=
                                                            '') {
                                                      available = false;
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        SnackBar(
                                                          content: Text(
                                                              userSnapshot[
                                                                      'name'] +
                                                                  ' is already assigned as an advisor.'),
                                                          width: 225.0,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                  if (available) {
                                                    String societyID =
                                                        await createSociety(
                                                            name.text);
                                                    updateAdvisor(
                                                        advisorID.text,
                                                        'Advisor',
                                                        societyID);
                                                    updateAdvisor(
                                                        coAdvisorID1.text,
                                                        'Co-advisor',
                                                        societyID);
                                                    updateAdvisor(
                                                        coAdvisorID2.text,
                                                        'Co-advisor',
                                                        societyID);
                                                    addMember(
                                                        societyID,
                                                        presidentID.text,
                                                        'President');
                                                    addMember(
                                                        societyID,
                                                        vpresidentID.text,
                                                        'Vice President');
                                                    addMember(
                                                        societyID,
                                                        secretaryID.text,
                                                        'Secretary');
                                                    addMember(
                                                        societyID,
                                                        vsecretaryID.text,
                                                        'Vice Secretary');
                                                    addMember(
                                                        societyID,
                                                        treasurerID.text,
                                                        'Treasurer');
                                                    addMember(
                                                        societyID,
                                                        vtreasurerID.text,
                                                        'Vice Treasurer');
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            const Society(),
                                                      ),
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                            '${name.text} has been registered.'),
                                                        width: 225.0,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        duration:
                                                            const Duration(
                                                                seconds: 3),
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Failed to register society. Please try again.'),
                                                      width: 225.0,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration:
                                                          Duration(seconds: 3),
                                                    ),
                                                  );
                                                }
                                              }
                                            }
                                          },
                                          text: 'Add Society',
                                          width: 200,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
