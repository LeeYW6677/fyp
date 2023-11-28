import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/studentOrganisedEvent.dart';
import 'package:intl/intl.dart';

class Schedule extends StatefulWidget {
  final String selectedEvent;
  const Schedule({super.key, required this.selectedEvent});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Program> programs = [];
  bool enable = true;
  String status = '';
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

  void _deleteProgram(int index) {
    setState(() {
      programs.removeAt(index);
    });
  }

  void addProgram() {
    final DateFormat timeFormat = DateFormat('HH:mm');
    DateTime parsedTime = timeFormat.parse(start.text);
    TimeOfDay startTime = TimeOfDay.fromDateTime(parsedTime);
    DateTime parsedTime2 = timeFormat.parse(end.text);
    TimeOfDay endTime = TimeOfDay.fromDateTime(parsedTime2);
    String dateText = date.text;
    final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
    DateTime parsedDate = dateFormat.parse(dateText);

    Program newProgram = Program(
      date: parsedDate,
      start: startTime,
      end: endTime,
      details: detail.text,
    );

    setState(() {
      programs.add(newProgram);
    });
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  final date = TextEditingController();
  final start = TextEditingController();
  final end = TextEditingController();
  final detail = TextEditingController();
  String selectedType = 'Talk';
  String? startError;
  String? endError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      drawer: !Responsive.isDesktop(context)
          ? const CustomDrawer(
              index: 2,
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
                ),
              ),
            Expanded(
              flex: 5,
              child: SingleChildScrollView(
                child: Column(children: [
                  NavigationMenu(
                    buttonTexts: const ['Event', 'Schedule'],
                    destination: [
                      const StudentOrganisedEvent(),
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
                            Form(
                                key: _formKey,
                                child: TabContainer(
                                    selectedEvent: widget.selectedEvent,
                                    tab: 'Pre',
                                    form: 'Schedule',
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Date',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 4,
                                                    child: CustomTextField(
                                                      controller: date,
                                                      hintText: 'Enter date',
                                                      suffixIcon: const Icon(Icons
                                                          .calendar_today_rounded),
                                                      onTap: () async {
                                                        DateTime? pickedDate =
                                                            await showDatePicker(
                                                          context: context,
                                                          initialDate:
                                                              DateTime.now()
                                                                  .add(Duration(
                                                                      days: 7)),
                                                          firstDate:
                                                              DateTime.now()
                                                                  .add(Duration(
                                                                      days: 7)),
                                                          lastDate:
                                                              DateTime.now()
                                                                  .add(Duration(
                                                                      days:
                                                                          365)),
                                                        );

                                                        if (pickedDate !=
                                                            null) {
                                                          setState(() {
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
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                children: [
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Time',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    flex: 2,
                                                    child: CustomTextField(
                                                      errorText: startError,
                                                      controller: start,
                                                      hintText:
                                                          'Enter start time',
                                                      suffixIcon: const Icon(
                                                          Icons.punch_clock),
                                                      onTap: () async {
                                                        TimeOfDay? pickedTime =
                                                            await showTimePicker(
                                                          context: context,
                                                          initialEntryMode:
                                                              TimePickerEntryMode
                                                                  .inputOnly,
                                                          initialTime:
                                                              const TimeOfDay(
                                                                  hour: 12,
                                                                  minute: 00),
                                                        );

                                                        if (pickedTime !=
                                                            null) {
                                                          startError = null;

                                                          if (end.text != '') {
                                                            final DateFormat
                                                                timeFormat =
                                                                DateFormat(
                                                                    'HH:mm');
                                                            DateTime
                                                                parsedTime =
                                                                timeFormat
                                                                    .parse(end
                                                                        .text);
                                                            TimeOfDay endTime =
                                                                TimeOfDay
                                                                    .fromDateTime(
                                                                        parsedTime);
                                                            if (pickedTime
                                                                        .hour >
                                                                    endTime
                                                                        .hour ||
                                                                (pickedTime.hour ==
                                                                        endTime
                                                                            .hour &&
                                                                    pickedTime
                                                                            .minute >
                                                                        endTime
                                                                            .minute)) {
                                                              setState(() {
                                                                start.text =
                                                                    pickedTime
                                                                        .format(
                                                                            context);
                                                              });
                                                            } else {
                                                              startError =
                                                                  'Start Time must be before End Time';
                                                            }
                                                          } else {
                                                            setState(() {
                                                              start.text =
                                                                  pickedTime
                                                                      .format(
                                                                          context);
                                                            });
                                                          }
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  const Text('     -     '),
                                                  Expanded(
                                                    flex: 2,
                                                    child: CustomTextField(
                                                      errorText: endError,
                                                      controller: end,
                                                      hintText:
                                                          'Enter end time',
                                                      suffixIcon: const Icon(
                                                          Icons.punch_clock),
                                                      onTap: () async {
                                                        TimeOfDay? pickedTime =
                                                            await showTimePicker(
                                                          context: context,
                                                          initialEntryMode:
                                                              TimePickerEntryMode
                                                                  .input,
                                                          initialTime:
                                                              const TimeOfDay(
                                                                  hour: 12,
                                                                  minute: 00),
                                                        );

                                                        if (pickedTime !=
                                                            null) {
                                                          endError = null;

                                                          if (start.text !=
                                                              '') {
                                                            final DateFormat
                                                                timeFormat =
                                                                DateFormat(
                                                                    'HH:mm');
                                                            DateTime
                                                                parsedTime =
                                                                timeFormat
                                                                    .parse(start
                                                                        .text);
                                                            TimeOfDay
                                                                startTime =
                                                                TimeOfDay
                                                                    .fromDateTime(
                                                                        parsedTime);

                                                            if (pickedTime
                                                                        .hour >
                                                                    startTime
                                                                        .hour ||
                                                                (pickedTime.hour ==
                                                                        startTime
                                                                            .hour &&
                                                                    pickedTime
                                                                            .minute >
                                                                        startTime
                                                                            .minute)) {
                                                              setState(() {
                                                                end.text =
                                                                    pickedTime
                                                                        .format(
                                                                            context);
                                                              });
                                                            } else {
                                                              endError =
                                                                  'End Time must be after Start Time';
                                                            }
                                                          } else {
                                                            setState(() {
                                                              end.text = pickedTime
                                                                  .format(
                                                                      context);
                                                            });
                                                          }
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
                                      Row(
                                        children: [
                                          Expanded(
                                              child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      const Expanded(
                                                        flex: 1,
                                                        child: Text(
                                                          'Programme Details',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      Expanded(
                                                        flex: 9,
                                                        child: CustomTextField(
                                                          maxLength: 100,
                                                          hintText:
                                                              'Enter programme details',
                                                          controller: detail,
                                                          maxLine: 3,
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Please enter programme details';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ))),
                                        ],
                                      ),
                                      CustomButton(
                                          width: 150,
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              addProgram();
                                            }
                                          },
                                          text: 'Add'),
                                      Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Date'),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 3,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Time'),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 8,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Details'),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 15,
                                      ),
                                      Column(
                                        children: [
                                          Container(
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              itemCount: programs.length,
                                              itemBuilder: (context, index) {
                                                return ProgramItem(
                                                  program: programs[index],
                                                  onDelete: () {
                                                    _deleteProgram(index);
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(
                                          thickness: 0.1, color: Colors.black),
                                      CustomTimeline(status: status),
                                    ]))
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

class Program {
  final DateTime date;
  final TimeOfDay start;
  final TimeOfDay end;
  final String details;

  Program(
      {required this.date,
      required this.start,
      required this.end,
      required this.details});
}

class ProgramItem extends StatelessWidget {
  final Program program;
  final VoidCallback onDelete;

  const ProgramItem({Key? key, required this.program, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Date: ${program.date.toLocal()}'),
      subtitle: Text(
          'Time: ${program.start.format(context)} - ${program.end.format(context)}'),
      onTap: () {
        _showDetailsDialog(context, program.details);
      },
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }

  Future<void> _showDetailsDialog(BuildContext context, String details) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Program Details'),
          content: Text(details),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
