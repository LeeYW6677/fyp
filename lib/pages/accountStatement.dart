import 'dart:math';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/viewClaim.dart';
import 'package:fyp/pages/viewImage.dart';
import 'package:image_picker/image_picker.dart';

class Account extends StatefulWidget {
  final String selectedEvent;
  final String status;
  final int progress;
  final String position;
  const Account(
      {super.key,
      required this.selectedEvent,
      required this.status,
      required this.progress,
      required this.position});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  final item = TextEditingController();
  final price = TextEditingController();
  final type = TextEditingController();
  String selectedType = 'Income';
  List<AccountStatement> income = [];
  List<AccountStatement> expense = [];
  bool enabled = true;
  List<XFile?> _imageFile = List.generate(1, (index) => null);
  bool isValid = false;
  String savedUrl = '';

  Future<void> _pickImage() async {
    isValid = false;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile[0] = XFile(pickedFile.path);
        isValid = true;
      }
    });
  }

  void resetTable() {
    setState(() {
      income = income;
      expense = expense;
    });
  }

  double calculateTotal(List<AccountStatement> items) {
    double total = 0;
    for (var item in items) {
      total += item.price;
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
          widget.status != 'Closing' ||
          (widget.progress != 0)) {
        enabled = false;
      }

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot<Map<String, dynamic>> budgetSnapshot = await firestore
          .collection('accountStatement')
          .where('eventID', isEqualTo: widget.selectedEvent)
          .get();

      for (var doc in budgetSnapshot.docs) {
        String itemType = doc.data()['recordType'];

        AccountStatement budgetItem = AccountStatement(
          name: doc.data()['description'],
          price: doc.data()['amount'],
          reference: doc.data()['reference'],
          type: itemType,
          imagePath: doc.data()['imagePath'],
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
                                          tab: 'Post',
                                          form: 'Account',
                                          status: widget.status,
                                          position: widget.position,
                                          progress: widget.progress,
                                          children: [
                                            if (enabled)
                                              Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        flex: 1,
                                                        child: InkWell(
                                                          onTap: enabled
                                                              ? () =>
                                                                  _pickImage()
                                                              : null,
                                                          child: _imageFile[
                                                                          0] !=
                                                                      null ||
                                                                  savedUrl != ''
                                                              ? CachedNetworkImage(
                                                                  width: 200,
                                                                  height: 200,
                                                                  imageUrl: _imageFile[
                                                                              0] !=
                                                                          null
                                                                      ? _imageFile[
                                                                              0]!
                                                                          .path
                                                                      : savedUrl,
                                                                  placeholder: (context,
                                                                          url) =>
                                                                      const CircularProgressIndicator(),
                                                                  errorWidget:
                                                                      (context,
                                                                          url,
                                                                          error) {
                                                                    isValid =
                                                                        false;
                                                                    return Container(
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.red,
                                                                          width:
                                                                              2.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                      ),
                                                                      child:
                                                                          const Column(
                                                                        mainAxisAlignment:
                                                                            MainAxisAlignment.center,
                                                                        children: [
                                                                          Icon(
                                                                            Icons.error,
                                                                            color:
                                                                                Colors.red,
                                                                            size:
                                                                                50.0,
                                                                          ),
                                                                          SizedBox(
                                                                              height: 8.0),
                                                                          Text(
                                                                            'Invalid Image File',
                                                                            style:
                                                                                TextStyle(
                                                                              color: Colors.red,
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    );
                                                                  },
                                                                  fit: BoxFit
                                                                      .fitHeight,
                                                                )
                                                              : Container(
                                                                  height: 200,
                                                                  width: 200,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    border:
                                                                        Border
                                                                            .all(
                                                                      color: Colors
                                                                          .blue,
                                                                      width:
                                                                          2.0,
                                                                    ),
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            10.0),
                                                                  ),
                                                                  child:
                                                                      const Icon(
                                                                    Icons
                                                                        .add_a_photo,
                                                                    color: Colors
                                                                        .blue,
                                                                    size: 50.0,
                                                                  ),
                                                                ),
                                                        ),
                                                      ),
                                                      Expanded(
                                                          flex: 2,
                                                          child: Column(
                                                            children: [
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
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
                                                                        .isDesktop(
                                                                            context))
                                                                      const Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Text(
                                                                          'Description',
                                                                          style:
                                                                              TextStyle(fontSize: 16),
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
                                                                            return 'Please enter description';
                                                                          }
                                                                          return null;
                                                                        },
                                                                        hintText:
                                                                            'Enter Description',
                                                                        controller:
                                                                            item,
                                                                        screen:
                                                                            !Responsive.isDesktop(context),
                                                                        labelText:
                                                                            'Description',
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
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
                                                                        .isDesktop(
                                                                            context))
                                                                      const Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Text(
                                                                          'Amount',
                                                                          style:
                                                                              TextStyle(fontSize: 16),
                                                                        ),
                                                                      ),
                                                                    Expanded(
                                                                      flex: 4,
                                                                      child:
                                                                          CustomTextField(
                                                                        screen:
                                                                            !Responsive.isDesktop(context),
                                                                        labelText:
                                                                            'Amount',
                                                                        prefixText:
                                                                            'RM',
                                                                        controller:
                                                                            price,
                                                                        hintText:
                                                                            'Enter amount',
                                                                        inputFormatters: [
                                                                          FilteringTextInputFormatter.allow(
                                                                              RegExp(r'^\d+\.?\d{0,2}$')),
                                                                        ],
                                                                        validator:
                                                                            (value) {
                                                                          if (value ==
                                                                              null) {
                                                                            return 'Please enter amount';
                                                                          } else if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(
                                                                              value)) {
                                                                            return 'Invalid Amount Format';
                                                                          } else if (value ==
                                                                              '0.00') {
                                                                            return 'Amount must be more than RM 0.00';
                                                                          }
                                                                          return null;
                                                                        },
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                              Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
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
                                                                        .isDesktop(
                                                                            context))
                                                                      const Expanded(
                                                                        flex: 1,
                                                                        child:
                                                                            Text(
                                                                          'Record Type',
                                                                          style:
                                                                              TextStyle(fontSize: 16),
                                                                        ),
                                                                      ),
                                                                    Expanded(
                                                                        flex: 4,
                                                                        child: CustomDDL<
                                                                            String>(
                                                                          onChanged:
                                                                              (String? newValue) {
                                                                            setState(() {
                                                                              selectedType = newValue!;
                                                                            });
                                                                          },
                                                                          labelText:
                                                                              'Record Type',
                                                                          screen:
                                                                              !Responsive.isDesktop(context),
                                                                          controller:
                                                                              type,
                                                                          hintText:
                                                                              'Select record type',
                                                                          value:
                                                                              selectedType,
                                                                          dropdownItems:
                                                                              [
                                                                            'Income',
                                                                            'Expense',
                                                                          ].map((type) {
                                                                            return DropdownMenuItem<String>(
                                                                              value: type,
                                                                              child: Text(type, overflow: TextOverflow.ellipsis),
                                                                            );
                                                                          }).toList(),
                                                                        )),
                                                                  ],
                                                                ),
                                                              ),
                                                            ],
                                                          )),
                                                    ],
                                                  ),
                                                  CustomButton(
                                                    onPressed: () async {
                                                      if (_formKey.currentState!
                                                          .validate()) {
                                                        String imageUrl = '';
                                                        String todayDate =
                                                            DateTime.now()
                                                                .toLocal()
                                                                .toString()
                                                                .substring(
                                                                    0, 10)
                                                                .replaceAll(
                                                                    '-', '');

                                                        String randomDigits =
                                                            Random()
                                                                .nextInt(999)
                                                                .toString()
                                                                .padLeft(
                                                                    3, '0');

                                                        // Concatenate the parts to form the eventID
                                                        String accountID =
                                                            'AS$todayDate$randomDigits';
                                                        String imageName =
                                                            '$accountID.jpg';
                                                        if (_imageFile[0] !=
                                                            null) {
                                                          try {
                                                            List<int>
                                                                fileBytes =
                                                                await _imageFile[
                                                                        0]!
                                                                    .readAsBytes();
                                                            Uint8List
                                                                imageBytes =
                                                                Uint8List.fromList(
                                                                    fileBytes);

                                                            await FirebaseStorage
                                                                .instance
                                                                .ref(
                                                                    'account/$imageName')
                                                                .putData(
                                                                    imageBytes);

                                                            imageUrl = await FirebaseStorage
                                                                .instance
                                                                .ref(
                                                                    'account/$imageName')
                                                                .getDownloadURL();
                                                          } catch (e) {
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                              const SnackBar(
                                                                content: Text(
                                                                    'Failed to upload image.'),
                                                                width: 225.0,
                                                                behavior:
                                                                    SnackBarBehavior
                                                                        .floating,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                              ),
                                                            );
                                                          }
                                                        }
                                                        AccountStatement
                                                            statement =
                                                            AccountStatement(
                                                          name: item.text,
                                                          price: double.parse(
                                                              double.parse(price
                                                                      .text)
                                                                  .toStringAsFixed(
                                                                      2)),
                                                          type: selectedType,
                                                          reference: accountID,
                                                          imagePath: imageUrl,
                                                        );

                                                        if (selectedType ==
                                                            'Income') {
                                                          income.add(statement);
                                                          setState(() {
                                                            income = income;
                                                          });
                                                        } else {
                                                          expense
                                                              .add(statement);
                                                          setState(() {
                                                            expense = expense;
                                                          });
                                                        }

                                                        item.clear();
                                                        type.clear();
                                                        price.clear();
                                                        _imageFile[0] = null;
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
                                                                        ''),
                                                                  ),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          'Income')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          '')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          '')),
                                                                ],
                                                                rows: [
                                                                  const DataRow(
                                                                    cells: [
                                                                      DataCell(Text(
                                                                          'Item Name',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold))),
                                                                      DataCell(Text(
                                                                          'Reference',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold))),
                                                                      DataCell(
                                                                        Text(
                                                                            'Amount',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                      ),
                                                                      DataCell(
                                                                          Text(
                                                                              '')),
                                                                    ],
                                                                  ),
                                                                  ...income
                                                                      .asMap()
                                                                      .entries
                                                                      .map(
                                                                          (entry) {
                                                                    final int
                                                                        index =
                                                                        entry
                                                                            .key;
                                                                    final AccountStatement
                                                                        statement =
                                                                        entry
                                                                            .value;

                                                                    return DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text(statement.name)),
                                                                        DataCell(
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => ViewImage(
                                                                                    accountID: statement.imagePath,
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              statement.reference,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        DataCell(
                                                                            Text('RM ${statement.price.toStringAsFixed(2)}')),
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
                                                                                          item: statement,
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
                                                                          '')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          'Expense')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          '')),
                                                                  DataColumn(
                                                                      label: Text(
                                                                          '')),
                                                                ],
                                                                rows: [
                                                                  const DataRow(
                                                                    cells: [
                                                                      DataCell(Text(
                                                                          'Item Name',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold))),
                                                                      DataCell(Text(
                                                                          'Reference',
                                                                          style:
                                                                              TextStyle(fontWeight: FontWeight.bold))),
                                                                      DataCell(
                                                                        Text(
                                                                            'Amount',
                                                                            style:
                                                                                TextStyle(fontWeight: FontWeight.bold)),
                                                                      ),
                                                                      DataCell(
                                                                          Text(
                                                                              '')),
                                                                    ],
                                                                  ),
                                                                  ...expense
                                                                      .asMap()
                                                                      .entries
                                                                      .map(
                                                                          (entry) {
                                                                    final int
                                                                        index =
                                                                        entry
                                                                            .key;
                                                                    final AccountStatement
                                                                        statement =
                                                                        entry
                                                                            .value;

                                                                    return DataRow(
                                                                      cells: [
                                                                        DataCell(
                                                                            Text(statement.name)),
                                                                        DataCell(
                                                                          TextButton(
                                                                            onPressed:
                                                                                () {
                                                                              if (statement.reference.startsWith('A')) {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => ViewImage(
                                                                                      accountID: statement.imagePath,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              } else {
                                                                                Navigator.push(
                                                                                  context,
                                                                                  MaterialPageRoute(
                                                                                    builder: (context) => ViewClaim(
                                                                                      selectedEvent: widget.selectedEvent,
                                                                                      selectedClaim: statement.reference,
                                                                                    ),
                                                                                  ),
                                                                                );
                                                                              }
                                                                            },
                                                                            child:
                                                                                Text(
                                                                              statement.reference,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                        DataCell(
                                                                            Text('RM${statement.price.toStringAsFixed(2)}')),
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
                                                                                          item: statement,
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
                                                                  'There is no item reigstered.'))),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            Text(
                                              'Balance : ${((calculateTotal(income) - calculateTotal(expense)) < 0 ? '-' : '')}RM${(calculateTotal(income) - calculateTotal(expense)).abs().toStringAsFixed(2)}',
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

                                                  CollectionReference account =
                                                      firestore.collection(
                                                          'accountStatement');

                                                  QuerySnapshot querySnapshot =
                                                      await account
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
                                                    AccountStatement statement =
                                                        income[index];

                                                    await account.add({
                                                      'eventID':
                                                          widget.selectedEvent,
                                                      'description':
                                                          statement.name,
                                                      'amount': statement.price,
                                                      'reference':
                                                          statement.reference,
                                                      'recordType':
                                                          statement.type,
                                                      'imagePath':
                                                          statement.imagePath,
                                                    });
                                                  }

                                                  for (int index = 0;
                                                      index < expense.length;
                                                      index++) {
                                                    AccountStatement statement =
                                                        expense[index];

                                                    await account.add({
                                                      'eventID':
                                                          widget.selectedEvent,
                                                      'description':
                                                          statement.name,
                                                      'amount': statement.price,
                                                      'reference':
                                                          statement.reference,
                                                      'recordType':
                                                          statement.type,
                                                      'imagePath':
                                                          statement.imagePath,
                                                    });
                                                  }
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    const SnackBar(
                                                      content: Text(
                                                          'Account Statement saved.'),
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

class AccountStatement {
  String name;
  double price;
  String type;
  String reference;
  String imagePath;

  AccountStatement({
    required this.name,
    required this.price,
    required this.type,
    this.reference = '',
    this.imagePath = '',
  });
}

class EditDialog extends StatefulWidget {
  final AccountStatement item;
  final int index;
  final VoidCallback function;
  final List<AccountStatement> income;
  final List<AccountStatement> expense;

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

  @override
  void initState() {
    super.initState();
    name.text = widget.item.name;
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
              labelText: 'Description',
              validator: (value) {
                if (value!.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
              controller: name,
              hintText: 'Enter description',
            ),
            const SizedBox(
              height: 15,
            ),
            CustomTextField(
              screen: true,
              labelText: 'Amount',
              prefixText: 'RM',
              controller: price,
              hintText: 'Enter amount',
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}$')),
              ],
              validator: (value) {
                if (value == null) {
                  return 'Please enter amount';
                } else if (!RegExp(r'^\d+(\.\d{1,2})?$').hasMatch(value)) {
                  return 'Invalid Amount Format';
                } else if (value == '0.00') {
                  return 'Amount must be more than RM 0.00';
                }
                return null;
              },
            ),
            const SizedBox(
              height: 15,
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
              AccountStatement statement = AccountStatement(
                name: name.text,
                price:
                    double.parse(double.parse(price.text).toStringAsFixed(2)),
                type: widget.item.type,
              );

              if (widget.item.type == 'Income') {
                widget.income[widget.index] = statement;
                widget.function();
              } else {
                widget.expense[widget.index] = statement;
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
