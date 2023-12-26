import 'dart:convert';
import 'dart:math';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emailjs/emailjs.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:fyp/pages/eventDetails.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:localstorage/localstorage.dart';
import 'package:http/http.dart' as http;

class ViewClaim extends StatefulWidget {
  final String selectedClaim;
  final String selectedEvent;
  const ViewClaim(
      {super.key, required this.selectedClaim, required this.selectedEvent});

  @override
  State<ViewClaim> createState() => _ViewClaimState();
}

class _ViewClaimState extends State<ViewClaim> {
  String? nameError;
  List<String> items = [];
  bool enabled = true;
  bool _isLoading = true;
  String imageUrl = '';
  List<Map<String, dynamic>> approvedClaim = [];
  List<XFile?> _imageFile = List.generate(1, (index) => null);
  bool isValid = false;
  final double containerSize = 400.0;
  String savedUrl = '';
  final date = TextEditingController();
  final vendor = TextEditingController();
  final name = TextEditingController();
  final submission = TextEditingController();
  final amount = TextEditingController();
  final title = TextEditingController();
  final nothing = TextEditingController();
  final item = TextEditingController();
  List<String> checkName = ['', '', ''];
  List<String> checkStatus = ['', '', ''];
  String status = '';
  String claimantID = '';
  int access = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final LocalStorage storage = LocalStorage('user');

  Future<void> _pickImage() async {
    isValid = false;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _imageFile[0] = XFile(pickedFile.path);
        isValid = true;
        sendData();
      }
    });
  }

  Future<void> sendData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // Read the image file as bytes
      List<int> imageBytes = await _imageFile[0]!.readAsBytes();

      // Encode the image bytes as a base64 string
      String base64Image = base64Encode(imageBytes);

      var response = await http.post(
        Uri.parse('http://127.0.0.1:5000'),
        body: jsonEncode({
          'image': base64Image,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        items.clear();
        Map<String, dynamic> jsonData = jsonDecode(response.body);
        print(jsonData);

        List<List<String>> entities = (jsonData['result'] as List)
            .map((dynamic e) => List<String>.from(e as List))
            .toList();
        setState(() {
          vendor.text = getValueByLabel(entities, "COMPANY");
          String totalValue = getValueByLabel(entities, "TOTAL");
          if (totalValue.split('.').length - 1 >= 2) {
            amount.text = extractRemainingDecimal(totalValue);
          } else {
            amount.text = totalValue;
          }
          String rawDateValue = getValueByLabel(entities, "DATE");

          if (rawDateValue.isNotEmpty) {
            DateTime pdate = parseDate(rawDateValue);

            String formattedDate = DateFormat('dd-MM-yyyy').format(pdate);
            date.text = formattedDate;
          }
          getAllItems(entities, "ITEM");
          items = items;
        });
      } else {
        var error = jsonDecode(response.body)['error'];
        print('Error: $error');
      }
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error: $e');
    }
  }

  String extractRemainingDecimal(String input) {
    // Find the first occurrence of '.'
    int firstIndex = input.indexOf('.');

    if (firstIndex != -1 && firstIndex < input.length - 3) {
      // Extract the remaining value after the first decimal point and the following two digits
      String remainingValue = input.substring(firstIndex + 3, input.length);
      return remainingValue;
    }

    return '0.00'; // Return '0.00' if no decimal point or not enough digits are found
  }

  void getAllItems(List<List<String>> dataList, String label) {
    for (var entry in dataList) {
      if (entry.isNotEmpty && entry.length > 1 && entry[0] == label) {
        items.add(entry[1]);
      }
    }
  }

  DateTime parseDate(String rawDate) {
    List<String> possibleFormats = ['dd/MM/yyyy', 'dd-MM-yyyy'];

    for (String format in possibleFormats) {
      try {
        return DateFormat(format).parseStrict(rawDate);
      } catch (e) {
        return DateTime.now();
      }
    }

    return DateTime.now();
  }

  String getValueByLabel(List<List<String>> dataList, String label) {
    for (var entry in dataList) {
      if (entry.isNotEmpty && entry.length > 1 && entry[0] == label) {
        return entry[1];
      }
    }
    return '';
  }

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      access = 0;
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot<Map<String, dynamic>> approvalSnapshot =
          await firestore
              .collection('claim')
              .where('claimID', isEqualTo: widget.selectedClaim)
              .get();
      checkName.clear();
      checkStatus.clear();
      if (approvalSnapshot.docs.isNotEmpty) {
        enabled = false;
        Map<String, dynamic> approvalData = approvalSnapshot.docs.first.data();
        title.text = approvalData['title'];
        amount.text = approvalData['amount'].toStringAsFixed(2);
        DateTime purchaseDate = approvalData['purchaseDate'].toDate();
        date.text = DateFormat('dd/MM/yyyy').format(purchaseDate);
        vendor.text = approvalData['vendor'];
        status = approvalData['status'];
        savedUrl = approvalData['receiptImage'];
        nothing.text = approvalData['comment'];
        claimantID = approvalData['claimantID'];
        dynamic claimItemData = approvalData['claimItem'];

        items = List<String>.from(claimItemData);
        final userDoc = await FirebaseFirestore.instance
            .collection('user')
            .doc(claimantID)
            .get();
        if (userDoc.exists) {
          name.text = userDoc['name'];
        }

        DateTime submissionDate = approvalData['submissionDate'].toDate();
        submission.text = DateFormat('dd/MM/yyyy').format(submissionDate);

        checkName.add('');
        checkName.add(approvalData['treasurerName'] ?? '');
        checkName.add(approvalData['advisorName'] ?? '');

        checkStatus.add('Approved');
        checkStatus.add(approvalData['treasurerStatus'] ?? '');
        checkStatus.add(approvalData['advisorStatus'] ?? '');

        if (storage.getItem('role') == 'advisor' &&
            approvalData['advisorName'] == '' &&
            approvalData['treasurerName'] != '') {
          access = 2;
        }
        QuerySnapshot committeeSnapshot = await FirebaseFirestore.instance
            .collection('committee')
            .where('eventID', isEqualTo: widget.selectedEvent)
            .get();

        List<DocumentSnapshot> treasurerDocuments = committeeSnapshot.docs
            .where((doc) => doc['position'].toString().contains('Treasurer'))
            .toList();

        if (treasurerDocuments.isNotEmpty) {
          treasurerDocuments.forEach((doc) {
            if (storage.getItem('id') == doc['studentID'] &&
                approvalData['treasurerName'] == '') {
              access = 1;
            }
          });
        }
      }

      setState(() {
        items = items;
        savedUrl = savedUrl;
        checkName = checkName;
        checkStatus = checkStatus;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          width: 225.0,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
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
              index: 4,
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
                        index: 4,
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
                                    'Claim Details',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                  ),
                                  const Divider(
                                    thickness: 0.1,
                                    color: Colors.black,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Expanded(
                                          flex: 1,
                                          child: InkWell(
                                            onTap: enabled
                                                ? () => _pickImage()
                                                : null,
                                            child: _imageFile[0] != null ||
                                                    savedUrl != ''
                                                ? CachedNetworkImage(
                                                    imageUrl: _imageFile[0] !=
                                                            null
                                                        ? _imageFile[0]!.path
                                                        : savedUrl,
                                                    placeholder: (context,
                                                            url) =>
                                                        const CircularProgressIndicator(),
                                                    errorWidget:
                                                        (context, url, error) {
                                                      isValid = false;
                                                      return Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          border: Border.all(
                                                            color: Colors.red,
                                                            width: 2.0,
                                                          ),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      10.0),
                                                        ),
                                                        child: const Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children: [
                                                            Icon(
                                                              Icons.error,
                                                              color: Colors.red,
                                                              size: 50.0,
                                                            ),
                                                            SizedBox(
                                                                height: 8.0),
                                                            Text(
                                                              'Invalid Image File',
                                                              style: TextStyle(
                                                                color:
                                                                    Colors.red,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    },
                                                    fit: BoxFit.cover,
                                                  )
                                                : Container(
                                                    width: containerSize,
                                                    height: containerSize,
                                                    decoration: BoxDecoration(
                                                      border: Border.all(
                                                        color: Colors.blue,
                                                        width: 2.0,
                                                      ),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10.0),
                                                    ),
                                                    child: const Icon(
                                                      Icons.add_a_photo,
                                                      color: Colors.blue,
                                                      size: 50.0,
                                                    ),
                                                  ),
                                          ),
                                        ),
                                        if (Responsive.isDesktop(context))
                                          const SizedBox(
                                            width: 50,
                                          ),
                                        Expanded(
                                          flex: 4,
                                          child: Form(
                                            key: _formKey,
                                            child: Column(
                                              children: [
                                                if (!enabled)
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
                                                                    'Claimant',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                flex: 4,
                                                                child:
                                                                    CustomTextField(
                                                                  enabled:
                                                                      false,
                                                                  validator:
                                                                      (value) {
                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return 'Please enter claimant name';
                                                                    }
                                                                    return null;
                                                                  },
                                                                  hintText:
                                                                      'Enter claimnat name',
                                                                  controller:
                                                                      name,
                                                                  screen: !Responsive
                                                                      .isDesktop(
                                                                          context),
                                                                  labelText:
                                                                      'Claimant',
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
                                                                    'Submission Date',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            16),
                                                                  ),
                                                                ),
                                                              Expanded(
                                                                flex: 4,
                                                                child:
                                                                    CustomTextField(
                                                                  enabled:
                                                                      false,
                                                                  validator:
                                                                      (value) {
                                                                    if (value!
                                                                        .isEmpty) {
                                                                      return 'Please enter submission date';
                                                                    }
                                                                    return null;
                                                                  },
                                                                  hintText:
                                                                      'Enter submission date',
                                                                  controller:
                                                                      submission,
                                                                  screen: !Responsive
                                                                      .isDesktop(
                                                                          context),
                                                                  labelText:
                                                                      'Submission Date',
                                                                ),
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
                                                                  'Title',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 4,
                                                              child:
                                                                  CustomTextField(
                                                                enabled:
                                                                    enabled,
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter title';
                                                                  }
                                                                  return null;
                                                                },
                                                                hintText:
                                                                    'Enter title',
                                                                controller:
                                                                    title,
                                                                screen: !Responsive
                                                                    .isDesktop(
                                                                        context),
                                                                labelText:
                                                                    'Title',
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
                                                                  'Purchase Date',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 4,
                                                              child:
                                                                  CustomTextField(
                                                                enabled:
                                                                    enabled,
                                                                controller:
                                                                    date,
                                                                labelText:
                                                                    'Purchase Date',
                                                                screen: !Responsive
                                                                    .isDesktop(
                                                                        context),
                                                                validator:
                                                                    (value) {
                                                                  final DateFormat
                                                                      dateFormat =
                                                                      DateFormat(
                                                                          'dd-MM-yyyy');

                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter purchase date';
                                                                  } else {
                                                                    try {
                                                                      DateTime
                                                                          enteredDate =
                                                                          dateFormat
                                                                              .parseStrict(value);

                                                                      if (enteredDate
                                                                          .isAfter(
                                                                              DateTime.now())) {
                                                                        return 'Please enter date before today';
                                                                      }
                                                                    } catch (e) {
                                                                      return 'Invalid Date Format. Format: dd-MM-yyyy';
                                                                    }
                                                                    if (!RegExp(
                                                                            r'^\d{2}-\d{2}-\d{4}$')
                                                                        .hasMatch(
                                                                            value)) {
                                                                      return 'Invalid Date Format. Format: dd-MM-yyyy';
                                                                    }
                                                                    return null;
                                                                  }
                                                                },
                                                                hintText:
                                                                    'Enter purchase date',
                                                                suffixIcon:
                                                                    IconButton(
                                                                  icon: const Icon(
                                                                      Icons
                                                                          .calendar_today_rounded),
                                                                  onPressed:
                                                                      () async {
                                                                    DateTime?
                                                                        pickedDate =
                                                                        await showDatePicker(
                                                                      context:
                                                                          context,
                                                                      initialDate:
                                                                          DateTime
                                                                              .now(),
                                                                      firstDate: DateTime
                                                                              .now()
                                                                          .add(const Duration(
                                                                              days: -365)),
                                                                      lastDate:
                                                                          DateTime
                                                                              .now(),
                                                                    );

                                                                    if (pickedDate !=
                                                                        null) {
                                                                      setState(
                                                                          () {
                                                                        date.text =
                                                                            DateFormat('dd-MM-yyyy').format(pickedDate);
                                                                      });
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
                                                const SizedBox(
                                                  height: 15,
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
                                                                  'Vendor',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 4,
                                                              child:
                                                                  CustomTextField(
                                                                enabled:
                                                                    enabled,
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please vendor name';
                                                                  }
                                                                  return null;
                                                                },
                                                                hintText:
                                                                    'Enter vendor name',
                                                                controller:
                                                                    vendor,
                                                                screen: !Responsive
                                                                    .isDesktop(
                                                                        context),
                                                                labelText:
                                                                    'Vendor',
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
                                                                  'Amount',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 4,
                                                              child:
                                                                  CustomTextField(
                                                                enabled:
                                                                    enabled,
                                                                screen: !Responsive
                                                                    .isDesktop(
                                                                        context),
                                                                labelText:
                                                                    'Amount',
                                                                prefixText:
                                                                    'RM',
                                                                controller:
                                                                    amount,
                                                                hintText:
                                                                    'Enter amount',
                                                                inputFormatters: [
                                                                  FilteringTextInputFormatter
                                                                      .allow(RegExp(
                                                                          r'^\d+\.?\d{0,2}$')),
                                                                ],
                                                                validator:
                                                                    (value) {
                                                                  if (value ==
                                                                      null) {
                                                                    return 'Please enter amount';
                                                                  } else if (!RegExp(
                                                                          r'^\d+(\.\d{1,2})?$')
                                                                      .hasMatch(
                                                                          value)) {
                                                                    return 'Invalid Amount Format';
                                                                  } else if (value ==
                                                                      '0.00') {
                                                                    return 'Amount must be more than RM0.00';
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
                                                const SizedBox(
                                                  height: 15,
                                                ),
                                                Padding(
                                                  padding:
                                                      const EdgeInsets.all(8.0),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      if (Responsive.isDesktop(
                                                              context) ||
                                                          enabled)
                                                        const Expanded(
                                                          flex: 1,
                                                          child: Text(
                                                            'Item',
                                                            style: TextStyle(
                                                                fontSize: 16),
                                                          ),
                                                        ),
                                                      if (enabled)
                                                        Expanded(
                                                          flex: 8,
                                                          child:
                                                              CustomTextField(
                                                            enabled: enabled,
                                                            screen: !Responsive
                                                                .isDesktop(
                                                                    context),
                                                            labelText:
                                                                'Item Name',
                                                            errorText:
                                                                nameError,
                                                            controller: item,
                                                            hintText:
                                                                'Enter item name',
                                                          ),
                                                        ),
                                                      const SizedBox(
                                                        width: 15,
                                                      ),
                                                      if (enabled)
                                                        CustomButton(
                                                          width: 150,
                                                          onPressed: () {
                                                            if (item.text
                                                                .isNotEmpty) {
                                                              setState(() {
                                                                nameError =
                                                                    null;
                                                                items.add(
                                                                    item.text);
                                                                item.clear();
                                                              });
                                                            } else {
                                                              setState(() {
                                                                nameError =
                                                                    'Please enter item name.';
                                                              });
                                                            }
                                                          },
                                                          text: 'Add',
                                                        ),
                                                    ],
                                                  ),
                                                ),
                                                if (items.isNotEmpty)
                                                  ConstrainedBox(
                                                    constraints:
                                                        const BoxConstraints(
                                                      minHeight: 100,
                                                      maxHeight: 500,
                                                    ),
                                                    child: Container(
                                                      child: GridView.builder(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        shrinkWrap: true,
                                                        gridDelegate:
                                                            const SliverGridDelegateWithFixedCrossAxisCount(
                                                          crossAxisCount: 2,
                                                          mainAxisSpacing: 0.0,
                                                          crossAxisSpacing:
                                                              10.0,
                                                          childAspectRatio: 8.0,
                                                        ),
                                                        itemCount: items.length,
                                                        itemBuilder:
                                                            (context, index) {
                                                          return Center(
                                                            child: Container(
                                                              height: 50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                border:
                                                                    Border.all(
                                                                  color: const Color
                                                                      .fromARGB(
                                                                      255,
                                                                      141,
                                                                      141,
                                                                      141),
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                              child: Column(
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Expanded(
                                                                        child:
                                                                            CustomTextField(
                                                                          enabled:
                                                                              enabled,
                                                                          controller:
                                                                              TextEditingController(text: items[index]),
                                                                          onChanged:
                                                                              (newValue) {
                                                                            setState(() {
                                                                              items[index] = newValue;
                                                                            });
                                                                          },
                                                                          hintText:
                                                                              'Enter item name',
                                                                        ),
                                                                      ),
                                                                      if (enabled)
                                                                        Row(
                                                                          children: [
                                                                            IconButton(
                                                                              icon: const Icon(Icons.delete),
                                                                              onPressed: () {
                                                                                setState(() {
                                                                                  items.removeAt(index);
                                                                                });
                                                                              },
                                                                            ),
                                                                          ],
                                                                        ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          );
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                if (!enabled)
                                                  CustomTimeline2(
                                                      status: status,
                                                      checkName: checkName,
                                                      checkStatus: checkStatus),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    if (enabled)
                                                      CustomButton(
                                                          width: 150,
                                                          onPressed: () async {
                                                            if (items.any(
                                                                (item) =>
                                                                    item ==
                                                                    '')) {
                                                              ScaffoldMessenger
                                                                      .of(context)
                                                                  .showSnackBar(
                                                                const SnackBar(
                                                                  content: Text(
                                                                      'Please enter all item name.'),
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
                                                              return;
                                                            }
                                                            if (_formKey
                                                                .currentState!
                                                                .validate()) {
                                                              if (_imageFile[
                                                                          0] !=
                                                                      null &&
                                                                  isValid) {
                                                                String todayDate = DateTime
                                                                        .now()
                                                                    .toLocal()
                                                                    .toString()
                                                                    .substring(
                                                                        0, 10)
                                                                    .replaceAll(
                                                                        '-',
                                                                        '');

                                                                String randomDigits =
                                                                    Random()
                                                                        .nextInt(
                                                                            999)
                                                                        .toString()
                                                                        .padLeft(
                                                                            3,
                                                                            '0');

                                                                // Concatenate the parts to form the eventID
                                                                String claimID =
                                                                    'C$todayDate$randomDigits';
                                                                String
                                                                    imageName =
                                                                    'receipt_$claimID.jpg';

                                                                try {
                                                                  List<int>
                                                                      fileBytes =
                                                                      await _imageFile[
                                                                              0]!
                                                                          .readAsBytes();
                                                                  Uint8List
                                                                      imageBytes =
                                                                      Uint8List
                                                                          .fromList(
                                                                              fileBytes);

                                                                  await FirebaseStorage
                                                                      .instance
                                                                      .ref(
                                                                          'receipt/$imageName')
                                                                      .putData(
                                                                          imageBytes);

                                                                  imageUrl = await FirebaseStorage
                                                                      .instance
                                                                      .ref(
                                                                          'receipt/$imageName')
                                                                      .getDownloadURL();
                                                                } catch (e) {
                                                                  ScaffoldMessenger.of(
                                                                          context)
                                                                      .showSnackBar(
                                                                    const SnackBar(
                                                                      content: Text(
                                                                          'Failed to upload image.'),
                                                                      width:
                                                                          225.0,
                                                                      behavior:
                                                                          SnackBarBehavior
                                                                              .floating,
                                                                      duration: Duration(
                                                                          seconds:
                                                                              3),
                                                                    ),
                                                                  );
                                                                }

                                                                DocumentReference
                                                                    docRef =
                                                                    FirebaseFirestore
                                                                        .instance
                                                                        .collection(
                                                                            'claim')
                                                                        .doc(
                                                                            claimID);

                                                                await docRef
                                                                    .set({
                                                                  'claimID':
                                                                      claimID,
                                                                  'claimantID':
                                                                      storage.getItem(
                                                                          'id'),
                                                                  'vendor':
                                                                      vendor
                                                                          .text,
                                                                  'eventID': widget
                                                                      .selectedEvent,
                                                                  'title': title
                                                                      .text,
                                                                  'submissionDate':
                                                                      DateTime
                                                                          .now(),
                                                                  'amount': double
                                                                      .parse(amount
                                                                          .text),
                                                                  'purchaseDate': Timestamp.fromDate(DateFormat(
                                                                          'dd-MM-yyyy')
                                                                      .parse(date
                                                                          .text)),
                                                                  'status':
                                                                      'Pending',
                                                                  'receiptImage':
                                                                      imageUrl,
                                                                  'treasurerName':
                                                                      '',
                                                                  'treasurerStatus':
                                                                      '',
                                                                  'advisorName':
                                                                      '',
                                                                  'advisorStatus':
                                                                      '',
                                                                  'comment': '',
                                                                  'claimItem':
                                                                      items,
                                                                });
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder: (context) =>
                                                                        EventDetails(
                                                                            selectedEvent:
                                                                                widget.selectedEvent),
                                                                  ),
                                                                );
                                                                enabled = false;
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        'Claim Request submitted.'),
                                                                    width:
                                                                        225.0,
                                                                    behavior:
                                                                        SnackBarBehavior
                                                                            .floating,
                                                                    duration: Duration(
                                                                        seconds:
                                                                            3),
                                                                  ),
                                                                );
                                                              } else {
                                                                ScaffoldMessenger.of(
                                                                        context)
                                                                    .showSnackBar(
                                                                  const SnackBar(
                                                                    content: Text(
                                                                        'Please upload receipt image.'),
                                                                    width:
                                                                        225.0,
                                                                    behavior:
                                                                        SnackBarBehavior
                                                                            .floating,
                                                                    duration: Duration(
                                                                        seconds:
                                                                            3),
                                                                  ),
                                                                );
                                                              }
                                                            }
                                                          },
                                                          text: 'Submit'),
                                                    const SizedBox(
                                                      width: 10,
                                                    ),
                                                    if (access >= 1)
                                                      CustomButton(
                                                          width: 150,
                                                          onPressed: () async {
                                                            showDialog(
                                                                context:
                                                                    context,
                                                                builder: (_) {
                                                                  return ApproveDialog(
                                                                      claimantID:
                                                                          claimantID,
                                                                      amount: amount
                                                                          .text,
                                                                      title: title
                                                                          .text,
                                                                      selectedEvent:
                                                                          widget
                                                                              .selectedEvent,
                                                                      function:
                                                                          getData,
                                                                      status:
                                                                          status,
                                                                      access:
                                                                          access,
                                                                      claimID:
                                                                          widget
                                                                              .selectedClaim);
                                                                });
                                                          },
                                                          text: 'Approve'),
                                                    if (access >= 1)
                                                      const SizedBox(
                                                        width: 15,
                                                      ),
                                                    if (access >= 1)
                                                      CustomButton(
                                                          width: 150,
                                                          buttonColor:
                                                              Colors.red,
                                                          onPressed: () async {
                                                            showDialog(
                                                              context: context,
                                                              builder: (_) {
                                                                return RejectDialog(
                                                                    claimantID:
                                                                        claimantID,
                                                                    amount: amount
                                                                        .text,
                                                                    title: title
                                                                        .text,
                                                                    function:
                                                                        getData,
                                                                    access:
                                                                        access,
                                                                    claimID: widget
                                                                        .selectedClaim,
                                                                    eventID: widget
                                                                        .selectedEvent);
                                                              },
                                                            );
                                                          },
                                                          text: 'Reject'),
                                                  ],
                                                ),
                                                if (status == 'Rejected')
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                          flex: 10,
                                                          child: Column(
                                                            crossAxisAlignment:
                                                                CrossAxisAlignment
                                                                    .start,
                                                            children: [
                                                              const Text(
                                                                'Reason for Rejection:',
                                                                style: TextStyle(
                                                                    fontSize:
                                                                        16),
                                                              ),
                                                              const SizedBox(
                                                                height: 15,
                                                              ),
                                                              CustomTextField(
                                                                controller:
                                                                    nothing,
                                                                hintText: '',
                                                                maxLine: 5,
                                                                enabled: false,
                                                              ),
                                                            ],
                                                          )),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
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

class ApproveDialog extends StatefulWidget {
  final String claimID;
  final int access;
  final String status;
  final VoidCallback? function;
  final String title;
  final String amount;
  final String selectedEvent;
  final String claimantID;

  const ApproveDialog({
    super.key,
    required this.claimID,
    required this.access,
    required this.status,
    required this.function,
    required this.title,
    required this.amount,
    required this.selectedEvent,
    required this.claimantID,
  });
  @override
  _ApproveDialogState createState() => _ApproveDialogState();
}

class _ApproveDialogState extends State<ApproveDialog> {
  String treasurerName = '';
  String advisorName = '';
  String treasurerStatus = '';
  String advisorStatus = '';
  String claimStatus = '';
  String eventStatus = '';

  final LocalStorage storage = LocalStorage('user');

  void _sendEmail() async {
    try {
      QuerySnapshot<Map<String, dynamic>> userQuery = await FirebaseFirestore
          .instance
          .collection('user')
          .where('id', isEqualTo: widget.claimantID)
          .get();
      String userName = userQuery.docs[0]['name'];
      String userEmail = userQuery.docs[0]['email'];
      QuerySnapshot<Map<String, dynamic>> eventQuery = await FirebaseFirestore
          .instance
          .collection('event')
          .where('eventID', isEqualTo: widget.selectedEvent)
          .get();
      String eventName = eventQuery.docs[0]['eventName'];
      await EmailJS.send(
        'service_ul1uscs',
        'template_alwxa78',
        {
          'name': userName,
          'subject': 'Claim Reimbursement Approval Notification',
          'email': userEmail,
          'message':
              'Congratulations, $userName! We are pleased to inform you that your claim reimbursement request has been approved.\n\nApproved Claim Details:\nEvent: $eventName\nTitle: ${widget.title}\nAmount: RM${widget.amount}\n\nIf you have any further questions or need additional information, please feel free to reach out. Thank you for your commitment.',
        },
        const Options(
          publicKey: 'Zfr0vuSDdyYaWouwQ',
          privateKey: 'c2nvTqTugRdLVJxuMSYwe',
        ),
      );
    } catch (error) {
      if (error is EmailJSResponseStatus) {
        print('ERROR... ${error.status}: ${error.text}');
      }
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Approve Claim'),
      content: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [Text('Are you sure you want to approve this claim?')],
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
            try {
              final FirebaseFirestore firestore = FirebaseFirestore.instance;
              eventStatus = widget.status;
              if (widget.access == 1) {
                treasurerName = storage.getItem('name');
                treasurerStatus = 'Approved';
              } else if (widget.access == 2) {
                advisorName = storage.getItem('name');
                advisorStatus = 'Approved';
                eventStatus = 'Approved';
                _sendEmail();
              }
              await firestore.collection('claim').doc(widget.claimID).update({
                if (treasurerName.isNotEmpty) 'treasurerName': treasurerName,
                if (treasurerStatus.isNotEmpty)
                  'treasurerStatus': treasurerStatus,
                if (advisorName.isNotEmpty) 'advisorName': advisorName,
                if (advisorStatus.isNotEmpty) 'advisorStatus': advisorStatus,
                'comment': '',
              });

              await firestore.collection('claim').doc(widget.claimID).update({
                'status': eventStatus,
              });

              if (widget.access == 2) {
                _sendEmail();
                await firestore
                    .collection('accountStatement')
                    .doc(widget.claimID)
                    .set({
                  'eventID': widget.selectedEvent,
                  'recordType': 'Expense',
                  'description': widget.title,
                  'reference': widget.claimID,
                  'amount': double.parse(widget.amount),
                });
              }
              widget.function!();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Claim Approved.'),
                  width: 200.0,
                  behavior: SnackBarBehavior.floating,
                  duration: Duration(seconds: 3),
                ),
              );
            } catch (e) {
              print(e.toString());
            }
          },
          child: const Text('OK'),
        ),
      ],
    );
  }
}

class RejectDialog extends StatefulWidget {
  final String eventID;
  final String claimID;
  final int access;
  final VoidCallback? function;
  final String title;
  final String amount;
  final String claimantID;

  const RejectDialog({
    super.key,
    required this.eventID,
    required this.access,
    required this.function,
    required this.claimantID,
    required this.amount,
    required this.claimID,
    required this.title,
  });
  @override
  _RejectDialogState createState() => _RejectDialogState();
}

class _RejectDialogState extends State<RejectDialog> {
  String treasurerName = '';
  String advisorName = '';
  String treasurerStatus = '';
  String advisorStatus = '';
  String eventStatus = '';
  final comment = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final LocalStorage storage = LocalStorage('user');

  void _sendEmail() async {
    String position;
    if (widget.access == 1) {
      position = "Society Treasurer";
    } else {
      position = "Society Advisor";
    }
    try {
      QuerySnapshot<Map<String, dynamic>> userQuery = await FirebaseFirestore
          .instance
          .collection('user')
          .where('id', isEqualTo: widget.claimantID)
          .get();
      String userName = userQuery.docs[0]['name'];
      String userEmail = userQuery.docs[0]['email'];
      QuerySnapshot<Map<String, dynamic>> eventQuery = await FirebaseFirestore
          .instance
          .collection('event')
          .where('eventID', isEqualTo: widget.eventID)
          .get();
      String eventName = eventQuery.docs[0]['eventName'];
      await EmailJS.send(
        'service_ul1uscs',
        'template_alwxa78',
        {
          'name': userName,
          'subject': 'Claim Reimbursement Rejection Notification',
          'email': userEmail,
          'message':
              'Dear $userName,\n\nWe regret to inform you that your claim reimbursement request has been rejected by ${storage.getItem('name')} ($position).\n\nRejected Claim Details:\nEvent: $eventName\nTitle: ${widget.title}\nAmount: RM${widget.amount}\n\nReason for Rejection: ${comment.text}\n\nIf you have any further questions or need clarification, please feel free to reach out. We appreciate your understanding.\n\nThank you for your cooperation.',
        },
        const Options(
          publicKey: 'Zfr0vuSDdyYaWouwQ',
          privateKey: 'c2nvTqTugRdLVJxuMSYwe',
        ),
      );
    } catch (error) {
      if (error is EmailJSResponseStatus) {
        print('ERROR... ${error.status}: ${error.text}');
      }
      print(error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Reject Claim'),
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

              await firestore.collection('claim').doc(widget.claimID).update({
                'status': 'Rejected',
                if (widget.access == 1)
                  'treasurerName': storage.getItem('name'),
                if (widget.access == 1) 'treasurerStatus': 'Rejected',
                if (widget.access == 2) 'advisorName': storage.getItem('name'),
                if (widget.access == 2) 'advisorStatus': 'Rejected',
                'comment': comment.text,
              });
              _sendEmail();
              Navigator.of(context).pop();
              widget.function!();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Claim Rejected'),
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
