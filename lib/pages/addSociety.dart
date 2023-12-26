import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailjs/emailjs.dart';
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

  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();
  final FocusNode _focusNode6 = FocusNode();
  final FocusNode _focusNode7 = FocusNode();
  final FocusNode _focusNode8 = FocusNode();
  final FocusNode _focusNode9 = FocusNode();
  List<Map<String, dynamic>> userList = [];
  List<Map<String, dynamic>> advisorList = [];
  bool _isLoading = true;

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

  Future<void> onTextChanged2(String value, TextEditingController name) async {
    if (RegExp(r'^A\d{3}$').hasMatch(value)) {
      bool hasMatch = false;
      String studentName = '';

      for (Map<String, dynamic> user in advisorList) {
        if (user['id'] == value) {
          hasMatch = true;
          studentName = user['name'];
          break;
        }
      }

      setState(() {
        name.text = hasMatch ? studentName : '';
      });
    } else {
      setState(() {
        name.text = '';
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
      String id, String newPosition, String societyID, String advisorName) async {
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
      _sendEmail(id, advisorName, name.text, newPosition, 'Society Advisor Selection Notification');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
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
          duration: const Duration(seconds: 3),
        ),
      );
      return 'S100';
    }
  }

  void _sendEmail(String studentID, String committeeName, String societyName,
      String position, String subject) async {
    try {
      Map<String, dynamic>? user = userList.firstWhere(
        (user) => user['id'].toString() == studentID,
      );

      // Retrieve email from the user
      String userEmail = user['email'].toString();

      // Send email using EmailJS
      await EmailJS.send(
        'service_ul1uscs',
        'template_alwxa78',
        {
          'name': committeeName,
          'email': userEmail,
          'subject': subject, 
          'message':
              'Congratulations! We are pleased to inform you that you have been selected as the $position for the $societyName at TAR UMT.\n\nYour willingness to contribute to our university community is truly appreciated, and we are excited to see the positive impact we know you will make within the society.\n\nThank you for your dedication, and we look forward to your valuable contributions to the success of $societyName.',
        },
        const Options(
          publicKey: 'Zfr0vuSDdyYaWouwQ',
          privateKey: 'c2nvTqTugRdLVJxuMSYwe',
        ),
      );
    } catch (error) {
      if (error is EmailJSResponseStatus) {
        print('ERROR... ${error.status}: ${error.text}');
      }
      print(error.toString());
    }
  }

  Future<void> addMember(
      String societyID, String studentID, String position, String committeeName) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference members = firestore.collection('member');

      await members.add({
        'societyID': societyID,
        'studentID': studentID,
        'position': position,
      });
      _sendEmail(studentID, committeeName, name.text, position, 'Society Committee Selection Notification');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot =
          await firestore.collection('user').where('id', isLessThan: 'A').get();

      querySnapshot.docs.forEach((DocumentSnapshot document) {
        userList.add(document.data() as Map<String, dynamic>);
      });

      QuerySnapshot querySnapshot1 = await firestore
          .collection('user')
          .where('id', isGreaterThanOrEqualTo: 'A', isLessThan: 'B')
          .get();

      List<DocumentSnapshot> filteredDocuments = querySnapshot1.docs
          .where((doc) =>
              doc['societyID'] == '' &&
              doc['position'] == '' &&
              doc['ic'] != '')
          .toList();

      filteredDocuments.forEach((DocumentSnapshot document) {
        advisorList.add(document.data() as Map<String, dynamic>);
      });

      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to fetch data. Please try again"),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SafeArea(
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        'Society Name',
                                                        style: TextStyle(
                                                            fontSize: 16),
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
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Co-advisor',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Co-advisor',
                                                    style:
                                                        TextStyle(fontSize: 16),
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
                                                      const Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          'Advisor ID',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode7,
                                                        textEditingController:
                                                            advisorID,
                                                        optionsBuilder:
                                                            (TextEditingValue
                                                                textEditingValue) {
                                                          return advisorList
                                                              .map<String>(
                                                                  (user) => user[
                                                                          'id']
                                                                      .toString())
                                                              .where((id) =>
                                                                  id.contains(
                                                                      textEditingValue
                                                                          .text))
                                                              .toList();
                                                        },
                                                        onSelected:
                                                            (String value) {
                                                          onTextChanged2(value,
                                                              advisorName);
                                                        },
                                                        fieldViewBuilder: (BuildContext
                                                                context,
                                                            TextEditingController
                                                                controller,
                                                            FocusNode focusNode,
                                                            VoidCallback
                                                                onFieldSubmitted) {
                                                          return TextFormField(
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'Please enter advisor ID';
                                                              } else if (!RegExp(
                                                                      r'^A\d{3}$')
                                                                  .hasMatch(
                                                                      value)) {
                                                                return 'Invalid advisor ID';
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                controller,
                                                            focusNode:
                                                                focusNode,
                                                            onChanged: (value) {
                                                              onTextChanged2(
                                                                  value,
                                                                  advisorName);
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Advisor ID',
                                                              hintText:
                                                                  'Enter advisor ID',
                                                            ),
                                                          );
                                                        },
                                                        optionsViewBuilder:
                                                            (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                          return Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Material(
                                                              elevation: 4.0,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  itemCount:
                                                                      options
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final String
                                                                        user =
                                                                        options.elementAt(
                                                                            index);
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        onSelected(
                                                                            user);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            user),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
                                                      const Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          'Advisor ID',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode8,
                                                        textEditingController:
                                                            coAdvisorID1,
                                                        optionsBuilder:
                                                            (TextEditingValue
                                                                textEditingValue) {
                                                          return advisorList
                                                              .map<String>(
                                                                  (user) => user[
                                                                          'id']
                                                                      .toString())
                                                              .where((id) =>
                                                                  id.contains(
                                                                      textEditingValue
                                                                          .text))
                                                              .toList();
                                                        },
                                                        onSelected:
                                                            (String value) {
                                                          onTextChanged2(value,
                                                              coAdvisorName1);
                                                        },
                                                        fieldViewBuilder: (BuildContext
                                                                context,
                                                            TextEditingController
                                                                controller,
                                                            FocusNode focusNode,
                                                            VoidCallback
                                                                onFieldSubmitted) {
                                                          return TextFormField(
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'Please enter advisor ID';
                                                              } else if (!RegExp(
                                                                      r'^A\d{3}$')
                                                                  .hasMatch(
                                                                      value)) {
                                                                return 'Invalid advisor ID';
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                controller,
                                                            focusNode:
                                                                focusNode,
                                                            onChanged: (value) {
                                                              onTextChanged2(
                                                                  value,
                                                                  coAdvisorName1);
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Advisor ID',
                                                              hintText:
                                                                  'Enter advisor ID',
                                                            ),
                                                          );
                                                        },
                                                        optionsViewBuilder:
                                                            (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                          return Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Material(
                                                              elevation: 4.0,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  itemCount:
                                                                      options
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final String
                                                                        user =
                                                                        options.elementAt(
                                                                            index);
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        onSelected(
                                                                            user);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            user),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
                                                      const Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          'Advisor ID',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode9,
                                                        textEditingController:
                                                            coAdvisorID2,
                                                        optionsBuilder:
                                                            (TextEditingValue
                                                                textEditingValue) {
                                                          return advisorList
                                                              .map<String>(
                                                                  (user) => user[
                                                                          'id']
                                                                      .toString())
                                                              .where((id) =>
                                                                  id.contains(
                                                                      textEditingValue
                                                                          .text))
                                                              .toList();
                                                        },
                                                        onSelected:
                                                            (String value) {
                                                          onTextChanged2(value,
                                                              coAdvisorName2);
                                                        },
                                                        fieldViewBuilder: (BuildContext
                                                                context,
                                                            TextEditingController
                                                                controller,
                                                            FocusNode focusNode,
                                                            VoidCallback
                                                                onFieldSubmitted) {
                                                          return TextFormField(
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'Please enter advisor ID';
                                                              } else if (!RegExp(
                                                                      r'^A\d{3}$')
                                                                  .hasMatch(
                                                                      value)) {
                                                                return 'Invalid advisor ID';
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                controller,
                                                            focusNode:
                                                                focusNode,
                                                            onChanged: (value) {
                                                              onTextChanged2(
                                                                  value,
                                                                  coAdvisorName2);
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Advisor ID',
                                                              hintText:
                                                                  'Enter advisor ID',
                                                            ),
                                                          );
                                                        },
                                                        optionsViewBuilder:
                                                            (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                          return Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Material(
                                                              elevation: 4.0,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  itemCount:
                                                                      options
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final String
                                                                        user =
                                                                        options.elementAt(
                                                                            index);
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        onSelected(
                                                                            user);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            user),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Advisor Found';
                                                          }
                                                          return null;
                                                        },
                                                        enabled: false,
                                                        controller:
                                                            coAdvisorName1,
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Advisor Found';
                                                          }
                                                          return null;
                                                        },
                                                        enabled: false,
                                                        controller:
                                                            coAdvisorName2,
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
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Secretary',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Treasurer',
                                                    style:
                                                        TextStyle(fontSize: 16),
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                      child: RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode,
                                                        textEditingController:
                                                            presidentID,
                                                        optionsBuilder:
                                                            (TextEditingValue
                                                                textEditingValue) {
                                                          return userList
                                                              .map<String>(
                                                                  (user) => user[
                                                                          'id']
                                                                      .toString())
                                                              .where((id) =>
                                                                  id.contains(
                                                                      textEditingValue
                                                                          .text))
                                                              .toList();
                                                        },
                                                        onSelected:
                                                            (String value) {
                                                          onTextChanged(value,
                                                              presidentName);
                                                        },
                                                        fieldViewBuilder: (BuildContext
                                                                context,
                                                            TextEditingController
                                                                controller,
                                                            FocusNode focusNode,
                                                            VoidCallback
                                                                onFieldSubmitted) {
                                                          return TextFormField(
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'Please enter student ID';
                                                              } else if (!RegExp(
                                                                      r'^\d{2}[A-Z]{3}\d{5}$')
                                                                  .hasMatch(
                                                                      value)) {
                                                                return 'Invalid student ID';
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                controller,
                                                            focusNode:
                                                                focusNode,
                                                            onChanged: (value) {
                                                              onTextChanged(
                                                                  value,
                                                                  presidentName);
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Student ID',
                                                              hintText:
                                                                  'Enter student ID',
                                                            ),
                                                          );
                                                        },
                                                        optionsViewBuilder:
                                                            (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                          return Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Material(
                                                              elevation: 4.0,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  itemCount:
                                                                      options
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final String
                                                                        user =
                                                                        options.elementAt(
                                                                            index);
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        onSelected(
                                                                            user);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            user),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                      child: RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode2,
                                                        textEditingController:
                                                            secretaryID,
                                                        optionsBuilder:
                                                            (TextEditingValue
                                                                textEditingValue) {
                                                          return userList
                                                              .map<String>(
                                                                  (user) => user[
                                                                          'id']
                                                                      .toString())
                                                              .where((id) =>
                                                                  id.contains(
                                                                      textEditingValue
                                                                          .text))
                                                              .toList();
                                                        },
                                                        onSelected:
                                                            (String value) {
                                                          onTextChanged(value,
                                                              secretaryName);
                                                        },
                                                        fieldViewBuilder: (BuildContext
                                                                context,
                                                            TextEditingController
                                                                controller,
                                                            FocusNode focusNode,
                                                            VoidCallback
                                                                onFieldSubmitted) {
                                                          return TextFormField(
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'Please enter student ID';
                                                              } else if (!RegExp(
                                                                      r'^\d{2}[A-Z]{3}\d{5}$')
                                                                  .hasMatch(
                                                                      value)) {
                                                                return 'Invalid student ID';
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                controller,
                                                            focusNode:
                                                                focusNode,
                                                            onChanged: (value) {
                                                              onTextChanged(
                                                                  value,
                                                                  secretaryName);
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Student ID',
                                                              hintText:
                                                                  'Enter student ID',
                                                            ),
                                                          );
                                                        },
                                                        optionsViewBuilder:
                                                            (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                          return Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Material(
                                                              elevation: 4.0,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  itemCount:
                                                                      options
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final String
                                                                        user =
                                                                        options.elementAt(
                                                                            index);
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        onSelected(
                                                                            user);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            user),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                      child: RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode3,
                                                        textEditingController:
                                                            treasurerID,
                                                        optionsBuilder:
                                                            (TextEditingValue
                                                                textEditingValue) {
                                                          return userList
                                                              .map<String>(
                                                                  (user) => user[
                                                                          'id']
                                                                      .toString())
                                                              .where((id) =>
                                                                  id.contains(
                                                                      textEditingValue
                                                                          .text))
                                                              .toList();
                                                        },
                                                        onSelected:
                                                            (String value) {
                                                          onTextChanged(value,
                                                              treasurerName);
                                                        },
                                                        fieldViewBuilder: (BuildContext
                                                                context,
                                                            TextEditingController
                                                                controller,
                                                            FocusNode focusNode,
                                                            VoidCallback
                                                                onFieldSubmitted) {
                                                          return TextFormField(
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'Please enter student ID';
                                                              } else if (!RegExp(
                                                                      r'^\d{2}[A-Z]{3}\d{5}$')
                                                                  .hasMatch(
                                                                      value)) {
                                                                return 'Invalid student ID';
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                controller,
                                                            focusNode:
                                                                focusNode,
                                                            onChanged: (value) {
                                                              onTextChanged(
                                                                  value,
                                                                  treasurerName);
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Student ID',
                                                              hintText:
                                                                  'Enter student ID',
                                                            ),
                                                          );
                                                        },
                                                        optionsViewBuilder:
                                                            (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                          return Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Material(
                                                              elevation: 4.0,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  itemCount:
                                                                      options
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final String
                                                                        user =
                                                                        options.elementAt(
                                                                            index);
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        onSelected(
                                                                            user);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            user),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Student Found';
                                                          }
                                                          return null;
                                                        },
                                                        enabled: false,
                                                        controller:
                                                            presidentName,
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Student Found';
                                                          }
                                                          return null;
                                                        },
                                                        enabled: false,
                                                        controller:
                                                            secretaryName,
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Student Found';
                                                          }
                                                          return null;
                                                        },
                                                        enabled: false,
                                                        controller:
                                                            treasurerName,
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
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Vice Secretary',
                                                    style:
                                                        TextStyle(fontSize: 16),
                                                  )),
                                              Expanded(
                                                  flex: 1,
                                                  child: Text(
                                                    'Vice Treasurer',
                                                    style:
                                                        TextStyle(fontSize: 16),
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                      child: RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode4,
                                                        textEditingController:
                                                            vpresidentID,
                                                        optionsBuilder:
                                                            (TextEditingValue
                                                                textEditingValue) {
                                                          return userList
                                                              .map<String>(
                                                                  (user) => user[
                                                                          'id']
                                                                      .toString())
                                                              .where((id) =>
                                                                  id.contains(
                                                                      textEditingValue
                                                                          .text))
                                                              .toList();
                                                        },
                                                        onSelected:
                                                            (String value) {
                                                          onTextChanged(value,
                                                              vpresidentName);
                                                        },
                                                        fieldViewBuilder: (BuildContext
                                                                context,
                                                            TextEditingController
                                                                controller,
                                                            FocusNode focusNode,
                                                            VoidCallback
                                                                onFieldSubmitted) {
                                                          return TextFormField(
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'Please enter student ID';
                                                              } else if (!RegExp(
                                                                      r'^\d{2}[A-Z]{3}\d{5}$')
                                                                  .hasMatch(
                                                                      value)) {
                                                                return 'Invalid student ID';
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                controller,
                                                            focusNode:
                                                                focusNode,
                                                            onChanged: (value) {
                                                              onTextChanged(
                                                                  value,
                                                                  vpresidentName);
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Student ID',
                                                              hintText:
                                                                  'Enter student ID',
                                                            ),
                                                          );
                                                        },
                                                        optionsViewBuilder:
                                                            (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                          return Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Material(
                                                              elevation: 4.0,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  itemCount:
                                                                      options
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final String
                                                                        user =
                                                                        options.elementAt(
                                                                            index);
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        onSelected(
                                                                            user);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            user),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                      child: RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode5,
                                                        textEditingController:
                                                            vsecretaryID,
                                                        optionsBuilder:
                                                            (TextEditingValue
                                                                textEditingValue) {
                                                          return userList
                                                              .map<String>(
                                                                  (user) => user[
                                                                          'id']
                                                                      .toString())
                                                              .where((id) =>
                                                                  id.contains(
                                                                      textEditingValue
                                                                          .text))
                                                              .toList();
                                                        },
                                                        onSelected:
                                                            (String value) {
                                                          onTextChanged(value,
                                                              vsecretaryName);
                                                        },
                                                        fieldViewBuilder: (BuildContext
                                                                context,
                                                            TextEditingController
                                                                controller,
                                                            FocusNode focusNode,
                                                            VoidCallback
                                                                onFieldSubmitted) {
                                                          return TextFormField(
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'Please enter student ID';
                                                              } else if (!RegExp(
                                                                      r'^\d{2}[A-Z]{3}\d{5}$')
                                                                  .hasMatch(
                                                                      value)) {
                                                                return 'Invalid student ID';
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                controller,
                                                            focusNode:
                                                                focusNode,
                                                            onChanged: (value) {
                                                              onTextChanged(
                                                                  value,
                                                                  vsecretaryName);
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Student ID',
                                                              hintText:
                                                                  'Enter student ID',
                                                            ),
                                                          );
                                                        },
                                                        optionsViewBuilder:
                                                            (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                          return Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Material(
                                                              elevation: 4.0,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  itemCount:
                                                                      options
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final String
                                                                        user =
                                                                        options.elementAt(
                                                                            index);
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        onSelected(
                                                                            user);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            user),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                      child: RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode6,
                                                        textEditingController:
                                                            vtreasurerID,
                                                        optionsBuilder:
                                                            (TextEditingValue
                                                                textEditingValue) {
                                                          return userList
                                                              .map<String>(
                                                                  (user) => user[
                                                                          'id']
                                                                      .toString())
                                                              .where((id) =>
                                                                  id.contains(
                                                                      textEditingValue
                                                                          .text))
                                                              .toList();
                                                        },
                                                        onSelected:
                                                            (String value) {
                                                          onTextChanged(value,
                                                              vtreasurerName);
                                                        },
                                                        fieldViewBuilder: (BuildContext
                                                                context,
                                                            TextEditingController
                                                                controller,
                                                            FocusNode focusNode,
                                                            VoidCallback
                                                                onFieldSubmitted) {
                                                          return TextFormField(
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'Please enter student ID';
                                                              } else if (!RegExp(
                                                                      r'^\d{2}[A-Z]{3}\d{5}$')
                                                                  .hasMatch(
                                                                      value)) {
                                                                return 'Invalid student ID';
                                                              }
                                                              return null;
                                                            },
                                                            controller:
                                                                controller,
                                                            focusNode:
                                                                focusNode,
                                                            onChanged: (value) {
                                                              onTextChanged(
                                                                  value,
                                                                  vtreasurerName);
                                                            },
                                                            decoration:
                                                                const InputDecoration(
                                                              enabledBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .grey),
                                                              ),
                                                              focusedBorder:
                                                                  OutlineInputBorder(
                                                                borderSide: BorderSide(
                                                                    width: 1,
                                                                    color: Colors
                                                                        .blue),
                                                              ),
                                                              errorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              focusedErrorBorder:
                                                                  OutlineInputBorder(
                                                                borderSide:
                                                                    BorderSide(
                                                                        width:
                                                                            1,
                                                                        color: Colors
                                                                            .red),
                                                              ),
                                                              labelText:
                                                                  'Student ID',
                                                              hintText:
                                                                  'Enter student ID',
                                                            ),
                                                          );
                                                        },
                                                        optionsViewBuilder:
                                                            (BuildContext
                                                                    context,
                                                                AutocompleteOnSelected<
                                                                        String>
                                                                    onSelected,
                                                                Iterable<String>
                                                                    options) {
                                                          return Align(
                                                            alignment: Alignment
                                                                .topLeft,
                                                            child: Material(
                                                              elevation: 4.0,
                                                              child:
                                                                  ConstrainedBox(
                                                                constraints:
                                                                    const BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          8.0),
                                                                  itemCount:
                                                                      options
                                                                          .length,
                                                                  itemBuilder:
                                                                      (BuildContext
                                                                              context,
                                                                          int index) {
                                                                    final String
                                                                        user =
                                                                        options.elementAt(
                                                                            index);
                                                                    return GestureDetector(
                                                                      onTap:
                                                                          () {
                                                                        onSelected(
                                                                            user);
                                                                      },
                                                                      child:
                                                                          ListTile(
                                                                        title: Text(
                                                                            user),
                                                                      ),
                                                                    );
                                                                  },
                                                                ),
                                                              ),
                                                            ),
                                                          );
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
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Student Found';
                                                          }
                                                          return null;
                                                        },
                                                        enabled: false,
                                                        controller:
                                                            vpresidentName,
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Student Found';
                                                          }
                                                          return null;
                                                        },
                                                        enabled: false,
                                                        controller:
                                                            vsecretaryName,
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Student Found';
                                                          }
                                                          return null;
                                                        },
                                                        enabled: false,
                                                        controller:
                                                            vtreasurerName,
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
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8.0,
                                                      vertical: 12.0),
                                              child: CustomButton(
                                                onPressed: () async {
                                                  if (_formKey1.currentState!
                                                      .validate()) {
                                                    if (hasDuplicateTextValues()) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Duplicate Advisor/Committee spotted. Please correct it.'),
                                                          width: 275.0,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                    } else {
                                                      try {
                                                        bool available = true;
                                                        FirebaseFirestore
                                                            firestore =
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
                                                                  .collection(
                                                                      'user')
                                                                  .doc(id)
                                                                  .get();

                                                          if (userSnapshot[
                                                                      'position'] !=
                                                                  '' ||
                                                              userSnapshot[
                                                                      'societyID'] !=
                                                                  '') {
                                                            available = false;
                                                            ScaffoldMessenger
                                                                    .of(context)
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
                                                                duration:
                                                                    const Duration(
                                                                        seconds:
                                                                            3),
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
                                                              societyID, advisorName.text);
                                                          updateAdvisor(
                                                              coAdvisorID1.text,
                                                              'Co-advisor',
                                                              societyID, coAdvisorName1.text);
                                                          updateAdvisor(
                                                              coAdvisorID2.text,
                                                              'Co-advisor',
                                                              societyID, coAdvisorName2.text);
                                                          addMember(
                                                              societyID,
                                                              presidentID.text,
                                                              'President', presidentName.text);
                                                          addMember(
                                                              societyID,
                                                              vpresidentID.text,
                                                              'Vice President', vpresidentName.text);
                                                          addMember(
                                                              societyID,
                                                              secretaryID.text,
                                                              'Secretary', secretaryName.text);
                                                          addMember(
                                                              societyID,
                                                              vsecretaryID.text,
                                                              'Vice Secretary', vsecretaryName.text);
                                                          addMember(
                                                              societyID,
                                                              treasurerID.text,
                                                              'Treasurer', treasurerName.text);
                                                          addMember(
                                                              societyID,
                                                              vtreasurerID.text,
                                                              'Vice Treasurer', vtreasurerName.text);
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
                                                                      seconds:
                                                                          3),
                                                            ),
                                                          );
                                                        }
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'Failed to register society. Please try again.'),
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
