import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:intl/intl.dart';

class Society extends StatefulWidget {
  const Society({super.key});

  @override
  State<Society> createState() => _SocietyState();
}

class _SocietyState extends State<Society> {
  final society = TextEditingController();
  String selectedSociety = 'S001';
  List<String> AdvisorNames = [''];
  List<String> coAdvisorNames = ['', ''];
  List<Map<String, dynamic>> _members = [];
  List<String> societyIDs = [];
  List<String> societyNames = [];
  List<String> positionOrder = [
    'President',
    'Vice President',
    'Secretary',
    'Vice Secretary',
    'Treasurer',
    'Vice Treasurer',
    'Member',
  ];

  String getSocietyNameById(String societyID) {
    int index = societyIDs.indexOf(societyID);
    if (index != -1 && index < societyNames.length) {
      return societyNames[index];
    } else {
      return 'Unknown Society';
    }
  }

  Future<void> _showInputDialog(BuildContext context) async {
    TextEditingController name = TextEditingController();
    TextEditingController id = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Member'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CustomTextField(
                  controller: id,
                  hintText: 'Enter student ID',
                  onChanged: (value) async {
                    FirebaseFirestore firestore = FirebaseFirestore.instance;
                    DocumentSnapshot<Map<String, dynamic>> student =
                        await FirebaseFirestore.instance
                            .collection('user')
                            .doc(id.text)
                            .get();

                    if (student.exists) {
                      Map<String, dynamic> studentData = student.data()!;
                      name.text = studentData['name'];
                    } else {
                      name.text = '';
                    }
                  },
                ),
                const SizedBox(height: 10),
                CustomTextField(
                  controller: name,
                  hintText: 'Associated Student Name',
                  enabled: false,
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
                QuerySnapshot<Map<String, dynamic>> existingMembers =
                    await FirebaseFirestore.instance
                        .collection('members')
                        .where('studentID', isEqualTo: id.text)
                        .where('societyID', isEqualTo: selectedSociety)
                        .get();

                if (existingMembers.docs.isEmpty) {
                  await FirebaseFirestore.instance.collection('members').add({
                    'studentID': id.text,
                    'societyID': selectedSociety,
                    'position': 'member'
                  });

                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Student already registered as member.'),
                      width: 225.0,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> getData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      QuerySnapshot society = await firestore
          .collection('member')
          .where('studentID', isEqualTo: UserRole.id)
          .get();

      societyIDs = List<String>.from(
          society.docs.map((doc) => doc['societyID'].toString()));


      QuerySnapshot societySnapshot = await firestore
          .collection('society')
          .where('societyID', whereIn: societyIDs)
          .get();

      societyNames = societySnapshot.docs
          .map((doc) => doc['societyName'].toString())
          .toList();
      QuerySnapshot advisor = await firestore
          .collection('user')
          .where('societyID', isEqualTo: selectedSociety)
          .get();

      AdvisorNames.clear();
      coAdvisorNames.clear();

      AdvisorNames.addAll(getPositionValues(advisor, 'Advisor'));
      coAdvisorNames.addAll(getPositionValues(advisor, 'Co-advisor'));

      QuerySnapshot<Map<String, dynamic>> members = await FirebaseFirestore
          .instance
          .collection('member')
          .where('societyID', isEqualTo: selectedSociety)
          .get();

      for (QueryDocumentSnapshot<Map<String, dynamic>> memberDocSnapshot
          in members.docs) {
        String studentID = memberDocSnapshot['studentID'];

        DocumentSnapshot<Map<String, dynamic>> memberDetails =
            await FirebaseFirestore.instance
                .collection('user')
                .doc(studentID)
                .get();
        if (memberDetails.exists) {
          Map<String, dynamic> userData = memberDetails.data()!;
          userData['position'] = memberDocSnapshot['position'];
          _members.add(userData);
        }

        _members.sort((a, b) {
          String positionA = a['position'] ?? 'Member';
          String positionB = b['position'] ?? 'Member';

          int indexA = positionOrder.indexOf(positionA);
          int indexB = positionOrder.indexOf(positionB);

          if (indexA == -1) indexA = positionOrder.length;
          if (indexB == -1) indexB = positionOrder.length;

          return indexA.compareTo(indexB);
        });
        setState(() {
          _members = _members;
        });
      }
    } catch (error) {
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

  List<String> getPositionValues(QuerySnapshot data, String targetPosition) {
    List<String> names = [];

    for (QueryDocumentSnapshot doc in data.docs) {
      if (doc['position'] == targetPosition) {
        setState(() {
          names.add(doc['name']);
        });
      }
    }

    return names;
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
              index: 2,
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
                ),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(children: [
                  const NavigationMenu(
                    buttonTexts: ['Society'],
                    destination: [Society()],
                  ),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Society',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Divider(
                              thickness: 0.1,
                              color: Colors.black,
                            ),
                            Row(
                              children: [
                                const Text('View'),
                                const SizedBox(
                                  width: 15,
                                ),
                                SizedBox(
                                    width: 400,
                                    child: DropdownButton<String>(
                                      value: selectedSociety,
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedSociety = newValue!;
                                        });
                                      },
                                      items: societyIDs.map((societyID) {
                                        String societyName =
                                            getSocietyNameById(societyID);

                                        return DropdownMenuItem<String>(
                                          value: societyID,
                                          child: Text(societyName),
                                        );
                                      }).toList(),
                                    ))
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        LayoutBuilder(
                                            builder: (context, constraints) {
                                          if (!Responsive.isMobile(context)) {
                                            return Column(
                                              children: [
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
                                                        AdvisorNames[0],
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
                                                        coAdvisorNames[0],
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
                                                        coAdvisorNames[1],
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            );
                                          } else {
                                            return Column(
                                              children: [
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
                                                        AdvisorNames[0],
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
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
                                                        coAdvisorNames[0],
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 2,
                                                      child: Container(),
                                                    ),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Text(
                                                        coAdvisorNames[1],
                                                        style: const TextStyle(
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ],
                                            );
                                          }
                                        }),
                                        const Row(
                                          children: [
                                            SizedBox(height: 10),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: CustomDataTable(
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text('Name'),
                                                    ),
                                                    DataColumn(
                                                        label: Text('Email')),
                                                    DataColumn(
                                                        label: Text('IC No.')),
                                                    DataColumn(
                                                        label: Text('Gender')),
                                                    DataColumn(
                                                        label: Text(
                                                            'Date of Birth')),
                                                    DataColumn(
                                                        label: Text('Contact')),
                                                    DataColumn(
                                                        label:
                                                            Text('Position')),
                                                  ],
                                                  source: _MembersDataSource(
                                                      _members),
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
                                              onPressed: () {
                                                _showInputDialog(context);
                                              },
                                              text: 'Add',
                                              buttonColor: Colors.green,
                                              width: 100,
                                            ),
                                            const SizedBox(
                                              width: 25,
                                            ),
                                            CustomButton(
                                              onPressed: () {},
                                              text: 'Edit',
                                              width: 100,
                                            ),
                                            const SizedBox(
                                              width: 25,
                                            ),
                                            CustomButton(
                                              onPressed: () {},
                                              text: 'Delete',
                                              buttonColor: Colors.red,
                                              width: 100,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )),
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

class CustomDataTable extends StatefulWidget {
  final List<DataColumn> columns;
  final _MembersDataSource source;

  const CustomDataTable({
    Key? key,
    required this.columns,
    required this.source,
  }) : super(key: key);

  @override
  _CustomDataTableState createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  int selectedRowsPerPage = 10;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final search = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PaginatedDataTable(
          header: Row(
            children: [
              const Text(
                'Rows per page: ',
                style: TextStyle(fontSize: 16),
              ),
              DropdownButton<int>(
                value: selectedRowsPerPage,
                onChanged: (value) {
                  setState(() {
                    selectedRowsPerPage = value!;
                    widget.source.rowsPerPage = value;
                  });
                },
                items: [10, 20, 50].map((rows) {
                  return DropdownMenuItem<int>(
                    value: rows,
                    child: Text('$rows'),
                  );
                }).toList(),
              ),
              const Spacer(),
              SizedBox(
                width: 200,
                child: CustomTextField(
                  hintText: 'Search by any field',
                  controller: search,
                  onChanged: (value) {
                    setState(() {
                      widget.source.filter(value);
                    });
                  },
                ),
              ),
            ],
          ),
          showCheckboxColumn: true,
          rowsPerPage: selectedRowsPerPage,
          columns: widget.columns.map((column) {
            return DataColumn(
              label: column.label,
              onSort: (int columnIndex, bool ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  widget.source.sort(
                    (Map<String, dynamic> member) {
                      switch (columnIndex) {
                        case 0:
                          return member['name'];
                        case 1:
                          return member['email'];
                        case 2:
                          return member['ic'];
                        case 3:
                          return member['gender'];
                        case 4:
                          return member['dob'];
                        case 5:
                          return member['contact'];
                        case 6:
                          return member['position'];
                        default:
                          return '';
                      }
                    },
                    columnIndex,
                    ascending,
                  );
                });
              },
            );
          }).toList(),
          source: widget.source,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
        ),
      ],
    );
  }
}

class _MembersDataSource extends DataTableSource {
  final List<Map<String, dynamic>> originalMembers;
  List<Map<String, dynamic>> displayedMembers = [];
  final Set<int> selectedRows = {};
  int rowsPerPage = 10;
  List<String> positionOrder = [
    'President',
    'Vice President',
    'Secretary',
    'Vice Secretary',
    'Treasurer',
    'Vice Treasurer',
    'Member',
  ];

  _MembersDataSource(this.originalMembers) {
    _initializeDisplayedMembers();
  }

  void _initializeDisplayedMembers() {
    displayedMembers.addAll(originalMembers);
  }

  @override
  DataRow? getRow(int index) {
    if (index >= displayedMembers.length) {
      return null;
    }
    final member = displayedMembers[index];
    return DataRow(
      cells: [
        DataCell(Text(member['name'].toString())),
        DataCell(Text(member['email'].toString())),
        DataCell(Text(member['ic'].toString())),
        DataCell(Text(member['gender'].toString())),
        DataCell(Text(
          (member['dob'] != null)
              ? DateFormat('dd-MM-yyyy')
                  .format((member['dob'] as Timestamp).toDate())
              : '',
        )),
        DataCell(Text(member['contact'].toString())),
        DataCell(Text(member['position'].toString())),
      ],
      selected: selectedRows.contains(index),
      onSelectChanged: (bool? isSelected) {
        if (isSelected != null) {
          onSelectedRow(index, isSelected);
        }
      },
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => displayedMembers.length;

  @override
  int get selectedRowCount => selectedRows.length;

  void onSelectedRow(int index, bool isSelected) {
    if (isSelected) {
      selectedRows.add(index);
    } else {
      selectedRows.remove(index);
    }
    notifyListeners();
  }

  void filter(String query) {
    displayedMembers.clear();
    displayedMembers.addAll(originalMembers.where((member) {
      return member.values.any((value) {
        if (value is Timestamp) {
          String formattedDate =
              DateFormat('dd-MM-yyyy').format(value.toDate());
          return formattedDate.toLowerCase().contains(query.toLowerCase());
        } else {
          return value.toString().toLowerCase().contains(query.toLowerCase());
        }
      });
    }));
    notifyListeners();
  }

  void sort<T>(
    Comparable<T> Function(Map<String, dynamic>) getField,
    int columnIndex,
    bool ascending,
  ) {
    displayedMembers.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      if (columnIndex == 6) {
        return ascending
            ? positionOrder.indexOf(aValue as String) -
                positionOrder.indexOf(bValue as String)
            : positionOrder.indexOf(bValue as String) -
                positionOrder.indexOf(aValue as String);
      }

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }
}
