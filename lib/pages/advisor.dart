import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/registerAdvisor.dart';

class Advisor extends StatefulWidget {
  const Advisor({super.key});

  @override
  State<Advisor> createState() => _AdvisorState();
}

class _AdvisorState extends State<Advisor> {
  List<Map<String, dynamic>> _advisor = [];

  Future<void> getData() async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot<Map<String, dynamic>> userDocuments = await firestore
          .collection('user')
          .where('ic', isNotEqualTo: '')
          .get();

      for (var documentSnapshot in userDocuments.docs) {
        String docId = documentSnapshot.id;

        if (docId.startsWith('A')) {
          Map<String, dynamic> data = documentSnapshot.data();
          data['advisorID'] = docId;
          _advisor.add(data);
        }
        final QuerySnapshot societySnapshot =
            await firestore.collection('society').get();
        List<String> societyNames = societySnapshot.docs
            .map((doc) => doc['societyName'].toString())
            .toList();

        for (Map<String, dynamic> advisorData in _advisor) {
          String societyID = advisorData['societyID'].toString();

          int societyIndex =
              societySnapshot.docs.indexWhere((doc) => doc.id == societyID);

          if (societyIndex != -1) {
            advisorData['societyName'] = societyNames[societyIndex];
          }
        }
      }
      setState(() {
        _advisor = _advisor;
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
                    page: 'Advisor',
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
                        page: 'Advisor',
                      ),
                    ),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        const NavigationMenu(
                          buttonTexts: ['Advisor'],
                          destination: [Advisor()],
                        ),
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Advisor',
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
                                                        columns: const [
                                                          DataColumn(
                                                            label: Text('Name'),
                                                          ),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Advisor ID')),
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
                                                                  'Department')),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Society')),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Position')),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Action')),
                                                        ],
                                                        source:
                                                            _AdvisorDataSource(
                                                                _advisor,
                                                                context),
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
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const RegisterAdvisor(),
                                                          ),
                                                        );
                                                      },
                                                      text: 'Add',
                                                      buttonColor: Colors.green,
                                                      width: 100,
                                                    ),
                                                  ]),
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
  final _AdvisorDataSource source;
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
                    (Map<String, dynamic> advisor) {
                      switch (columnIndex) {
                        case 0:
                          return advisor['name'];
                        case 1:
                          return advisor['advisorID'];
                        case 2:
                          return advisor['email'];
                        case 3:
                          return advisor['ic'];
                        case 4:
                          return advisor['contact'];
                        case 5:
                          return advisor['department'];
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

class _AdvisorDataSource extends DataTableSource {
  final BuildContext context;
  final List<Map<String, dynamic>> originalAdvisor;
  List<Map<String, dynamic>> displayedAdvisor = [];
  int rowsPerPage = 10;

  _AdvisorDataSource(this.originalAdvisor, this.context) {
    _initializeDisplayedAdvisor();
  }

  void _initializeDisplayedAdvisor() {
    displayedAdvisor.addAll(originalAdvisor);
  }

  @override
  DataRow? getRow(int index) {
    if (index >= displayedAdvisor.length) {
      return null;
    }
    final advisor = displayedAdvisor[index];
    return DataRow(
      cells: [
        DataCell(Text(advisor['name'].toString())),
        DataCell(Text(advisor['advisorID'].toString())),
        DataCell(Text(advisor['email'].toString())),
        DataCell(Text(advisor['ic'].toString())),
        DataCell(Text('+60${advisor['contact']}')),
        DataCell(Text(advisor['department'].toString())),
        DataCell(Text(advisor['societyName'] != null
            ? advisor['societyName'].toString()
            : 'Unassigned')),
        DataCell(Text(advisor['position'] != null
            ? advisor['position'].toString()
            : 'Unassigned')),
        DataCell(
          IconButton(
            icon: Icon(
              advisor['status'] == true ? Icons.lock_open : Icons.lock,
              color: advisor['status'] == true ? Colors.green : Colors.red,
            ),
            onPressed: () {
              _showConfirmationDialog(
                  context, index, advisor, advisor['status']);
            },
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => displayedAdvisor.length;

  @override
  int get selectedRowCount => 0;

  void filter(String query) {
    displayedAdvisor.clear();
    displayedAdvisor.addAll(originalAdvisor.where((advisor) {
      return advisor.values.any((value) {
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
    displayedAdvisor.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      return ascending
          ? Comparable.compare(aValue, bValue)
          : Comparable.compare(bValue, aValue);
    });
    notifyListeners();
  }

  Future<void> updateAdvisorStatus(
      int index, String advisorID, bool newStatus) async {
    try {
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      await firestore.collection('user').doc(advisorID).update({
        'status': newStatus,
      });

      if (index < displayedAdvisor.length) {
        displayedAdvisor[index]['status'] = newStatus;
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

  void _showConfirmationDialog(BuildContext context, int index,
      Map<String, dynamic> advisor, bool status) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(status ? 'Disable Account' : 'Enable Account'),
          content: Text(status
              ? 'Are you sure you want to disable the account of ${advisor['advisorID']}?'
              : 'Are you sure you want to enable the account of ${advisor['advisorID']}?'),
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
                updateAdvisorStatus(
                    index, advisor['advisorID'], !advisor['status']);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }
}
