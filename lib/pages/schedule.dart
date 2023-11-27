import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/budget.dart';
import 'package:fyp/pages/committee.dart';
import 'package:fyp/pages/proposal.dart';
import 'package:fyp/pages/studentEvent.dart';
import 'package:intl/intl.dart';
import 'package:timelines/timelines.dart';

class Schedule extends StatefulWidget {
  final String selectedEvent;
  const Schedule({super.key, required this.selectedEvent});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  bool enable = true;
  String status = '';
  List<String> progress = ['Planning', 'Checked', 'Recommended', 'Approved'];
  Future<void> getData() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch event data
      final QuerySnapshot<Map<String, dynamic>> eventSnapshot = await firestore
          .collection('event')
          .where('eventID', isEqualTo: widget.selectedEvent)
          .get();

      if (eventSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> eventData = eventSnapshot.docs.first.data();
        status = eventData['status'];
        if (status != 'Planning') {
          enable = false;
        }
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

  List<TableRow> tableRows = [];
  void addToTable() {
    if (date.text.isNotEmpty &&
        start.text.isNotEmpty &&
        end.text.isNotEmpty &&
        description.text.isNotEmpty) {
      setState(() {
        tableRows.add(
          TableRow(
            children: [
              Column(children: [Text('${date.text}')]),
              Column(children: [Text('${start.text} - ${end.text}')]),
              Column(children: [Text('${description.text}')]),
              
            ],
          ),
        );
      });
    } else {
      // Handle validation errors or show a message to the user
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  final date = TextEditingController();
  final start = TextEditingController();
  final end = TextEditingController();
  final aim = TextEditingController();
  final description = TextEditingController();
  String selectedType = 'Talk';
  int characterCount = 0;
  int characterCount2 = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
        future: getData(),
        builder: (context, snapshot) {
          return Scaffold(
            appBar: const Header(),
            drawer: !Responsive.isDesktop(context)
                ? const CustomDrawer(
                    index: 1,
                  )
                : null,
            body: SafeArea(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (Responsive.isDesktop(context))
                    const Expanded(
                      child: CustomDrawer(
                        index: 1,
                      ),
                    ),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: Column(children: [
                        NavigationMenu(
                          buttonTexts: const ['Event', 'Schedule'],
                          destination: [
                            const StudentEvent(),
                            Schedule(selectedEvent: widget.selectedEvent)
                          ],
                        ),
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
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Proposal(
                                                    selectedEvent:
                                                        widget.selectedEvent)),
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
                                        child: const Text('Proposal'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) => Schedule(
                                                    selectedEvent:
                                                        widget.selectedEvent)),
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
                                        child: const Text('Schedule'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Committee()),
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
                                        child: const Text('Committee'),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    const Budget()),
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.all(24.0),
                                          foregroundColor: Colors.black,
                                          backgroundColor: Colors.grey[200],
                                          side: const BorderSide(
                                              color: Colors.grey, width: 1.0),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(0.0),
                                          ),
                                        ),
                                        child: const Text('Budget'),
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
                                                            const Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                'Date',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 4,
                                                              child:
                                                                  CustomTextField(
                                                                controller:
                                                                    date,
                                                                hintText:
                                                                    'Enter date',
                                                                suffixIcon:
                                                                    const Icon(Icons
                                                                        .calendar_today_rounded),
                                                                onTap:
                                                                    () async {
                                                                  DateTime?
                                                                      pickedDate =
                                                                      await showDatePicker(
                                                                    context:
                                                                        context,
                                                                    initialDate:
                                                                        DateTime(
                                                                            2000),
                                                                    firstDate:
                                                                        DateTime(
                                                                            1900),
                                                                    lastDate:
                                                                        DateTime(
                                                                            2010),
                                                                  );

                                                                  if (pickedDate !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      date.text = DateFormat(
                                                                              'dd-MM-yyyy')
                                                                          .format(
                                                                              pickedDate);
                                                                    });
                                                                  }
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
                                                            const Expanded(
                                                              flex: 1,
                                                              child: Text(
                                                                'Time',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 2,
                                                              child:
                                                                  CustomTextField(
                                                                controller:
                                                                    start,
                                                                hintText:
                                                                    'Enter start time',
                                                                suffixIcon:
                                                                    const Icon(Icons
                                                                        .punch_clock),
                                                                onTap:
                                                                    () async {
                                                                  TimeOfDay?
                                                                      pickedTime =
                                                                      await showTimePicker(
                                                                    context:
                                                                        context,
                                                                    initialTime:
                                                                        TimeOfDay
                                                                            .now(),
                                                                  );

                                                                  if (pickedTime !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      start.text =
                                                                          pickedTime
                                                                              .format(context);
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                            const Text(
                                                                '     -     '),
                                                            Expanded(
                                                              flex: 2,
                                                              child:
                                                                  CustomTextField(
                                                                controller: end,
                                                                hintText:
                                                                    'Enter end time',
                                                                suffixIcon:
                                                                    const Icon(Icons
                                                                        .punch_clock),
                                                                onTap:
                                                                    () async {
                                                                  TimeOfDay?
                                                                      pickedTime =
                                                                      await showTimePicker(
                                                                    context:
                                                                        context,
                                                                    initialTime:
                                                                        TimeOfDay
                                                                            .now(),
                                                                  );

                                                                  if (pickedTime !=
                                                                      null) {
                                                                    setState(
                                                                        () {
                                                                      end.text =
                                                                          pickedTime
                                                                              .format(context);
                                                                    });
                                                                  }
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 15,
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
                                                                      .start,
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                                const Expanded(
                                                                  flex: 1,
                                                                  child: Text(
                                                                    'Programme Details',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                                Expanded(
                                                                  flex: 9,
                                                                  child:
                                                                      CustomTextField(
                                                                    hintText:
                                                                        'Enter programme details',
                                                                    controller:
                                                                        description,
                                                                    maxLine: 3,
                                                                    validator:
                                                                        (value) {
                                                                      if (value!
                                                                          .isEmpty) {
                                                                        return 'Please enter programme details';
                                                                      }
                                                                      return null;
                                                                    },
                                                                    onChanged:
                                                                        (text) {
                                                                      setState(
                                                                          () {
                                                                        characterCount =
                                                                            text.length;
                                                                      });
                                                                    },
                                                                  ),
                                                                ),
                                                              ],
                                                            ))),
                                                  ],
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Text('$characterCount/100'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 15),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    if (status == 'Planning')
                                                      CustomButton(
                                                        onPressed: () {
                                                          addToTable();
                                                        },
                                                        text: 'Save',
                                                        width: 150,
                                                      ),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Table(
                                                  columnWidths: const {
                                                    0: FlexColumnWidth(1),
                                                    1: FlexColumnWidth(1),
                                                    2: FlexColumnWidth(4),
                                                  },
                                                  border: TableBorder.all(
                                                    color: Colors.grey,
                                                  ),
                                                  children: [
                                                    const TableRow(
                                                      children: [
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12.0),
                                                            child: Text('Date'),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12.0),
                                                            child: Text('Time'),
                                                          ),
                                                        ),
                                                        TableCell(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    12.0),
                                                            child: Text(
                                                                'Programme Details'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    for (TableRow row
                                                        in tableRows)
                                                      TableRow(
                                                        children: [
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12.0),
                                                            child: Text(
                                                                row.children![0]
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14)),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12.0),
                                                            child: Text(
                                                                row.children![1]
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14)),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(12.0),
                                                            child: Text(
                                                                row.children![2]
                                                                    .toString(),
                                                                style:
                                                                    const TextStyle(
                                                                        fontSize:
                                                                            14)),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                                const Divider(
                                                    thickness: 0.1,
                                                    color: Colors.black),
                                                SizedBox(
                                                  height: 175,
                                                  child: Timeline.tileBuilder(
                                                    shrinkWrap: true,
                                                    padding: EdgeInsets.zero,
                                                    theme: TimelineThemeData(
                                                      direction:
                                                          Axis.horizontal,
                                                      connectorTheme:
                                                          const ConnectorThemeData(
                                                              space: 8.0,
                                                              thickness: 2.0),
                                                    ),
                                                    builder: TimelineTileBuilder
                                                        .connected(
                                                      connectionDirection:
                                                          ConnectionDirection
                                                              .before,
                                                      itemCount: 4,
                                                      itemExtentBuilder:
                                                          (_, __) {
                                                        return (MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width -
                                                                200) /
                                                            4.0;
                                                      },
                                                      oppositeContentsBuilder:
                                                          (context, index) {
                                                        return Container();
                                                      },
                                                      contentsBuilder:
                                                          (context, index) {
                                                        return Column(
                                                          children: [
                                                            Text(progress[
                                                                index]),
                                                            const SizedBox(
                                                                height: 10),
                                                            if (index <=
                                                                progress
                                                                    .indexOf(
                                                                        status))
                                                              CustomButton(
                                                                  onPressed: status ==
                                                                          'Planning'
                                                                      ? () {}
                                                                      : () {},
                                                                  text: status ==
                                                                          'Planning'
                                                                      ? 'Submit'
                                                                      : 'Unsubmit'),
                                                          ],
                                                        );
                                                      },
                                                      indicatorBuilder:
                                                          (_, index) {
                                                        if (index <=
                                                            progress.indexOf(
                                                                status)) {
                                                          return const DotIndicator(
                                                            size: 30.0,
                                                            color: Colors.green,
                                                          );
                                                        } else {
                                                          return const OutlinedDotIndicator(
                                                            borderWidth: 4.0,
                                                            color: Colors.green,
                                                          );
                                                        }
                                                      },
                                                      connectorBuilder:
                                                          (_, index, type) {
                                                        if (index > 0) {
                                                          return const SolidLineConnector(
                                                            color: Colors.green,
                                                          );
                                                        } else {
                                                          return null;
                                                        }
                                                      },
                                                    ),
                                                  ),
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
        });
  }
}
