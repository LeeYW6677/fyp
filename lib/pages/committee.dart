import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/studentOrganisedEvent.dart';

class OrgCommittee extends StatefulWidget {
  final String selectedEvent;
  const OrgCommittee({super.key, required this.selectedEvent});

  @override
  State<OrgCommittee> createState() => _OrgCommitteeState();
}

class _OrgCommitteeState extends State<OrgCommittee> {
    int progress = -1;
  List<String> restrictedPositions = [
    'president',
    'vice president',
    'secretary',
    'vice secretary',
    'treasurer',
    'vice treasurer',
  ];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<Committee> committeeList = [];
  String status = '';

  void resetTable() {
    setState(() {
      committeeList = committeeList;
    });
  }

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch event data
      final QuerySnapshot<Map<String, dynamic>> eventSnapshot = await firestore
          .collection('event')
          .where('eventID', isEqualTo: widget.selectedEvent)
          .get();
      if (eventSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> eventData = eventSnapshot.docs.first.data();
        status = eventData['status'];
        progress = eventData['progress'];

        final QuerySnapshot<Map<String, dynamic>> committeeSnapshot =
            await firestore
                .collection('committee')
                .where('eventID', isEqualTo: widget.selectedEvent)
                .get();

        if (committeeSnapshot.docs.isNotEmpty) {
          committeeList = committeeSnapshot.docs
              .map((DocumentSnapshot<Map<String, dynamic>> doc) {
            return Committee(
              studentID: doc.data()!['studentID'],
              name: doc.data()!['name'],
              position: doc.data()!['position'],
              contact: doc.data()!['contact'],
            );
          }).toList();
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

  Future<void> onTextChanged(String value, TextEditingController name,
      TextEditingController contact) async {
    setState(() {
      idError = null;
    });
    bool isCommittee =
        committeeList.any((committee) => committee.studentID == value);
    if (isCommittee) {
      setState(() {
        idError = 'Already registered as committee';
      });
      return;
    }
    if (RegExp(r'^\d{2}[A-Z]{3}\d{5}$').hasMatch(value)) {
      DocumentSnapshot<Map<String, dynamic>> student =
          await FirebaseFirestore.instance.collection('user').doc(value).get();

      if (student.exists) {
        Map<String, dynamic> studentData = student.data()!;
        setState(() {
          name.text = studentData['name'];
          contact.text = studentData['contact'];
        });
      } else {
        setState(() {
          name.text = '';
          contact.text = '';
        });
      }
    } else {
      setState(() {
        name.text = '';
        contact.text = '';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  final id = TextEditingController();
  final name = TextEditingController();
  final contact = TextEditingController();
  final position = TextEditingController();
  String? idError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      drawer: !Responsive.isDesktop(context)
          ? const CustomDrawer(
              index: 2,
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
                      ),
                    ),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        NavigationMenu(
                          buttonTexts: const ['Event', 'Committee'],
                          destination: [
                            const StudentOrganisedEvent(),
                            OrgCommittee(selectedEvent: widget.selectedEvent)
                          ],
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Event Details',
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
                                      child: TabContainer(
                                          selectedEvent: widget.selectedEvent,
                                          tab: 'Pre',
                                          form: 'Committee',
                                          status: status,
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (Responsive
                                                            .isDesktop(context))
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
                                                          child:
                                                              CustomTextField(
                                                            hintText:
                                                                'Enter Student ID',
                                                            controller: id,
                                                            errorText: idError,
                                                            screen: !Responsive
                                                                .isDesktop(
                                                                    context),
                                                            labelText:
                                                                'Student ID',
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
                                                            onChanged: (value) {
                                                              onTextChanged(
                                                                  value,
                                                                  name,
                                                                  contact);
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (Responsive
                                                            .isDesktop(context))
                                                          const Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              'Position',
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                        Expanded(
                                                          flex: 4,
                                                          child:
                                                              CustomTextField(
                                                            validator: (value) {
                                                              if (value!
                                                                  .isEmpty) {
                                                                return 'Please enter position';
                                                              }

                                                              if (restrictedPositions
                                                                  .contains(value
                                                                      .toLowerCase())) {
                                                                return 'Position not allowed';
                                                              }

                                                              return null;
                                                            },
                                                            screen: !Responsive
                                                                .isDesktop(
                                                                    context),
                                                            labelText:
                                                                'Position',
                                                            controller:
                                                                position,
                                                            hintText:
                                                                'Enter position',
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (Responsive
                                                            .isDesktop(context))
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
                                                          child:
                                                              CustomTextField(
                                                            screen: !Responsive
                                                                .isDesktop(
                                                                    context),
                                                            enabled: false,
                                                            labelText: 'Name',
                                                            controller: name,
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
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      children: [
                                                        if (Responsive
                                                            .isDesktop(context))
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
                                                          child:
                                                              CustomTextField(
                                                            screen: !Responsive
                                                                .isDesktop(
                                                                    context),
                                                            prefixText: '+60',
                                                            labelText:
                                                                'Contact No.',
                                                            enabled: false,
                                                            controller: contact,
                                                            hintText:
                                                                'Associated Contact No.',
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
                                                CustomButton(
                                                    width: 150,
                                                    onPressed: () {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        if (idError == null) {
                                                          Committee
                                                              newCommittee =
                                                              Committee(
                                                            studentID: id.text,
                                                            name: name.text,
                                                            position:
                                                                position.text,
                                                            contact:
                                                                contact.text,
                                                          );

                                                          committeeList.add(
                                                              newCommittee);
                                                          setState(() {
                                                            committeeList =
                                                                committeeList;
                                                          });
                                                          id.clear();
                                                          name.clear();
                                                          position.clear();
                                                          contact.clear();
                                                        }
                                                      }
                                                    },
                                                    text: 'Add'),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Column(
                                              children: [
                                                Center(
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: DataTable(
                                                      border: TableBorder.all(
                                                        width: 1,
                                                        style:
                                                            BorderStyle.solid,
                                                      ),
                                                      columns: const [
                                                        DataColumn(
                                                            label:
                                                                Text('Name')),
                                                        DataColumn(
                                                            label: Text(
                                                                'Student ID')),
                                                        DataColumn(
                                                            label: Text(
                                                                'Position')),
                                                        DataColumn(
                                                            label: Text(
                                                                'Contact No.')),
                                                        DataColumn(
                                                            label:
                                                                Text('Action')),
                                                      ],
                                                      rows: committeeList
                                                          .asMap()
                                                          .entries
                                                          .map((entry) {
                                                        final int index =
                                                            entry.key;
                                                        final Committee
                                                            committee =
                                                            entry.value;

                                                        return DataRow(
                                                          cells: [
                                                            DataCell(Text(
                                                                committee
                                                                    .name)),
                                                            DataCell(Text(
                                                                committee
                                                                    .studentID)),
                                                            DataCell(Text(
                                                                committee
                                                                    .position)),
                                                            DataCell(Text(
                                                                '+60${committee.contact}')),
                                                            DataCell(Row(
                                                              children: [
                                                                if (!restrictedPositions
                                                                    .contains(committee
                                                                        .position
                                                                        .toLowerCase()))
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .edit),
                                                                    onPressed:
                                                                        () {
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (_) {
                                                                            return EditDialog(
                                                                              committee: committee,
                                                                              index: index,
                                                                              list: committeeList,
                                                                              function: resetTable,
                                                                            );
                                                                          });
                                                                    },
                                                                  ),
                                                                if (!restrictedPositions
                                                                    .contains(committee
                                                                        .position
                                                                        .toLowerCase()))
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .delete),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        committeeList
                                                                            .removeAt(index);
                                                                      });
                                                                    },
                                                                  ),
                                                              ],
                                                            )),
                                                          ],
                                                        );
                                                      }).toList(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            CustomButton(
                                                width: 150,
                                                onPressed: () async {
                                                  if (committeeList
                                                      .isNotEmpty) {
                                                    FirebaseFirestore
                                                        firestore =
                                                        FirebaseFirestore
                                                            .instance;

                                                    CollectionReference
                                                        committees =
                                                        firestore.collection(
                                                            'committee');

                                                    QuerySnapshot
                                                        querySnapshot =
                                                        await committees
                                                            .where('eventID',
                                                                isEqualTo: widget
                                                                    .selectedEvent)
                                                            .get();

                                                    for (QueryDocumentSnapshot documentSnapshot
                                                        in querySnapshot.docs) {
                                                      await documentSnapshot
                                                          .reference
                                                          .delete();
                                                    }

                                                    for (int index = 0;
                                                        index <
                                                            committeeList
                                                                .length;
                                                        index++) {
                                                      Committee committee =
                                                          committeeList[index];

                                                      await committees.add({
                                                        'eventID': widget
                                                            .selectedEvent,
                                                        'studentID':
                                                            committee.studentID,
                                                        'name': committee.name,
                                                        'position':
                                                            committee.position,
                                                        'contact':
                                                            committee.contact,
                                                      });
                                                    }
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Committee List saved.'),
                                                        width: 150.0,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        duration: Duration(
                                                            seconds: 3),
                                                      ),
                                                    );
                                                  }
                                                },
                                                text: 'Save'),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            const Divider(
                                                thickness: 0.1,
                                                color: Colors.black),
                                            CustomTimeline(
                                              status: status,
                                              progress: progress,
                                              eventID: widget.selectedEvent,
                                            ),
                                          ])),
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

class Committee {
  String studentID;
  String position;
  String name;
  String contact;

  Committee(
      {required this.studentID,
      required this.position,
      required this.name,
      required this.contact});
}

class EditDialog extends StatefulWidget {
  final Committee committee;
  final int index;
  final VoidCallback function;
  final List<Committee> list;

  const EditDialog({
    required this.index,
    required this.committee,
    required this.function,
    required this.list,
  });
  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController id = TextEditingController();
  TextEditingController contact = TextEditingController();
  TextEditingController position = TextEditingController();
  String? idError;
  List<String> restrictedPositions = [
    'president',
    'vice president',
    'secretary',
    'vice secretary',
    'treasurer',
    'vice treasurer',
  ];

  @override
  void initState() {
    super.initState();
    name.text = widget.committee.name;
    id.text = widget.committee.studentID;
    position.text = widget.committee.position;
    contact.text = widget.committee.contact;
  }

  Future<void> onTextChanged(String value, TextEditingController name,
      TextEditingController contact) async {
    setState(() {
      idError = null;
    });
    bool isCommittee =
        widget.list.any((committee) => committee.studentID == value);
    if (isCommittee) {
      setState(() {
        idError = 'Already registered as committee';
      });
      return;
    }
    if (RegExp(r'^\d{2}[A-Z]{3}\d{5}$').hasMatch(value)) {
      DocumentSnapshot<Map<String, dynamic>> student =
          await FirebaseFirestore.instance.collection('user').doc(value).get();

      if (student.exists) {
        Map<String, dynamic> studentData = student.data()!;
        setState(() {
          name.text = studentData['name'];
          contact.text = studentData['contact'];
        });
      } else {
        setState(() {
          name.text = '';
          contact.text = '';
        });
      }
    } else {
      setState(() {
        name.text = '';
        contact.text = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Committee Details'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              hintText: 'Enter Student ID',
              controller: id,
              errorText: idError,
              screen: true,
              labelText: 'Student ID',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter student ID';
                } else if (!RegExp(r'^\d{2}[A-Z]{3}\d{5}$').hasMatch(value)) {
                  return 'Invalid student ID';
                }
                return null;
              },
              onChanged: (value) {
                onTextChanged(value, name, contact);
              },
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              screen: true,
              enabled: false,
              labelText: 'Name',
              controller: name,
              hintText: 'Associated Student Name',
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              screen: true,
              prefixText: '+60',
              labelText: 'Contact No.',
              enabled: false,
              controller: contact,
              hintText: 'Associated Contact No.',
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter position';
                }

                if (restrictedPositions.contains(value.toLowerCase())) {
                  return 'Position not allowed';
                }

                return null;
              },
              screen: true,
              labelText: 'Position',
              controller: position,
              hintText: 'Enter position',
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (idError == null) {
                Committee newCommittee = Committee(
                  studentID: id.text,
                  name: name.text,
                  position: position.text,
                  contact: contact.text,
                );

                widget.list[widget.index] = newCommittee;
                widget.function();
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
