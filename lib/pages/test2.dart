import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String parsedtext = '';
  parsethetext() async {
    final imagefile = await ImagePicker()
        .pickImage(source: ImageSource.gallery, maxWidth: 670, maxHeight: 970);
    var bytes = File(imagefile!.path.toString()).readAsBytesSync();
    String img64 = base64Encode(bytes);
    var url = 'https://api.ocr.space/parse/image';
    var payload = {"base64Image": "data:image/jpg;base64,${img64.toString()}"};
    var header = {"apikey": 'TEST'};
    var post = await http.post((url = url) as Uri, body: payload, headers: header);
    var result = jsonDecode(post.body);
    setState(() {
      parsedtext = result['ParsedResults'][0]['ParsedText'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(top: 30.0),
            alignment: Alignment.center,
            child: Text(
              "OCR APP",
            ),
          ),
          SizedBox(height: 15.0),
          Container(
              width: MediaQuery.of(context).size.width / 2,
              child: ElevatedButton(
                  onPressed: () => parsethetext(),
                  child: Text(
                    'Upload a image',
                  )))
        ],
      ),
    );
  }
}
