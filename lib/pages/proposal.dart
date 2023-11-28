import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/studentOrganisedEvent.dart';
import 'package:flutter/services.dart';

class Proposal extends StatefulWidget {
  final String selectedEvent;
  const Proposal({super.key, required this.selectedEvent});

  @override
  State<Proposal> createState() => _ProposalState();
}

class _ProposalState extends State<Proposal> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
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
        setState(() {
          status = status;
        });
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

  final name = TextEditingController();
  final type = TextEditingController();
  final aim = TextEditingController();
  final description = TextEditingController();
  final member = TextEditingController();
  final nonMember = TextEditingController();
  final guest = TextEditingController();

  String selectedType = 'Talk';

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
                    buttonTexts: const ['Event', 'Proposal'],
                    destination: [
                      const StudentOrganisedEvent(),
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
                            Form(
                                key: _formKey,
                                child: TabContainer(
                                    selectedEvent: widget.selectedEvent,
                                    tab: 'Pre',
                                    form: 'Proposal',
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
                                                        'Event Name',
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
                                                      controller: name,
                                                      labelText: 'Event Name',
                                                      hintText:
                                                          'Enter event name',
                                                      validator: (value) {
                                                        if (value!.isEmpty) {
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
                                                        'Event Type',
                                                        style: TextStyle(
                                                            fontSize: 16),
                                                      ),
                                                    ),
                                                  Expanded(
                                                      flex: 4,
                                                      child: CustomDDL<String>(
                                                        labelText: 'Event Type',
                                                        screen: !Responsive
                                                            .isDesktop(context),
                                                        controller: type,
                                                        hintText:
                                                            'Select event type',
                                                        value: selectedType,
                                                        dropdownItems: [
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
                                                            value: type,
                                                            child: Text(type,
                                                                overflow:
                                                                    TextOverflow
                                                                        .ellipsis),
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
                                                            'Description',
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ),
                                                        ),
                                                      Expanded(
                                                        flex: 9,
                                                        child: CustomTextField(
                                                          screen: !Responsive
                                                              .isDesktop(
                                                                  context),
                                                          maxLength: 400,
                                                          labelText:
                                                              'Description',
                                                          hintText:
                                                              'Enter event description',
                                                          controller:
                                                              description,
                                                          maxLine: 5,
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Please enter event description';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ))),
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
                                                            'Aim',
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ),
                                                        ),
                                                      Expanded(
                                                        flex: 9,
                                                        child: CustomTextField(
                                                          maxLength: 400,
                                                          labelText: 'Aim',
                                                          screen: !Responsive
                                                              .isDesktop(
                                                                  context),
                                                          hintText:
                                                              'Enter aim of event',
                                                          controller: aim,
                                                          maxLine: 5,
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return 'Please enter aim of the event';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ))),
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
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      if (Responsive.isDesktop(
                                                          context))
                                                        const Expanded(
                                                          flex: 3,
                                                          child: Text(
                                                            'Participants',
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ),
                                                        ),
                                                      const Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          'Member',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 50,
                                                        child: CustomTextField(
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          hintText: '0',
                                                          controller: member,
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return ' ';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 50,
                                                      ),
                                                      const Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          'Non-Member',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 50,
                                                        child: CustomTextField(
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          hintText: '0',
                                                          controller: nonMember,
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return ' ';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        width: 50,
                                                      ),
                                                      const Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                          'Guest',
                                                          style: TextStyle(
                                                              fontSize: 16),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 50,
                                                        child: CustomTextField(
                                                          inputFormatters: [
                                                            FilteringTextInputFormatter
                                                                .digitsOnly
                                                          ],
                                                          hintText: '0',
                                                          controller: guest,
                                                          validator: (value) {
                                                            if (value!
                                                                .isEmpty) {
                                                              return ' ';
                                                            }
                                                            return null;
                                                          },
                                                        ),
                                                      ),
                                                    ],
                                                  ))),
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
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  FirebaseFirestore firestore =
                                                      FirebaseFirestore
                                                          .instance;
                                                  Map<String, dynamic>
                                                      updatedData = {
                                                    'eventName': name.text,
                                                    'type': selectedType,
                                                    'description':
                                                        description.text,
                                                    'aim': aim.text,
                                                    'memberCount': member.text,
                                                    'nonMemberCount':
                                                        nonMember.text,
                                                    'guestCOunt': guest.text,
                                                  };

                                                  try {
                                                    await firestore
                                                        .collection('event')
                                                        .doc(widget
                                                            .selectedEvent)
                                                        .update(updatedData);
                                                  } catch (error) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Failed to update proposal. Please try again.'),
                                                        width: 225.0,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        duration: Duration(
                                                            seconds: 3),
                                                      ),
                                                    );
                                                  }
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
                                          thickness: 0.1, color: Colors.black),
                                      CustomTimeline(status: status),
                                    ])),
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
