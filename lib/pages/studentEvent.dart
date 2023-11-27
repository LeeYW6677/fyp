import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/proposal.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

class StudentEvent extends StatefulWidget {
  const StudentEvent({super.key});

  @override
  State<StudentEvent> createState() => _StudentEventState();
}

class _StudentEventState extends State<StudentEvent> {
  final LocalStorage storage = LocalStorage('user');
  List<Map<String, dynamic>> ongoingEvents = [];
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

  Future<void> getData() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // Fetch event data
      final QuerySnapshot<Map<String, dynamic>> relatedEvent = await firestore
          .collection('committee')
          .where('studentID', isEqualTo: storage.getItem('id'))
          .where('position', whereIn: position)
          .get();

      List<String> eventIds =
          relatedEvent.docs.map((doc) => doc['eventID'] as String).toList();

      final QuerySnapshot<Map<String, dynamic>> eventSnapshot = await firestore
          .collection('event')
          .where('eventID', whereIn: eventIds)
          .get();

      for (var docSnapshot in eventSnapshot.docs) {
        Map<String, dynamic> eventData = docSnapshot.data();
        String status = eventData['status'];

        if (status == 'Completed') {
          completedEvents.add(eventData);
        } else {
          ongoingEvents.add(eventData);
        }
      }
      for (var eventData in ongoingEvents) {
        String eventId = eventData['eventID'];
        final QuerySnapshot<Map<String, dynamic>> committeeSnapshot =
            await firestore
                .collection('committee')
                .where('eventID', isEqualTo: eventId)
                .where('position', isEqualTo: 'President')
                .get();

        for (var committeeDocSnapshot in committeeSnapshot.docs) {
          Map<String, dynamic> committeeData = committeeDocSnapshot.data();
          int eventIndex =
              ongoingEvents.indexWhere((event) => event['eventID'] == eventId);

          if (eventIndex != -1) {
            ongoingEvents[eventIndex]['president'] =
                committeeData['name'] ?? 'Unassigned';
          }
        }
      }
      setState(() {
        ongoingEvents = ongoingEvents;
      });

      for (var eventData in completedEvents) {
        String eventId = eventData['eventID'];
        final QuerySnapshot<Map<String, dynamic>> committeeSnapshot =
            await firestore
                .collection('committee')
                .where('eventID', isEqualTo: eventId)
                .where('position', isEqualTo: 'President')
                .get();

        for (var committeeDocSnapshot in committeeSnapshot.docs) {
          Map<String, dynamic> committeeData = committeeDocSnapshot.data();
          int eventIndex = completedEvents
              .indexWhere((event) => event['eventID'] == eventId);

          if (eventIndex != -1) {
            completedEvents[eventIndex]['president'] =
                committeeData['name'] ?? 'Unassigned';
          }
        }
      }
      setState(() {
        completedEvents = completedEvents;
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
              index: 3,
            )
          : null,
      body: SafeArea(
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
                  const NavigationMenu(
                    buttonTexts: ['Event'],
                    destination: [
                      StudentEvent(),
                    ],
                  ),
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
                            DefaultTabController(
                              length: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 300,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      border: const Border(
                                        top: BorderSide(
                                            color: Colors.grey, width: 1.0),
                                        left: BorderSide(
                                            color: Colors.grey, width: 1.0),
                                        right: BorderSide(
                                            color: Colors.grey, width: 1.0),
                                        bottom: BorderSide(
                                            color: Colors.white, width: 1.0),
                                      ),
                                    ),
                                    child: const TabBar(
                                      labelColor: Colors.black,
                                      indicator: BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                          top: BorderSide(
                                              color: Colors.grey, width: 1.0),
                                          left: BorderSide(
                                              color: Colors.grey, width: 1.0),
                                          right: BorderSide(
                                              color: Colors.grey, width: 1.0),
                                          bottom: BorderSide(
                                              color: Colors.white, width: 1.0),
                                        ),
                                      ),
                                      tabs: [
                                        Tab(
                                          text: 'Ongoing',
                                        ),
                                        Tab(
                                          text: 'Organised',
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(
                                          width: 1.0, color: Colors.grey),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(16.0),
                                      child: TabBarView(
                                        children: [
                                          Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                              CustomDataTable(
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text('Name'),
                                                    ),
                                                    DataColumn(
                                                        label:
                                                            Text('President')),
                                                    DataColumn(
                                                        label: Text('Date')),
                                                    DataColumn(
                                                        label: Text('Action')),
                                                  ],
                                                  source: _EventDataSource(
                                                      ongoingEvents, context),
                                                  refresh: getData,
                                                  context: context),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                            ],
                                          ),
                                          Column(
                                            children: [
                                              CustomDataTable2(
                                                  columns: const [
                                                    DataColumn(
                                                      label: Text('Name'),
                                                    ),
                                                    DataColumn(
                                                        label:
                                                            Text('President')),
                                                    DataColumn(
                                                        label: Text('Date')),
                                                    DataColumn(
                                                        label: Text('Action')),
                                                  ],
                                                  source: _EventDataSource2(
                                                      completedEvents, context),
                                                  refresh: getData,
                                                  context: context),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
                          return member['date'];
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
                          return member['president'];
                        case 2:
                          return member['date'];
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
  final List<Map<String, dynamic>> originalEvent;
  List<Map<String, dynamic>> displayedEvent = [];
  final Set<int> selectedRows = {};
  final BuildContext context;
  int rowsPerPage = 10;

  _EventDataSource(this.originalEvent, this.context) {
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
        DataCell(Text(
          event['date'] != null
              ? DateFormat('dd-MM-yyyy').format(event['date'].toDate())
              : 'Not decided',
        )),
        DataCell(Row(
          children: [
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        Proposal(selectedEvent: event['eventID'].toString()),
                  ),
                );
              },
              text: 'View',
              width: 100,
            ),
            const SizedBox(
              width: 15,
            ),
            CustomButton(
              onPressed: () {},
              text: 'Delete',
              width: 100,
              buttonColor: Colors.red,
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
        DataCell(Text(event['president'].toString())),
        DataCell(Text(DateFormat('dd-MM-yyyy').format(event['date'].toDate()))),
        DataCell(Row(
          children: [
            CustomButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Proposal(
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
            CustomButton(
              onPressed: () {},
              text: 'Delete',
              width: 100,
              buttonColor: Colors.red,
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
