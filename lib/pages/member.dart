import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';

class Member extends StatefulWidget {
  const Member({super.key});

  @override
  State<Member> createState() => _MemberState();
}

class _MemberState extends State<Member> {
  final society = TextEditingController();
  List<String> AdvisorNames = [''];
  List<String> coAdvisorNames = ['', ''];
  late List<Map<String, dynamic>> _members = [];

  Future<void> getData() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    QuerySnapshot data = await firestore
        .collection('user')
        .where('societyID', isEqualTo: 'S001')
        .get();

    AdvisorNames.clear();
    coAdvisorNames.clear();

    AdvisorNames.addAll(getPositionValues(data, 'Advisor'));
    coAdvisorNames.addAll(getPositionValues(data, 'Co-advisor'));

    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
          await FirebaseFirestore.instance
              .collection('user')
              .where('societyID', isEqualTo: 'S001').where('id', isGreaterThanOrEqualTo: 'A', isLessThan: 'B')
              .get();

      setState(() {
        _members = querySnapshot.docs.map((doc) => doc.data()).toList();
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch data. Please try again.'),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  List<String> getPositionValues(QuerySnapshot data, String targetPosition) {
    List<String> names = [];

    for (QueryDocumentSnapshot doc in data.docs) {
      if (doc['position'] == targetPosition) {
        setState(() {
          names.add(doc['name']);
        });
      }
    }

    return names;
  }

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
                  const NavigationMenu(
                    buttonTexts: ['Member'],
                    destination: [Member()],
                  ),
                  Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Society',
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
                              children: [
                                const Text('View'),
                                const SizedBox(
                                  width: 15,
                                ),
                                SizedBox(
                                  width: 400,
                                  child: CustomDDL(
                                      controller: society,
                                      hintText: 'Select society',
                                      items: const ['Computer Science Society'],
                                      value: 'Computer Science Society'),
                                ),
                              ],
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 20.0),
                              child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(
                                      color: Colors.grey,
                                      width: 1.0,
                                    ),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            const Expanded(
                                              flex: 1,
                                              child: Text(
                                                'Advisor:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                AdvisorNames[0],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            const Expanded(
                                              flex: 1,
                                              child: Text(
                                                'Co-Advisor:',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                coAdvisorNames[0],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: Container(),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Container(),
                                            ),
                                            Expanded(
                                              flex: 1,
                                              child: Container(),
                                            ),
                                            Expanded(
                                              flex: 4,
                                              child: Text(
                                                coAdvisorNames[1],
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: CustomDataTable(
                                                 columns: [
                                                  DataColumn(
                                                      label: Text('Name')),
                                                  DataColumn(
                                                      label:
                                                          Text('Society ID')),
                                                ],
                                                source: _MembersDataSource(
                                                    _members),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            CustomButton(
                                              onPressed: () {
                                                
                                              },
                                              text: 'Add',
                                              buttonColor: Colors.green,
                                              width: 100,
                                            ),
                                            const SizedBox(
                                              width: 25,
                                            ),
                                            CustomButton(
                                              onPressed: () {},
                                              text: 'Edit',
                                              width: 100,
                                            ),
                                            const SizedBox(
                                              width: 25,
                                            ),
                                            CustomButton(
                                              onPressed: () {},
                                              text: 'Delete',
                                              buttonColor: Colors.red,
                                              width: 100,
                                            )
                                          ],
                                        )
                                      ],
                                    ),
                                  )),
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

class _MembersDataSource extends DataTableSource {
  final List<Map<String, dynamic>> members;

  _MembersDataSource(this.members);

  @override
  DataRow? getRow(int index) {
    if (index >= members.length) {
      return null;
    }
    final member = members[index];
    return DataRow(cells: [
      DataCell(Text(member['studentID'].toString())),
      DataCell(Text(member['societyID'].toString())),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => members.length;

  @override
  int get selectedRowCount => 0;
}
