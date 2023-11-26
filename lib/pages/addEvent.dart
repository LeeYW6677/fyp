import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/society.dart';
import 'package:fyp/pages/viewEvent.dart';

class AddEvent extends StatefulWidget {
  final String selectedSociety;
  const AddEvent({super.key, required this.selectedSociety});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final name = TextEditingController();
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
  List<Map<String, dynamic>> advisorList = [];
  List<Map<String, dynamic>> coAdvisorList = [];
  List<Map<String, dynamic>> allAdvisor = [];
  String advisorname = '';

  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  Future<void> getAdvisor() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    final QuerySnapshot<Map<String, dynamic>> advisorSnapshot = await firestore
        .collection('user')
        .where('societyID', isEqualTo: widget.selectedSociety)
        .where('position', whereIn: ['Advisor', 'Co-advisor']).get();

    for (var docSnapshot in advisorSnapshot.docs) {
      Map<String, dynamic> userData = docSnapshot.data();

      String position = userData['position'];
      if (position == 'Advisor') {
        setState(() {
          advisorList.add(userData);
        });
      } else if (position == 'Co-advisor') {
        setState(() {
          coAdvisorList.add(userData);
        });
      }
    }
  }

  bool hasDuplicateTextValues() {
    List<String> textValues = [
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

  Future<String> createEvent(String eventName) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      QuerySnapshot<Map<String, dynamic>> snapshot =
          await firestore.collection('event').get();

      int totalCount = snapshot.size;

      String eventID = 'E${(totalCount + 1).toString().padLeft(3, '0')}';

      DocumentReference<Map<String, dynamic>> societyReference =
          firestore.collection('event').doc(eventID);

      await societyReference.set({
        'eventID': eventID,
        'eventName': eventName,
        'societyID': widget.selectedSociety,
        'eventStatus': 'Planning',
        'advisorName': advisorList[0]['name'],
        'coAdvisorName1': coAdvisorList[0]['name'],
        'coAdvisorName2': coAdvisorList[1]['name'],
      });
      return eventID;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to add event. Please try again.'),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return 'S100';
    }
  }

  Future<String> getContactNo(String userID) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await firestore.collection('user').doc(userID).get();

    if (userSnapshot.exists) {
      return userSnapshot['contact'];
    } else {
      return '';
    }
  }

  Future<void> addCommittee(String eventID, String studentID, String position,
      String committeeName, String contactNo) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      CollectionReference committee =
          firestore.collection('organisingCommittee');

      await committee.add({
        'eventID': eventID,
        'societyID': widget.selectedSociety,
        'name': committeeName,
        'studentID': studentID,
        'position': position,
        'contactNo': contactNo,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to register committee. Please try again.'),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getAdvisor();
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
                  NavigationMenu(
                    buttonTexts: const ['Society', 'Event', 'Add Event'],
                    destination: [
                      const Society(),
                      ViewEvent(selectedSociety: widget.selectedSociety),
                      AddEvent(selectedSociety: widget.selectedSociety)
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Add Event',
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              const Expanded(
                                                flex: 2,
                                                child: Text(
                                                  'Event Name',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  controller: name,
                                                  hintText: 'Enter event name',
                                                  validator: (value) {
                                                    if (value!.isEmpty) {
                                                      return 'Please enter event name';
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
                                        'Advisor Info',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Divider(
                                    thickness: 0.1,
                                    color: Colors.black,
                                  ),
                                  Row(
                                    children: [
                                      const Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Advisor:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          advisorList.isNotEmpty
                                              ? advisorList[0]['name']
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Co-Advisor:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          coAdvisorList.isNotEmpty
                                              ? coAdvisorList[0]['name']
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Container(),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Container(),
                                      ),
                                      Expanded(
                                        flex: 2,
                                        child: Container(),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          coAdvisorList.isNotEmpty
                                              ? coAdvisorList[1]['name']
                                              : '',
                                          style: const TextStyle(
                                            fontSize: 16,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                                  onChanged: (value) async {
                                                    if (RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          student =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'user')
                                                              .doc(presidentID
                                                                  .text)
                                                              .get();

                                                      if (student.exists) {
                                                        Map<String, dynamic>
                                                            studentData =
                                                            student.data()!;
                                                        presidentName.text =
                                                            studentData['name'];
                                                      } else {
                                                        presidentName.text = '';
                                                      }
                                                    } else {
                                                      presidentName.text = '';
                                                    }
                                                  },
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                                  onChanged: (value) async {
                                                    if (RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          student =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'user')
                                                              .doc(secretaryID
                                                                  .text)
                                                              .get();

                                                      if (student.exists) {
                                                        Map<String, dynamic>
                                                            studentData =
                                                            student.data()!;
                                                        secretaryName.text =
                                                            studentData['name'];
                                                      } else {
                                                        secretaryName.text = '';
                                                      }
                                                    } else {
                                                      secretaryName.text = '';
                                                    }
                                                  },
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                                  onChanged: (value) async {
                                                    if (RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          student =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'user')
                                                              .doc(treasurerID
                                                                  .text)
                                                              .get();

                                                      if (student.exists) {
                                                        Map<String, dynamic>
                                                            studentData =
                                                            student.data()!;
                                                        treasurerName.text =
                                                            studentData['name'];
                                                      } else {
                                                        treasurerName.text = '';
                                                      }
                                                    } else {
                                                      treasurerName.text = '';
                                                    }
                                                  },
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                                  onChanged: (value) async {
                                                    if (RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          student =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'user')
                                                              .doc(vpresidentID
                                                                  .text)
                                                              .get();

                                                      if (student.exists) {
                                                        Map<String, dynamic>
                                                            studentData =
                                                            student.data()!;
                                                        vpresidentName.text =
                                                            studentData['name'];
                                                      } else {
                                                        vpresidentName.text =
                                                            '';
                                                      }
                                                    } else {
                                                      vpresidentName.text = '';
                                                    }
                                                  },
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                                  onChanged: (value) async {
                                                    if (RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          student =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'user')
                                                              .doc(vsecretaryID
                                                                  .text)
                                                              .get();

                                                      if (student.exists) {
                                                        Map<String, dynamic>
                                                            studentData =
                                                            student.data()!;
                                                        vsecretaryName.text =
                                                            studentData['name'];
                                                      } else {
                                                        vsecretaryName.text =
                                                            '';
                                                      }
                                                    } else {
                                                      vsecretaryName.text = '';
                                                    }
                                                  },
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                                  onChanged: (value) async {
                                                    if (RegExp(
                                                            r'^\d{2}[A-Z]{3}\d{5}$')
                                                        .hasMatch(value)) {
                                                      DocumentSnapshot<
                                                              Map<String,
                                                                  dynamic>>
                                                          student =
                                                          await FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'user')
                                                              .doc(vtreasurerID
                                                                  .text)
                                                              .get();

                                                      if (student.exists) {
                                                        Map<String, dynamic>
                                                            studentData =
                                                            student.data()!;
                                                        vtreasurerName.text =
                                                            studentData['name'];
                                                      } else {
                                                        vtreasurerName.text =
                                                            '';
                                                      }
                                                    } else {
                                                      vtreasurerName.text = '';
                                                    }
                                                  },
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
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
                                                        'Duplicate Committee spotted. Please correct it.'),
                                                    width: 275.0,
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    duration:
                                                        Duration(seconds: 3),
                                                  ),
                                                );
                                              } else {
                                                try {
                                                  String contactNo;
                                                  String eventID =
                                                      await createEvent(
                                                          name.text);
                                                  contactNo =
                                                      await getContactNo(
                                                          presidentID.text);
                                                  addCommittee(
                                                      eventID,
                                                      presidentID.text,
                                                      'President',
                                                      presidentName.text,
                                                      contactNo);
                                                  contactNo =
                                                      await getContactNo(
                                                          vpresidentID.text);
                                                  addCommittee(
                                                      eventID,
                                                      vpresidentID.text,
                                                      'Vice President',
                                                      vpresidentName.text,
                                                      contactNo);
                                                  contactNo =
                                                      await getContactNo(
                                                          secretaryID.text);
                                                  addCommittee(
                                                      eventID,
                                                      secretaryID.text,
                                                      'Secretary',
                                                      secretaryName.text,
                                                      contactNo);
                                                  contactNo =
                                                      await getContactNo(
                                                          vsecretaryID.text);
                                                  addCommittee(
                                                      eventID,
                                                      vsecretaryID.text,
                                                      'Vice Secretary',
                                                      vsecretaryName.text,
                                                      contactNo);
                                                  contactNo =
                                                      await getContactNo(
                                                          treasurerID.text);
                                                  addCommittee(
                                                      eventID,
                                                      treasurerID.text,
                                                      'Treasurer',
                                                      treasurerName.text,
                                                      contactNo);
                                                  contactNo =
                                                      await getContactNo(
                                                          vtreasurerID.text);
                                                  addCommittee(
                                                      eventID,
                                                      vtreasurerID.text,
                                                      'Vice Treasurer',
                                                      vtreasurerName.text,
                                                      contactNo);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          ViewEvent(selectedSociety: widget.selectedSociety,),
                                                    ),
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          '${name.text} has been registered.'),
                                                      width: 225.0,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration:
                                                          const Duration(seconds: 3),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Failed to add event. Please try again.'),
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
                                          text: 'Add Event',
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