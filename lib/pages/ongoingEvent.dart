import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/addEvent.dart';
import 'package:fyp/pages/editEvent.dart';
import 'package:fyp/pages/organisedEvent.dart';
import 'package:fyp/pages/proposal.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class OngoingEvent extends StatefulWidget {
  final String selectedSociety;
  final String position;
  const OngoingEvent(
      {super.key, required this.selectedSociety, this.position = ''});

  @override
  State<OngoingEvent> createState() => _OngoingEventState();
}

class _OngoingEventState extends State<OngoingEvent> {
  List<Map<String, dynamic>> ongoingEvents = [];
  bool _isLoading = true;
  DateTime? startDate;
  DateTime? endDate;
  List<String> checkName = ['', '', '', ''];
  List<String> checkStatus = ['', '', '', ''];
  String eventDate = '';
  String eventStatus = '';

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Fetch event and committee data
      final QuerySnapshot<Map<String, dynamic>> eventSnapshot = await firestore
          .collection('event')
          .where('societyID', isEqualTo: widget.selectedSociety)
          .where('status', isNotEqualTo: 'Completed')
          .get();

      ongoingEvents.clear();

      for (var eventDocSnapshot in eventSnapshot.docs) {
        Map<String, dynamic> eventData = eventDocSnapshot.data();
        String eventId = eventData['eventID'];

        final QuerySnapshot<Map<String, dynamic>> committeeSnapshot =
            await firestore
                .collection('committee')
                .where('eventID', isEqualTo: eventId)
                .where('position', isEqualTo: 'President')
                .get();

        String presidentName = 'Unassigned';
        if (committeeSnapshot.docs.isNotEmpty) {
          Map<String, dynamic> committeeData =
              committeeSnapshot.docs.first.data();
          presidentName = committeeData['name'] ?? 'Unassigned';
        }

        final QuerySnapshot<Map<String, dynamic>> approvalSnapshot =
            await firestore
                .collection('approval')
                .where('eventID', isEqualTo: eventId)
                .get();
        checkName.clear();
        checkStatus.clear();

        if (approvalSnapshot.docs.isNotEmpty) {
          Map<String, dynamic> approvalData =
              approvalSnapshot.docs.first.data();
          checkName.add('');
          checkName.add(approvalData['presidentName']);
          checkName.add(approvalData['advisorName']);
          checkName.add(approvalData['branchHeadName']);
          checkStatus.add('Approved');
          checkStatus.add(approvalData['presidentStatus']);
          checkStatus.add(approvalData['advisorStatus']);
          checkStatus.add(approvalData['branchHeadStatus']);
        }

        if (checkStatus.any((element) => element == 'Rejected')) {
          eventStatus = 'Rejected';
        } else {
          eventStatus = 'Pending';
        }

        Query<Map<String, dynamic>> query = firestore
            .collection('schedule')
            .where('eventID', isEqualTo: eventId)
            .orderBy('date');

        QuerySnapshot<Map<String, dynamic>> snapshot =
            await query.limit(1).get();

        Query<Map<String, dynamic>> query2 = firestore
            .collection('schedule')
            .where('eventID', isEqualTo: eventId)
            .orderBy('date', descending: true);

        QuerySnapshot<Map<String, dynamic>> snapshot2 =
            await query2.limit(1).get();

        if (snapshot.docs.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> earliestDoc =
              snapshot.docs.first;

          Timestamp date = earliestDoc['date'];
          startDate = date.toDate();
        }

        if (snapshot2.docs.isNotEmpty) {
          DocumentSnapshot<Map<String, dynamic>> latestDoc =
              snapshot2.docs.first;

          Timestamp date = latestDoc['date'];
          endDate = date.toDate();
        }
        if (startDate != null && endDate != null) {
          eventDate = DateFormat('dd/MM/yyyy').format(startDate!) +
              ' - ' +
              DateFormat('dd/MM/yyyy').format(endDate!);
        } else {
          eventDate = 'Undecided';
        }

        ongoingEvents.add({
          ...eventData,
          'president': presidentName,
          'eventDate': eventDate,
          'eventStatus': eventStatus,
        });
      }

      setState(() {
        ongoingEvents = List.from(ongoingEvents);
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
                                    'Event',
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
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OngoingEvent(
                                                        selectedSociety: widget
                                                            .selectedSociety)),
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
                                        child: const Text('Ongoing'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    OrganisedEvent(
                                                      selectedSociety: widget
                                                          .selectedSociety,
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
                                        child: const Text('Organising'),
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
                                          child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,
                                              children: [
                                                CustomDataTable(
                                                  columns: const [
                                                    DataColumn(
                                                        label: Text('Name')),
                                                    DataColumn(
                                                        label:
                                                            Text('President')),
                                                    DataColumn(
                                                        label: Text('Date')),
                                                    DataColumn(
                                                        label: Text('Phase')),
                                                    DataColumn(
                                                        label:
                                                            Text('Progress')),
                                                    DataColumn(
                                                        label: Text('Status')),
                                                    DataColumn(
                                                        label: Text('Action')),
                                                  ],
                                                  source: _EventDataSource(
                                                      ongoingEvents,
                                                      context,
                                                      widget.selectedSociety,
                                                      widget.position),
                                                  refresh: getData,
                                                  context: context,
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                CustomButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            AddEvent(
                                                          selectedSociety: widget
                                                              .selectedSociety,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  buttonColor: Colors.green,
                                                  text: 'Add Event',
                                                  width: 150,
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                              ],
                                            ),
                                          ),
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
  final _EventDataSource source;
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
                          return member['name'];
                        case 1:
                          return member['president'];
                        case 2:
                          return member['eventDate'];
                        case 3:
                          return member['status'];
                        case 4:
                          return member['progress'];
                        case 5:
                          return member['eventStatus'];
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

class _EventDataSource extends DataTableSource {
  final LocalStorage storage = LocalStorage('user');
  final List<Map<String, dynamic>> originalEvent;
  List<Map<String, dynamic>> displayedEvent = [];
  final Set<int> selectedRows = {};
  final BuildContext context;
  final String selectedSociety;
  final String position;
  int rowsPerPage = 10;

  _EventDataSource(
      this.originalEvent, this.context, this.selectedSociety, this.position) {
    _initializeDisplayedEvent();
  }

  void _initializeDisplayedEvent() {
    displayedEvent.addAll(originalEvent);
  }

  @override
  DataRow? getRow(int index) {
    if (index >= displayedEvent.length) {
      return null;
    }
    final event = displayedEvent[index];
    return DataRow(
      cells: [
        DataCell(Text(event['eventName'].toString())),
        DataCell(Text(event['president'] != null
            ? event['president'].toString()
            : 'Not decided')),
        DataCell(Text(event['eventDate'].toString())),
        DataCell(Text(event['status'].toString())),
        DataCell(Text('${event['progress']}/3')),
        DataCell(Text(event['eventStatus'].toString())),
        DataCell(Row(
          children: [
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Proposal(selectedEvent: event['eventID']),
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
  int get rowCount => displayedEvent.length;

  @override
  int get selectedRowCount => 0;

  void filter(String query) {
    displayedEvent.clear();
    displayedEvent.addAll(originalEvent.where((event) {
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
    displayedEvent.sort((a, b) {
      final aValue = getField(a);
      final bValue = getField(b);

      if (columnIndex == 2) {
        final aDate = DateTime.parse(aValue.toString());
        final bDate = DateTime.parse(bValue.toString());
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
