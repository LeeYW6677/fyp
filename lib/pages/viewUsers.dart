import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';

class ViewUsers extends StatefulWidget {
  const ViewUsers({super.key});

  @override
  State<ViewUsers> createState() => _ViewUsersState();
}

class _ViewUsersState extends State<ViewUsers> {
  final society = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                    const NavigationMenu(
                      buttonTexts: ['Users'],
                      destination: [ViewUsers()],
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Users',
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
                                    child: CustomDDL<String>(
                                      controller: society,
                                      hintText: 'Select society',
                                      items: const [
                                        'Student',
                                        'Advisor',
                                        'Society'
                                      ],
                                      value: 'Student',
                                      dropdownItems: const [
                                        DropdownMenuItem<String>(
                                          value: 'Student',
                                          child: Text('Student'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'Advisor',
                                          child: Text('Advisor'),
                                        ),
                                        DropdownMenuItem<String>(
                                          value: 'Society',
                                          child: Text('Society'),
                                        ),
                                      ],
                                    )),
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
                                    padding: EdgeInsets.all(8.0),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: SizedBox(),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            CustomButton(
                                              onPressed: () {},
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
                            )
                          ]),
                    ),
                  ]),
                ))
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
