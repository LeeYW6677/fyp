import 'dart:typed_data';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class Evaluation extends StatefulWidget {
  final String selectedEvent;
  const Evaluation({super.key, required this.selectedEvent});

  @override
  State<Evaluation> createState() => _EvaluationState();
}

class _EvaluationState extends State<Evaluation> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = true;
  String status = '';
  final description = TextEditingController();
  final problem = TextEditingController();
  final improvement = TextEditingController();
  final conclusion = TextEditingController();
  List<XFile?> _imageFiles = List.generate(3, (index) => null);
  List<String> savedUrl = [];
  List<bool> valid = [false, false, false];
  final double containerSize = 200.0;
  final double imageSize = 200.0;
  int progress = -1;

  Future<void> _pickImage(int index) async {
    valid[index] = true;
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _imageFiles[index] = XFile(pickedFile.path);
      }
    });
  }

  Future<void> getData() async {
    try {
      setState(() {
        _isLoading = true;
      });
      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      final QuerySnapshot<Map<String, dynamic>> evaluationSnapshot =
          await firestore
              .collection('evaluation')
              .where('eventID', isEqualTo: widget.selectedEvent)
              .get();
      if (evaluationSnapshot.docs.isNotEmpty) {
        Map<String, dynamic> evaluationData =
            evaluationSnapshot.docs.first.data();
        description.text = evaluationData['description'] ?? '';
        problem.text = evaluationData['problem'] ?? '';
        improvement.text = evaluationData['improvement'] ?? '';
        conclusion.text = evaluationData['conclusion'] ?? '';
        savedUrl = List.from(evaluationData['imageUrls']);
      }
      setState(() {
        savedUrl = savedUrl;
        status = status;
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
                                          form: 'Evaluation',
                                          status: status,
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
                                                                  .start,
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
                                                                  'Description',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 9,
                                                              child:
                                                                  CustomTextField(
                                                                screen: !Responsive
                                                                    .isDesktop(
                                                                        context),
                                                                maxLength: 400,
                                                                labelText:
                                                                    'Description',
                                                                hintText:
                                                                    'Enter event description',
                                                                controller:
                                                                    description,
                                                                maxLine: 5,
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter event description';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ))),
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
                                                                  .start,
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
                                                                  'Problem Faced',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 9,
                                                              child:
                                                                  CustomTextField(
                                                                screen: !Responsive
                                                                    .isDesktop(
                                                                        context),
                                                                maxLength: 400,
                                                                labelText:
                                                                    'Problem Faced',
                                                                hintText:
                                                                    'Enter problem faced',
                                                                controller:
                                                                    problem,
                                                                maxLine: 5,
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter problem faced';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ))),
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
                                                                  .start,
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
                                                                  'Future Improvement',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 9,
                                                              child:
                                                                  CustomTextField(
                                                                screen: !Responsive
                                                                    .isDesktop(
                                                                        context),
                                                                maxLength: 400,
                                                                labelText:
                                                                    'Future Improvement',
                                                                hintText:
                                                                    'Enter future improvemetn',
                                                                controller:
                                                                    improvement,
                                                                maxLine: 5,
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter future improvement';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ))),
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
                                                                  .start,
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
                                                                  'Conclusion',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          16),
                                                                ),
                                                              ),
                                                            Expanded(
                                                              flex: 9,
                                                              child:
                                                                  CustomTextField(
                                                                screen: !Responsive
                                                                    .isDesktop(
                                                                        context),
                                                                maxLength: 400,
                                                                labelText:
                                                                    'Conclusion',
                                                                hintText:
                                                                    'Enter conclusion',
                                                                controller:
                                                                    conclusion,
                                                                maxLine: 5,
                                                                validator:
                                                                    (value) {
                                                                  if (value!
                                                                      .isEmpty) {
                                                                    return 'Please enter conclusion';
                                                                  }
                                                                  return null;
                                                                },
                                                              ),
                                                            ),
                                                          ],
                                                        ))),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                if (Responsive.isDesktop(
                                                    context))
                                                  const Expanded(
                                                    flex: 1,
                                                    child: Text(
                                                      'Image',
                                                      style: TextStyle(
                                                          fontSize: 16),
                                                    ),
                                                  ),
                                                Expanded(
                                                  flex: 9,
                                                  child: SingleChildScrollView(
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    child: Row(
                                                      children: [
                                                        InkWell(
                                                          onTap: () =>
                                                              _pickImage(0),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              _imageFiles[0] !=
                                                                          null ||
                                                                      savedUrl !=
                                                                          []
                                                                  ? CachedNetworkImage(
                                                                      imageUrl: _imageFiles[0] !=
                                                                              null
                                                                          ? _imageFiles[0]!
                                                                              .path
                                                                          : savedUrl[
                                                                              0],
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              const CircularProgressIndicator(),
                                                                      errorWidget:
                                                                          (context,
                                                                              url,
                                                                              error) {
                                                                        valid[0] =
                                                                            false;
                                                                        return Container(
                                                                          width:
                                                                              imageSize,
                                                                          height:
                                                                              imageSize,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(
                                                                              color: Colors.red,
                                                                              width: 2.0,
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
                                                                                color: Colors.red,
                                                                                size: 50.0,
                                                                              ),
                                                                              SizedBox(height: 8.0),
                                                                              Text(
                                                                                'Invalid Image File',
                                                                                style: TextStyle(
                                                                                  color: Colors.red,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width:
                                                                          imageSize,
                                                                      height:
                                                                          imageSize,
                                                                    )
                                                                  : Container(
                                                                      width:
                                                                          containerSize,
                                                                      height:
                                                                          containerSize,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.blue,
                                                                          width:
                                                                              2.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                      ),
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .add_a_photo,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            50.0,
                                                                      ),
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 20,
                                                        ),
                                                        InkWell(
                                                          onTap: () =>
                                                              _pickImage(1),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              _imageFiles[1] !=
                                                                          null ||
                                                                      savedUrl !=
                                                                          []
                                                                  ? CachedNetworkImage(
                                                                      imageUrl: _imageFiles[1] !=
                                                                              null
                                                                          ? _imageFiles[1]!
                                                                              .path
                                                                          : savedUrl[
                                                                              1],
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              const CircularProgressIndicator(),
                                                                      errorWidget:
                                                                          (context,
                                                                              url,
                                                                              error) {
                                                                        print(
                                                                            error);
                                                                        valid[1] =
                                                                            false;
                                                                        return Container(
                                                                          width:
                                                                              imageSize,
                                                                          height:
                                                                              imageSize,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(
                                                                              color: Colors.red,
                                                                              width: 2.0,
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
                                                                                color: Colors.red,
                                                                                size: 50.0,
                                                                              ),
                                                                              SizedBox(height: 8.0),
                                                                              Text(
                                                                                'Invalid Image File',
                                                                                style: TextStyle(
                                                                                  color: Colors.red,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width:
                                                                          imageSize,
                                                                      height:
                                                                          imageSize,
                                                                    )
                                                                  : Container(
                                                                      width:
                                                                          containerSize,
                                                                      height:
                                                                          containerSize,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.blue,
                                                                          width:
                                                                              2.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                      ),
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .add_a_photo,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            50.0,
                                                                      ),
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                            width: 20.0),
                                                        InkWell(
                                                          onTap: () =>
                                                              _pickImage(2),
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: <Widget>[
                                                              _imageFiles[2] !=
                                                                          null ||
                                                                      savedUrl !=
                                                                          []
                                                                  ? CachedNetworkImage(
                                                                      imageUrl: _imageFiles[2] !=
                                                                              null
                                                                          ? _imageFiles[2]!
                                                                              .path
                                                                          : savedUrl[
                                                                              2],
                                                                      placeholder:
                                                                          (context, url) =>
                                                                              const CircularProgressIndicator(),
                                                                      errorWidget:
                                                                          (context,
                                                                              url,
                                                                              error) {
                                                                        valid[2] =
                                                                            false;
                                                                        return Container(
                                                                          width:
                                                                              imageSize,
                                                                          height:
                                                                              imageSize,
                                                                          decoration:
                                                                              BoxDecoration(
                                                                            border:
                                                                                Border.all(
                                                                              color: Colors.red,
                                                                              width: 2.0,
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
                                                                                color: Colors.red,
                                                                                size: 50.0,
                                                                              ),
                                                                              SizedBox(height: 8.0),
                                                                              Text(
                                                                                'Invalid Image File',
                                                                                style: TextStyle(
                                                                                  color: Colors.red,
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                      fit: BoxFit
                                                                          .cover,
                                                                      width:
                                                                          imageSize,
                                                                      height:
                                                                          imageSize,
                                                                    )
                                                                  : Container(
                                                                      width:
                                                                          containerSize,
                                                                      height:
                                                                          containerSize,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        border:
                                                                            Border.all(
                                                                          color:
                                                                              Colors.blue,
                                                                          width:
                                                                              2.0,
                                                                        ),
                                                                        borderRadius:
                                                                            BorderRadius.circular(10.0),
                                                                      ),
                                                                      child:
                                                                          const Icon(
                                                                        Icons
                                                                            .add_a_photo,
                                                                        color: Colors
                                                                            .blue,
                                                                        size:
                                                                            50.0,
                                                                      ),
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 15,
                                            ),
                                            CustomButton(
                                                width: 150,
                                                onPressed: () async {
                                                  if (_formKey.currentState!
                                                      .validate()) {
                                                    if (_imageFiles.every(
                                                            (image) =>
                                                                image !=
                                                                null) &&
                                                        valid.every((element) =>
                                                            element == true)) {
                                                      List<String> imageUrls =
                                                          [];
                                                      for (int index = 0;
                                                          index <
                                                              _imageFiles
                                                                  .length;
                                                          index++) {
                                                        XFile? imageFile =
                                                            _imageFiles[index];

                                                        if (imageFile != null) {
                                                          String imageName =
                                                              'image_$index.jpg';

                                                          try {
                                                            List<int>
                                                                fileBytes =
                                                                await imageFile
                                                                    .readAsBytes();
                                                            Uint8List
                                                                imageBytes =
                                                                Uint8List.fromList(
                                                                    fileBytes);

                                                            await FirebaseStorage
                                                                .instance
                                                                .ref(
                                                                    '${widget.selectedEvent}/$imageName')
                                                                .putData(
                                                                    imageBytes);

                                                            String imageUrl =
                                                                await FirebaseStorage
                                                                    .instance
                                                                    .ref(
                                                                        '${widget.selectedEvent}/$imageName')
                                                                    .getDownloadURL();

                                                            imageUrls
                                                                .add(imageUrl);
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
                                                      }
                                                      DocumentReference docRef =
                                                          FirebaseFirestore
                                                              .instance
                                                              .collection(
                                                                  'evaluation')
                                                              .doc(widget
                                                                  .selectedEvent);

                                                      await docRef.set({
                                                        'eventID': widget
                                                            .selectedEvent,
                                                        'description':
                                                            description.text,
                                                        'conclusion':
                                                            conclusion.text,
                                                        'problem': problem.text,
                                                        'improvement':
                                                            improvement.text,
                                                        'imageUrls': imageUrls,
                                                      });

                                                      ScaffoldMessenger.of(
                                                              context)
                                                          .showSnackBar(
                                                        const SnackBar(
                                                          content: Text(
                                                              'Evaluation Report Saved.'),
                                                          width: 225.0,
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
                                                              'Please upload image of the event.'),
                                                          width: 225.0,
                                                          behavior:
                                                              SnackBarBehavior
                                                                  .floating,
                                                          duration: Duration(
                                                              seconds: 3),
                                                        ),
                                                      );
                                                    }
                                                  }
                                                },
                                                text: 'Save'),
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
