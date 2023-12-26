import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:another_flushbar/flushbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';

class OrgCommittee extends StatefulWidget {
  final String selectedEvent;
  final String status;
  final int progress;
  final String position;
  const OrgCommittee({
    super.key,
    required this.selectedEvent,
    required this.status,
    required this.progress,
    required this.position,
  });

  @override
  State<OrgCommittee> createState() => _OrgCommitteeState();
}

class _OrgCommitteeState extends State<OrgCommittee> {
  bool enabled = true;
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
  List<Map<String, dynamic>> userList = [];
  final FocusNode _focusNode = FocusNode();

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

      if (!widget.position.startsWith('org') ||
          widget.position.contains('Treasurer') ||
          widget.status != 'Planning' ||
          (widget.progress != 0)) {
        enabled = false;
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

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

      QuerySnapshot querySnapshot =
          await firestore.collection('user').where('id', isLessThan: 'A').get();

      querySnapshot.docs.forEach((DocumentSnapshot document) {
        userList.add(document.data() as Map<String, dynamic>);
      });

      setState(() {
        userList = userList;
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

  Future<void> displayFirstColumnValues(Uint8List bytes) async {
    String csvString = utf8.decode(bytes);
    List<List<dynamic>> csvTable =
        const CsvToListConverter().convert(csvString);

    List<int> rowsWithoutUser = [];
    List<int> registeredUser = [];
    List<int> blockedPosition = [];

    for (int rowIndex = 0; rowIndex < csvTable.length; rowIndex++) {
      List<dynamic> row = csvTable[rowIndex];
      if (row.isNotEmpty && row[0] != null) {
        String studentID = row[0].toString();
        String position = row[1].toString();

        Map<String, dynamic> user = userList.firstWhere(
          (user) => user['id'].toString() == studentID,
          orElse: () => {
            'id': '',
            'name': '',
            'contact': '',
          },
        );

        if (user['id'].isNotEmpty) {
          bool isParticipant = committeeList
              .any((committee) => committee.studentID == user['id']);
          if (!isParticipant &&
              !restrictedPositions.contains(position.toLowerCase())) {
            Committee newParticipants = Committee(
              studentID: user['id'].toString(),
              position: position,
              name: user['name'].toString(),
              contact: user['contact'].toString(),
            );
            committeeList.add(newParticipants);
            setState(() {
              committeeList = committeeList;
            });
          } else if (isParticipant) {
            registeredUser.add(rowIndex + 1);
          } else {
            blockedPosition.add(rowIndex + 1);
          }
        } else {
          rowsWithoutUser.add(rowIndex + 1);
        }
      }
    }
    String message = '';

    if (registeredUser.isNotEmpty) {
      message +=
          'Rows with Duplicate Participant: ${registeredUser.join(', ')}\n';
    }
    if (blockedPosition.isNotEmpty) {
      message += 'Rows with Blocked Position: ${blockedPosition.join(', ')}\n';
    }

    if (rowsWithoutUser.isNotEmpty) {
      message +=
          'Rows with Unknown Student ID: ${rowsWithoutUser.join(', ')}\n';
    }

    if (message.isNotEmpty) {
      Flushbar(
        message: message,
        duration: const Duration(seconds: 60),
        isDismissible: false,
        margin: EdgeInsets.all(50),
        borderRadius: BorderRadius.circular(8),
        maxWidth: 500,
        flushbarStyle: FlushbarStyle.FLOATING,
        mainButton: TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Dismiss'),
        ),
      ).show(context);
    }
  }

  Future<File?> pickCSVFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null) {
      if (result.files.single.extension?.toLowerCase() == 'csv') {
        if (result.files.single.bytes != null) {
          await displayFirstColumnValues(result.files.single.bytes!);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invalid file type. Please select a CSV file.'),
            width: 225.0,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
      }
      return null;
    } else {
      return null;
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
                                          status: widget.status,
                                          position: widget.position,
                                          progress: widget.progress,
                                          children: [
                                            if (enabled)
                                              Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.end,
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
                                                                      RawAutocomplete<
                                                                          String>(
                                                                    focusNode:
                                                                        _focusNode,
                                                                    textEditingController:
                                                                        id,
                                                                    optionsBuilder:
                                                                        (TextEditingValue
                                                                            textEditingValue) {
                                                                      return userList
                                                                          .map<String>((user) => user['id']
                                                                              .toString())
                                                                          .where((id) =>
                                                                              id.contains(textEditingValue.text))
                                                                          .toList();
                                                                    },
                                                                    onSelected:
                                                                        (String
                                                                            value) {
                                                                      onTextChanged(
                                                                          value,
                                                                          name,
                                                                          contact);
                                                                    },
                                                                    fieldViewBuilder: (BuildContext context,
                                                                        TextEditingController
                                                                            controller,
                                                                        FocusNode
                                                                            focusNode,
                                                                        VoidCallback
                                                                            onFieldSubmitted) {
                                                                      return TextFormField(
                                                                        validator:
                                                                            (value) {
                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return 'Please enter student ID';
                                                                          } else if (!RegExp(r'^\d{2}[A-Z]{3}\d{5}$')
                                                                              .hasMatch(value)) {
                                                                            return 'Invalid student ID';
                                                                          }
                                                                          return null;
                                                                        },
                                                                        controller:
                                                                            controller,
                                                                        focusNode:
                                                                            focusNode,
                                                                        onChanged:
                                                                            (value) {
                                                                          onTextChanged(
                                                                              value,
                                                                              name,
                                                                              contact);
                                                                        },
                                                                        decoration:
                                                                            InputDecoration(
                                                                          errorText:
                                                                              idError,
                                                                          enabledBorder:
                                                                              const OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(width: 1, color: Colors.grey),
                                                                          ),
                                                                          focusedBorder:
                                                                              const OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(width: 1, color: Colors.blue),
                                                                          ),
                                                                          errorBorder:
                                                                              const OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(width: 1, color: Colors.red),
                                                                          ),
                                                                          focusedErrorBorder:
                                                                              const OutlineInputBorder(
                                                                            borderSide:
                                                                                BorderSide(width: 1, color: Colors.red),
                                                                          ),
                                                                          labelText:
                                                                              'Student ID',
                                                                          hintText:
                                                                              'Enter student ID',
                                                                        ),
                                                                      );
                                                                    },
                                                                    optionsViewBuilder: (BuildContext context,
                                                                        AutocompleteOnSelected<String>
                                                                            onSelected,
                                                                        Iterable<String>
                                                                            options) {
                                                                      return Align(
                                                                        alignment:
                                                                            Alignment.topLeft,
                                                                        child:
                                                                            Material(
                                                                          elevation:
                                                                              4.0,
                                                                          child:
                                                                              ConstrainedBox(
                                                                            constraints:
                                                                                const BoxConstraints(
                                                                              maxWidth: 300,
                                                                              maxHeight: 250,
                                                                            ),
                                                                            child:
                                                                                ListView.builder(
                                                                              padding: const EdgeInsets.all(8.0),
                                                                              itemCount: options.length,
                                                                              itemBuilder: (BuildContext context, int index) {
                                                                                final String user = options.elementAt(index);
                                                                                return GestureDetector(
                                                                                  onTap: () {
                                                                                    onSelected(user);
                                                                                  },
                                                                                  child: ListTile(
                                                                                    title: Text(user),
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
                                                                      'Position',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                Expanded(
                                                                  flex: 4,
                                                                  child:
                                                                      CustomTextField(
                                                                    validator:
                                                                        (value) {
                                                                      if (value!
                                                                          .isEmpty) {
                                                                        return 'Please enter position';
                                                                      }

                                                                      if (restrictedPositions
                                                                          .contains(
                                                                              value.toLowerCase())) {
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
                                                        Tooltip(
                                                          message: "Column of CSV File : Student ID, Position",
                                                          child: CustomButton(
                                                              width: 150,
                                                              onPressed: () {
                                                                pickCSVFile();
                                                              },
                                                              text: 'Import CSV'),
                                                        ),
                                                        const SizedBox(
                                                          width: 15,
                                                        ),
                                                        CustomButton(
                                                            width: 150,
                                                            onPressed: () {
                                                              if (_formKey
                                                                  .currentState!
                                                                  .validate()) {
                                                                if (idError ==
                                                                    null) {
                                                                  Committee
                                                                      newCommittee =
                                                                      Committee(
                                                                    studentID:
                                                                        id.text,
                                                                    name: name
                                                                        .text,
                                                                    position:
                                                                        position
                                                                            .text,
                                                                    contact:
                                                                        contact
                                                                            .text,
                                                                  );

                                                                  committeeList.add(
                                                                      newCommittee);
                                                                  setState(() {
                                                                    committeeList =
                                                                        committeeList;
                                                                  });
                                                                  id.clear();
                                                                  name.clear();
                                                                  position
                                                                      .clear();
                                                                  contact
                                                                      .clear();
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
                                                    const Divider(
                                                      thickness: 0.1,
                                                      color: Colors.black,
                                                    ),
                                                  ]),
                                            Column(
                                              children: [
                                                Center(
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: DataTable(
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
                                                            label: Text('')),
                                                      ],
                                                      rows: committeeList
                                                          .asMap()
                                                          .entries
                                                          .map(
                                                            (entry) => DataRow(
                                                              cells: [
                                                                DataCell(Text(
                                                                    entry.value
                                                                        .name)),
                                                                DataCell(Text(entry
                                                                    .value
                                                                    .studentID)),
                                                                DataCell(Text(entry
                                                                    .value
                                                                    .position)),
                                                                DataCell(Text(
                                                                    '+60${entry.value.contact}')),
                                                                DataCell(
                                                                  Row(
                                                                    children: [
                                                                      if (!restrictedPositions.contains(entry
                                                                              .value
                                                                              .position
                                                                              .toLowerCase()) &&
                                                                          enabled)
                                                                        IconButton(
                                                                          icon:
                                                                              const Icon(Icons.edit),
                                                                          onPressed:
                                                                              () {
                                                                            showDialog(
                                                                              context: context,
                                                                              builder: (_) {
                                                                                return EditDialog(
                                                                                  committee: entry.value,
                                                                                  index: entry.key,
                                                                                  list: committeeList,
                                                                                  function: resetTable,
                                                                                  userList: userList,
                                                                                );
                                                                              },
                                                                            );
                                                                          },
                                                                        ),
                                                                      if (!restrictedPositions.contains(entry
                                                                              .value
                                                                              .position
                                                                              .toLowerCase()) &&
                                                                          enabled)
                                                                        IconButton(
                                                                          icon:
                                                                              const Icon(Icons.delete),
                                                                          onPressed:
                                                                              () {
                                                                            setState(() {
                                                                              committeeList.removeAt(entry.key);
                                                                            });
                                                                          },
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          )
                                                          .toList(),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (enabled)
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
                                                          in querySnapshot
                                                              .docs) {
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
                                                            committeeList[
                                                                index];

                                                        await committees.add({
                                                          'eventID': widget
                                                              .selectedEvent,
                                                          'studentID': committee
                                                              .studentID,
                                                          'name':
                                                              committee.name,
                                                          'position': committee
                                                              .position,
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
  final List<Map<String, dynamic>> userList;

  const EditDialog({
    required this.index,
    required this.committee,
    required this.function,
    required this.list,
    required this.userList,
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
  final FocusNode _focusNode = FocusNode();
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
            RawAutocomplete<String>(
              focusNode: _focusNode,
              textEditingController: id,
              optionsBuilder: (TextEditingValue textEditingValue) {
                return widget.userList
                    .map<String>((user) => user['id'].toString())
                    .where((id) => id.contains(textEditingValue.text))
                    .toList();
              },
              onSelected: (String value) {
                onTextChanged(value, name, contact);
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController controller,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted) {
                return TextFormField(
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter student ID';
                    } else if (!RegExp(r'^\d{2}[A-Z]{3}\d{5}$')
                        .hasMatch(value)) {
                      return 'Invalid student ID';
                    }
                    return null;
                  },
                  controller: controller,
                  focusNode: focusNode,
                  onChanged: (value) {
                    onTextChanged(value, name, contact);
                  },
                  decoration: InputDecoration(
                    errorText: idError,
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.blue),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.red),
                    ),
                    focusedErrorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(width: 1, color: Colors.red),
                    ),
                    labelText: 'Student ID',
                    hintText: 'Enter student ID',
                  ),
                );
              },
              optionsViewBuilder: (BuildContext context,
                  AutocompleteOnSelected<String> onSelected,
                  Iterable<String> options) {
                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 4.0,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 300,
                        maxHeight: 250,
                      ),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(8.0),
                        itemCount: options.length,
                        itemBuilder: (BuildContext context, int index) {
                          final String user = options.elementAt(index);
                          return GestureDetector(
                            onTap: () {
                              onSelected(user);
                            },
                            child: ListTile(
                              title: Text(user),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
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
