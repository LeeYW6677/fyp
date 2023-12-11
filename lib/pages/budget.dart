import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';

class Budget extends StatefulWidget {
  final String selectedEvent;
  final String status;
  final int progress;
  final String position;
  const Budget(
      {super.key,
      required this.selectedEvent,
      required this.status,
      required this.progress,
      required this.position});

  @override
  State<Budget> createState() => _BudgetState();
}

class _BudgetState extends State<Budget> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  final item = TextEditingController();
  final price = TextEditingController();
  final quantity = TextEditingController();
  final type = TextEditingController();
  List<BudgetItem> income = [];
  List<BudgetItem> expense = [];
  String selectedType = 'Income';
  bool enabled = true;

  double calculateTotal(List<BudgetItem> items) {
    double total = 0;
    for (var item in items) {
      total += item.qty * item.price;
    }
    return total;
  }

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      if (!widget.position.startsWith('org') ||
          widget.position.contains('Secretary') ||
          widget.status != 'Planning' ||
          (widget.progress != 0)) {
        enabled = false;
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      // Fetch event data
      final QuerySnapshot<Map<String, dynamic>> budgetSnapshot = await firestore
          .collection('budgetItem')
          .where('eventID', isEqualTo: widget.selectedEvent)
          .get();

      for (var doc in budgetSnapshot.docs) {
        String itemType = doc.data()['itemType'];

        BudgetItem budgetItem = BudgetItem(
          name: doc.data()['itemName'],
          qty: doc.data()['quantity'],
          price: doc.data()['unitPrice'],
          type: itemType,
        );

        if (itemType == 'Income') {
          income.add(budgetItem);
        } else if (itemType == 'Expense') {
          expense.add(budgetItem);
        }
      }

      setState(() {
        income = income;
        expense = expense;
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
      income = income;
      expense = expense;
    });
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
                                          status: widget.status,
                                          progress: widget.progress,
                                          position: widget.position,
                                          children: [
                                            if (enabled)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
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
                                                                    'Item Name',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                flex: 4,
                                                                child:
                                                                    CustomTextField(
                                                                  validator:
                                                                      (value) {
                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return 'Please enter item name';
                                                                    }
                                                                    return null;
                                                                  },
                                                                  hintText:
                                                                      'Enter Item Name',
                                                                  controller:
                                                                      item,
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
                                                                    'Unit Price',
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
                                                                  labelText:
                                                                      'Unit Price',
                                                                  prefixText:
                                                                      'RM',
                                                                  controller:
                                                                      price,
                                                                  hintText:
                                                                      'Enter unit price',
                                                                  inputFormatters: [
                                                                    FilteringTextInputFormatter
                                                                        .allow(RegExp(
                                                                            r'^\d+\.?\d{0,2}$')),
                                                                  ],
                                                                  validator:
                                                                      (value) {
                                                                    if (value ==
                                                                        null) {
                                                                      return 'Please enter unit price';
                                                                    } else if (!RegExp(
                                                                            r'^\d+(\.\d{1,2})?$')
                                                                        .hasMatch(
                                                                            value)) {
                                                                      return 'Invalid Price Format';
                                                                    } else if (value ==
                                                                        '0.00') {
                                                                      return 'Price must be more than RM0.00';
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
                                                                    'Quantity',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                flex: 4,
                                                                child:
                                                                    CustomTextField(
                                                                  validator:
                                                                      (value) {
                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return 'Please enter quantity';
                                                                    } else if (value ==
                                                                        '0') {
                                                                      return 'Quantity must be more than 0';
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
                                                                    'Item Type',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                  flex: 4,
                                                                  child:
                                                                      CustomDDL<
                                                                          String>(
                                                                    onChanged:
                                                                        (String?
                                                                            newValue) {
                                                                      setState(
                                                                          () {
                                                                        selectedType =
                                                                            newValue!;
                                                                      });
                                                                    },
                                                                    labelText:
                                                                        'Item Type',
                                                                    screen: !Responsive
                                                                        .isDesktop(
                                                                            context),
                                                                    controller:
                                                                        type,
                                                                    hintText:
                                                                        'Select item type',
                                                                    value:
                                                                        selectedType,
                                                                    dropdownItems:
                                                                        [
                                                                      'Income',
                                                                      'Expense',
                                                                    ].map((type) {
                                                                      return DropdownMenuItem<
                                                                          String>(
                                                                        value:
                                                                            type,
                                                                        child: Text(
                                                                            type,
                                                                            overflow:
                                                                                TextOverflow.ellipsis),
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
                                                              double.parse(price
                                                                      .text)
                                                                  .toStringAsFixed(
                                                                      2)),
                                                          type: type.text,
                                                        );

                                                        if (selectedType ==
                                                            'Income') {
                                                          income
                                                              .add(budgetItem);
                                                          setState(() {
                                                            income = income;
                                                          });
                                                        } else {
                                                          expense
                                                              .add(budgetItem);
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
                                                ],
                                              ),
                                            Column(
                                              children: [
                                                Center(
                                                  child: income.isNotEmpty ||
                                                          expense.isNotEmpty
                                                      ? SingleChildScrollView(
                                                          scrollDirection:
                                                              Axis.horizontal,
                                                          child: Row(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              DataTable(
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
                                                                          '')),
                                                                ],
                                                                rows: [
                                                                  ...income
                                                                      .asMap()
                                                                      .entries
                                                                      .map(
                                                                          (entry) {
                                                                    final int
                                                                        index =
                                                                        entry
                                                                            .key;
                                                                    final BudgetItem
                                                                        item =
                                                                        entry
                                                                            .value;

                                                                    return DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text(item.name)),
                                                                        DataCell(
                                                                            Text('RM ${item.price.toStringAsFixed(2)}')),
                                                                        DataCell(Text(item
                                                                            .qty
                                                                            .toString())),
                                                                        DataCell(
                                                                          Text(
                                                                            'RM ${(item.qty * item.price).toStringAsFixed(2)}',
                                                                          ),
                                                                        ),
                                                                        DataCell(
                                                                          Row(
                                                                            children: [
                                                                              if (enabled)
                                                                                IconButton(
                                                                                  icon: const Icon(Icons.edit),
                                                                                  onPressed: () {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (_) {
                                                                                        return EditDialog(
                                                                                          item: item,
                                                                                          index: index,
                                                                                          income: income,
                                                                                          expense: expense,
                                                                                          function: resetTable,
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              if (enabled)
                                                                                IconButton(
                                                                                  icon: const Icon(Icons.delete),
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      income.removeAt(index);
                                                                                    });
                                                                                  },
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }).toList(),
                                                                  DataRow(
                                                                    cells: [
                                                                      const DataCell(Text(
                                                                          'Total Income',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold))),
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                      DataCell(
                                                                        Text(
                                                                          'RM ${calculateTotal(income).toStringAsFixed(2)}',
                                                                          style:
                                                                              const TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                              const SizedBox(
                                                                width: 15,
                                                              ),
                                                              DataTable(
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
                                                                          '')),
                                                                ],
                                                                rows: [
                                                                  ...expense
                                                                      .asMap()
                                                                      .entries
                                                                      .map(
                                                                          (entry) {
                                                                    final int
                                                                        index =
                                                                        entry
                                                                            .key;
                                                                    final BudgetItem
                                                                        item =
                                                                        entry
                                                                            .value;

                                                                    return DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text(item.name)),
                                                                        DataCell(
                                                                            Text('RM${item.price.toStringAsFixed(2)}')),
                                                                        DataCell(Text(item
                                                                            .qty
                                                                            .toString())),
                                                                        DataCell(
                                                                          Text(
                                                                            'RM ${(item.qty * item.price).toStringAsFixed(2)}',
                                                                          ),
                                                                        ),
                                                                        DataCell(
                                                                          Row(
                                                                            children: [
                                                                              if (enabled)
                                                                                IconButton(
                                                                                  icon: const Icon(Icons.edit),
                                                                                  onPressed: () {
                                                                                    showDialog(
                                                                                      context: context,
                                                                                      builder: (_) {
                                                                                        return EditDialog(
                                                                                          item: item,
                                                                                          index: index,
                                                                                          income: income,
                                                                                          expense: expense,
                                                                                          function: resetTable,
                                                                                        );
                                                                                      },
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              if (enabled)
                                                                                IconButton(
                                                                                  icon: const Icon(Icons.delete),
                                                                                  onPressed: () {
                                                                                    setState(() {
                                                                                      expense.removeAt(index);
                                                                                    });
                                                                                  },
                                                                                ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    );
                                                                  }).toList(),
                                                                  DataRow(
                                                                    cells: [
                                                                      const DataCell(Text(
                                                                          'Total Expense',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold))),
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                      DataCell(
                                                                        Text(
                                                                          'RM ${calculateTotal(expense).toStringAsFixed(2)}',
                                                                          style:
                                                                              const TextStyle(fontWeight: FontWeight.bold),
                                                                        ),
                                                                      ),
                                                                      const DataCell(
                                                                          Text(
                                                                              '')),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        )
                                                      : const SizedBox(
                                                          height: 500,
                                                          child: Center(
                                                              child: Text(
                                                                  'There is no budget item registered.'))),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            if (income.isNotEmpty ||
                                                expense.isNotEmpty)
                                              Text(
                                                'Profit/Loss : ${((calculateTotal(income) - calculateTotal(expense)) < 0 ? '-' : '')}RM${(calculateTotal(income) - calculateTotal(expense)).abs().toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            if (enabled)
                                              CustomButton(
                                                onPressed: () async {
                                                  FirebaseFirestore firestore =
                                                      FirebaseFirestore
                                                          .instance;

                                                  CollectionReference budget =
                                                      firestore.collection(
                                                          'budgetItem');

                                                  QuerySnapshot querySnapshot =
                                                      await budget
                                                          .where('eventID',
                                                              isEqualTo: widget
                                                                  .selectedEvent)
                                                          .get();

                                                  for (QueryDocumentSnapshot documentSnapshot
                                                      in querySnapshot.docs) {
                                                    await documentSnapshot
                                                        .reference
                                                        .delete();
                                                  }

                                                  for (int index = 0;
                                                      index < income.length;
                                                      index++) {
                                                    BudgetItem budgetItem =
                                                        income[index];

                                                    await budget.add({
                                                      'eventID':
                                                          widget.selectedEvent,
                                                      'itemName':
                                                          budgetItem.name,
                                                      'quantity':
                                                          budgetItem.qty,
                                                      'unitPrice':
                                                          budgetItem.price,
                                                      'itemType':
                                                          budgetItem.type,
                                                    });
                                                  }

                                                  for (int index = 0;
                                                      index < expense.length;
                                                      index++) {
                                                    BudgetItem budgetItem =
                                                        expense[index];

                                                    await budget.add({
                                                      'eventID':
                                                          widget.selectedEvent,
                                                      'itemName':
                                                          budgetItem.name,
                                                      'quantity':
                                                          budgetItem.qty,
                                                      'unitPrice':
                                                          budgetItem.price,
                                                      'itemType':
                                                          budgetItem.type,
                                                    });
                                                  }
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content:
                                                          Text('Budget saved.'),
                                                      width: 150.0,
                                                      behavior: SnackBarBehavior
                                                          .floating,
                                                      duration:
                                                          Duration(seconds: 3),
                                                    ),
                                                  );
                                                },
                                                text: 'Save',
                                                width: 150,
                                              ),
                                            const SizedBox(
                                              height: 15,
                                            ),
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

class EditDialog extends StatefulWidget {
  final BudgetItem item;
  final int index;
  final VoidCallback function;
  final List<BudgetItem> income;
  final List<BudgetItem> expense;

  const EditDialog({
    required this.index,
    required this.item,
    required this.function,
    required this.income,
    required this.expense,
  });
  @override
  _EditDialogState createState() => _EditDialogState();
}

class _EditDialogState extends State<EditDialog> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController name = TextEditingController();
  TextEditingController price = TextEditingController();
  TextEditingController qty = TextEditingController();

  @override
  void initState() {
    super.initState();
    name.text = widget.item.name;
    qty.text = widget.item.qty.toString();
    price.text = widget.item.price.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Edit Budget Item'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomTextField(
              screen: true,
              labelText: 'Item Name',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter item name';
                }
                return null;
              },
              controller: name,
              hintText: 'Enter item name',
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              screen: true,
              labelText: 'Unit Price',
              prefixText: 'RM',
              controller: price,
              hintText: 'Enter unit price',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please enter unit price';
                } else if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
                  return 'Invalid Price Format';
                } else if (value == '0.00') {
                  return 'Price must be more than RM0.00';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter quantity';
                } else if (value == '0') {
                  return 'Quantity must be more than 0';
                }
                return null;
              },
              labelText: 'Quantity',
              screen: true,
              hintText: '0',
              controller: qty,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
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
              BudgetItem budgetItem = BudgetItem(
                name: name.text,
                qty: int.parse(qty.text),
                price:
                    double.parse(double.parse(price.text).toStringAsFixed(2)),
                type: widget.item.type,
              );

              if (widget.item.type == 'Income') {
                widget.income[widget.index] = budgetItem;
                widget.function();
              } else {
                widget.expense[widget.index] = budgetItem;
                widget.function();
              }
              Navigator.of(context).pop();
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}
