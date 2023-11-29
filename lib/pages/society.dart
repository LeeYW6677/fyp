import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/addSociety.dart';
import 'package:fyp/pages/ongoingEvent.dart';

class Society extends StatefulWidget {
  const Society({super.key});

  @override
  State<Society> createState() => _SocietyState();

  static _SocietyState? of(BuildContext context) {
    return context.findAncestorStateOfType<_SocietyState>();
  }
}

class _SocietyState extends State<Society> {
  final society = TextEditingController();
    bool _isLoading = true;
  String selectedSociety = '';
  List<Map<String, dynamic>> advisorList = [];
  List<Map<String, dynamic>> coAdvisorList = [];
  List<Map<String, dynamic>> allAdvisor = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> highcomm = [];
  List<Map<String, dynamic>> lowcomm = [];
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

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot societySnapshot =
          await firestore.collection('society').get();

      societyIDs = societySnapshot.docs
          .map((doc) => doc['societyID'].toString())
          .toSet()
          .toList();
      selectedSociety = societyIDs[0];

      societyNames = societySnapshot.docs
          .map((doc) => doc['societyName'].toString())
          .toList();
      fetchSocietyDetails();
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

  Future<void> fetchSocietyDetails() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Fetch advisor data
      final QuerySnapshot<Map<String, dynamic>> advisorSnapshot =
          await firestore
              .collection('user')
              .where('societyID', isEqualTo: selectedSociety)
              .where('position', whereIn: ['Advisor', 'Co-advisor']).get();

      advisorList.clear();
      coAdvisorList.clear();
      for (var docSnapshot in advisorSnapshot.docs) {
        Map<String, dynamic> userData = docSnapshot.data();

        String position = userData['position'];
        if (position == 'Advisor') {
          advisorList.add(userData);
        } else if (position == 'Co-advisor') {
          coAdvisorList.add(userData);
        }
      }

      allAdvisor.clear();

      setState(() {
        allAdvisor.addAll(advisorList);
        allAdvisor.addAll(coAdvisorList);
      });

      // Fetch member data
      final QuerySnapshot<Map<String, dynamic>> membersSnapshot =
          await FirebaseFirestore.instance
              .collection('member')
              .where('societyID', isEqualTo: selectedSociety)
              .get();

      _members =
          await Future.wait(membersSnapshot.docs.map((memberDocSnapshot) async {
        final String studentID = memberDocSnapshot['studentID'];

        final DocumentSnapshot<Map<String, dynamic>> memberDetails =
            await FirebaseFirestore.instance
                .collection('user')
                .doc(studentID)
                .get();

        if (memberDetails.exists) {
          final Map<String, dynamic> userData = memberDetails.data()!;
          userData['studentID'] = memberDocSnapshot['studentID'];
          userData['position'] = memberDocSnapshot['position'];
          return userData;
        }

        return <String, dynamic>{};
      }));

      //arrange members
      _members.sort((a, b) {
        String positionA = a['position'] ?? 'Member';
        String positionB = b['position'] ?? 'Member';

        int indexA = positionOrder.indexOf(positionA);
        int indexB = positionOrder.indexOf(positionB);

        if (indexA == -1) indexA = positionOrder.length;
        if (indexB == -1) indexB = positionOrder.length;

        return indexA.compareTo(indexB);
      });

      highcomm =
          _members.where((member) => member['position'] != 'Member').toList();
      lowcomm =
          _members.where((member) => member['position'] == 'Member').toList();
      setState(() {
        _members = _members;
      });
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

  String getSocietyNameById(String societyID) {
    int index = societyIDs.indexOf(societyID);
    if (index != -1 && index < societyNames.length) {
      return societyNames[index];
    } else {
      return 'Unknown Society';
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
                    page: 'Society',
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
                                          width: 300,
                                          child: CustomDDL<String>(
                                            controller: society,
                                            hintText: 'Select society',
                                            value: selectedSociety,
                                            onChanged: (String? newValue) {
                                              setState(() {
                                                selectedSociety = newValue!;
                                                fetchSocietyDetails();
                                              });
                                            },
                                            dropdownItems:
                                                societyIDs.map((societyID) {
                                              String societyName =
                                                  getSocietyNameById(societyID);

                                              return DropdownMenuItem<String>(
                                                value: societyID,
                                                child: Text(societyName,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              );
                                            }).toList(),
                                          )),
                                    ],
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const AddSociety(),
                                            ),
                                          );
                                        },
                                        text: 'Add Society',
                                        width: 100,
                                        buttonColor: Colors.green,
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      CustomButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => OngoingEvent(
                                                selectedSociety:
                                                    selectedSociety,
                                              ),
                                            ),
                                          );
                                        },
                                        text: 'View Event',
                                        width: 100,
                                      ),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                    ],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0),
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
                                              LayoutBuilder(builder:
                                                  (context, constraints) {
                                                if (!Responsive.isMobile(
                                                    context)) {
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
                                                              advisorList
                                                                      .isNotEmpty
                                                                  ? advisorList[
                                                                      0]['name']
                                                                  : '',
                                                              style:
                                                                  const TextStyle(
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
                                                              coAdvisorList
                                                                      .isNotEmpty
                                                                  ? coAdvisorList[
                                                                      0]['name']
                                                                  : '',
                                                              style:
                                                                  const TextStyle(
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
                                                              coAdvisorList
                                                                      .isNotEmpty
                                                                  ? coAdvisorList[
                                                                      1]['name']
                                                                  : '',
                                                              style:
                                                                  const TextStyle(
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
                                                              advisorList
                                                                      .isNotEmpty
                                                                  ? advisorList[
                                                                      0]['name']
                                                                  : '',
                                                              style:
                                                                  const TextStyle(
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
                                                              coAdvisorList
                                                                      .isNotEmpty
                                                                  ? coAdvisorList[
                                                                      0]['name']
                                                                  : '',
                                                              style:
                                                                  const TextStyle(
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
                                                              coAdvisorList
                                                                      .isNotEmpty
                                                                  ? coAdvisorList[
                                                                      1]['name']
                                                                  : '',
                                                              style:
                                                                  const TextStyle(
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
                                              Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 20),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    CustomButton(
                                                      onPressed: () {
                                                        showDialog(
                                                            context: context,
                                                            builder: (_) {
                                                              return ChangeDialog(
                                                                original:
                                                                    allAdvisor,
                                                                selectedSociety:
                                                                    selectedSociety,
                                                                function: () {
                                                                  fetchSocietyDetails();
                                                                },
                                                              );
                                                            });
                                                      },
                                                      text: 'Change Advisor',
                                                      width: 150,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: SizedBox(
                                                      width:
                                                          MediaQuery.of(context)
                                                              .size
                                                              .width,
                                                      child: CustomDataTable(
                                                        context: context,
                                                        selectedSociety:
                                                            selectedSociety,
                                                        fetchSocietyDetails:
                                                            fetchSocietyDetails,
                                                        highcomm: highcomm,
                                                        lowcomm: lowcomm,
                                                        columns: const [
                                                          DataColumn(
                                                            label: Text('Name'),
                                                          ),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Student ID')),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Email')),
                                                          DataColumn(
                                                              label: Text(
                                                                  'IC No.')),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Contact')),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Position')),
                                                        ],
                                                        source:
                                                            _MembersDataSource(
                                                                _members),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
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
  final String selectedSociety;
  final VoidCallback fetchSocietyDetails;
  final List<Map<String, dynamic>> highcomm;
  final List<Map<String, dynamic>> lowcomm;
  final BuildContext context;

  const CustomDataTable({
    Key? key,
    required this.columns,
    required this.source,
    required this.selectedSociety,
    required this.fetchSocietyDetails,
    required this.highcomm,
    required this.lowcomm,
    required this.context,
  }) : super(key: key);

  @override
  _CustomDataTableState createState() => _CustomDataTableState();
}

class _CustomDataTableState extends State<CustomDataTable> {
  int selectedRowsPerPage = 10;
  int? _sortColumnIndex;
  bool _sortAscending = true;
  final search = TextEditingController();
  final row = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Rows per page: ',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(
              width: 65,
              child: CustomDDL<int>(
                controller: row,
                hintText: 'Select rows per page',
                value: selectedRowsPerPage,
                onChanged: (int? newValue) {
                  setState(() {
                    selectedRowsPerPage = newValue!;
                    widget.source.rowsPerPage = newValue;
                  });
                },
                dropdownItems: [10, 20, 50].map((rows) {
                  return DropdownMenuItem<int>(
                    value: rows,
                    child: Text('$rows'),
                  );
                }).toList(),
              ),
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
        PaginatedDataTable(
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
                          return member['studentID'];
                        case 2:
                          return member['email'];
                        case 3:
                          return member['ic'];
                        case 4:
                          return member['contact'];
                        case 5:
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
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
              onPressed: () {
                showDialog(
                    context: widget.context,
                    builder: (_) {
                      return AddDialog(
                        selectedSociety: widget.selectedSociety,
                        function: () {
                          widget.fetchSocietyDetails();
                        },
                      );
                    });
              },
              text: 'Add',
              buttonColor: Colors.green,
              width: 100,
            ),
            const SizedBox(
              width: 25,
            ),
            CustomButton(
              onPressed: () {
                if (widget.lowcomm.isNotEmpty) {
                  showDialog(
                      context: widget.context,
                      builder: (_) {
                        return EditDialog(
                          selectedSociety: widget.selectedSociety,
                          highcomm: widget.highcomm,
                          lowcomm: widget.lowcomm,
                          function: () {
                            widget.fetchSocietyDetails();
                          },
                        );
                      });
                } else {
                  ScaffoldMessenger.of(widget.context).showSnackBar(
                    const SnackBar(
                      content: Text('There is no available member to promote.'),
                      width: 300.0,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              },
              text: 'Promote',
              width: 100,
            ),
            const SizedBox(
              width: 25,
            ),
            CustomButton(
              onPressed: () {
                List<String> selectedStudentIDs =
                    widget.source.fetchSelectedRows();
                if (selectedStudentIDs.isEmpty) {
                  ScaffoldMessenger.of(widget.context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Unable to delete member(s) that hold position.'),
                      width: 325.0,
                      behavior: SnackBarBehavior.floating,
                      duration: Duration(seconds: 3),
                    ),
                  );
                } else if (selectedStudentIDs[0] == 'No rows selected.') {
                  ScaffoldMessenger.of(widget.context).showSnackBar(
                    SnackBar(
                      content: Text(selectedStudentIDs[0]),
                      width: 150.0,
                      behavior: SnackBarBehavior.floating,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                } else {
                  showDialog(
                      context: widget.context,
                      builder: (_) {
                        return DeleteDialog(
                          selectedStudentIDs: selectedStudentIDs,
                          selectedSociety: widget.selectedSociety,
                          function: () {
                            widget.fetchSocietyDetails();
                          },
                        );
                      });
                }
              },
              text: 'Remove',
              buttonColor: Colors.red,
              width: 100,
            )
          ],
        )
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
        DataCell(Text(member['studentID'].toString())),
        DataCell(Text(member['email'].toString())),
        DataCell(Text(member['ic'].toString())),
        DataCell(Text('+60${member['contact']}')),
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
        return value.toString().toLowerCase().contains(query.toLowerCase());
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

      if (columnIndex == 5) {
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

  List<String> fetchSelectedRows() {
    List<String> selectedStudentIDs = [];
    bool found = false;
    for (int index in selectedRows) {
      if (index < displayedMembers.length) {
        String position = displayedMembers[index]['position'];
        if (position == 'Member') {
          selectedStudentIDs.add(displayedMembers[index]['studentID']);
        } else {
          found = true;
        }
      }
    }
    if (found) {
      return [];
    } else if (selectedRows.isEmpty) {
      return ['No rows selected.'];
    } else {
      return selectedStudentIDs;
    }
  }
}

class AddDialog extends StatefulWidget {
  final String selectedSociety;
  final VoidCallback? function;

  AddDialog({required this.selectedSociety, this.function});
  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController id = TextEditingController();
  String? errorMessage;
  bool found = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add New Member'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(
                controller: id,
                errorText: errorMessage,
                hintText: 'Enter student ID',
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter student ID';
                  } else if (!RegExp(r'^\d{2}[A-Z]{3}\d{5}$').hasMatch(value)) {
                    return 'Invalid student ID';
                  }
                  return null;
                },
                onChanged: (value) async {
                  if (RegExp(r'^\d{2}[A-Z]{3}\d{5}$').hasMatch(value)) {
                    DocumentSnapshot<Map<String, dynamic>> student =
                        await FirebaseFirestore.instance
                            .collection('user')
                            .doc(id.text)
                            .get();

                    if (student.exists) {
                      Map<String, dynamic> studentData = student.data()!;
                      name.text = studentData['name'];
                      found = true;
                    } else {
                      name.text = '';
                      found = false;
                    }
                  } else {
                    name.text = '';
                    found = false;
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
            setState(() {
              errorMessage = null;
            });

            if (_formKey.currentState!.validate() && found) {
              QuerySnapshot<Map<String, dynamic>> existingMembers =
                  await FirebaseFirestore.instance
                      .collection('member')
                      .where('studentID', isEqualTo: id.text)
                      .where('societyID', isEqualTo: widget.selectedSociety)
                      .get();
              if (existingMembers.docs.isEmpty) {
                await FirebaseFirestore.instance.collection('member').doc(widget.selectedSociety + '/' + id.text).set({
                  'studentID': id.text,
                  'societyID': widget.selectedSociety,
                  'position': 'Member'
                });
                if (widget.function != null) {
                  widget.function!();
                }
                Navigator.of(context).pop();
              } else {
                setState(() {
                  errorMessage = 'Student already registered';
                });
              }
            } else {
              setState(() {
                errorMessage = 'Student not found';
              });
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class EditDialog extends StatefulWidget {
  final String selectedSociety;
  final VoidCallback? function;
  final List<Map<String, dynamic>> highcomm;
  final List<Map<String, dynamic>> lowcomm;

  EditDialog(
      {required this.selectedSociety,
      this.function,
      required this.highcomm,
      required this.lowcomm});
  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  TextEditingController position = TextEditingController();
  TextEditingController id1 = TextEditingController();
  TextEditingController id2 = TextEditingController();
  TextEditingController name1 = TextEditingController();
  TextEditingController name2 = TextEditingController();

  @override
  Widget build(BuildContext context) {
    position.text = widget.highcomm[0]['position'].toString();
    name2.text = widget.highcomm[0]['name'].toString();
    name1.text = widget.lowcomm[0]['name'].toString();
    String selectedID1 = widget.lowcomm[0]['studentID'].toString();
    String selectedID2 = widget.highcomm[0]['studentID'].toString();
    return AlertDialog(
      title: const Text('Promote Member'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Promoted Member'),
            const SizedBox(height: 10),
            CustomDDL<String>(
              value: widget.lowcomm[0]['studentID'].toString(),
              controller: id1,
              hintText: 'Select student ID',
              dropdownItems: widget.lowcomm.map((student) {
                String studentID = student['studentID'];
                return DropdownMenuItem<String>(
                  value: studentID,
                  child: Text(studentID),
                );
              }).toList(),
              onChanged: (value) {
                int index = widget.lowcomm
                    .indexWhere((student) => student['studentID'] == id1.text);
                name1.text = widget.lowcomm[index]['name'].toString();
                selectedID1 = id1.text;
              },
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: name1,
              hintText: 'Student Name',
              enabled: false,
            ),
            const SizedBox(height: 50),
            const Text('Demoted Member'),
            const SizedBox(height: 10),
            CustomDDL<String>(
              value: widget.highcomm[0]['studentID'].toString(),
              controller: id2,
              hintText: 'Select student ID',
              dropdownItems: widget.highcomm.map((student) {
                String studentID = student['studentID'];
                return DropdownMenuItem<String>(
                  value: studentID,
                  child: Text(studentID),
                );
              }).toList(),
              onChanged: (value) {
                int index = widget.highcomm
                    .indexWhere((student) => student['studentID'] == id2.text);
                position.text = widget.highcomm[index]['position'].toString();
                name2.text = widget.highcomm[index]['name'].toString();
                selectedID2 = id2.text;
              },
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: name2,
              hintText: 'Student Name',
              enabled: false,
            ),
            const SizedBox(height: 10),
            CustomTextField(
              controller: position,
              hintText: 'Student Position',
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
            try {
              await FirebaseFirestore.instance
                  .collection('member')
                  .where('studentID', isEqualTo: selectedID1)
                  .where('societyID', isEqualTo: widget.selectedSociety)
                  .get()
                  .then((snapshot) {
                for (var doc in snapshot.docs) {
                  doc.reference.update({
                    'position': position.text,
                  });
                }
              });

              await FirebaseFirestore.instance
                  .collection('member')
                  .where('studentID', isEqualTo: selectedID2)
                  .where('societyID', isEqualTo: widget.selectedSociety)
                  .get()
                  .then((snapshot) {
                for (var doc in snapshot.docs) {
                  doc.reference.update({
                    'position': 'Member',
                  });
                }
              });
              if (widget.function != null) {
                widget.function!();
              }
              Navigator.of(context).pop();
            } catch (error) {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to update position. Please try again.'),
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
  }
}

class DeleteDialog extends StatefulWidget {
  final String selectedSociety;
  final VoidCallback? function;
  final List<String> selectedStudentIDs;

  DeleteDialog({
    required this.selectedSociety,
    this.function,
    required this.selectedStudentIDs,
  });
  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Remove Member'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Are you sure you want to delete the following members?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            const Text(
              'Members to be deleted:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text(
              widget.selectedStudentIDs.join('\n'),
              style: const TextStyle(fontSize: 14),
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
            for (String studentID in widget.selectedStudentIDs) {
              await FirebaseFirestore.instance
                  .collection('member')
                  .where('studentID', isEqualTo: studentID)
                  .where('societyID', isEqualTo: widget.selectedSociety)
                  .get()
                  .then((querySnapshot) {
                for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
                    in querySnapshot.docs) {
                  docSnapshot.reference.delete();
                }
              });
            }
            Navigator.pop(context);
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class ChangeDialog extends StatefulWidget {
  final String selectedSociety;
  final VoidCallback? function;
  final List<Map<String, dynamic>> original;

  ChangeDialog({
    required this.selectedSociety,
    this.function,
    required this.original,
  });
  @override
  _ChangeDialogState createState() => _ChangeDialogState();
}

class _ChangeDialogState extends State<ChangeDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController position = TextEditingController();
  TextEditingController id1 = TextEditingController();
  TextEditingController id2 = TextEditingController();
  TextEditingController name1 = TextEditingController();
  TextEditingController name2 = TextEditingController();
  String? errorMessage;
  bool found = false;
  String? selectedID;
  @override
  Widget build(BuildContext context) {
    name2.text = widget.original[0]['name'].toString();
    position.text = widget.original[0]['position'].toString();
    selectedID = widget.original[0]['id'].toString();
    return AlertDialog(
      title: const Text('Change Advisor'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('New Advisor'),
              const SizedBox(height: 10),
              CustomTextField(
                  errorText: errorMessage,
                  controller: id1,
                  hintText: 'Enter Advisor ID',
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter advisor ID';
                    } else if (!RegExp(r'^A\d{3}').hasMatch(value)) {
                      return 'Invalid advisor ID';
                    }
                    return null;
                  },
                  onChanged: (value) async {
                    if (RegExp(r'^A\d{3}').hasMatch(value)) {
                      DocumentSnapshot<Map<String, dynamic>> advisor =
                          await FirebaseFirestore.instance
                              .collection('user')
                              .doc(id1.text)
                              .get();

                      if (advisor.exists) {
                        Map<String, dynamic> advisorData = advisor.data()!;
                        if (advisorData['ic'] != '') {
                          name1.text = advisorData['name'];
                          found = true;
                        }
                      } else {
                        name1.text = '';
                        found = false;
                      }
                    } else {
                      name1.text = '';
                      found = false;
                    }
                  }),
              const SizedBox(height: 10),
              CustomTextField(
                controller: name1,
                hintText: 'Associated Advisor Name',
                enabled: false,
              ),
              const SizedBox(height: 50),
              const Text('Current Advisor'),
              const SizedBox(height: 10),
              CustomDDL<String>(
                value: selectedID,
                controller: id2,
                hintText: 'Select advisor ID',
                dropdownItems: widget.original.map((advisor) {
                  String advisorID = advisor['id'];
                  return DropdownMenuItem<String>(
                    value: advisorID,
                    child: Text(advisorID),
                  );
                }).toList(),
                onChanged: (value) {
                  int index = widget.original
                      .indexWhere((advisor) => advisor['id'] == id2.text);
                  name2.text = widget.original[index]['name'].toString();
                  position.text = widget.original[index]['position'].toString();
                },
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: name2,
                hintText: 'Advisor Name',
                enabled: false,
              ),
              const SizedBox(height: 10),
              CustomTextField(
                controller: position,
                hintText: 'Advisor Position',
                enabled: false,
              ),
            ],
          ),
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
            setState(() {
              errorMessage = null;
            });

            if (_formKey.currentState!.validate() && found) {
              DocumentReference<Map<String, dynamic>> newAdvisorRef =
                  FirebaseFirestore.instance.collection('user').doc(id1.text);

              DocumentReference<Map<String, dynamic>> currentAdvisorRef =
                  FirebaseFirestore.instance.collection('user').doc(selectedID);

              DocumentSnapshot<Map<String, dynamic>> newAdvisorSnapshot =
                  await newAdvisorRef.get();

              Map<String, dynamic> newAdvisorData = newAdvisorSnapshot.data()!;

              if (newAdvisorData['societyID'] == '' &&
                  newAdvisorData['position'] == '') {
                await newAdvisorRef.update({
                  'societyID': widget.selectedSociety,
                  'position': position.text,
                });

                await currentAdvisorRef.update({
                  'societyID': '',
                  'position': '',
                });
                if (widget.function != null) {
                  widget.function!();
                }
                Navigator.pop(context);
              } else {
                setState(() {
                  errorMessage = 'This advisor is unavailable';
                });
              }
            } else {
              setState(() {
                errorMessage = 'Advisor not found';
              });
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
