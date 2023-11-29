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
  bool _isLoading = true;
  bool enable = true;
  String status = '';
  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
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
      setState(() {
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
      body: _isLoading
        ? Center(
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
                                                  if (Responsive.isDesktop(
                                                      context))
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
                                                      screen:
                                                          !Responsive.isDesktop(
                                                              context),
                                                      labelText: 'Date',
                                                      validator: (value) {
                                                        final DateFormat
                                                            dateFormat =
                                                            DateFormat(
                                                                'dd-MM-yyyy');

                                                        if (value!.isEmpty) {
                                                          return 'Please enter date';
                                                        } else {
                                                          try {
                                                            DateTime
                                                                enteredDate =
                                                                dateFormat
                                                                    .parseStrict(
                                                                        value);
                                                            if (enteredDate
                                                                .isBefore(DateTime
                                                                        .now()
                                                                    .add(const Duration(
                                                                        days:
                                                                            6)))) {
                                                              return 'Date must be 1 week after today';
                                                            }
                                                          } catch (e) {
                                                            return 'Invalid Date Format. Format: dd-MM-yyyy';
                                                          }
                                                          return null;
                                                        }
                                                      },
                                                      controller: date,
                                                      hintText: 'Enter date',
                                                      suffixIcon: const Icon(Icons
                                                          .calendar_today_rounded),
                                                      onTap: () async {
                                                        DateTime? pickedDate =
                                                            await showDatePicker(
                                                          context: context,
                                                          initialDate: DateTime
                                                                  .now()
                                                              .add(
                                                                  const Duration(
                                                                      days: 7)),
                                                          firstDate: DateTime
                                                                  .now()
                                                              .add(
                                                                  const Duration(
                                                                      days: 7)),
                                                          lastDate: DateTime
                                                                  .now()
                                                              .add(
                                                                  const Duration(
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
                                          if (Responsive.isDesktop(context))
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
                                                    if (Responsive.isDesktop(
                                                        context))
                                                      Expanded(
                                                        flex: 2,
                                                        child: CustomTextField(
                                                          validator: (value) {
                                                            final DateFormat
                                                                timeFormat =
                                                                DateFormat(
                                                                    'HH:mm a');

                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Enter start time';
                                                            } else {
                                                              try {
                                                                final DateTime
                                                                    parsedTime =
                                                                    timeFormat
                                                                        .parse(
                                                                            value);
                                                              } catch (e) {
                                                                return 'Format: HH-mm AM/PM';
                                                              }
                                                              return null;
                                                            }
                                                          },
                                                          screen: !Responsive
                                                              .isDesktop(
                                                                  context),
                                                          labelText:
                                                              'Start Time',
                                                          errorText: startError,
                                                          controller: start,
                                                          hintText:
                                                              'Enter start time',
                                                          suffixIcon:
                                                              const Icon(Icons
                                                                  .punch_clock),
                                                          onTap: () async {
                                                            TimeOfDay?
                                                                pickedTime =
                                                                await showTimePicker(
                                                              context: context,
                                                              initialEntryMode:
                                                                  TimePickerEntryMode
                                                                      .inputOnly,
                                                              initialTime:
                                                                  const TimeOfDay(
                                                                      hour: 12,
                                                                      minute:
                                                                          00),
                                                            );

                                                            if (pickedTime !=
                                                                null) {
                                                              startError = null;

                                                              if (end.text
                                                                  .isNotEmpty) {
                                                                final DateFormat
                                                                    timeFormat =
                                                                    DateFormat(
                                                                        'hh:mm a');
                                                                DateTime
                                                                    parsedStartTime =
                                                                    timeFormat.parse(
                                                                        pickedTime
                                                                            .format(context));
                                                                DateTime
                                                                    parsedEndTime =
                                                                    timeFormat
                                                                        .parse(end
                                                                            .text);
                                                                if (parsedStartTime
                                                                    .isBefore(
                                                                        parsedEndTime)) {
                                                                  setState(() {
                                                                    start.text =
                                                                        pickedTime
                                                                            .format(context);
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    startError =
                                                                        'Must be before End Time';
                                                                  });
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
                                                    if (Responsive.isDesktop(
                                                        context))
                                                      const Text('     -     '),
                                                    if (Responsive.isDesktop(
                                                        context))
                                                      Expanded(
                                                        flex: 2,
                                                        child: CustomTextField(
                                                          screen: !Responsive
                                                              .isDesktop(
                                                                  context),
                                                          labelText: 'End Time',
                                                          errorText: endError,
                                                          controller: end,
                                                          hintText:
                                                              'Enter end time',
                                                          suffixIcon:
                                                              const Icon(Icons
                                                                  .punch_clock),
                                                          validator: (value) {
                                                            final DateFormat
                                                                timeFormat =
                                                                DateFormat(
                                                                    'HH:mm a');

                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Enter start time';
                                                            } else {
                                                              try {
                                                                final DateTime
                                                                    parsedTime =
                                                                    timeFormat
                                                                        .parse(
                                                                            value);
                                                              } catch (e) {
                                                                return 'Format: HH-mm AM/PM';
                                                              }
                                                              return null;
                                                            }
                                                          },
                                                          onTap: () async {
                                                            TimeOfDay?
                                                                pickedTime =
                                                                await showTimePicker(
                                                              context: context,
                                                              initialEntryMode:
                                                                  TimePickerEntryMode
                                                                      .input,
                                                              initialTime:
                                                                  const TimeOfDay(
                                                                      hour: 12,
                                                                      minute:
                                                                          0),
                                                            );

                                                            if (pickedTime !=
                                                                null) {
                                                              endError = null;

                                                              if (start.text !=
                                                                  '') {
                                                                final DateFormat
                                                                    timeFormat =
                                                                    DateFormat(
                                                                        'hh:mm a');
                                                                DateTime
                                                                    parsedStartTime =
                                                                    timeFormat
                                                                        .parse(start
                                                                            .text);
                                                                DateTime
                                                                    parsedEndTime =
                                                                    timeFormat.parse(
                                                                        pickedTime
                                                                            .format(context));

                                                                if (parsedEndTime
                                                                    .isAfter(
                                                                        parsedStartTime)) {
                                                                  setState(() {
                                                                    end.text = pickedTime
                                                                        .format(
                                                                            context);
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    endError =
                                                                        'Must be after Start Time';
                                                                  });
                                                                }
                                                              } else {
                                                                setState(() {
                                                                  end.text =
                                                                      pickedTime
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
                                      if (!Responsive.isDesktop(context))
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
                                                    if (Responsive.isDesktop(
                                                        context))
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
                                                        screen: !Responsive
                                                            .isDesktop(context),
                                                        validator: (value) {
                                                          final DateFormat
                                                              timeFormat =
                                                              DateFormat(
                                                                  'HH:mm a');

                                                          if (value!.isEmpty) {
                                                            return 'Enter start time';
                                                          } else {
                                                            try {
                                                              final DateTime
                                                                  parsedTime =
                                                                  timeFormat
                                                                      .parse(
                                                                          value);
                                                            } catch (e) {
                                                              return 'Format: HH-mm AM/PM';
                                                            }
                                                            return null;
                                                          }
                                                        },
                                                        labelText: 'Start Time',
                                                        errorText: startError,
                                                        controller: start,
                                                        hintText:
                                                            'Enter start time',
                                                        suffixIcon: const Icon(
                                                            Icons.punch_clock),
                                                        onTap: () async {
                                                          TimeOfDay?
                                                              pickedTime =
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

                                                            if (end.text
                                                                .isNotEmpty) {
                                                              final DateFormat
                                                                  timeFormat =
                                                                  DateFormat(
                                                                      'hh:mm a');
                                                              DateTime
                                                                  parsedStartTime =
                                                                  timeFormat.parse(
                                                                      pickedTime
                                                                          .format(
                                                                              context));
                                                              DateTime
                                                                  parsedEndTime =
                                                                  timeFormat
                                                                      .parse(end
                                                                          .text);

                                                              if (parsedStartTime
                                                                  .isBefore(
                                                                      parsedEndTime)) {
                                                                setState(() {
                                                                  start.text =
                                                                      pickedTime
                                                                          .format(
                                                                              context);
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  startError =
                                                                      'Must be before End Time';
                                                                });
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
                                                        screen: !Responsive
                                                            .isDesktop(context),
                                                        labelText: 'End Time',
                                                        validator: (value) {
                                                          final DateFormat
                                                              timeFormat =
                                                              DateFormat(
                                                                  'HH:mm a');

                                                          if (value!.isEmpty) {
                                                            return 'Enter start time';
                                                          } else {
                                                            try {
                                                              final DateTime
                                                                  parsedTime =
                                                                  timeFormat
                                                                      .parse(
                                                                          value);
                                                            } catch (e) {
                                                              return 'Format: HH-mm AM/PM';
                                                            }
                                                            return null;
                                                          }
                                                        },
                                                        errorText: endError,
                                                        controller: end,
                                                        hintText:
                                                            'Enter end time',
                                                        suffixIcon: const Icon(
                                                            Icons.punch_clock),
                                                        onTap: () async {
                                                          TimeOfDay?
                                                              pickedTime =
                                                              await showTimePicker(
                                                            context: context,
                                                            initialEntryMode:
                                                                TimePickerEntryMode
                                                                    .input,
                                                            initialTime:
                                                                const TimeOfDay(
                                                                    hour: 12,
                                                                    minute: 0),
                                                          );

                                                          if (pickedTime !=
                                                              null) {
                                                            endError = null;

                                                            if (start.text !=
                                                                '') {
                                                              final DateFormat
                                                                  timeFormat =
                                                                  DateFormat(
                                                                      'hh:mm a');
                                                              DateTime
                                                                  parsedStartTime =
                                                                  timeFormat
                                                                      .parse(start
                                                                          .text);
                                                              DateTime
                                                                  parsedEndTime =
                                                                  timeFormat.parse(
                                                                      pickedTime
                                                                          .format(
                                                                              context));

                                                              if (parsedEndTime
                                                                  .isAfter(
                                                                      parsedStartTime)) {
                                                                setState(() {
                                                                  end.text =
                                                                      pickedTime
                                                                          .format(
                                                                              context);
                                                                });
                                                              } else {
                                                                setState(() {
                                                                  endError =
                                                                      'Must be after Start Time';
                                                                });
                                                              }
                                                            } else {
                                                              setState(() {
                                                                end.text =
                                                                    pickedTime
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
                                                      if (Responsive.isDesktop(
                                                          context))
                                                        const Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            'Details',
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
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Date'),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 2,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Time'),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 6,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Details'),
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black),
                                                ),
                                                child: const Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Action'),
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
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: Text(DateFormat('dd-MM-yyyy').format(program.date)),
          ),
          const Divider(thickness: 1, color: Colors.black),
          Expanded(
            flex: 2,
            child: Text(
              '${program.start.format(context)} - ${program.end.format(context)}',
            ),
          ),
          const Divider(thickness: 1, color: Colors.black),
          Expanded(
            flex: 6,
            child: Text('${program.details}'),
          ),
          const Divider(thickness: 1, color: Colors.black),
          Expanded(
            flex: 1,
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: onDelete,
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDetailsDialog(BuildContext context, String details) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Programme Details'),
          content: Text(details),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
