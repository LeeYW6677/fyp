import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/proposal.dart';
import 'package:intl/intl.dart';

class EventDetails extends StatefulWidget {
  final String selectedEvent;

  EventDetails({Key? key, required this.selectedEvent}) : super(key: key);

  @override
  State<EventDetails> createState() => _EventDetailsState();
}

class _EventDetailsState extends State<EventDetails> {
  String status = '';
  int progress = -1;
  bool _isLoading = true;
  List<String> restrictedPositions = [
    'President',
    'Vice President',
    'Secretary',
    'Vice Secretary',
    'Treasurer',
    'Vice Treasurer',
  ];
  Map<String, List<String>> positionData = {};
  final nothing = TextEditingController();
  List<String> preProgress = ['Planning', 'Checked', 'Recommended', 'Approved'];
  List<String> postProgress = ['Closing', 'Checked', 'Verified', 'Accepted'];
  DateTime? startDate;
  DateTime? endDate;
  List<String> checkName = ['', '', '', ''];
  List<String> checkStatus = ['', '', '', ''];
  String name = '';
  String eventStatus = '';
  String comment = '';

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch event and committee data
      final QuerySnapshot<Map<String, dynamic>> committeeSnapshot =
          await firestore
              .collection('committee')
              .where('eventID', isEqualTo: widget.selectedEvent)
              .where('position', whereIn: restrictedPositions)
              .get();
      for (var position in restrictedPositions) {
        positionData[position] = [];
      }

      for (var doc in committeeSnapshot.docs) {
        String position = doc.data()['position'];
        String name = doc.data()['name'];

        positionData[position]?.add(name);
      }

      // Fetch event data
      final QuerySnapshot<Map<String, dynamic>> eventSnapshot = await firestore
          .collection('event')
          .where('eventID', isEqualTo: widget.selectedEvent)
          .get();
      if (eventSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> eventData = eventSnapshot.docs.first.data();
        status = eventData['status'];
        progress = eventData['progress'];
        name = eventData['eventName'];
      }
      final QuerySnapshot<Map<String, dynamic>> approvalSnapshot =
          await firestore
              .collection('approval')
              .where('eventID', isEqualTo: widget.selectedEvent)
              .get();
      checkName.clear();
      checkStatus.clear();
      if (approvalSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> approvalData = approvalSnapshot.docs.first.data();
        comment = approvalData['comment'];
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
      } else if (checkStatus.any((element) => element == '')) {
        eventStatus = 'Pending';
      } else {
        eventStatus = 'Approved';
      }

      Query<Map<String, dynamic>> query = firestore
          .collection('schedule')
          .where('eventID', isEqualTo: widget.selectedEvent)
          .orderBy('date');

      QuerySnapshot<Map<String, dynamic>> snapshot = await query.limit(1).get();

      Query<Map<String, dynamic>> query2 = firestore
          .collection('schedule')
          .where('eventID', isEqualTo: widget.selectedEvent)
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
        DocumentSnapshot<Map<String, dynamic>> latestDoc = snapshot2.docs.first;

        Timestamp date = latestDoc['date'];
        endDate = date.toDate();
      }

      setState(() {
        checkName = checkName;
        checkStatus = checkStatus;
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
              index: 1,
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
                        index: 1,
                      ),
                    ),
                  Expanded(
                    flex: 5,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
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
                                const SizedBox(
                                  height: 15,
                                ),
                                Center(
                                  child: Text(
                                    name,
                                    style: const TextStyle(fontSize: 36),
                                  ),
                                ),
                                Center(
                                  child: Text(
                                    'Event Date: ${startDate != null ? DateFormat('dd/MM/yyyy').format(startDate!) : 'Undecided'} - ${endDate != null ? DateFormat('dd/MM/yyyy').format(endDate!) : 'Undecided'}',
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const Text(
                                  'Organising Committee:',
                                  style: TextStyle(fontSize: 20),
                                ),
                                const Divider(
                                  thickness: 0.1,
                                  color: Colors.black,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      if (Responsive.isDesktop(context))
                                        const Expanded(
                                            flex: 2, child: SizedBox()),
                                      const Expanded(
                                        flex: 2,
                                        child: Text(
                                          'President:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          positionData['President']
                                                      ?.isNotEmpty ??
                                                  false
                                              ? positionData['President']![0]
                                              : 'Unassigned',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Vice President:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          positionData['Vice President']
                                                      ?.isNotEmpty ??
                                                  false
                                              ? positionData['Vice President']![
                                                  0]
                                              : 'Unassigned',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (Responsive.isDesktop(context))
                                        const Expanded(
                                            flex: 2, child: SizedBox()),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      if (Responsive.isDesktop(context))
                                        const Expanded(
                                            flex: 2, child: SizedBox()),
                                      const Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Secretary:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          positionData['Secretary']
                                                      ?.isNotEmpty ??
                                                  false
                                              ? positionData['Secretary']![0]
                                              : 'Unassigned',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Vice Secretary:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          positionData['Vice Secretary']
                                                      ?.isNotEmpty ??
                                                  false
                                              ? positionData['Vice Secretary']![
                                                  0]
                                              : 'Unassigned',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (Responsive.isDesktop(context))
                                        const Expanded(
                                            flex: 2, child: SizedBox()),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      if (Responsive.isDesktop(context))
                                        const Expanded(
                                            flex: 2, child: SizedBox()),
                                      const Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Treasurer:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          positionData['Treasurer']
                                                      ?.isNotEmpty ??
                                                  false
                                              ? positionData['Treasurer']![0]
                                              : 'Unassigned',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const Expanded(
                                        flex: 2,
                                        child: Text(
                                          'Vice Treasurer:',
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: Text(
                                          positionData['Vice Treasurer']
                                                      ?.isNotEmpty ??
                                                  false
                                              ? positionData['Vice Treasurer']![
                                                  0]
                                              : 'Unassigned',
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      if (Responsive.isDesktop(context))
                                        const Expanded(
                                            flex: 2, child: SizedBox()),
                                    ],
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomButton(
                                        buttonColor: Colors.green,
                                        width: 150,
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Proposal(
                                                  selectedEvent:
                                                      widget.selectedEvent),
                                            ),
                                          );
                                        },
                                        text: 'Edit'),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                const Text(
                                  'Event Status:',
                                  style: TextStyle(fontSize: 20),
                                ),
                                const Divider(
                                  thickness: 0.1,
                                  color: Colors.black,
                                ),
                                CustomTimeline(
                                  status: status,
                                  progress: progress,
                                  eventID: widget.selectedEvent,
                                  checkName: checkName,
                                  checkStatus: checkStatus,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Center(
                                    child: Text(
                                  'Status : $eventStatus',
                                  style: const TextStyle(fontSize: 16),
                                )),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    CustomButton(
                                        onPressed: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => Proposal(
                                                  selectedEvent:
                                                      widget.selectedEvent),
                                            ),
                                          );
                                        },
                                        text: 'View Documents'),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    if (status == 'Planning' && progress != 3)
                                      CustomButton(
                                          width: 150,
                                          onPressed: status == 'Planning' &&
                                                  progress == 0
                                              ? () async {
                                                  final FirebaseFirestore
                                                      firestore =
                                                      FirebaseFirestore
                                                          .instance;

                                                  bool description = false;

                                                  final QuerySnapshot<
                                                          Map<String, dynamic>>
                                                      eventSnapshot =
                                                      await firestore
                                                          .collection('event')
                                                          .where('eventID',
                                                              isEqualTo: widget
                                                                  .selectedEvent)
                                                          .get();

                                                  if (eventSnapshot
                                                      .docs.isNotEmpty) {
                                                    Map<String, dynamic>
                                                        eventData =
                                                        eventSnapshot.docs.first
                                                            .data();
                                                    description = eventData[
                                                            'description'] ==
                                                        null;
                                                  }

                                                  final QuerySnapshot<
                                                          Map<String, dynamic>>
                                                      scheduleSnapshot =
                                                      await firestore
                                                          .collection(
                                                              'schedule')
                                                          .where('eventID',
                                                              isEqualTo: widget
                                                                  .selectedEvent)
                                                          .get();
                                                  bool schedule =
                                                      scheduleSnapshot
                                                          .docs.isEmpty;

                                                  if (schedule || description) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Please save the required document before submitting.'),
                                                        width: 200.0,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        duration: Duration(
                                                            seconds: 3),
                                                      ),
                                                    );
                                                  } else {
                                                    if (startDate?.isBefore(
                                                            DateTime.now().add(
                                                                const Duration(
                                                                    days:
                                                                        -7))) ??
                                                        false) {
                                                      await firestore
                                                          .collection('event')
                                                          .doc(widget
                                                              .selectedEvent)
                                                          .update({
                                                        'status': 'Planning',
                                                        'progress': 1,
                                                      });
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Event document submitted for approval.'),
                                                          width: 200.0,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                    } else {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'You can only apply the event atleast one week before the event date.'),
                                                          width: 200.0,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                }
                                              : () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return ConfirmDialog(
                                                            eventID: widget
                                                                .selectedEvent);
                                                      });
                                                },
                                          text: progress == 0
                                              ? 'Submit'
                                              : 'Unsubmit'),
                                    if (status == 'Closing' && progress != 3)
                                      CustomButton(
                                          width: 150,
                                          onPressed: status == 'Closing' &&
                                                  progress == 0
                                              ? () async {
                                                  final FirebaseFirestore
                                                      firestore =
                                                      FirebaseFirestore
                                                          .instance;

                                                  if (endDate?.isAfter(
                                                          DateTime.now()) ??
                                                      false) {
                                                    final QuerySnapshot<
                                                            Map<String,
                                                                dynamic>>
                                                        participantSnapshot =
                                                        await firestore
                                                            .collection(
                                                                'participant')
                                                            .where('eventID',
                                                                isEqualTo: widget
                                                                    .selectedEvent)
                                                            .get();
                                                    bool participant =
                                                        participantSnapshot
                                                            .docs.isEmpty;

                                                    final QuerySnapshot<
                                                            Map<String,
                                                                dynamic>>
                                                        evaluationSnapshot =
                                                        await firestore
                                                            .collection(
                                                                'evaluation')
                                                            .where('eventID',
                                                                isEqualTo: widget
                                                                    .selectedEvent)
                                                            .get();
                                                    bool evaluation =
                                                        evaluationSnapshot
                                                            .docs.isEmpty;

                                                    final QuerySnapshot<
                                                            Map<String,
                                                                dynamic>>
                                                        claimSnapshot =
                                                        await firestore
                                                            .collection('claim')
                                                            .where('eventID',
                                                                isEqualTo: widget
                                                                    .selectedEvent)
                                                            .where('status',
                                                                isEqualTo:
                                                                    'Pending')
                                                            .get();
                                                    bool claim = claimSnapshot
                                                        .docs.isNotEmpty;

                                                    if (participant ||
                                                        evaluation) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Please save the required document before submitting.'),
                                                          width: 200.0,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                    } else if (claim) {
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Please process all the claim request before submitting'),
                                                          width: 200.0,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                    } else {
                                                      await firestore
                                                          .collection('event')
                                                          .doc(widget
                                                              .selectedEvent)
                                                          .update({
                                                        'status': 'Closing',
                                                        'progress': 1,
                                                      });

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Event document submitted for approval.'),
                                                          width: 200.0,
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
                                                            'Event closing document can only be submittted after the event date.'),
                                                        width: 200.0,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        duration: Duration(
                                                            seconds: 3),
                                                      ),
                                                    );
                                                  }
                                                }
                                              : () {
                                                  showDialog(
                                                      context: context,
                                                      builder: (_) {
                                                        return ConfirmDialog2(
                                                            eventID: widget
                                                                .selectedEvent);
                                                      });
                                                  getData();
                                                },
                                          text: progress == 0
                                              ? 'Submit'
                                              : 'Unsubmit'),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                if (comment != '')
                                  Row(
                                    children: [
                                      if (Responsive.isDesktop(context))
                                        const Expanded(
                                            flex: 2, child: SizedBox()),
                                      Expanded(
                                          flex: 10,
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              const Text(
                                                'Reason for Rejection:',
                                                style: TextStyle(fontSize: 16),
                                              ),
                                              const SizedBox(
                                                height: 15,
                                              ),
                                              CustomTextField(
                                                controller: nothing,
                                                hintText: '',
                                                maxLine: 5,
                                                enabled: false,
                                              ),
                                            ],
                                          )),
                                      if (Responsive.isDesktop(context))
                                        const Expanded(
                                            flex: 2, child: SizedBox()),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: const Footer(),
    );
  }
}

class ConfirmDialog extends StatefulWidget {
  final String eventID;

  const ConfirmDialog({
    super.key,
    required this.eventID,
  });
  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unsubmit Documents'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('Are you sure you want to unsubmit the doucment?')],
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
            final FirebaseFirestore firestore = FirebaseFirestore.instance;
            final QuerySnapshot<Map<String, dynamic>> approvalSnapshot =
                await firestore
                    .collection('approval')
                    .where('eventID', isEqualTo: widget.eventID)
                    .get();

            for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
                in approvalSnapshot.docs) {
              await docSnapshot.reference.update({
                'presidentName': '',
                'presidentStatus': '',
                'advisorName': '',
                'advisorStatus': '',
                'branchHeadName': '',
                'branchHeadStatus': '',
                'comment': '',
              });
            }

            await firestore.collection('event').doc(widget.eventID).update({
              'status': 'Planning',
              'progress': 0,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event documents unsubmitted'),
                width: 200.0,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
              ),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class ConfirmDialog2 extends StatefulWidget {
  final String eventID;

  const ConfirmDialog2({
    super.key,
    required this.eventID,
  });
  @override
  _ConfirmDialog2State createState() => _ConfirmDialog2State();
}

class _ConfirmDialog2State extends State<ConfirmDialog2> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unsubmit Documents'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('Are you sure you want to unsubmit the doucment?')],
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
            final FirebaseFirestore firestore = FirebaseFirestore.instance;
            final QuerySnapshot<Map<String, dynamic>> approvalSnapshot =
                await firestore
                    .collection('completion')
                    .where('eventID', isEqualTo: widget.eventID)
                    .get();

            for (QueryDocumentSnapshot<Map<String, dynamic>> docSnapshot
                in approvalSnapshot.docs) {
              await docSnapshot.reference.update({
                'presidentName': '',
                'presidentStatus': '',
                'advisorName': '',
                'advisorStatus': '',
                'branchHeadName': '',
                'branchHeadStatus': '',
                'comment': '',
              });
            }

            await firestore.collection('event').doc(widget.eventID).update({
              'status': 'Closing',
              'progress': 0,
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event documents unsubmitted'),
                width: 200.0,
                behavior: SnackBarBehavior.floating,
                duration: Duration(seconds: 3),
              ),
            );
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
