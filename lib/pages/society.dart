import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailjs/emailjs.dart';
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
  List<Map<String, dynamic>> allAdvisorList = [];
  List<Map<String, dynamic>> allAdvisor = [];
  List<Map<String, dynamic>> _members = [];
  List<Map<String, dynamic>> highcomm = [];
  List<Map<String, dynamic>> lowcomm = [];
  List<Map<String, dynamic>> userList = [];
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

      QuerySnapshot querySnapshot =
          await firestore.collection('user').where('id', isLessThan: 'A').get();

      querySnapshot.docs.forEach((DocumentSnapshot document) {
        userList.add(document.data() as Map<String, dynamic>);
      });

      fetchSocietyDetails();
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print(error.toString());
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

      allAdvisorList.clear();
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
        allAdvisorList.add(document.data() as Map<String, dynamic>);
      });

      for (Map<String, dynamic> advisor in allAdvisor) {
        String advisorId = advisor['id'];
        allAdvisorList.removeWhere((advisor) => advisor['id'] == advisorId);
      }
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
                                              builder: (context) =>
                                                  OngoingEvent(
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
                                                                allAdvisorList:
                                                                    allAdvisorList,
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
                                                        userList: userList,
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
  final List<Map<String, dynamic>> userList;
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
    required this.userList,
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
                        highcomm: widget.highcomm,
                        lowcomm: widget.lowcomm,
                        userList: widget.userList,
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
  final List<Map<String, dynamic>> highcomm;
  final List<Map<String, dynamic>> lowcomm;
  final List<Map<String, dynamic>> userList;

  AddDialog(
      {required this.selectedSociety,
      this.function,
      required this.userList,
      required this.highcomm,
      required this.lowcomm});
  @override
  _AddDialogState createState() => _AddDialogState();
}

class _AddDialogState extends State<AddDialog> {
  TextEditingController name = TextEditingController();
  TextEditingController id = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  String? errorMessage;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  Future<void> onTextChanged(String value, TextEditingController name) async {
    setState(() {
      errorMessage = null;
    });
    bool isInHighComm =
        widget.highcomm.any((item) => item['studentID'] == value);

    bool isInLowComm = widget.lowcomm.any((item) => item['studentID'] == value);

    bool isParticipant = isInHighComm && isInLowComm;

    if (isParticipant) {
      setState(() {
        errorMessage = 'Already registered as member';
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
        });
      } else {
        setState(() {
          name.text = '';
        });
      }
    } else {
      setState(() {
        name.text = '';
      });
    }
  }

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
                  onTextChanged(value, name);
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
                      onTextChanged(value, name);
                    },
                    decoration: InputDecoration(
                      errorText: errorMessage,
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
            try {
              if (_formKey.currentState!.validate()) {
                QuerySnapshot<Map<String, dynamic>> existingMembers =
                    await FirebaseFirestore.instance
                        .collection('member')
                        .where('studentID', isEqualTo: id.text)
                        .where('societyID', isEqualTo: widget.selectedSociety)
                        .get();
                if (existingMembers.docs.isEmpty) {
                  await FirebaseFirestore.instance
                      .collection('member')
                      .doc()
                      .set({
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
              }
            } catch (error) {
              print("Error fetching student data: $error");
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

  void _sendEmail(String studentID, String committeeName, String position,
      String email) async {
    String subject;
    String message;
    String societyName = '';
    DocumentSnapshot<Map<String, dynamic>> societySnapshot =
        await FirebaseFirestore.instance
            .collection('society')
            .doc(widget.selectedSociety)
            .get();

    if (societySnapshot.exists) {
      societyName = societySnapshot.data()?['societyName'] ?? 'Unknown Society';
    }

    if (position == 'Member') {
      subject = 'Adv Demotion Notification';
      message =
          'We regret to inform you that your role as $position within the $societyName at TAR UMT has been adjusted. We appreciate your past contributions and dedication to our university community.\n\nWhile this decision has been made, we value your continued involvement and encourage you to explore other opportunities to contribute to the $societyName.\n\nThank you for your understanding, and we look forward to your ongoing support within our community.';
    } else {
      subject = 'Committee Promotion Notification';
      message =
          'Congratulations! We are pleased to inform you that you have been promoted to the position of $position within the $societyName at TAR UMT.\n\nYour dedication and outstanding contributions have not gone unnoticed, and we are confident that you will excel in your new role. Thank you for your continued commitment to our university community.\n\nWe look forward to your continued success and valuable contributions to the $societyName.';
    }

    try {
      // Send email using EmailJS
      await EmailJS.send(
        'service_ul1uscs',
        'template_alwxa78',
        {
          'name': committeeName,
          'email': email,
          'subject': subject,
          'message': message,
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
              Map<String, dynamic>? user = widget.lowcomm.firstWhere(
                (user) => user['id'].toString() == selectedID1,
              );

              // Retrieve email from the user
              String userEmail = user['email'].toString();
              _sendEmail(selectedID1, name1.text, position.text, userEmail);

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
              Map<String, dynamic>? user2 = widget.highcomm.firstWhere(
                (user) => user['id'].toString() == selectedID2,
              );

              // Retrieve email from the user
              String userEmail2 = user2['email'].toString();
              _sendEmail(selectedID2, name2.text, 'Member', userEmail2);
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
            if (widget.function != null) {
              widget.function!();
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
  final List<Map<String, dynamic>> allAdvisorList;

  ChangeDialog({
    required this.selectedSociety,
    this.function,
    required this.original,
    required this.allAdvisorList,
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
  final FocusNode _focusNode = FocusNode();
  String? errorMessage;
  String? selectedID;

  @override
  void initState() {
    super.initState();
    name2.text = widget.original[0]['name'].toString();
    position.text = widget.original[0]['position'].toString();
    selectedID = widget.original[0]['id'].toString();
  }

  void _sendEmail(String studentID, String committeeName, String position, String type) async {
    String subject;
    String message;
    String societyName = '';
    String email ='';

    DocumentSnapshot<Map<String, dynamic>> userSnapshot =
        await FirebaseFirestore.instance
            .collection('user')
            .doc(studentID)
            .get();

    if (userSnapshot.exists) {
      email = userSnapshot.data()?['email'] ?? 'Unknown email';
    }

    DocumentSnapshot<Map<String, dynamic>> societySnapshot =
        await FirebaseFirestore.instance
            .collection('society')
            .doc(widget.selectedSociety)
            .get();

    if (societySnapshot.exists) {
      societyName = societySnapshot.data()?['societyName'] ?? 'Unknown Society';
    }

    if (type == 'demote') {
      subject = 'Society Advisor Demotion Notification';
      message =
          'We regret to inform you that your role as $position within the $societyName at TAR UMT has been adjusted. We appreciate your past contributions and dedication to our university community.\n\nWhile this decision has been made, we value your continued involvement and encourage you to explore other opportunities to contribute to the $societyName.\n\nThank you for your understanding, and we look forward to your ongoing support within our community.';
    } else {
      subject = 'Society Advisor Promotion Notification';
      message =
          'Congratulations! We are pleased to inform you that you have been promoted to the position of $position within the $societyName at TAR UMT.\n\nYour dedication and outstanding contributions have not gone unnoticed, and we are confident that you will excel in your new role. Thank you for your continued commitment to our university community.\n\nWe look forward to your continued success and valuable contributions to the $societyName.';
    }

    try {
      // Send email using EmailJS
      await EmailJS.send(
        'service_ul1uscs',
        'template_alwxa78',
        {
          'name': committeeName,
          'email': email,
          'subject': subject,
          'message': message,
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

  Future<void> onTextChanged(String value, TextEditingController name) async {
    if (RegExp(r'^A\d{3}$').hasMatch(value)) {
      bool hasMatch = false;
      String studentName = '';

      for (Map<String, dynamic> user in widget.allAdvisorList) {
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

  @override
  Widget build(BuildContext context) {
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
              RawAutocomplete<String>(
                focusNode: _focusNode,
                textEditingController: id1,
                optionsBuilder: (TextEditingValue textEditingValue) {
                  return widget.allAdvisorList
                      .map<String>((user) => user['id'].toString())
                      .where((id) => id.contains(textEditingValue.text))
                      .toList();
                },
                onSelected: (String value) {
                  onTextChanged(value, name1);
                },
                fieldViewBuilder: (BuildContext context,
                    TextEditingController controller,
                    FocusNode focusNode,
                    VoidCallback onFieldSubmitted) {
                  return TextFormField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter advisor ID';
                      } else if (!RegExp(r'^A\d{3}$').hasMatch(value)) {
                        return 'Invalid advisor ID';
                      }
                      return null;
                    },
                    controller: controller,
                    focusNode: focusNode,
                    onChanged: (value) {
                      onTextChanged(value, name1);
                    },
                    decoration: InputDecoration(
                      errorText: errorMessage,
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
                      labelText: 'Advisor ID',
                      hintText: 'Enter advisor ID',
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
                  selectedID = value;
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

            if (_formKey.currentState!.validate()) {
              try {
                DocumentReference<Map<String, dynamic>> newAdvisorRef =
                    FirebaseFirestore.instance.collection('user').doc(id1.text);

                DocumentReference<Map<String, dynamic>> currentAdvisorRef =
                    FirebaseFirestore.instance
                        .collection('user')
                        .doc(selectedID);


                DocumentSnapshot<Map<String, dynamic>> currentAdvisorSnapshot =
                    await currentAdvisorRef.get();

                await newAdvisorRef.update({
                  'societyID': widget.selectedSociety,
                  'position': currentAdvisorSnapshot['position'],
                });
                _sendEmail(
                    id1.text, name1.text, currentAdvisorSnapshot['position'], 'promote');

                await currentAdvisorRef.update({
                  'societyID': '',
                  'position': '',
                });
                _sendEmail(
                    id2.text, name2.text, position.text, 'demote');
                if (widget.function != null) {
                  widget.function!();
                }
                Navigator.pop(context);
              } catch (e) {
                print(e.toString());
              }
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
