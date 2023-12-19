import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/editEvent.dart';
import 'package:fyp/pages/pendingClaim.dart';
import 'package:fyp/pages/proposal.dart';
import 'package:fyp/pages/society.dart';
import 'package:fyp/pages/studentSociety.dart';
import 'package:fyp/pages/viewClaim.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';

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
  final LocalStorage storage = LocalStorage('user');
  List<String> preProgress = ['Planning', 'Checked', 'Recommended', 'Approved'];
  List<String> postProgress = ['Closing', 'Checked', 'Verified', 'Accepted'];
  DateTime? startDate;
  DateTime? endDate;
  List<String> checkName = ['', '', '', ''];
  List<String> checkStatus = ['', '', '', ''];
  List<String> checkName2 = ['', '', '', ''];
  List<String> checkStatus2 = ['', '', '', ''];
  String name = '';
  String comment = '';
  String comment2 = '';
  String position = '';
  String societyID = '';
  bool rejected = false;
  bool rejected2 = false;
  int progress2 = 0;
  int access = 0;

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      access = 0;
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
        societyID = eventData['societyID'];
      }

      if (status == 'Closing') {
        progress2 = 3;
      } else {
        progress2 = progress;
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

      final QuerySnapshot<Map<String, dynamic>> completionSnapshot =
          await firestore
              .collection('completion')
              .where('eventID', isEqualTo: widget.selectedEvent)
              .get();
      checkName2.clear();
      checkStatus2.clear();
      if (completionSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> completionData =
            completionSnapshot.docs.first.data();
        comment2 = completionData['comment'];
        checkName2.add('');
        checkName2.add(completionData['presidentName']);
        checkName2.add(completionData['advisorName']);
        checkName2.add(completionData['branchHeadName']);
        checkStatus2.add('Approved');
        checkStatus2.add(completionData['presidentStatus']);
        checkStatus2.add(completionData['advisorStatus']);
        checkStatus2.add(completionData['branchHeadStatus']);
      }

      if (checkStatus.any((element) => element == 'Rejected')) {
        rejected = true;
      }
      if (checkStatus2.any((element) => element == 'Rejected')) {
        rejected2 = true;
      }

      if (status == 'Planning') {
        nothing.text = comment.toString();
      } else if (status == 'Closing') {
        nothing.text = comment2.toString();
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

      final QuerySnapshot<Map<String, dynamic>> memberSnapshot = await firestore
          .collection('member')
          .where('societyID', isEqualTo: societyID)
          .where('studentID', isEqualTo: storage.getItem('id'))
          .get();

      position = 'member';

      if (memberSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> memberData = memberSnapshot.docs.first.data();
        String memberPosition = memberData['position'];
        if (memberPosition.contains('President')) {
          position = 'top';
          if (progress == 1) {
            access = 1;
          }
        } else {
          position = 'viewer';
        }
      }

      for (var doc in committeeSnapshot.docs) {
        String studentIDInCommittee = doc['studentID'];

        if (studentIDInCommittee == storage.getItem('id')) {
          position = 'org ' + doc['position'];
          break;
        }
      }

      if (storage.getItem('role') == 'advisor') {
        position = 'top';
        if (progress == 2) {
          access = 2;
        }
      } else if (storage.getItem('role') == 'branch head') {
        position = 'top';
        if (progress == 3 && status != 'Completed') {
          access = 3;
        }
      }
      setState(() {
        checkName = checkName;
        checkStatus = checkStatus;
        checkName2 = checkName2;
        checkStatus2 = checkStatus2;
        comment = comment;
        comment2 = comment2;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to fetch data. Please try again later.'),
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
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if ((position == 'top' ||
                                            position == 'org President') &&
                                        status != 'Completed')
                                      CustomButton(
                                          width: 150,
                                          buttonColor: Colors.red,
                                          onPressed: () {
                                            showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return DeleteDialog(
                                                      eventID:
                                                          widget.selectedEvent);
                                                });
                                          },
                                          text: 'Cancel Event'),
                                  ],
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
                                if ((position == 'top' ||
                                        position == 'org President') &&
                                    status == 'Planning')
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
                                                builder: (context) => EditEvent(
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
                                const Center(
                                    child: Text(
                                  'Planning Phase',
                                  style: TextStyle(fontSize: 16),
                                )),
                                CustomTimeline(
                                  status: 'Planning',
                                  progress: progress2,
                                  eventID: widget.selectedEvent,
                                  checkName: checkName,
                                  checkStatus: checkStatus,
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                if (status != 'Planning')
                                  const Center(
                                      child: Text(
                                    'Closing Phase',
                                    style: TextStyle(fontSize: 16),
                                  )),
                                if (status != 'Planning')
                                  CustomTimeline(
                                    status: 'Closing',
                                    progress: progress,
                                    eventID: widget.selectedEvent,
                                    checkName: checkName2,
                                    checkStatus: checkStatus2,
                                  ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (status != 'Planning' &&
                                        position != 'member')
                                      CustomButton(
                                          width: 150,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    PendingClaim(
                                                  selectedEvent:
                                                      widget.selectedEvent,
                                                ),
                                              ),
                                            );
                                          },
                                          text: 'View Claim'),
                                    const SizedBox(
                                      width: 15,
                                    ),
                                    if (position != 'member')
                                      CustomButton(
                                          width: 150,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => Proposal(
                                                  selectedEvent:
                                                      widget.selectedEvent,
                                                  position: position,
                                                  status: status,
                                                  progress: progress,
                                                ),
                                              ),
                                            );
                                          },
                                          text: 'View Forms'),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    if (status == 'Closing' &&
                                        (position == 'member' ||
                                            position.startsWith('org')) &&
                                        progress == 0)
                                      CustomButton(
                                          width: 150,
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ViewClaim(
                                                  selectedEvent:
                                                      widget.selectedEvent,
                                                  selectedClaim: '',
                                                ),
                                              ),
                                            );
                                          },
                                          text: 'Submit Claim'),
                                    if ( progress != 3 &&
                                        position.startsWith('org') &&
                                        position.contains('President'))
                                      const SizedBox(
                                        width: 15,
                                      ),
                                    if (status == 'Planning' &&
                                        progress != 3 &&
                                        position.startsWith('org') &&
                                        position.contains('President'))
                                      CustomButton(
                                          buttonColor: progress == 0
                                              ? Colors.blue
                                              : Colors.red,
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
                                                            'Please save the required forms before submitting.'),
                                                        width: 200.0,
                                                        behavior:
                                                            SnackBarBehavior
                                                                .floating,
                                                        duration: Duration(
                                                            seconds: 3),
                                                      ),
                                                    );
                                                  } else {
                                                    if (startDate?.isAfter(
                                                            DateTime.now().add(
                                                                const Duration(
                                                                    days:
                                                                        6))) ??
                                                        false) {
                                                      await firestore
                                                          .collection('event')
                                                          .doc(widget
                                                              .selectedEvent)
                                                          .update({
                                                        'status': 'Planning',
                                                        'progress': 1,
                                                      });
                                                      getData();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Event forms submitted for approval.'),
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
                                                            function: getData,
                                                            eventID: widget
                                                                .selectedEvent);
                                                      });
                                                },
                                          text: progress == 0
                                              ? 'Submit Form'
                                              : 'Unsubmit Form'),
                                    if (status == 'Closing' &&
                                        progress != 3 &&
                                        position.startsWith('org') &&
                                        position.contains('President'))
                                      CustomButton(
                                          width: 150,
                                          onPressed: status == 'Closing' &&
                                                  progress == 0
                                              ? () async {
                                                  final FirebaseFirestore
                                                      firestore =
                                                      FirebaseFirestore
                                                          .instance;

                                                  if (endDate?.isBefore(
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
                                                              'Please save the required forms before submitting.'),
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
                                                      getData();
                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Event forms submitted for approval.'),
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
                                                            'Event closing forms can only be submittted after the event date.'),
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
                                                            function: getData,
                                                            eventID: widget
                                                                .selectedEvent);
                                                      });
                                                  getData();
                                                },
                                          buttonColor: progress == 0
                                              ? Colors.blue
                                              : Colors.red,
                                          text: progress == 0
                                              ? 'Submit Form'
                                              : 'Unsubmit Form'),
                                  ],
                                ),
                                const SizedBox(
                                  height: 15,
                                ),
                                if (access >= 1)
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      CustomButton(
                                          width: 150,
                                          onPressed: () async {
                                            showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return ApproveDialog(
                                                      function: getData,
                                                      status: status,
                                                      access: access,
                                                      eventID:
                                                          widget.selectedEvent);
                                                });
                                          },
                                          text: 'Approve'),
                                      const SizedBox(
                                        width: 15,
                                      ),
                                      CustomButton(
                                          buttonColor: Colors.red,
                                          width: 150,
                                          onPressed: () async {
                                            showDialog(
                                                context: context,
                                                builder: (_) {
                                                  return RejectDialog(
                                                      status: status,
                                                      function: getData,
                                                      access: access,
                                                      eventID:
                                                          widget.selectedEvent);
                                                });
                                          },
                                          text: 'Reject'),
                                    ],
                                  ),
                                const SizedBox(
                                  height: 15,
                                ),
                                if (comment != '' || comment2 != '')
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
  final VoidCallback? function;
  final String eventID;

  const ConfirmDialog({
    super.key,
    required this.function,
    required this.eventID,
  });
  @override
  _ConfirmDialogState createState() => _ConfirmDialogState();
}

class _ConfirmDialogState extends State<ConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unsubmit Forms'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('Are you sure you want to unsubmit the forms?')],
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
            widget.function!();
            Navigator.of(context).pop();
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
  final VoidCallback function;
  final String eventID;

  const ConfirmDialog2({
    super.key,
    required this.function,
    required this.eventID,
  });
  @override
  _ConfirmDialog2State createState() => _ConfirmDialog2State();
}

class _ConfirmDialog2State extends State<ConfirmDialog2> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Unsubmit Forms'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('Are you sure you want to unsubmit the forms?')],
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
            widget.function!();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event forms unsubmitted'),
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

class DeleteDialog extends StatefulWidget {
  final String eventID;

  const DeleteDialog({
    super.key,
    required this.eventID,
  });
  @override
  _DeleteDialogState createState() => _DeleteDialogState();
}

class _DeleteDialogState extends State<DeleteDialog> {
  final LocalStorage storage = LocalStorage('user');
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Cancel Event'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('Are you sure you want to cancel this event?')],
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
            // Create a batch
            WriteBatch batch = firestore.batch();

            // Collections to delete data from
            List<String> collectionsToDelete = [
              'event',
              'approval',
              'completion',
              'budget',
              'claim',
              'schedule',
              'evaluation',
              'participant',
              'committee',
              'account',
              'claimApproval',
            ];

            for (String collectionName in collectionsToDelete) {
              CollectionReference<Map<String, dynamic>> collectionReference =
                  firestore.collection(collectionName);

              QuerySnapshot<Map<String, dynamic>> documentsToDelete =
                  await collectionReference
                      .where('eventID', isEqualTo: widget.eventID)
                      .get();

              for (QueryDocumentSnapshot<Map<String, dynamic>> document
                  in documentsToDelete.docs) {
                batch.delete(collectionReference.doc(document.id));
              }
            }

            await batch.commit();
            Navigator.of(context).pop();
            if (storage.getItem('role') == 'branch head') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => Society(),
                ),
              );
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => StudentSociety(),
                ),
              );
            }

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event cancelled'),
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

class ApproveDialog extends StatefulWidget {
  final String eventID;
  final int access;
  final String status;
  final VoidCallback? function;

  const ApproveDialog({
    super.key,
    required this.eventID,
    required this.access,
    required this.status,
    required this.function,
  });
  @override
  _ApproveDialogState createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<ApproveDialog> {
  String presidentName = '';
  String advisorName = '';
  String branchHeadName = '';
  String presidentStatus = '';
  String advisorStatus = '';
  String branchHeadStatus = '';
  String eventStatus = '';
  int progress = 0;

  final LocalStorage storage = LocalStorage('user');
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Approve Event'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('Are you sure you want to approve this event?')],
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
            eventStatus = widget.status;
            if (widget.access == 1) {
              presidentName = storage.getItem('name');
              presidentStatus = 'Approved';
              progress = 2;
            } else if (widget.access == 2) {
              advisorName = storage.getItem('name');
              advisorStatus = 'Approved';
              progress = 3;
            } else if (widget.access == 3) {
              branchHeadName = storage.getItem('name');
              branchHeadStatus = 'Approved';
              if (widget.status == 'Planning') {
                eventStatus = 'Closing';
                progress = 0;
              } else {
                eventStatus = 'Completed';
                progress = 3;
              }
            }

            if (widget.status == 'Planning') {
              await firestore
                  .collection('approval')
                  .doc(widget.eventID)
                  .update({
                if (presidentName.isNotEmpty) 'presidentName': presidentName,
                if (presidentStatus.isNotEmpty)
                  'presidentStatus': presidentStatus,
                if (advisorName.isNotEmpty) 'advisorName': advisorName,
                if (advisorStatus.isNotEmpty) 'advisorStatus': advisorStatus,
                if (branchHeadName.isNotEmpty) 'branchHeadName': branchHeadName,
                if (branchHeadStatus.isNotEmpty)
                  'branchHeadStatus': branchHeadStatus,
                'comment': '',
              });
            } else {
              await firestore
                  .collection('completion')
                  .doc(widget.eventID)
                  .update({
                if (presidentName.isNotEmpty) 'presidentName': presidentName,
                if (presidentStatus.isNotEmpty)
                  'presidentStatus': presidentStatus,
                if (advisorName.isNotEmpty) 'advisorName': advisorName,
                if (advisorStatus.isNotEmpty) 'advisorStatus': advisorStatus,
                if (branchHeadName.isNotEmpty) 'branchHeadName': branchHeadName,
                if (branchHeadStatus.isNotEmpty)
                  'branchHeadStatus': branchHeadStatus,
                'comment': '',
              });
            }
            await firestore.collection('event').doc(widget.eventID).update({
              'status': eventStatus,
              'progress': progress,
            });

            widget.function!();
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Event Approved.'),
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

class RejectDialog extends StatefulWidget {
  final String status;
  final String eventID;
  final int access;
  final VoidCallback? function;

  const RejectDialog({
    super.key,
    required this.status,
    required this.eventID,
    required this.access,
    required this.function,
  });
  @override
  _RejectDialogState createState() => _RejectDialogState();
}

class _RejectDialogState extends State<RejectDialog> {
  String presidentName = '';
  String advisorName = '';
  String branchHeadName = '';
  String presidentStatus = '';
  String advisorStatus = '';
  String branchHeadStatus = '';
  String eventStatus = '';
  int progress = 0;
  final comment = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final LocalStorage storage = LocalStorage('user');
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Event'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Form(
            key: formKey,
            child: CustomTextField(
              controller: comment,
              labelText: 'Reason',
              screen: true,
              hintText: 'Enter reason for rejection',
              maxLine: 5,
              maxLength: 200,
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter reason';
                }
                return null;
              },
            ),
          ),
        ],
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
            if (formKey.currentState!.validate()) {
              final FirebaseFirestore firestore = FirebaseFirestore.instance;

              if (widget.status == 'Planning') {
                await firestore
                    .collection('approval')
                    .doc(widget.eventID)
                    .update({
                  if (widget.access == 1)
                    'presidentName': storage.getItem('name'),
                  if (widget.access == 1) 'presidentStatus': 'Rejected',
                  if (widget.access == 2)
                    'advisorName': storage.getItem('name'),
                  if (widget.access == 2) 'advisorStatus': 'Rejected',
                  if (widget.access == 3)
                    'branchHeadName': storage.getItem('name'),
                  if (widget.access == 3) 'branchHeadStatus': 'Rejected',
                  'comment': comment.text,
                });
              } else {
                await firestore
                    .collection('completion')
                    .doc(widget.eventID)
                    .update({
                  if (widget.access == 1)
                    'presidentName': storage.getItem('name'),
                  if (widget.access == 1) 'presidentStatus': 'Rejected',
                  if (widget.access == 2)
                    'advisorName': storage.getItem('name'),
                  if (widget.access == 2) 'advisorStatus': 'Rejected',
                  if (widget.access == 3)
                    'branchHeadName': storage.getItem('name'),
                  if (widget.access == 3) 'branchHeadStatus': 'Rejected',
                  'comment': comment.text,
                });
              }

              widget.function!();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Event Rejected'),
                  width: 200.0,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
