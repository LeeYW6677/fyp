import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/eventDetails.dart';

import 'package:fyp/pages/studentOngoingEvent.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class StudentOrganisedEvent extends StatefulWidget {
  const StudentOrganisedEvent({super.key});

  @override
  State<StudentOrganisedEvent> createState() => _StudentOrganisedEventState();
}

class _StudentOrganisedEventState extends State<StudentOrganisedEvent> {
  final LocalStorage storage = LocalStorage('user');
  bool _isLoading = true;
  List<Map<String, dynamic>> completedEvents = [];
  List<String> position = [
    'President',
    'Vice President',
    'Secretary',
    'Vice Secretary',
    'Treasurer',
    'Vice Treasurer',
    'Member',
  ];
  DateTime? startDate;
  DateTime? endDate;

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Fetch event data
      final QuerySnapshot<Map<String, dynamic>> relatedEvent = await firestore
          .collection('committee')
          .where('studentID', isEqualTo: storage.getItem('id'))
          .get();

      if (relatedEvent.docs.isNotEmpty) {
        List<String> eventIds =
            relatedEvent.docs.map((doc) => doc['eventID'] as String).toList();

        final QuerySnapshot<Map<String, dynamic>> eventSnapshot =
            await firestore
                .collection('event')
                .where('eventID', whereIn: eventIds)
                .where('status', isEqualTo: 'Completed')
                .get();

        for (var docSnapshot in eventSnapshot.docs) {
          Map<String, dynamic> eventData = docSnapshot.data();

          String societyID = eventData['societyID'];
          final DocumentSnapshot<Map<String, dynamic>> societySnapshot =
              await firestore.collection('society').doc(societyID).get();

          Map<String, dynamic>? societyData = societySnapshot.data();
          eventData['society'] = societyData!['societyName'];
          completedEvents.add(eventData);
        }

        for (var eventData in completedEvents) {
          String eventId = eventData['eventID'];
          final QuerySnapshot<Map<String, dynamic>> committeeSnapshot =
              await firestore
                  .collection('committee')
                  .where('eventID', isEqualTo: eventId)
                  .where('position', isEqualTo: 'President')
                  .get();
          int eventIndex = completedEvents
              .indexWhere((event) => event['eventID'] == eventId);
          for (var committeeDocSnapshot in committeeSnapshot.docs) {
            Map<String, dynamic> committeeData = committeeDocSnapshot.data();

            if (eventIndex != -1) {
              completedEvents[eventIndex]['president'] =
                  committeeData['name'] ?? 'Unassigned';
            }
          }
          final QuerySnapshot<Map<String, dynamic>> participantSnapshot =
              await firestore
                  .collection('participant')
                  .where('eventID', isEqualTo: eventId)
                  .get();

          int participantCount = participantSnapshot.size;
          completedEvents[eventIndex]['participant'] = participantCount;

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
          startDate = null;
          endDate = null;
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
            completedEvents[eventIndex]['startDate'] =
                DateFormat('dd/MM/yyyy').format(startDate!);
            completedEvents[eventIndex]['endDate'] =
                DateFormat('dd/MM/yyyy').format(endDate!);
          } else {
            completedEvents[eventIndex]['startDate'] = 'Undecided';
            completedEvents[eventIndex]['endDate'] = 'Undecided';
          }
        }
      }
      setState(() {
        completedEvents = completedEvents;
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
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const StudentOngoingEvent()),
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
                                        child: const Text('Ongoing'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pushReplacement(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const StudentOrganisedEvent()),
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
                                        child: const Text('Organised'),
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
                                          child: completedEvents.isNotEmpty
                                              ? Padding(
                                                  padding: const EdgeInsets.all(
                                                      16.0),
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment.end,
                                                    children: [
                                                      CustomDataTable2(
                                                          columns: const [
                                                            DataColumn(
                                                              label:
                                                                  Text('Name'),
                                                            ),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Society')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'President')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Start Date')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'End Date')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Participant')),
                                                            DataColumn(
                                                                label:
                                                                    Text('')),
                                                          ],
                                                          source:
                                                              _EventDataSource2(
                                                                  completedEvents,
                                                                  context),
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
                                                          'You have not organised any event.'))),
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

class CustomDataTable2 extends StatefulWidget {
  final List<DataColumn> columns;
  final _EventDataSource2 source;
  final VoidCallback refresh;
  final BuildContext context;

  const CustomDataTable2({
    Key? key,
    required this.columns,
    required this.source,
    required this.refresh,
    required this.context,
  }) : super(key: key);

  @override
  _CustomDataTable2State createState() => _CustomDataTable2State();
}

class _CustomDataTable2State extends State<CustomDataTable2> {
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
                          return member['society'];
                        case 2:
                          return member['president'];
                        case 3:
                          return member['startDate'];
                        case 4:
                          return member['endDate'];
                        case 5:
                          return member['participant'];
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

class _EventDataSource2 extends DataTableSource {
  final List<Map<String, dynamic>> originalEvent;
  List<Map<String, dynamic>> displayedEvent = [];
  final Set<int> selectedRows = {};
  final BuildContext context;
  int rowsPerPage = 10;

  _EventDataSource2(this.originalEvent, this.context) {
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
        DataCell(Text(event['society'].toString())),
        DataCell(Text(event['president'].toString())),
        DataCell(Text(event['startDate'].toString())),
        DataCell(Text(event['endDate'].toString())),
        DataCell(Text(event['participant'].toString())),
        DataCell(Row(
          children: [
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EventDetails(
                      selectedEvent: event['eventID'],
                    ),
                  ),
                );
              },
              text: 'View',
              width: 100,
            ),
            const SizedBox(
              width: 15,
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

      if (columnIndex == 3 || columnIndex == 4) {
        if (aValue.toString().toLowerCase() == 'undecided') {
          return bValue.toString().toLowerCase() == 'undecided' ? 0 : 1;
        } else if (bValue.toString().toLowerCase() == 'undecided') {
          return -1;
        } else {
          final aDate = DateFormat('dd/MM/yyyy').parse(aValue.toString());
          final bDate = DateFormat('dd/MM/yyyy').parse(bValue.toString());
          return ascending ? aDate.compareTo(bDate) : bDate.compareTo(aDate);
        }
      } else {
        return ascending
            ? Comparable.compare(aValue, bValue)
            : Comparable.compare(bValue, aValue);
      }
    });
    notifyListeners();
  }
}
