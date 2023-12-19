import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/eventDetails.dart';

class EditEvent extends StatefulWidget {
  final String selectedEvent;
  const EditEvent({super.key, required this.selectedEvent});

  @override
  State<EditEvent> createState() => _EditEventState();
}

class _EditEventState extends State<EditEvent> {
  final name = TextEditingController();
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
  bool _isLoading = true;
  List<String> restrictedPositions = [
    'President',
    'Vice President',
    'Secretary',
    'Vice Secretary',
    'Treasurer',
    'Vice Treasurer',
  ];
  final GlobalKey<FormState> _formKey1 = GlobalKey<FormState>();

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      CollectionReference events = firestore.collection('event');
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await events
          .where('eventID', isEqualTo: widget.selectedEvent)
          .limit(1)
          .get() as QuerySnapshot<Map<String, dynamic>>;

      if (querySnapshot.docs.isNotEmpty) {
        name.text = querySnapshot.docs[0].data()['eventName'];
      }
      final QuerySnapshot<Map<String, dynamic>> committeeSnapshot =
          await firestore
              .collection('committee')
              .where('eventID', isEqualTo: widget.selectedEvent)
              .where('position', whereIn: restrictedPositions)
              .get();

      if (committeeSnapshot.docs.isNotEmpty) {
        for (QueryDocumentSnapshot<Map<String, dynamic>> documentSnapshot
            in committeeSnapshot.docs) {
          String position = documentSnapshot.data()['position'].toLowerCase();

          switch (position) {
            case 'president':
              presidentID.text = documentSnapshot.data()['studentID'];
              presidentName.text = documentSnapshot.data()['name'];
              break;
            case 'vice president':
              vpresidentID.text = documentSnapshot.data()['studentID'];
              vpresidentName.text = documentSnapshot.data()['name'];
              break;
            case 'secretary':
              secretaryID.text = documentSnapshot.data()['studentID'];
              secretaryName.text = documentSnapshot.data()['name'];
              break;
            case 'vice secretary':
              vsecretaryID.text = documentSnapshot.data()['studentID'];
              vsecretaryName.text = documentSnapshot.data()['name'];
              break;
            case 'treasurer':
              treasurerID.text = documentSnapshot.data()['studentID'];
              treasurerName.text = documentSnapshot.data()['name'];
              break;
            case 'vice treasurer':
              vtreasurerID.text = documentSnapshot.data()['studentID'];
              vtreasurerName.text = documentSnapshot.data()['name'];
              break;
            default:
              break;
          }
        }
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch data. Please try again.'),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
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

  Future<void> updateCommittee(
    String eventID,
    String studentID,
    String position,
    String committeeName,
    String contactNo,
  ) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot2 =
          await firestore.collection('user').where('id', isLessThan: 'A').get();

      querySnapshot2.docs.forEach((DocumentSnapshot document) {
        userList.add(document.data() as Map<String, dynamic>);
      });

      CollectionReference committee = firestore.collection('committee');

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await committee
          .where('position', isEqualTo: position)
          .where('eventID', isEqualTo: eventID)
          .get() as QuerySnapshot<Map<String, dynamic>>;

      if (querySnapshot.docs.isNotEmpty) {
        String committeeID = querySnapshot.docs[0].id;

        await committee.doc(committeeID).update({
          'name': committeeName,
          'position': position,
          'contact': contactNo,
          'studentID': studentID,
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to update committee. Please try again.'),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

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
                              'Change Committee',
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
                                                  'Event Name',
                                                  style:
                                                      TextStyle(fontSize: 16),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 4,
                                                child: CustomTextField(
                                                  enabled: false,
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
                                                child: RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode,
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
                                                child:RawAutocomplete<
                                                          String>(
                                                        focusNode: _focusNode2,
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
                                                  contactNo =
                                                      await getContactNo(
                                                          presidentID.text);
                                                  updateCommittee(
                                                      widget.selectedEvent,
                                                      presidentID.text,
                                                      'President',
                                                      presidentName.text,
                                                      contactNo);
                                                  contactNo =
                                                      await getContactNo(
                                                          vpresidentID.text);
                                                  updateCommittee(
                                                      widget.selectedEvent,
                                                      vpresidentID.text,
                                                      'Vice President',
                                                      vpresidentName.text,
                                                      contactNo);
                                                  contactNo =
                                                      await getContactNo(
                                                          secretaryID.text);
                                                  updateCommittee(
                                                      widget.selectedEvent,
                                                      secretaryID.text,
                                                      'Secretary',
                                                      secretaryName.text,
                                                      contactNo);
                                                  contactNo =
                                                      await getContactNo(
                                                          vsecretaryID.text);
                                                  updateCommittee(
                                                      widget.selectedEvent,
                                                      vsecretaryID.text,
                                                      'Vice Secretary',
                                                      vsecretaryName.text,
                                                      contactNo);
                                                  contactNo =
                                                      await getContactNo(
                                                          treasurerID.text);
                                                  updateCommittee(
                                                      widget.selectedEvent,
                                                      treasurerID.text,
                                                      'Treasurer',
                                                      treasurerName.text,
                                                      contactNo);
                                                  contactNo =
                                                      await getContactNo(
                                                          vtreasurerID.text);
                                                  await updateCommittee(
                                                      widget.selectedEvent,
                                                      vtreasurerID.text,
                                                      'Vice Treasurer',
                                                      vtreasurerName.text,
                                                      contactNo);
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          EventDetails(
                                                        selectedEvent: widget
                                                            .selectedEvent,
                                                      ),
                                                    ),
                                                  );
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          '${name.text}\'s committee has been updated.'),
                                                      width: 225.0,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration: const Duration(
                                                          seconds: 3),
                                                    ),
                                                  );
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Failed to update committee. Please try again.'),
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
                                          text: 'Change Committee',
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
