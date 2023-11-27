import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/budget.dart';
import 'package:fyp/pages/committee.dart';
import 'package:fyp/pages/schedule.dart';
import 'package:fyp/pages/studentEvent.dart';
import 'package:timelines/timelines.dart';

class Proposal extends StatefulWidget {
  final String selectedEvent;
  const Proposal({super.key, required this.selectedEvent});

  @override
  State<Proposal> createState() => _ProposalState();
}

class _ProposalState extends State<Proposal> {
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
        name.text = eventData['eventName'] ?? '';
        selectedType = eventData['type'] ?? 'Talk';
        description.text = eventData['description'] ?? '';
        aim.text = eventData['aim'] ?? '';
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

  @override
  void initState() {
    super.initState();
    getData();
  }

  final name = TextEditingController();
  final type = TextEditingController();
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
                          buttonTexts: const ['Event', 'Proposal'],
                          destination: [
                            const StudentEvent(),
                            Proposal(selectedEvent: widget.selectedEvent)
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
                                          backgroundColor: Colors.white,
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
                                                builder: (context) =>
                                                    Schedule(selectedEvent: widget.selectedEvent,)),
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
                                                                'Event Name',
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
                                                                    name,
                                                                hintText:
                                                                    'Enter event name',
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter event name';
                                                                  }
                                                                  return null;
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
                                                                'Event Type',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                            ),
                                                            Expanded(
                                                                flex: 4,
                                                                child:
                                                                    CustomDDL<
                                                                        String>(
                                                                  controller:
                                                                      type,
                                                                  hintText:
                                                                      'Select event type',
                                                                  value:
                                                                      selectedType,
                                                                  dropdownItems:
                                                                      [
                                                                    'Talk',
                                                                    'Workshop',
                                                                    'Competition',
                                                                    'Meeting',
                                                                    'Trip',
                                                                    'Fund Raising',
                                                                    'Performance',
                                                                    'Training',
                                                                    'Exhibition'
                                                                  ].map((type) {
                                                                    return DropdownMenuItem<
                                                                        String>(
                                                                      value:
                                                                          type,
                                                                      child: Text(
                                                                          type),
                                                                    );
                                                                  }).toList(),
                                                                )),
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
                                                                    'Description',
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
                                                                        'Enter event description',
                                                                    controller:
                                                                        description,
                                                                    maxLine: 5,
                                                                    validator:
                                                                        (value) {
                                                                      if (value!
                                                                          .isEmpty) {
                                                                        return 'Please enter event description';
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
                                                    Text('$characterCount/400'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
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
                                                                    'Aim',
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
                                                                        'Enter aim of event',
                                                                    controller:
                                                                        aim,
                                                                    maxLine: 5,
                                                                    validator:
                                                                        (value) {
                                                                      if (value!
                                                                          .isEmpty) {
                                                                        return 'Please enter aim of the event';
                                                                      }
                                                                      return null;
                                                                    },
                                                                    onChanged:
                                                                        (text) {
                                                                      setState(
                                                                          () {
                                                                        characterCount2 =
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
                                                    Text(
                                                        '$characterCount2/400'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    if (status == 'Planning')
                                                      CustomButton(
                                                        onPressed: () async {
                                                          FirebaseFirestore
                                                              firestore =
                                                              FirebaseFirestore
                                                                  .instance;
                                                          Map<String, dynamic>
                                                              updatedData = {
                                                            'eventName': name.text,
                                                            'type':
                                                                selectedType,
                                                            'description':
                                                                description
                                                                    .text,
                                                            'aim': aim.text,
                                                          };

                                                          try {
                                                            await firestore
                                                                .collection(
                                                                    'event')
                                                                .doc(widget
                                                                    .selectedEvent)
                                                                .update(
                                                                    updatedData);
                                                          } catch (error) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'Failed to update proposal. Please try again.'),
                                                                width: 225.0,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                              ),
                                                            );
                                                          }
                                                        },
                                                        text: 'Save',
                                                        width: 150,
                                                      ),
                                                    const SizedBox(
                                                      width: 10,
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
                                                          return DotIndicator(
                                                            size: 30.0,
                                                            color: Colors.green,
                                                          );
                                                        } else {
                                                          return OutlinedDotIndicator(
                                                            borderWidth: 4.0,
                                                            color: Colors.green,
                                                          );
                                                        }
                                                      },
                                                      connectorBuilder:
                                                          (_, index, type) {
                                                        if (index > 0) {
                                                          return SolidLineConnector(
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
