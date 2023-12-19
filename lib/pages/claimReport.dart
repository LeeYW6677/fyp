import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';

class ClaimReport extends StatefulWidget {
  final String selectedEvent;
  const ClaimReport({super.key, required this.selectedEvent});

  @override
  State<ClaimReport> createState() => _ClaimReportState();
}

class _ClaimReportState extends State<ClaimReport> {
  bool _isLoading = true;
  List<Map<String, dynamic>> acceptedClaims = [];
  List<Map<String, dynamic>> rejectedClaims = [];
  String name = '';
  double totalProfitLoss = 0;

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot<Map<String, dynamic>> claimSnapshot = await firestore
          .collection('claim')
          .where('eventID', isEqualTo: widget.selectedEvent)
          .get();

      for (DocumentSnapshot<Map<String, dynamic>> document
          in claimSnapshot.docs) {
        Map<String, dynamic>? claimData = document.data();
        String status = claimData?['status'];
        String claimantID = claimData?['claimantID'];

        // Fetch the claimant's name from the 'user' collection
        DocumentSnapshot<Map<String, dynamic>> userDoc =
            await firestore.collection('user').doc(claimantID).get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data()!;
          String claimantName = userData['name'];

          // Add claimant's name to the respective list
          if (status == 'Approved') {
            acceptedClaims.add({...claimData!, 'claimantName': claimantName});
          } else if (status == 'Rejected') {
            rejectedClaims.add({...claimData!, 'claimantName': claimantName});
          }

          acceptedClaims.forEach((Map<String, dynamic> claim) {
            double claimAmount = claim['amount'] ?? 0.0;
            totalProfitLoss += claimAmount;
          });

          rejectedClaims.forEach((Map<String, dynamic> claim) {
            String treasurerStatus = claim['treasurerStatus'];
            String advisorStatus = claim['advisorStatus'];

            if (treasurerStatus == 'Rejected') {
              claim['rejected'] =  claim['treasurerName'];
            }

            // Set advisorName to a predefined value if advisorStatus is 'Rejected'
            if (advisorStatus == 'Rejected') {
              claim['rejected'] =  claim['advisorName'];
            }
          });
        }
      }

      DocumentSnapshot<Map<String, dynamic>> eventDoc =
          await firestore.collection('event').doc(widget.selectedEvent).get();

      if (eventDoc.exists) {
        Map<String, dynamic> eventData = eventDoc.data()!;
        name = eventData['eventName'];
      }

      setState(() {
        acceptedClaims = acceptedClaims;
        rejectedClaims = rejectedClaims;
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
                                    'Claim Report',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 0.1,
                                    color: Colors.black,
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
                                        padding: const EdgeInsets.all(
                                            10.0), // Adjust padding as needed
                                        child:
                                            acceptedClaims.isNotEmpty ||
                                                    rejectedClaims.isNotEmpty
                                                ? Center(
                                                    child: Column(
                                                      children: [
                                                        const SizedBox(
                                                          height: 25,
                                                        ),
                                                        Center(
                                                          child: Text(
                                                            name,
                                                            style:
                                                                const TextStyle(
                                                                    fontSize:
                                                                        36),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        const Center(
                                                          child: Text(
                                                            'Claim Summary Report',
                                                            style: TextStyle(
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
                                                              'Claim Request Submitted : ' +
                                                                  (acceptedClaims
                                                                              .length +
                                                                          rejectedClaims
                                                                              .length)
                                                                      .toString(),
                                                              style:
                                                                  const TextStyle(
                                                                      fontSize:
                                                                          20),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                          height: 15,
                                                        ),
                                                        SizedBox(width: 500, height: 500, child: buildBarChart(acceptedClaims)),
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
                                                                          'Claimant')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          'Title')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          'Checked by')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          'Approved by')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          'Amount(RM)')),
                                                                ],
                                                                rows: [
                                                                  ...acceptedClaims
                                                                      .asMap()
                                                                      .entries
                                                                      .map(
                                                                          (entry) {
                                                                    final int
                                                                        index =
                                                                        entry
                                                                            .key;
                                                                    final Map<
                                                                            String,
                                                                            dynamic>
                                                                        event =
                                                                        entry
                                                                            .value;

                                                                    return DataRow(
                                                                      cells: [
                                                                        DataCell(Text((index +
                                                                                1)
                                                                            .toString())),
                                                                        DataCell(
                                                                            Text(event['claimantName'].toString())),
                                                                        DataCell(
                                                                            Text(event['title'].toString())),
                                                                        DataCell(
                                                                          Text(event['treasurerName']
                                                                              .toString()),
                                                                        ),
                                                                        DataCell(
                                                                          Text(event['advisorName']
                                                                              .toString()),
                                                                        ),
                                                                        DataCell(
                                                                            Text(
                                                                          event['amount']
                                                                              .toStringAsFixed(2),
                                                                        )),
                                                                      ],
                                                                    );
                                                                  }).toList(),
                                                                  DataRow(
                                                                    cells: [
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                      const DataCell(
                                                                          Text(
                                                                        'Total',
                                                                        style: TextStyle(
                                                                            fontWeight:
                                                                                FontWeight.bold),
                                                                      )),
                                                                      DataCell(Text(
                                                                          totalProfitLoss.toStringAsFixed(
                                                                              2),
                                                                          style:
                                                                              const TextStyle(fontWeight: FontWeight.bold))),
                                                                    ],
                                                                  ),
                                                                ])),
                                                        const SizedBox(
                                                          height: 50,
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
                                                                          'Claimant')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          'Title')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          'Rejected by')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          'Reason')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          'Amount(RM)')),
                                                                ],
                                                                rows: [
                                                                  ...rejectedClaims
                                                                      .asMap()
                                                                      .entries
                                                                      .map(
                                                                          (entry) {
                                                                    final int
                                                                        index =
                                                                        entry
                                                                            .key;
                                                                    final Map<
                                                                            String,
                                                                            dynamic>
                                                                        event =
                                                                        entry
                                                                            .value;

                                                                    return DataRow(
                                                                      cells: [
                                                                        DataCell(Text((index +
                                                                                1)
                                                                            .toString())),
                                                                        DataCell(
                                                                            Text(event['claimantName'].toString())),
                                                                        DataCell(
                                                                            Text(event['title'].toString())),
                                                                        DataCell(
                                                                          Text(event['rejected']
                                                                              .toString()),
                                                                        ),
                                                                        DataCell(
                                                                          Text(event['comment']
                                                                              .toString()),
                                                                        ),
                                                                        DataCell(
                                                                            Text(
                                                                          event['amount']
                                                                              .toStringAsFixed(2),
                                                                        )),
                                                                      ],
                                                                    );
                                                                  }).toList(),
                                                                ])),
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(
                                                    height: 500,
                                                    child: Center(
                                                      child: Text(
                                                          'There is no claim accepted or rejected.'),
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

Widget buildBarChart(List<Map<String, dynamic>> acceptedClaims) {
  List<double> amounts = acceptedClaims.map<double>((claim) => claim['amount']).toList();

  return BarChart(
    BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: amounts.reduce((value, element) => value > element ? value : element) + 100,
      barGroups: [
        BarChartGroupData(x: 0, barsSpace: 4, barRods: [
          BarChartRodData(
            toY: amounts.reduce((value, element) => value + element),
            width: 16,
          ),
        ]),
      ],
    ),
  );
}
