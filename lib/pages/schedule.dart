import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:intl/intl.dart';

class Schedule extends StatefulWidget {
  final String selectedEvent;
  final String status;
  final int progress;
  final String position;
  const Schedule(
      {super.key,
      required this.selectedEvent,
      required this.status,
      required this.progress,
      required this.position});

  @override
  State<Schedule> createState() => _ScheduleState();
}

class _ScheduleState extends State<Schedule> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  List<Programme> programList = [];
  bool _isLoading = true;
  bool enabled = true;

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });

      if (!widget.position.startsWith('org') ||
          widget.position.contains('Treasurer') ||
          widget.status != 'Planning' ||
          widget.progress != 0) {
        enabled = false;
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot<Map<String, dynamic>> scheduleSnapshot =
          await firestore
              .collection('schedule')
              .where('eventID', isEqualTo: widget.selectedEvent)
              .get();
      programList.clear();

      for (QueryDocumentSnapshot<Map<String, dynamic>> doc
          in scheduleSnapshot.docs) {
        DateTime date = (doc['date'] as Timestamp).toDate();
        DateTime startTime = (doc['startTime'] as Timestamp).toDate();
        DateTime endTime = (doc['endTime'] as Timestamp).toDate();

        Programme program = Programme(
          date: date,
          startTime: startTime,
          endTime: endTime,
          venue: doc['venue'] ?? '',
          details: doc['details'] ?? '',
        );

        programList.add(program);
      }
      programList.sort((a, b) {
        int dateComparison = a.date.compareTo(b.date);
        if (dateComparison == 0) {
          return a.startTime.compareTo(b.startTime);
        }
        return dateComparison;
      });

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

  void resetTable() {
    setState(() {
      programList = programList;
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
  final venue = TextEditingController();
  String? startError;
  String? endError;
  String? dateError;

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
                                          status: widget.status,
                                          position: widget.position,
                                          progress: widget.progress,
                                          children: [
                                            if(enabled)
                                            Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8.0),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            if (Responsive
                                                                .isDesktop(context))
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
                                                              child:
                                                                  CustomTextField(
                                                                errorText:
                                                                    dateError,
                                                                screen: !Responsive
                                                                    .isDesktop(
                                                                        context),
                                                                labelText: 'Date',
                                                                validator: (value) {
                                                                  final DateFormat
                                                                      dateFormat =
                                                                      DateFormat(
                                                                          'dd-MM-yyyy');

                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter date';
                                                                  } else {
                                                                    try {
                                                                      DateTime
                                                                          enteredDate =
                                                                          dateFormat
                                                                              .parseStrict(
                                                                                  value);
                                                                      if (enteredDate.isBefore(DateTime
                                                                              .now()
                                                                          .add(const Duration(
                                                                              days:
                                                                                  6)))) {
                                                                        return 'Date must be 1 week after today';
                                                                      }
                                                                    } catch (e) {
                                                                      return 'Invalid Date Format. Format: dd-MM-yyyy';
                                                                    }
                                                                    if (!RegExp(
                                                                            r'^\d{2}-\d{2}-\d{4}$')
                                                                        .hasMatch(
                                                                            value)) {
                                                                      return 'Invalid Date Format. Format: dd-MM-yyyy';
                                                                    }
                                                                    return null;
                                                                  }
                                                                },
                                                                controller: date,
                                                                hintText:
                                                                    'Enter date',
                                                                suffixIcon:
                                                                    IconButton(
                                                                        icon: const Icon(
                                                                            Icons
                                                                                .calendar_today_rounded),
                                                                        onPressed:
                                                                            () async {
                                                                          DateTime?
                                                                              pickedDate =
                                                                              await showDatePicker(
                                                                            context:
                                                                                context,
                                                                            initialDate:
                                                                                DateTime.now().add(const Duration(days: 7)),
                                                                            firstDate:
                                                                                DateTime.now().add(const Duration(days: 7)),
                                                                            lastDate:
                                                                                DateTime.now().add(const Duration(days: 365)),
                                                                          );

                                                                          if (pickedDate !=
                                                                              null) {
                                                                            setState(
                                                                                () {
                                                                              date.text =
                                                                                  DateFormat('dd-MM-yyyy').format(pickedDate);
                                                                            });
                                                                          }
                                                                        }),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets.all(
                                                                8.0),
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
                                                                'Venue',
                                                                style: TextStyle(
                                                                    fontSize: 16),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              flex: 4,
                                                              child:
                                                                  CustomTextField(
                                                                validator: (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter programme venue';
                                                                  }
                                                                  return null;
                                                                },
                                                                screen: !Responsive
                                                                    .isDesktop(
                                                                        context),
                                                                labelText: 'Venue',
                                                                controller: venue,
                                                                hintText:
                                                                    'Enter programme venue',
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
                                                            const EdgeInsets.all(
                                                                8.0),
                                                        child: Row(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
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
                                                                    if (Responsive
                                                                        .isDesktop(
                                                                            context))
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
                                                                      flex: 4,
                                                                      child:
                                                                          CustomTextField(
                                                                        screen: !Responsive
                                                                            .isDesktop(
                                                                                context),
                                                                        validator:
                                                                            (value) {
                                                                          final DateFormat
                                                                              timeFormat =
                                                                              DateFormat(
                                                                                  'HH:mm a');

                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return 'Enter start time';
                                                                          } else {
                                                                            try {
                                                                              DateTime
                                                                                  parsedStartTime =
                                                                                  timeFormat.parse(value);
                                                                              final DateTime
                                                                                  parsedEndTime =
                                                                                  timeFormat.parse(end.text);

                                                                              if (parsedStartTime
                                                                                  .isAfter(parsedEndTime)) {
                                                                                return 'Must be before End time';
                                                                              }
                                                                            } catch (e) {
                                                                              return 'Format: HH:mm AM/PM';
                                                                            }
                                                                            final RegExp
                                                                                timeRegex =
                                                                                RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9] (AM|PM)$');
                                                                            if (!timeRegex
                                                                                .hasMatch(value)) {
                                                                              return 'Format: HH:mm AM/PM';
                                                                            }
                                                                            return null;
                                                                          }
                                                                        },
                                                                        labelText:
                                                                            'Start Time',
                                                                        errorText:
                                                                            startError,
                                                                        controller:
                                                                            start,
                                                                        hintText:
                                                                            'Enter start time',
                                                                        suffixIcon:
                                                                            IconButton(
                                                                                icon:
                                                                                    const Icon(Icons.punch_clock),
                                                                                onPressed: () async {
                                                                                  TimeOfDay? pickedTime = await showTimePicker(
                                                                                    context: context,
                                                                                    initialEntryMode: TimePickerEntryMode.inputOnly,
                                                                                    initialTime: const TimeOfDay(hour: 12, minute: 00),
                                                                                  );

                                                                                  if (pickedTime != null) {
                                                                                    startError = null;

                                                                                    if (end.text.isNotEmpty) {
                                                                                      final DateFormat timeFormat = DateFormat('hh:mm a');
                                                                                      DateTime parsedStartTime = timeFormat.parse(pickedTime.format(context));
                                                                                      DateTime parsedEndTime = timeFormat.parse(end.text);

                                                                                      if (parsedStartTime.isBefore(parsedEndTime)) {
                                                                                        setState(() {
                                                                                          start.text = pickedTime.format(context);
                                                                                        });
                                                                                      } else {
                                                                                        setState(() {
                                                                                          startError = 'Must be before End Time';
                                                                                        });
                                                                                      }
                                                                                    } else {
                                                                                      setState(() {
                                                                                        start.text = pickedTime.format(context);
                                                                                      });
                                                                                    }
                                                                                  }
                                                                                }),
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
                                                                      child: Center(
                                                                        child: Text(
                                                                            '-'),
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      flex: 4,
                                                                      child:
                                                                          CustomTextField(
                                                                        screen: !Responsive
                                                                            .isDesktop(
                                                                                context),
                                                                        labelText:
                                                                            'End Time',
                                                                        validator:
                                                                            (value) {
                                                                          final DateFormat
                                                                              timeFormat =
                                                                              DateFormat(
                                                                                  'HH:mm a');

                                                                          if (value!
                                                                              .isEmpty) {
                                                                            return 'Enter end time';
                                                                          } else {
                                                                            try {
                                                                              DateTime
                                                                                  parsedStartTime =
                                                                                  timeFormat.parse(start.text);
                                                                              final DateTime
                                                                                  parsedEndTime =
                                                                                  timeFormat.parse(value);

                                                                              if (parsedStartTime
                                                                                  .isAfter(parsedEndTime)) {
                                                                                return 'Must be after Start time';
                                                                              }
                                                                            } catch (e) {
                                                                              return 'Format: HH:mm AM/PM';
                                                                            }
                                                                            final RegExp
                                                                                timeRegex =
                                                                                RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9] (AM|PM)$');
                                                                            if (!timeRegex
                                                                                .hasMatch(value)) {
                                                                              return 'Format: HH:mm AM/PM';
                                                                            }
                                                                            return null;
                                                                          }
                                                                        },
                                                                        errorText:
                                                                            endError,
                                                                        controller:
                                                                            end,
                                                                        hintText:
                                                                            'Enter end time',
                                                                        suffixIcon:
                                                                            IconButton(
                                                                                icon:
                                                                                    const Icon(Icons.punch_clock),
                                                                                onPressed: () async {
                                                                                  TimeOfDay? pickedTime = await showTimePicker(
                                                                                    context: context,
                                                                                    initialEntryMode: TimePickerEntryMode.input,
                                                                                    initialTime: const TimeOfDay(hour: 12, minute: 0),
                                                                                  );

                                                                                  if (pickedTime != null) {
                                                                                    endError = null;

                                                                                    if (start.text != '') {
                                                                                      final DateFormat timeFormat = DateFormat('hh:mm a');
                                                                                      DateTime parsedStartTime = timeFormat.parse(start.text);
                                                                                      DateTime parsedEndTime = timeFormat.parse(pickedTime.format(context));

                                                                                      if (parsedEndTime.isAfter(parsedStartTime)) {
                                                                                        setState(() {
                                                                                          end.text = pickedTime.format(context);
                                                                                        });
                                                                                      } else {
                                                                                        setState(() {
                                                                                          endError = 'Must be after Start Time';
                                                                                        });
                                                                                      }
                                                                                    } else {
                                                                                      setState(() {
                                                                                        end.text = pickedTime.format(context);
                                                                                      });
                                                                                    }
                                                                                  }
                                                                                }),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
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
                                                                if (Responsive
                                                                    .isDesktop(
                                                                        context))
                                                                  const Expanded(
                                                                    flex: 1,
                                                                    child: Text(
                                                                      'Details',
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16),
                                                                    ),
                                                                  ),
                                                                Expanded(
                                                                  flex: 9,
                                                                  child:
                                                                      CustomTextField(
                                                                    screen: !Responsive
                                                                        .isDesktop(
                                                                            context),
                                                                    labelText:
                                                                        'Programme Details',
                                                                    maxLength: 100,
                                                                    hintText:
                                                                        'Enter programme details',
                                                                    controller:
                                                                        detail,
                                                                    maxLine: 3,
                                                                    validator:
                                                                        (value) {
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
                                                        setState(() {
                                                          startError = null;
                                                          dateError = null;
                                                        });

                                                        Programme newProgramme =
                                                            Programme(
                                                          date: DateFormat(
                                                                  'dd-MM-yyyy')
                                                              .parse(date.text),
                                                          startTime: DateFormat(
                                                                  'hh:mm a')
                                                              .parse(start.text),
                                                          endTime:
                                                              DateFormat('hh:mm a')
                                                                  .parse(end.text),
                                                          venue: venue.text,
                                                          details: detail.text,
                                                        );
                                                        if (programList
                                                                .isNotEmpty &&
                                                            newProgramme.date
                                                                .isBefore(
                                                                    programList.last
                                                                        .date)) {
                                                          setState(() {
                                                            dateError =
                                                                'Must start after last programme';
                                                          });
                                                          return;
                                                        }

                                                        if (programList
                                                                .isNotEmpty &&
                                                            newProgramme.date
                                                                .isAtSameMomentAs(
                                                                    programList.last
                                                                        .date) &&
                                                            newProgramme.startTime
                                                                .isBefore(
                                                                    programList.last
                                                                        .endTime)) {
                                                          setState(() {
                                                            startError =
                                                                'Must start after last programme';
                                                          });
                                                          return;
                                                        }

                                                        programList
                                                            .add(newProgramme);
                                                        setState(() {
                                                          programList = programList;
                                                        });

                                                        date.clear();
                                                        start.clear();
                                                        end.clear();
                                                        detail.clear();
                                                        venue.clear();
                                                      }
                                                    },
                                                    text: 'Add'),
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                              ],
                                            ),
                                            if (programList.isNotEmpty)
                                              Column(
                                                children: [
                                                  Center(
                                                    child: programList.isNotEmpty?
                                                        SingleChildScrollView(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      child: DataTable(
                                                        columns: const [
                                                          DataColumn(
                                                              label:
                                                                  Text('Date')),
                                                          DataColumn(
                                                              label:
                                                                  Text('Time')),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Venue')),
                                                          DataColumn(
                                                              label: Text(
                                                                  'Details')),
                                                          DataColumn(
                                                              label: Text('')),
                                                        ],
                                                        rows: programList
                                                            .asMap()
                                                            .entries
                                                            .map((entry) {
                                                          final int index =
                                                              entry.key;
                                                          final Programme
                                                              program =
                                                              entry.value;

                                                          return DataRow(
                                                            cells: [
                                                              DataCell(Text(DateFormat(
                                                                      'dd-MM-yyyy')
                                                                  .format(program
                                                                      .date))),
                                                              DataCell(Text(
                                                                  '${DateFormat('hh:mm a').format(program.startTime)} - ${DateFormat('hh:mm a').format(program.endTime)}')),
                                                              DataCell(Text(
                                                                  program
                                                                      .venue)),
                                                              DataCell(Text(
                                                                  program
                                                                      .details)),
                                                              DataCell(Row(
                                                                children: [
                                                                  if(enabled)
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .edit),
                                                                    onPressed:
                                                                        () {
                                                                      showDialog(
                                                                          context:
                                                                              context,
                                                                          builder:
                                                                              (_) {
                                                                            return EditDialog(
                                                                              program: program,
                                                                              index: index,
                                                                              programList: programList,
                                                                              function: resetTable,
                                                                            );
                                                                          });
                                                                    },
                                                                  ),
                                                                  if(enabled)
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .delete),
                                                                    onPressed:
                                                                        () {
                                                                      setState(
                                                                          () {
                                                                        programList
                                                                            .removeAt(index);
                                                                      });
                                                                    },
                                                                  ),
                                                                ],
                                                              )),
                                                            ],
                                                          );
                                                        }).toList(),
                                                      ),
                                                    ) : const SizedBox(height: 500, child: Center(child: Text('There is no programme registered.'))),
                                                  ),
                                                ],
                                              ),
                                            if (enabled)
                                              CustomButton(
                                                  width: 150,
                                                  onPressed: () async {
                                                    if (programList
                                                        .isNotEmpty) {
                                                      FirebaseFirestore
                                                          firestore =
                                                          FirebaseFirestore
                                                              .instance;

                                                      CollectionReference
                                                          schedules =
                                                          firestore.collection(
                                                              'schedule');

                                                      QuerySnapshot
                                                          querySnapshot =
                                                          await schedules
                                                              .where('eventID',
                                                                  isEqualTo: widget
                                                                      .selectedEvent)
                                                              .get();

                                                      for (QueryDocumentSnapshot documentSnapshot
                                                          in querySnapshot
                                                              .docs) {
                                                        await documentSnapshot
                                                            .reference
                                                            .delete();
                                                      }

                                                      for (int index = 0;
                                                          index <
                                                              programList
                                                                  .length;
                                                          index++) {
                                                        Programme program =
                                                            programList[index];

                                                        await schedules.add({
                                                          'eventID': widget
                                                              .selectedEvent,
                                                          'date': Timestamp
                                                              .fromDate(
                                                                  program.date),
                                                          'startTime': Timestamp
                                                              .fromDate(program
                                                                  .startTime),
                                                          'endTime': Timestamp
                                                              .fromDate(program
                                                                  .endTime),
                                                          'venue':
                                                              program.venue,
                                                          'details':
                                                              program.details,
                                                        });
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                'Schedule saved.'),
                                                            width: 150.0,
                                                            behavior:
                                                                SnackBarBehavior
                                                                    .floating,
                                                            duration: Duration(
                                                                seconds: 3),
                                                          ),
                                                        );
                                                      }
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Please enter atleast one programme.'),
                                                          width: 225.0,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                    }
                                                  },
                                                  text: 'Save'),
                                            const SizedBox(
                                              height: 15,
                                            ),
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

class Programme {
  DateTime date;
  DateTime startTime;
  DateTime endTime;
  String venue;
  String details;

  Programme(
      {required this.date,
      required this.startTime,
      required this.endTime,
      required this.venue,
      required this.details});
}

class EditDialog extends StatefulWidget {
  final Programme program;
  final int index;
  final List<Programme> programList;
  final VoidCallback function;

  const EditDialog({
    required this.program,
    required this.index,
    required this.programList,
    required this.function,
  });
  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController date = TextEditingController();
  TextEditingController start = TextEditingController();
  TextEditingController end = TextEditingController();
  TextEditingController venue = TextEditingController();
  TextEditingController detail = TextEditingController();
  String? startError;
  String? endError;
  String? dateError;

  @override
  void initState() {
    super.initState();
    date.text = DateFormat('dd-MM-yyyy').format(widget.program.date);
    start.text = DateFormat('HH:mm a').format(widget.program.startTime);
    end.text = DateFormat('HH:mm a').format(widget.program.endTime);
    venue.text = widget.program.venue;
    detail.text = widget.program.details;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Programme'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: CustomTextField(
                    screen: true,
                    labelText: 'Date',
                    errorText: dateError,
                    validator: (value) {
                      final DateFormat dateFormat = DateFormat('dd-MM-yyyy');
                      if (value!.isEmpty) {
                        return 'Please enter date';
                      } else {
                        try {
                          DateTime enteredDate = dateFormat.parseStrict(value);
                          if (enteredDate.isBefore(
                              DateTime.now().add(const Duration(days: 6)))) {
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
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.calendar_today_rounded),
                        onPressed: () async {
                          DateTime? pickedDate = await showDatePicker(
                            context: context,
                            initialDate:
                                DateTime.now().add(const Duration(days: 7)),
                            firstDate:
                                DateTime.now().add(const Duration(days: 7)),
                            lastDate:
                                DateTime.now().add(const Duration(days: 365)),
                          );

                          if (pickedDate != null) {
                            setState(() {
                              date.text =
                                  DateFormat('dd-MM-yyyy').format(pickedDate);
                            });
                          }
                        }),
                  ),
                ),
                const Text('     '),
                SizedBox(
                  width: 200,
                  child: CustomTextField(
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Please enter programme venue';
                      }
                      return null;
                    },
                    screen: true,
                    labelText: 'Venue',
                    errorText: startError,
                    controller: venue,
                    hintText: 'Enter programme venue',
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                SizedBox(
                  width: 200,
                  child: CustomTextField(
                    screen: true,
                    validator: (value) {
                      final DateFormat timeFormat = DateFormat('HH:mm a');

                      if (value!.isEmpty) {
                        return 'Enter start time';
                      } else {
                        try {
                          DateTime parsedStartTime = timeFormat.parse(value);
                          final DateTime parsedEndTime =
                              timeFormat.parse(end.text);

                          if (parsedStartTime.isAfter(parsedEndTime)) {
                            return 'Must be before End time';
                          }
                        } catch (e) {
                          return 'Format: HH:mm AM/PM';
                        }
                        final RegExp timeRegex =
                            RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9] (AM|PM)$');
                        if (!timeRegex.hasMatch(value)) {
                          return 'Format: HH:mm AM/PM';
                        }
                        return null;
                      }
                    },
                    labelText: 'Start Time',
                    errorText: startError,
                    controller: start,
                    hintText: 'Enter start time',
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.punch_clock),
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialEntryMode: TimePickerEntryMode.inputOnly,
                            initialTime: const TimeOfDay(hour: 12, minute: 00),
                          );

                          if (pickedTime != null) {
                            startError = null;

                            if (end.text.isNotEmpty) {
                              final DateFormat timeFormat =
                                  DateFormat('hh:mm a');
                              DateTime parsedStartTime =
                                  timeFormat.parse(pickedTime.format(context));
                              DateTime parsedEndTime =
                                  timeFormat.parse(end.text);

                              if (parsedStartTime.isBefore(parsedEndTime)) {
                                setState(() {
                                  start.text = pickedTime.format(context);
                                });
                              } else {
                                setState(() {
                                  startError = 'Must be before End Time';
                                });
                              }
                            } else {
                              setState(() {
                                start.text = pickedTime.format(context);
                              });
                            }
                          }
                        }),
                  ),
                ),
                const Text('  -  '),
                SizedBox(
                  width: 200,
                  child: CustomTextField(
                    screen: true,
                    labelText: 'End Time',
                    validator: (value) {
                      final DateFormat timeFormat = DateFormat('HH:mm a');

                      if (value!.isEmpty) {
                        return 'Enter end time';
                      } else {
                        try {
                          DateTime parsedStartTime =
                              timeFormat.parse(start.text);
                          final DateTime parsedEndTime =
                              timeFormat.parse(value);

                          if (parsedStartTime.isAfter(parsedEndTime)) {
                            return 'Must be after Start time';
                          }
                        } catch (e) {
                          return 'Format: HH:mm AM/PM';
                        }
                        final RegExp timeRegex =
                            RegExp(r'^([01]?[0-9]|2[0-3]):[0-5][0-9] (AM|PM)$');
                        if (!timeRegex.hasMatch(value)) {
                          return 'Format: HH:mm AM/PM';
                        }
                        return null;
                      }
                    },
                    errorText: endError,
                    controller: end,
                    hintText: 'Enter end time',
                    suffixIcon: IconButton(
                        icon: const Icon(Icons.punch_clock),
                        onPressed: () async {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialEntryMode: TimePickerEntryMode.input,
                            initialTime: const TimeOfDay(hour: 12, minute: 0),
                          );

                          if (pickedTime != null) {
                            endError = null;

                            if (start.text != '') {
                              final DateFormat timeFormat =
                                  DateFormat('hh:mm a');
                              DateTime parsedStartTime =
                                  timeFormat.parse(start.text);
                              DateTime parsedEndTime =
                                  timeFormat.parse(pickedTime.format(context));

                              if (parsedEndTime.isAfter(parsedStartTime)) {
                                setState(() {
                                  end.text = pickedTime.format(context);
                                });
                              } else {
                                setState(() {
                                  endError = 'Must be after Start Time';
                                });
                              }
                            } else {
                              setState(() {
                                end.text = pickedTime.format(context);
                              });
                            }
                          }
                        }),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: 420,
              child: CustomTextField(
                screen: true,
                labelText: 'Programme Details',
                maxLength: 100,
                hintText: 'Enter programme details',
                controller: detail,
                maxLine: 3,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter programme details';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (_formKey.currentState!.validate()) {
              if (_isDateTimeValid()) {
                Programme updatedProgramme = Programme(
                  date: DateFormat('dd-MM-yyyy').parse(date.text),
                  startTime: DateFormat('hh:mm a').parse(start.text),
                  endTime: DateFormat('hh:mm a').parse(end.text),
                  venue: venue.text,
                  details: detail.text,
                );

                widget.programList[widget.index] = updatedProgramme;

                widget.function();
                Navigator.of(context).pop();
              }
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }

  bool _isDateTimeValid() {
    DateTime enteredDate = DateFormat('dd-MM-yyyy').parseStrict(date.text)!;
    DateTime enteredStartTime = DateFormat('hh:mm a').parse(start.text)!;
    DateTime enteredEndTime = DateFormat('hh:mm a').parse(end.text)!;

    if (widget.index > 0) {
      DateTime previousProgramEndTime =
          widget.programList[widget.index - 1].endTime;
      if (enteredDate.isBefore(widget.programList[widget.index - 1].date)) {
        setState(() {
          dateError = 'Must start after previous programme';
        });
        return false;
      }

      if (enteredDate
              .isAtSameMomentAs(widget.programList[widget.index - 1].date) &&
          enteredStartTime.isBefore(previousProgramEndTime)) {
        setState(() {
          startError = 'Must start after previous programme';
        });
        return false;
      }
    }

    if (widget.index < widget.programList.length - 1) {
      DateTime nextProgramStartTime =
          widget.programList[widget.index + 1].startTime;
      if (enteredDate.isAfter(widget.programList[widget.index + 1].date)) {
        setState(() {
          dateError = 'Must end before next programme';
        });
        return false;
      }

      if (enteredDate
              .isAtSameMomentAs(widget.programList[widget.index + 1].date) &&
          enteredEndTime.isAfter(nextProgramStartTime)) {
        setState(() {
          endError = 'Must end before next programme';
        });
        return false;
      }
    }

    setState(() {
      dateError = null;
      startError = null;
      endError = null;
    });

    return true;
  }
}
