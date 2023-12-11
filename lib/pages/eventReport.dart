import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:intl/intl.dart';

class EventReport extends StatefulWidget {
  final String selectedSociety;
  const EventReport({super.key, required this.selectedSociety});

  @override
  State<EventReport> createState() => _EventReportState();
}

class _EventReportState extends State<EventReport> {
  bool _isLoading = true;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final start = TextEditingController();
  final end = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  String startDateString = '';
  String endDateString = '';
  List<Map<String, dynamic>> completedEvents = [];
  String name = '';
  double totalProfitLoss = 0;

  String? startError;
  String? endError;
  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot<Map<String, dynamic>> societySnapshot =
          await firestore
              .collection('society')
              .where('societyID', isEqualTo: widget.selectedSociety)
              .get();

      if (societySnapshot.docs.isNotEmpty) {
        name = societySnapshot.docs.first['societyName'];
      }

      setState(() {
        name = name;
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
              index: 2,
              page: 'Event Report',
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
                        page: 'Event Report',
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
                                    'Event Report',
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
                                      child: Column(
                                        children: [
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
                                                                    'Date',
                                                                    style:
                                                                        TextStyle(
                                                                      fontSize:
                                                                          16,
                                                                    ),
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
                                                                        dateFormat =
                                                                        DateFormat(
                                                                            'dd/MM/yyyy');

                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return 'Enter start date';
                                                                    } else {
                                                                      try {
                                                                        DateTime
                                                                            parsedStartDate =
                                                                            dateFormat.parse(value);

                                                                        if (parsedStartDate
                                                                            .isAfter(DateTime.now())) {
                                                                          return 'Must be before today.';
                                                                        }

                                                                        if (end
                                                                            .text
                                                                            .isNotEmpty) {
                                                                          DateTime
                                                                              parsedEndDate =
                                                                              dateFormat.parse(end.text);

                                                                          if (parsedStartDate
                                                                              .isAfter(parsedEndDate)) {
                                                                            return 'Must be before End date';
                                                                          }
                                                                        }
                                                                      } catch (e) {
                                                                        return 'Invalid date format. (Format: dd/MM/yyyy)';
                                                                      }
                                                                      return null;
                                                                    }
                                                                  },
                                                                  labelText:
                                                                      'Start Date',
                                                                  errorText:
                                                                      startError,
                                                                  controller:
                                                                      start,
                                                                  hintText:
                                                                      'Enter start date',
                                                                  suffixIcon:
                                                                      IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .calendar_today),
                                                                    onPressed:
                                                                        () async {
                                                                      DateTime?
                                                                          pickedDate =
                                                                          await showDatePicker(
                                                                        context:
                                                                            context,
                                                                        initialDate:
                                                                            DateTime(2023),
                                                                        firstDate:
                                                                            DateTime(2023),
                                                                        lastDate:
                                                                            DateTime.now(),
                                                                      );

                                                                      if (pickedDate !=
                                                                          null) {
                                                                        startError =
                                                                            null;

                                                                        if (end
                                                                            .text
                                                                            .isNotEmpty) {
                                                                          final DateFormat
                                                                              dateFormat =
                                                                              DateFormat('dd/MM/yyyy');
                                                                          DateTime
                                                                              parsedStartDate =
                                                                              pickedDate;
                                                                          DateTime
                                                                              parsedEndDate =
                                                                              dateFormat.parse(end.text);

                                                                          if (parsedStartDate
                                                                              .isBefore(parsedEndDate)) {
                                                                            setState(() {
                                                                              start.text = dateFormat.format(pickedDate);
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              startError = 'Must be before End Date';
                                                                            });
                                                                          }
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            start.text =
                                                                                DateFormat('dd/MM/yyyy').format(pickedDate);
                                                                          });
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
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
                                                                  child:
                                                                      Text('-'),
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
                                                                      'End Date',
                                                                  validator:
                                                                      (value) {
                                                                    final DateFormat
                                                                        dateFormat =
                                                                        DateFormat(
                                                                            'dd/MM/yyyy');

                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return 'Enter end date';
                                                                    } else {
                                                                      try {
                                                                        final DateTime
                                                                            parsedStartDate =
                                                                            dateFormat.parse(start.text);
                                                                        DateTime
                                                                            parsedEndDate =
                                                                            dateFormat.parse(value);

                                                                        if (parsedEndDate
                                                                            .isAfter(DateTime.now())) {
                                                                          return 'Must be before today.';
                                                                        }

                                                                        if (parsedStartDate.isAfter(parsedEndDate) ||
                                                                            parsedStartDate.isAtSameMomentAs(parsedEndDate)) {
                                                                          return 'Must be after Start date';
                                                                        }
                                                                      } catch (e) {
                                                                        return 'Invalid date format. (Format: dd/MM/yyyy)';
                                                                      }

                                                                      return null;
                                                                    }
                                                                  },
                                                                  errorText:
                                                                      endError,
                                                                  controller:
                                                                      end,
                                                                  hintText:
                                                                      'Enter end date',
                                                                  suffixIcon:
                                                                      IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .calendar_today),
                                                                    onPressed:
                                                                        () async {
                                                                      DateTime?
                                                                          pickedDate =
                                                                          await showDatePicker(
                                                                        context:
                                                                            context,
                                                                        initialDate:
                                                                            DateTime(2023),
                                                                        firstDate:
                                                                            DateTime(2023),
                                                                        lastDate:
                                                                            DateTime.now(),
                                                                      );

                                                                      if (pickedDate !=
                                                                          null) {
                                                                        endError =
                                                                            null;

                                                                        if (start
                                                                            .text
                                                                            .isNotEmpty) {
                                                                          final DateFormat
                                                                              dateFormat =
                                                                              DateFormat('dd/MM/yyyy');
                                                                          DateTime
                                                                              parsedStartDate =
                                                                              dateFormat.parse(start.text);
                                                                          DateTime
                                                                              parsedEndDate =
                                                                              pickedDate;

                                                                          if (parsedEndDate
                                                                              .isAfter(parsedStartDate)) {
                                                                            setState(() {
                                                                              end.text = dateFormat.format(pickedDate);
                                                                            });
                                                                          } else {
                                                                            setState(() {
                                                                              endError = 'Must be after Start Date';
                                                                            });
                                                                          }
                                                                        } else {
                                                                          setState(
                                                                              () {
                                                                            end.text =
                                                                                DateFormat('dd/MM/yyyy').format(pickedDate);
                                                                          });
                                                                        }
                                                                      }
                                                                    },
                                                                  ),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              CustomButton(
                                                  width: 150,
                                                  onPressed: () async {
                                                    if (_formKey.currentState!
                                                        .validate()) {
                                                      FirebaseFirestore
                                                          firestore =
                                                          FirebaseFirestore
                                                              .instance;
                                                      try {
                                                        final QuerySnapshot<
                                                                Map<String,
                                                                    dynamic>>
                                                            eventSnapshot =
                                                            await firestore
                                                                .collection(
                                                                    'event')
                                                                .where(
                                                                    'societyID',
                                                                    isEqualTo:
                                                                        widget
                                                                            .selectedSociety)
                                                                .where('status',
                                                                    isEqualTo:
                                                                        'Completed')
                                                                .get();

                                                        completedEvents.clear();

                                                        for (var eventDocSnapshot
                                                            in eventSnapshot
                                                                .docs) {
                                                          Map<String, dynamic>
                                                              eventData =
                                                              eventDocSnapshot
                                                                  .data();
                                                          String eventId =
                                                              eventData[
                                                                  'eventID'];

                                                          Query<
                                                                  Map<String,
                                                                      dynamic>>
                                                              query = firestore
                                                                  .collection(
                                                                      'schedule')
                                                                  .where(
                                                                      'eventID',
                                                                      isEqualTo:
                                                                          eventId)
                                                                  .orderBy(
                                                                      'date');

                                                          QuerySnapshot<
                                                                  Map<String,
                                                                      dynamic>>
                                                              snapshot =
                                                              await query
                                                                  .limit(1)
                                                                  .get();

                                                          Query<
                                                                  Map<String,
                                                                      dynamic>>
                                                              query2 = firestore
                                                                  .collection(
                                                                      'schedule')
                                                                  .where(
                                                                      'eventID',
                                                                      isEqualTo:
                                                                          eventId)
                                                                  .orderBy(
                                                                      'date',
                                                                      descending:
                                                                          true);

                                                          QuerySnapshot<
                                                                  Map<String,
                                                                      dynamic>>
                                                              snapshot2 =
                                                              await query2
                                                                  .limit(1)
                                                                  .get();

                                                          startDate = null;
                                                          endDate = null;
                                                          if (snapshot.docs
                                                              .isNotEmpty) {
                                                            DocumentSnapshot<
                                                                    Map<String,
                                                                        dynamic>>
                                                                earliestDoc =
                                                                snapshot
                                                                    .docs.first;

                                                            Timestamp date =
                                                                earliestDoc[
                                                                    'date'];
                                                            startDate =
                                                                date.toDate();
                                                          }

                                                          if (snapshot2.docs
                                                              .isNotEmpty) {
                                                            DocumentSnapshot<
                                                                    Map<String,
                                                                        dynamic>>
                                                                latestDoc =
                                                                snapshot2
                                                                    .docs.first;

                                                            Timestamp date =
                                                                latestDoc[
                                                                    'date'];
                                                            endDate =
                                                                date.toDate();
                                                          }
                                                          if (startDate !=
                                                                  null &&
                                                              endDate != null) {
                                                            startDateString =
                                                                DateFormat(
                                                                        'dd/MM/yyyy')
                                                                    .format(
                                                                        startDate!);
                                                            endDateString =
                                                                DateFormat(
                                                                        'dd/MM/yyyy')
                                                                    .format(
                                                                        endDate!);
                                                            DateTime?
                                                                formattedStartText =
                                                                DateFormat(
                                                                        'dd/MM/yyyy')
                                                                    .parse(start
                                                                        .text);

                                                            DateTime?
                                                                formattedEndText =
                                                                DateFormat(
                                                                        'dd/MM/yyyy')
                                                                    .parse(end
                                                                        .text);

                                                            if (formattedStartText != null &&
                                                                formattedEndText !=
                                                                    null &&
                                                                formattedStartText
                                                                    .isBefore(
                                                                        startDate!) &&
                                                                endDate!.isBefore(
                                                                    formattedEndText)) {
                                                              completedEvents
                                                                  .add({
                                                                ...eventData,
                                                                'startDate':
                                                                    startDateString,
                                                                'endDate':
                                                                    endDateString,
                                                              });
                                                            }
                                                          }
                                                        }
                                                        for (var completedEvent
                                                            in completedEvents) {
                                                          String eventId =
                                                              completedEvent[
                                                                  'eventID'];

                                                          QuerySnapshot<
                                                                  Map<String,
                                                                      dynamic>>
                                                              participantSnapshot =
                                                              await firestore
                                                                  .collection(
                                                                      'participant')
                                                                  .where(
                                                                      'eventID',
                                                                      isEqualTo:
                                                                          eventId)
                                                                  .get();

                                                          int participantCount =
                                                              participantSnapshot
                                                                  .size;
                                                          completedEvent[
                                                                  'participantCount'] =
                                                              participantCount;

                                                          QuerySnapshot<
                                                                  Map<String,
                                                                      dynamic>>
                                                              budgetItemsSnapshot =
                                                              await firestore
                                                                  .collection(
                                                                      'budgetItem')
                                                                  .where(
                                                                      'eventID',
                                                                      isEqualTo:
                                                                          eventId)
                                                                  .get();

                                                          double
                                                              totalIncomeAmount =
                                                              0.0;
                                                          double
                                                              totalExpenseAmount =
                                                              0.0;

                                                          for (var budgetItemDoc
                                                              in budgetItemsSnapshot
                                                                  .docs) {
                                                            double qty =
                                                                budgetItemDoc[
                                                                        'quantity'] ??
                                                                    0.0;
                                                            double unitPrice =
                                                                budgetItemDoc[
                                                                        'unitPrice'] ??
                                                                    0.0;

                                                            // Calculate the amount based on qty and unitPrice
                                                            double amount =
                                                                qty * unitPrice;

                                                            String itemType =
                                                                budgetItemDoc[
                                                                    'itemType'];

                                                            if (itemType ==
                                                                'Income') {
                                                              totalIncomeAmount +=
                                                                  amount;
                                                            } else if (itemType ==
                                                                'Expense') {
                                                              totalExpenseAmount +=
                                                                  amount;
                                                            }
                                                          }

                                                          completedEvent[
                                                                  'totalIncomeAmount'] =
                                                              totalIncomeAmount;
                                                          completedEvent[
                                                                  'totalExpenseAmount'] =
                                                              totalExpenseAmount;

                                                          // Query accountStatements collection based on eventID
                                                          QuerySnapshot<
                                                                  Map<String,
                                                                      dynamic>>
                                                              accountStatementsSnapshot =
                                                              await firestore
                                                                  .collection(
                                                                      'accountStatement')
                                                                  .where(
                                                                      'eventID',
                                                                      isEqualTo:
                                                                          eventId)
                                                                  .get();

                                                          double totalIncome =
                                                              0.0;
                                                          double totalExpense =
                                                              0.0;

                                                          for (var accountStatementDoc
                                                              in accountStatementsSnapshot
                                                                  .docs) {
                                                            double amount =
                                                                accountStatementDoc[
                                                                        'amount'] ??
                                                                    0.0;
                                                            String itemType =
                                                                accountStatementDoc[
                                                                    'recordType'];

                                                            if (itemType ==
                                                                'Income') {
                                                              totalIncome +=
                                                                  amount;
                                                            } else if (itemType ==
                                                                'Expense') {
                                                              totalExpense +=
                                                                  amount;
                                                            }
                                                          }

                                                          // Update the completedEvent map with the total income and expense amounts
                                                          completedEvent[
                                                                  'totalIncome'] =
                                                              totalIncome;
                                                          completedEvent[
                                                                  'totalExpense'] =
                                                              totalExpense;

                                                          int memberCount =
                                                              completedEvent[
                                                                      'memberCount'] ??
                                                                  0;
                                                          int nonMemberCount =
                                                              completedEvent[
                                                                      'nonMemberCount'] ??
                                                                  0;


                                                          // Calculate the total count
                                                          int totalCount =
                                                              memberCount +
                                                                  nonMemberCount;

                                                          // Update the completedEvent map with the total count
                                                          completedEvent[
                                                                  'totalCount'] =
                                                              totalCount;
                                                        }
                                                        totalProfitLoss = completedEvents
                                                            .map((event) =>
                                                                (event['totalIncome'] ??
                                                                    0.0) -
                                                                (event['totalExpense'] ??
                                                                    0.0))
                                                            .fold(
                                                                0.0,
                                                                (sum, value) =>
                                                                    sum +
                                                                    value);

                                                        print(completedEvents);
                                                        setState(() {
                                                          completedEvents =
                                                              completedEvents;
                                                        });
                                                      } catch (e) {
                                                        print(
                                                            'Error retrieving events and dates: $e');
                                                      }
                                                    }
                                                  },
                                                  text: 'Generate'),
                                              const SizedBox(
                                                width: 15,
                                              ),
                                            ],
                                          ),
                                        ],
                                      )),
                                  const SizedBox(
                                    height: 15,
                                  ),
                                  Column(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: Colors
                                                  .black), // Adjust color as needed
                                          borderRadius: BorderRadius.circular(
                                              10.0), // Adjust radius as needed
                                        ),
                                        padding: EdgeInsets.all(
                                            10.0), // Adjust padding as needed
                                        child: completedEvents.isNotEmpty
                                            ? Center(
                                                child: Column(
                                                  children: [
                                                    const SizedBox(
                                                      height: 25,
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        name,
                                                        style: const TextStyle(
                                                            fontSize: 36),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    Center(
                                                      child: Text(
                                                        'Date Range: ' +
                                                            start.text +
                                                            ' - ' +
                                                            end.text,
                                                        style: const TextStyle(
                                                            fontSize: 20),
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          'Total Number of Events : ' +
                                                              completedEvents
                                                                  .length
                                                                  .toString(),
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 20),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 15,
                                                    ),
                                                    SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: DataTable(
                                                            columns: const [
                                                              DataColumn(
                                                                  label: Text(
                                                                      'No.')),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Event Name')),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Expected')),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Actual')),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Expected(RM)')),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Actual(RM)')),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Expected(RM)')),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Actual(RM)')),
                                                              DataColumn(
                                                                  label: Text(
                                                                      'Profit/Loss(RM)')),
                                                            ],
                                                            rows: [
                                                              ...completedEvents
                                                                  .asMap()
                                                                  .entries
                                                                  .map((entry) {
                                                                final int
                                                                    index =
                                                                    entry.key;
                                                                final Map<
                                                                        String,
                                                                        dynamic>
                                                                    event =
                                                                    entry.value;

                                                                return DataRow(
                                                                  cells: [
                                                                    DataCell(Text(
                                                                        (index +
                                                                                1)
                                                                            .toString())),
                                                                    DataCell(Text(
                                                                        event['eventName']
                                                                            .toString())),
                                                                    DataCell(Text(
                                                                        event['totalCount']
                                                                            .toString())),
                                                                    DataCell(
                                                                        Text(
                                                                      event['participantCount']
                                                                          .toString(),
                                                                      style:
                                                                          TextStyle(
                                                                        color: event['totalCount'] <=
                                                                                event['participantCount']
                                                                            ? Colors.green
                                                                            : Colors.red,
                                                                      ),
                                                                    )),
                                                                    DataCell(
                                                                        Text(
                                                                      event['totalIncomeAmount']
                                                                          .toStringAsFixed(
                                                                              2),
                                                                    )),
                                                                    DataCell(
                                                                        Text(
                                                                      event['totalIncome']
                                                                          .toStringAsFixed(
                                                                              2),
                                                                      style:
                                                                          TextStyle(
                                                                        color: event['totalIncome'] >=
                                                                                event['totalIncomeAmount']
                                                                            ? Colors.green
                                                                            : Colors.red,
                                                                      ),
                                                                    )),
                                                                    DataCell(Text(event[
                                                                            'totalExpenseAmount']
                                                                        .toStringAsFixed(
                                                                            2))),
                                                                    DataCell(
                                                                        Text(
                                                                      event['totalExpense']
                                                                          .toStringAsFixed(
                                                                              2),
                                                                      style:
                                                                          TextStyle(
                                                                        color: event['totalExpense'] <=
                                                                                event['totalExpenseAmount']
                                                                            ? Colors.green
                                                                            : Colors.red,
                                                                      ),
                                                                    )),
                                                                    DataCell(
                                                                        Text(
                                                                      (event['totalIncome'] -
                                                                              event['totalExpense'])
                                                                          .toStringAsFixed(2),
                                                                      style:
                                                                          TextStyle(
                                                                        color: event['totalIncome'] - event['totalExpense'] >
                                                                                0
                                                                            ? Colors.green
                                                                            : Colors.red,
                                                                      ),
                                                                    )),
                                                                  ],
                                                                );
                                                              }).toList(),
                                                              DataRow(
                                                                cells: [
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(
                                                                      Text('')),
                                                                  DataCell(Text(
                                                                    'Total',
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  )),
                                                                  DataCell(Text(
                                                                      totalProfitLoss
                                                                          .toStringAsFixed(
                                                                              2),
                                                                      style: TextStyle(
                                                                          fontWeight:
                                                                              FontWeight.bold))),
                                                                ],
                                                              ),
                                                            ])),
                                                  ],
                                                ),
                                              )
                                            : const SizedBox(
                                                height: 500,
                                                child: Center(
                                                  child: Text(
                                                      'There is no event organised within the time range.'),
                                                ),
                                              ),
                                      )
                                    ],
                                  ),
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
