import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';

class Participant extends StatefulWidget {
  final String selectedEvent;
  final String status;
  final int progress;
  final String position;
  final bool rejected;
  final bool rejected2;
  const Participant(
      {super.key,
      required this.selectedEvent,
      required this.status,
      required this.progress,
      required this.position,
      required this.rejected,
      required this.rejected2});

  @override
  State<Participant> createState() => _ParticipantState();
}

class _ParticipantState extends State<Participant> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  bool enabled = true;
  final id = TextEditingController();
  final name = TextEditingController();
  final contact = TextEditingController();
  List<Participants> participantList = [];
  String? idError;
  List<String> checkName = [];
  List<String> checkStatus = [];

  void resetTable() {
    setState(() {
      participantList = participantList;
    });
  }

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (!widget.position.startsWith('org') ||
          widget.position.contains('Treasurer') ||
          widget.status != 'Closing' ||
          (widget.progress != 0 && !widget.rejected2)) {
        enabled = false;
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot<Map<String, dynamic>> participantSnapshot =
          await firestore
              .collection('participant')
              .where('eventID', isEqualTo: widget.selectedEvent)
              .get();

      if (participantSnapshot.docs.isNotEmpty) {
        participantList = participantSnapshot.docs
            .map((DocumentSnapshot<Map<String, dynamic>> doc) {
          return Participants(
            studentID: doc.data()!['studentID'],
            name: doc.data()!['name'],
            contact: doc.data()!['contact'],
          );
        }).toList();
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
    bool isParticipant =
        participantList.any((participant) => participant.studentID == value);
    if (isParticipant) {
      setState(() {
        idError = 'Already registered as participant';
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
                                          tab: 'Post',
                                          form: 'Participant',
                                          status: widget.status,
                                          position: widget.position,
                                          progress: widget.progress,
                                          rejected2: widget.rejected2,
                                          rejected: widget.rejected,
                                          children: [
                                            if (enabled)
                                              Column(
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              if (Responsive
                                                                  .isDesktop(
                                                                      context))
                                                                const Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                    'Student ID',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                flex: 4,
                                                                child:
                                                                    CustomTextField(
                                                                  hintText:
                                                                      'Enter Student ID',
                                                                  controller:
                                                                      id,
                                                                  errorText:
                                                                      idError,
                                                                  screen: !Responsive
                                                                      .isDesktop(
                                                                          context),
                                                                  labelText:
                                                                      'Student ID',
                                                                  validator:
                                                                      (value) {
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
                                                                  onChanged:
                                                                      (value) {
                                                                    onTextChanged(
                                                                        value,
                                                                        name,
                                                                        contact);
                                                                  },
                                                                ),
                                                              ),
                                                              if (Responsive
                                                                  .isDesktop(
                                                                      context))
                                                                const Expanded(
                                                                    flex: 1,
                                                                    child:
                                                                        SizedBox()),
                                                              const Expanded(
                                                                  flex: 4,
                                                                  child:
                                                                      SizedBox()),
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
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              if (Responsive
                                                                  .isDesktop(
                                                                      context))
                                                                const Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                    'Name',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                flex: 4,
                                                                child:
                                                                    CustomTextField(
                                                                  screen: !Responsive
                                                                      .isDesktop(
                                                                          context),
                                                                  enabled:
                                                                      false,
                                                                  labelText:
                                                                      'Name',
                                                                  controller:
                                                                      name,
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
                                                              const EdgeInsets
                                                                  .all(8.0),
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .center,
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .start,
                                                            children: [
                                                              if (Responsive
                                                                  .isDesktop(
                                                                      context))
                                                                const Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                    'Contact No.',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                flex: 4,
                                                                child:
                                                                    CustomTextField(
                                                                  screen: !Responsive
                                                                      .isDesktop(
                                                                          context),
                                                                  prefixText:
                                                                      '+60',
                                                                  labelText:
                                                                      'Contact No.',
                                                                  enabled:
                                                                      false,
                                                                  controller:
                                                                      contact,
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
                                                            if (_formKey
                                                                .currentState!
                                                                .validate()) {
                                                              if (idError ==
                                                                  null) {
                                                                Participants
                                                                    newParticipants =
                                                                    Participants(
                                                                  studentID:
                                                                      id.text,
                                                                  name:
                                                                      name.text,
                                                                  contact:
                                                                      contact
                                                                          .text,
                                                                );

                                                                participantList.add(
                                                                    newParticipants);
                                                                setState(() {
                                                                  participantList =
                                                                      participantList;
                                                                });
                                                                id.clear();
                                                                name.clear();
                                                                contact.clear();
                                                              }
                                                            }
                                                          },
                                                          text: 'Add'),
                                                    ],
                                                  ),
                                                  const SizedBox(
                                                    height: 15,
                                                  ),
                                                  const Divider(
                                                    thickness: 0.1,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                            Column(
                                              children: [
                                                Center(
                                                  child: participantList
                                                          .isNotEmpty
                                                      ? SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: DataTable(
                                                            columns: const [
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Name')),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Student ID')),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Contact No.')),
                                                              DataColumn(
                                                                  label:
                                                                      Text('')),
                                                            ],
                                                            rows: participantList
                                                                .asMap()
                                                                .entries
                                                                .map((entry) {
                                                              final int index =
                                                                  entry.key;
                                                              final Participants
                                                                  participant =
                                                                  entry.value;

                                                              return DataRow(
                                                                cells: [
                                                                  DataCell(Text(
                                                                      participant
                                                                          .name)),
                                                                  DataCell(Text(
                                                                      participant
                                                                          .studentID)),
                                                                  DataCell(Text(
                                                                      '+60${participant.contact}')),
                                                                  DataCell(Row(
                                                                    children: [
                                                                      if (enabled)
                                                                        IconButton(
                                                                          icon:
                                                                              const Icon(Icons.edit),
                                                                          onPressed:
                                                                              () {
                                                                            showDialog(
                                                                                context: context,
                                                                                builder: (_) {
                                                                                  return EditDialog(
                                                                                    participant: participant,
                                                                                    index: index,
                                                                                    list: participantList,
                                                                                    function: resetTable,
                                                                                  );
                                                                                });
                                                                          },
                                                                        ),
                                                                      if (enabled)
                                                                        IconButton(
                                                                          icon:
                                                                              const Icon(Icons.delete),
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              participantList.removeAt(index);
                                                                            });
                                                                          },
                                                                        ),
                                                                    ],
                                                                  )),
                                                                ],
                                                              );
                                                            }).toList(),
                                                          ),
                                                        )
                                                      : const SizedBox(
                                                          height: 500,
                                                          child: Center(
                                                              child: Text(
                                                                  'There is no participant registered.'))),
                                                ),
                                              ],
                                            ),
                                            if (enabled)
                                              CustomButton(
                                                  width: 150,
                                                  onPressed: () async {
                                                    if (participantList
                                                        .isNotEmpty) {
                                                      FirebaseFirestore
                                                          firestore =
                                                          FirebaseFirestore
                                                              .instance;

                                                      CollectionReference
                                                          participants =
                                                          firestore.collection(
                                                              'participant');

                                                      QuerySnapshot
                                                          querySnapshot =
                                                          await participants
                                                              .where('eventID',
                                                                  isEqualTo: widget
                                                                      .selectedEvent)
                                                              .get();

                                                      for (QueryDocumentSnapshot documentSnapshot
                                                          in querySnapshot
                                                              .docs) {
                                                        await documentSnapshot
                                                            .reference
                                                            .delete();
                                                      }

                                                      for (int index = 0;
                                                          index <
                                                              participantList
                                                                  .length;
                                                          index++) {
                                                        Participants person =
                                                            participantList[
                                                                index];

                                                        await participants.add({
                                                          'eventID': widget
                                                              .selectedEvent,
                                                          'studentID':
                                                              person.studentID,
                                                          'name': person.name,
                                                          'contact':
                                                              person.contact,
                                                        });
                                                      }
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Participant List saved.'),
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

class Participants {
  String studentID;
  String name;
  String contact;

  Participants(
      {required this.studentID, required this.name, required this.contact});
}

class EditDialog extends StatefulWidget {
  final Participants participant;
  final int index;
  final VoidCallback function;
  final List<Participants> list;

  const EditDialog({
    required this.index,
    required this.participant,
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
  String? idError;

  @override
  void initState() {
    super.initState();
    name.text = widget.participant.name;
    id.text = widget.participant.studentID;
    contact.text = widget.participant.contact;
  }

  Future<void> onTextChanged(String value, TextEditingController name,
      TextEditingController contact) async {
    setState(() {
      idError = null;
    });
    bool isParticipant =
        widget.list.any((participant) => participant.studentID == value);
    if (isParticipant) {
      setState(() {
        idError = 'Already registered as participant';
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
      title: const Text('Edit Participant Details'),
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
                Participants newParticipant = Participants(
                  studentID: id.text,
                  name: name.text,
                  contact: contact.text,
                );

                widget.list[widget.index] = newParticipant;
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
