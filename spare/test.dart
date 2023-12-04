import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/studentOrganisedEvent.dart';

class Budget extends StatefulWidget {
  final String selectedEvent;
  const Budget({super.key, required this.selectedEvent});

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String status = '';
  final item = TextEditingController();
  final price = TextEditingController();
  final quantity = TextEditingController();
  final type = TextEditingController();
  List<BudgetItem> income = [];
  List<BudgetItem> expense = [];
  String selectedType = 'Income';

  @override
  void initState() {
    super.initState();
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
                        NavigationMenu(
                          buttonTexts: const ['Event', 'Budget'],
                          destination: [
                            const StudentOrganisedEvent(),
                            Budget(selectedEvent: widget.selectedEvent)
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
                                          form: 'Budget',
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
                                                              'Item Name',
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
                                                                return 'Please enter item name';
                                                              }
                                                              return null;
                                                            },
                                                            hintText:
                                                                'Enter Item Name',
                                                            controller: item,
                                                            screen: !Responsive
                                                                .isDesktop(
                                                                    context),
                                                            labelText:
                                                                'Item Name',
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
                                                        if (Responsive
                                                            .isDesktop(context))
                                                          const Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              'Unit Price',
                                                              style: TextStyle(
                                                                  fontSize: 16),
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
                                                                'Unit Price',
                                                            prefixText: 'RM',
                                                            controller: price,
                                                            hintText:
                                                                'Enter unit price',
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter
                                                                  .allow(RegExp(
                                                                      r'^\d+\.?\d{0,2}$')),
                                                            ],
                                                            validator: (value) {
                                                              if (value ==
                                                                  null) {
                                                                return 'Please enter unit price';
                                                              } else if (!RegExp(
                                                                      r'^\d+(\.\d{1,2})?$')
                                                                  .hasMatch(
                                                                      value)) {
                                                                return 'Invalid Price Format';
                                                              }
                                                              return null;
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
                                                              'Quantity',
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
                                                                return 'Please enter quantity';
                                                              }
                                                              return null;
                                                            },
                                                            labelText:
                                                                'Quantity',
                                                            screen: !Responsive
                                                                .isDesktop(
                                                                    context),
                                                            hintText: '0',
                                                            controller:
                                                                quantity,
                                                            inputFormatters: [
                                                              FilteringTextInputFormatter
                                                                  .digitsOnly,
                                                            ],
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
                                                        if (Responsive
                                                            .isDesktop(context))
                                                          const Expanded(
                                                            flex: 1,
                                                            child: Text(
                                                              'Item Type',
                                                              style: TextStyle(
                                                                  fontSize: 16),
                                                            ),
                                                          ),
                                                        Expanded(
                                                            flex: 4,
                                                            child: CustomDDL<
                                                                String>(
                                                              onChanged: (String?
                                                                  newValue) {
                                                                setState(() {
                                                                  selectedType =
                                                                      newValue!;
                                                                });
                                                              },
                                                              labelText:
                                                                  'Item Type',
                                                              screen: !Responsive
                                                                  .isDesktop(
                                                                      context),
                                                              controller: type,
                                                              hintText:
                                                                  'Select item type',
                                                              value:
                                                                  selectedType,
                                                              dropdownItems: [
                                                                'Income',
                                                                'Expense',
                                                              ].map((type) {
                                                                return DropdownMenuItem<
                                                                    String>(
                                                                  value: type,
                                                                  child: Text(
                                                                      type,
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
                                            CustomButton(
                                              onPressed: () async {
                                                if (_formKey.currentState!
                                                    .validate()) {
                                                  BudgetItem budgetItem =
                                                      BudgetItem(
                                                    name: item.text,
                                                    qty: int.parse(
                                                        quantity.text),
                                                    price: double.parse(
                                                        double.parse(price.text)
                                                            .toStringAsFixed(
                                                                2)),
                                                    type: type.text,
                                                  );

                                                  if (selectedType ==
                                                      'Income') {
                                                    income.add(budgetItem);
                                                    setState(() {
                                                      income = income;
                                                    });
                                                  } else {
                                                    expense.add(budgetItem);
                                                    setState(() {
                                                      expense = expense;
                                                    });
                                                  }

                                                  item.clear();
                                                  quantity.clear();
                                                  type.clear();
                                                  price.clear();
                                                }
                                              },
                                              text: 'Add',
                                              width: 150,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Column(
                                              children: [
                                                Center(
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        DataTable(
                                                          border:
                                                              TableBorder.all(
                                                            width: 1,
                                                            style: BorderStyle
                                                                .solid,
                                                          ),
                                                          columns: const [
                                                            DataColumn(
                                                              label: Text(
                                                                  'Item Name'),
                                                            ),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Unit Price')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Qty')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Total')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Action')),
                                                          ],
                                                          rows: income
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                            final int index =
                                                                entry.key;
                                                            final BudgetItem
                                                                items =
                                                                entry.value;

                                                            return DataRow(
                                                              cells: [
                                                                DataCell(Text(
                                                                    items
                                                                        .name)),
                                                                DataCell(Text(
                                                                    'RM ${items.price.toStringAsFixed(2)}')),
                                                                DataCell(Text(items
                                                                    .qty
                                                                    .toString())),
                                                                DataCell(Text(
                                                                  'RM ${(items.qty * items.price).toStringAsFixed(2)}',
                                                                )),
                                                              ],
                                                            );
                                                          }).toList(),
                                                        ),
                                                        DataTable(
                                                          border:
                                                              TableBorder.all(
                                                            width: 1,
                                                            style: BorderStyle
                                                                .solid,
                                                          ),
                                                          columns: const [
                                                            DataColumn(
                                                                label: Text(
                                                                    'Item Name')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Unit Price')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Qty')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Total')),
                                                            DataColumn(
                                                                label: Text(
                                                                    'Action')),
                                                          ],
                                                          rows: expense
                                                              .asMap()
                                                              .entries
                                                              .map((entry) {
                                                            final int index =
                                                                entry.key;
                                                            final BudgetItem
                                                                items =
                                                                entry.value;

                                                            return DataRow(
                                                              cells: [
                                                                DataCell(Text(
                                                                    items
                                                                        .name)),
                                                                DataCell(Text(
                                                                    'RM${items.price.toStringAsFixed(2)}')),
                                                                DataCell(Text(items
                                                                    .qty
                                                                    .toString())),
                                                                DataCell(Text(
                                                                  'RM ${(items.qty * items.price).toStringAsFixed(2)}',
                                                                )),
                                                              ],
                                                            );
                                                          }).toList(),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            CustomButton(
                                              onPressed: () {},
                                              text: 'Save',
                                              width: 150,
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            const Divider(
                                                thickness: 0.1,
                                                color: Colors.black),
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

class BudgetItem {
  String name;
  double price;
  int qty;
  String type;

  BudgetItem(
      {required this.name,
      required this.price,
      required this.qty,
      required this.type});
}
