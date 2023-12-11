import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/approvedClaim.dart';
import 'package:fyp/pages/pendingClaim.dart';
import 'package:fyp/pages/viewClaim.dart';
import 'package:intl/intl.dart';

class RejectedClaim extends StatefulWidget {
  final String selectedEvent;
  const RejectedClaim({super.key, required this.selectedEvent});

  @override
  State<RejectedClaim> createState() => _RejectedClaimState();
}

class _RejectedClaimState extends State<RejectedClaim> {
  bool _isLoading = true;
  List<Map<String, dynamic>> approvedClaim = [];

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot<Map<String, dynamic>> relatedClaim = await firestore
          .collection('claim')
          .where('eventID', isEqualTo: widget.selectedEvent)
          .where('status', isEqualTo: 'Rejected')
          .get();

      for (var claim in relatedClaim.docs) {
        Map<String, dynamic>? claimData = claim.data();

        String claimantID = claimData['claimantID'];
        final DocumentSnapshot<Map<String, dynamic>> claimantSnapshot =
            await firestore.collection('user').doc(claimantID).get();

        Map<String, dynamic>? claimantData = claimantSnapshot.data();
        claimData['claimant'] = claimantData?['name'];

        approvedClaim.add(claimData);
      }
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch data. Please try again later'),
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
              index: 3,
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
                        index: 3,
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
                                    'Claim',
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    PendingClaim(
                                                      selectedEvent:
                                                          widget.selectedEvent,
                                                    )),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(24.0),
                                          backgroundColor: Colors.grey[200],
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                              color: Colors.grey, width: 1.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                        ),
                                        child: const Text('Pending'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ApprovedClaim(
                                                      selectedEvent:
                                                          widget.selectedEvent,
                                                    )),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(24.0),
                                          backgroundColor: Colors.grey[200],
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                              color: Colors.grey, width: 1.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                        ),
                                        child: const Text('Approved'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    RejectedClaim(
                                                      selectedEvent:
                                                          widget.selectedEvent,
                                                    )),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(24.0),
                                          backgroundColor: Colors.white,
                                          foregroundColor: Colors.black,
                                          side: const BorderSide(
                                              color: Colors.grey, width: 1.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                        ),
                                        child: const Text('Rejected'),
                                      ),
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            border: Border.all(
                                                width: 1.0, color: Colors.grey),
                                          ),
                                          child: approvedClaim.isNotEmpty
                                              ? Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      CustomDataTable(
                                                          columns: const [
                                                            DataColumn(
                                                              label:
                                                                  Text('Title'),
                                                            ),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Claimant')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Submission Date')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Amount')),
                                                            DataColumn(
                                                                label:
                                                                    Text('')),
                                                          ],
                                                          source:
                                                              _ClaimDataSource(
                                                                  approvedClaim,
                                                                  context, widget.selectedEvent),
                                                          refresh: getData,
                                                          context: context),
                                                      const SizedBox(
                                                        height: 15,
                                                      ),
                                                    ],
                                                  ),
                                                )
                                              : const SizedBox(
                                                  height: 500,
                                                  child: Center(
                                                      child: Text(
                                                          'There is no claim rejected.'))),
                                        ),
                                      ),
                                    ],
                                  )
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
  final _ClaimDataSource source;
  final VoidCallback refresh;
  final BuildContext context;

  const CustomDataTable({
    Key? key,
    required this.columns,
    required this.source,
    required this.refresh,
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
                          return member['title'];
                        case 1:
                          return member['claimant'];
                        case 2:
                          return member['submissionDate'];
                        case 3:
                          return member['amount'];
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

class _ClaimDataSource extends DataTableSource {
  final String selectedEvent;
  final List<Map<String, dynamic>> originalClaim;
  List<Map<String, dynamic>> displayedClaim = [];
  final Set<int> selectedRows = {};
  final BuildContext context;
  int rowsPerPage = 10;

  _ClaimDataSource(this.originalClaim, this.context, this.selectedEvent) {
    _initializeDisplayedClaim();
  }

  void _initializeDisplayedClaim() {
    displayedClaim.addAll(originalClaim);
  }

  @override
  DataRow? getRow(int index) {
    if (index >= displayedClaim.length) {
      return null;
    }
    final claim = displayedClaim[index];
    return DataRow(
      cells: [
        DataCell(Text(claim['title'].toString())),
        DataCell(Text(claim['claimant'].toString())),
        DataCell(Text(
            DateFormat('dd/MM/yyyy').format(claim['submissionDate'].toDate()))),
        DataCell(Text('RM ' + claim['amount'].toStringAsFixed(2))),
        DataCell(Row(
          children: [
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        ViewClaim(selectedClaim: claim['claimID'].toString(), selectedEvent: selectedEvent,),
                  ),
                );
              },
              text: 'View',
              width: 100,
            ),
          ],
        )),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => displayedClaim.length;

  @override
  int get selectedRowCount => 0;

  void filter(String query) {
    displayedClaim.clear();
    displayedClaim.addAll(originalClaim.where((event) {
      return event.values.any((value) {
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
    displayedClaim.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      if (columnIndex == 2) {
        final aDate = DateFormat('dd/MM/yyyy').parse(aValue.toString());
        final bDate = DateFormat('dd/MM/yyyy').parse(bValue.toString());
        return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
      } else {
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      }
    });
    notifyListeners();
  }
}
