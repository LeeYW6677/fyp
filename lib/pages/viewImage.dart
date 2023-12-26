import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fyp/functions/customWidget.dart';
import 'package:fyp/functions/responsive.dart';
import 'package:image_picker/image_picker.dart';

class ViewImage extends StatefulWidget {
  final String accountID;
  const ViewImage({super.key, required this.accountID});

  @override
  State<ViewImage> createState() => _ViewImageState();
}

class _ViewImageState extends State<ViewImage> {
  List<XFile?> _imageFile = List.generate(1, (index) => null);
  String savedUrl = '';

  Future<void> getData() async {
    try {
      setState(() {
        savedUrl = widget.accountID;
      });
    } catch (error) {
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
                        Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Reference Image',
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                          color: Colors.grey,
                                          width: 1.0,
                                        ),
                                      ),
                                      child: Expanded(
                                        flex: 5,
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Center(
                                            child: InkWell(
                                              onTap: null,
                                              child: _imageFile[0] != null ||
                                                      savedUrl != ''
                                                  ? CachedNetworkImage(
                                                    height: 500,
                                                      imageUrl:
                                                          _imageFile[0] != null
                                                              ? _imageFile[0]!.path
                                                              : savedUrl,
                                                      placeholder: (context, url) =>
                                                          const CircularProgressIndicator(),
                                                      errorWidget:
                                                          (context, url, error) {
                                                        return Container(
                                                          decoration: BoxDecoration(
                                                            border: Border.all(
                                                              color: Colors.red,
                                                              width: 2.0,
                                                            ),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(10.0),
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
                                                      fit: BoxFit.fitHeight,
                                                    )
                                                  : Container(
                                                      width: 500,
                                                      height: 500,
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
                                        ),
                                      ),
                                    ),
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
