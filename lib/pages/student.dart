import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';

class Student extends StatefulWidget {
  const Student({super.key});

  @override
  State<Student> createState() => _StudentState();
}

class _StudentState extends State<Student> {
  List<Map<String, dynamic>> _student = [];

  Future<void> getData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> userDocuments =
          await firestore.collection('user').get();

      for (var documentSnapshot in userDocuments.docs) {
        String docId = documentSnapshot.id;

        if (!docId.startsWith('A') && !docId.startsWith('B')) {
          Map<String, dynamic> data = documentSnapshot.data();

          _student.add(data);
        }
      }
      setState(() {
        _student = _student;
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
              page: 'Student',
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
                  page: 'Student',
                ),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(children: [
                  const NavigationMenu(
                    buttonTexts: ['Student'],
                    destination: [Student()],
                  ),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Student',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                              ),
                            ),
                            const Divider(
                              thickness: 0.1,
                              color: Colors.black,
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
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                child: CustomDataTable(
                                                  context: context,
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text('Name'),
                                                    ),
                                                    DataColumn(
                                                        label:
                                                            Text('Student ID')),
                                                    DataColumn(
                                                        label: Text('Email')),
                                                    DataColumn(
                                                        label: Text('IC No.')),
                                                    DataColumn(
                                                        label: Text('Contact')),
                                                    DataColumn(
                                                        label:
                                                            Text('Programme')),
                                                    DataColumn(
                                                        label: Text('Action')),
                                                  ],
                                                  source: _StudentDataSource(
                                                      _student, context),
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
  final _StudentDataSource source;
  final BuildContext context;

  const CustomDataTable({
    Key? key,
    required this.columns,
    required this.source,
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
          rowsPerPage: selectedRowsPerPage,
          columns: widget.columns.map((column) {
            return DataColumn(
              label: column.label,
              onSort: (int columnIndex, bool ascending) {
                setState(() {
                  _sortColumnIndex = columnIndex;
                  _sortAscending = ascending;
                  widget.source.sort(
                    (Map<String, dynamic> student) {
                      switch (columnIndex) {
                        case 0:
                          return student['name'];
                        case 1:
                          return student['id'];
                        case 2:
                          return student['email'];
                        case 3:
                          return student['ic'];
                        case 4:
                          return student['contact'];
                        case 5:
                          return student['programme'];
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
      ],
    );
  }
}

class _StudentDataSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> originalStudent;
  List<Map<String, dynamic>> displayedStudent = [];
  int rowsPerPage = 10;

  _StudentDataSource(this.originalStudent, this.context) {
    _initializeDisplayedStudent();
  }

  void _initializeDisplayedStudent() {
    displayedStudent.addAll(originalStudent);
  }

  @override
  DataRow? getRow(int index) {
    if (index >= displayedStudent.length) {
      return null;
    }
    final student = displayedStudent[index];
    return DataRow(
      cells: [
        DataCell(Text(student['name'].toString())),
        DataCell(Text(student['id'].toString())),
        DataCell(Text(student['email'].toString())),
        DataCell(Text(student['ic'].toString())),
        DataCell(Text('+60${student['contact']}')),
        DataCell(Text(student['programme'].toString())),
        DataCell(
          IconButton(
            icon: Icon(
              student['status'] == true ? Icons.lock_open : Icons.lock,
              color: student['status'] == true ? Colors.green : Colors.red,
            ),
            onPressed: () {
              _showConfirmationDialog(
                  context, index, student, student['status']);
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => displayedStudent.length;

  @override
  int get selectedRowCount => 0;

  void filter(String query) {
    displayedStudent.clear();
    displayedStudent.addAll(originalStudent.where((student) {
      return student.values.any((value) {
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
    displayedStudent.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  Future<void> updateStudentStatus(
      int index, String studentID, bool newStatus) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('user').doc(studentID).update({
        'status': newStatus,
      });

      if (index < displayedStudent.length) {
        displayedStudent[index]['status'] = newStatus;
        notifyListeners();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to disable/enable account. Please try again.'),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _showConfirmationDialog(
      BuildContext context, int index, Map<String, dynamic> student, bool status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status ? 'Disable Account' : 'Enable Account'),
          content: Text(status ? 'Are you sure you want to disable the account of ${student['id']}?' : 'Are you sure you want to enable the account of ${student['id']}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                updateStudentStatus(
                    index, student['id'], !student['status']);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
