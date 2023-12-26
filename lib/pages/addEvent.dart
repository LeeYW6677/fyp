import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/ongoingEvent.dart';
import 'package:emailjs/emailjs.dart';

class AddEvent extends StatefulWidget {
  final String selectedSociety;
  const AddEvent({super.key, required this.selectedSociety});

  @override
  State<AddEvent> createState() => _AddEventState();
}

class _AddEventState extends State<AddEvent> {
  final name = TextEditingController();
  bool _isLoading = true;
  final FocusNode _focusNode = FocusNode();
  final FocusNode _focusNode2 = FocusNode();
  final FocusNode _focusNode3 = FocusNode();
  final FocusNode _focusNode4 = FocusNode();
  final FocusNode _focusNode5 = FocusNode();
  final FocusNode _focusNode6 = FocusNode();
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
  List<Map<String, dynamic>> userList = [];

  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

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

      // Get today's date in the format 'yyyyMMdd'
      String todayDate = DateTime.now()
          .toLocal()
          .toString()
          .substring(0, 10)
          .replaceAll('-', '');

      String randomDigits = Random().nextInt(999).toString().padLeft(3, '0');

      // Concatenate the parts to form the eventID
      String eventID = 'E$todayDate$randomDigits';

      DocumentReference<Map<String, dynamic>> eventReference =
          firestore.collection('event').doc(eventID);

      await eventReference.set({
        'eventID': eventID,
        'eventName': eventName,
        'societyID': widget.selectedSociety,
        'status': 'Planning',
        'progress': 0
      });

      DocumentReference<Map<String, dynamic>> approvalReference =
          firestore.collection('approval').doc(eventID);

      await approvalReference.set({
        'eventID': eventID,
        'presidentName': '',
        'presidentStatus': '',
        'advisorName': '',
        'advisorStatus': '',
        'branchHeadName': '',
        'branchHeadStatus': '',
        'comment': '',
      });

      DocumentReference<Map<String, dynamic>> completionReference =
          firestore.collection('completion').doc(eventID);

      await completionReference.set({
        'eventID': eventID,
        'presidentName': '',
        'presidentStatus': '',
        'advisorName': '',
        'advisorStatus': '',
        'branchHeadName': '',
        'branchHeadStatus': '',
        'comment': '',
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
      CollectionReference committee = firestore.collection('committee');

      await committee.add({
        'eventID': eventID,
        'name': committeeName,
        'studentID': studentID,
        'position': position,
        'contact': contactNo,
      });
      _sendEmail(studentID, committeeName, name.text, position);
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

  void _sendEmail(String studentID, String committeeName, String eventName,
      String position) async {
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
          'subject': 'Organising Committee Selection Notifcation',
          'email': userEmail,
          'message':
              'Congratulations! We are pleased to inform you that you have been selected as the $position for the upcoming event, $eventName at TAR UMT.\n\nYour willingness to contribute to our university community is truly appreciated, and we are excited to see the positive impact we know you will make.\n\nThank you for your dedication, and we look forward to your valuable contributions to the success of $eventName.',
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

  Future<void> onTextChanged(
      String value, TextEditingController controller) async {
    bool hasMatch = false;
    String studentName = '';

    for (Map<String, dynamic> user in userList) {
      if (user['id'] == value) {
        hasMatch = true;
        studentName = user['name'];
        break;
      }
    }

    setState(() {
      controller.text = hasMatch ? studentName : '';
    });
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
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: [
                                                    const Expanded(
                                                      flex: 2,
                                                      child: Text(
                                                        'Event Name',
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: CustomTextField(
                                                        controller: name,
                                                        hintText:
                                                            'Enter event name',
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
                                                        focusNode: _focusNode2,
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
                                                                    BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      EdgeInsets
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
                                                                    BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      EdgeInsets
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
                                                        focusNode: _focusNode4,
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
                                                                    BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      EdgeInsets
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
                                                        enabled: false,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Student Found';
                                                          }
                                                          return null;
                                                        },
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
                                                        enabled: false,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Student Found';
                                                          }
                                                          return null;
                                                        },
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
                                                        enabled: false,
                                                        validator: (value) {
                                                          if (value!.isEmpty) {
                                                            return 'No Student Found';
                                                          }
                                                          return null;
                                                        },
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
                                                        focusNode: _focusNode5,
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
                                                                    BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      EdgeInsets
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
                                                                    BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      EdgeInsets
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
                                                        focusNode: _focusNode,
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
                                                                    BoxConstraints(
                                                                  maxWidth: 300,
                                                                  maxHeight:
                                                                      250,
                                                                ),
                                                                child: ListView
                                                                    .builder(
                                                                  padding:
                                                                      EdgeInsets
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
                                                              'Duplicate Committee spotted. Please correct it.'),
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
                                                        String contactNo;
                                                        String eventID =
                                                            await createEvent(
                                                                name.text);
                                                        contactNo =
                                                            await getContactNo(
                                                                presidentID
                                                                    .text);
                                                        addCommittee(
                                                            eventID,
                                                            presidentID.text,
                                                            'President',
                                                            presidentName.text,
                                                            contactNo);
                                                        contactNo =
                                                            await getContactNo(
                                                                vpresidentID
                                                                    .text);
                                                        addCommittee(
                                                            eventID,
                                                            vpresidentID.text,
                                                            'Vice President',
                                                            vpresidentName.text,
                                                            contactNo);
                                                        contactNo =
                                                            await getContactNo(
                                                                secretaryID
                                                                    .text);
                                                        addCommittee(
                                                            eventID,
                                                            secretaryID.text,
                                                            'Secretary',
                                                            secretaryName.text,
                                                            contactNo);
                                                        contactNo =
                                                            await getContactNo(
                                                                vsecretaryID
                                                                    .text);
                                                        addCommittee(
                                                            eventID,
                                                            vsecretaryID.text,
                                                            'Vice Secretary',
                                                            vsecretaryName.text,
                                                            contactNo);
                                                        contactNo =
                                                            await getContactNo(
                                                                treasurerID
                                                                    .text);
                                                        addCommittee(
                                                            eventID,
                                                            treasurerID.text,
                                                            'Treasurer',
                                                            treasurerName.text,
                                                            contactNo);
                                                        contactNo =
                                                            await getContactNo(
                                                                vtreasurerID
                                                                    .text);
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
                                                                OngoingEvent(
                                                              selectedSociety:
                                                                  widget
                                                                      .selectedSociety,
                                                            ),
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
                                                      } catch (e) {
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'Failed to add event. Please try again.'),
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
