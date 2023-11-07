import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: Color.fromARGB(255, 218, 218, 218),
            width: 1.0,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'COPYRIGHT © 2023 TAR UMT. All rights reserved.',
            style: TextStyle(
              color: Colors.blue,
              fontSize: 12,
            ),
          ),
          IconButton(
            onPressed: () async {
              Uri _url = Uri.parse(
                  'https://www.youtube.com/channel/UCqjsPpVnwjCRT5mgAgFo1ng');
              if (await canLaunchUrl(_url)) {
                await launchUrl(_url);
              } else {
                throw 'Could not launch $_url';
              }
            },
            icon: const FaIcon(FontAwesomeIcons.youtube,
                size: 20, color: Colors.blue),
          ),
          IconButton(
            onPressed: () async{
              Uri url1 = Uri.parse(
                  'https://www.facebook.com/tarumtkl');
              if (await canLaunchUrl(url1)) {
                await launchUrl(url1);
              } else {
                throw 'Could not launch $url1';
              }
            },
            icon: const FaIcon(FontAwesomeIcons.facebook,
                size: 20, color: Colors.blue),
          ),
          IconButton(
            onPressed: () async{
              Uri url0 = Uri.parse(
                  'https://www.instagram.com/tarumt.official/');
              if (await canLaunchUrl(url0)) {
                await launchUrl(url0);
              } else {
                throw 'Could not launch $url0';
              }
            },
            icon: const FaIcon(FontAwesomeIcons.instagram,
                size: 20, color: Colors.blue),
          ),
          IconButton(
            onPressed: () async{
              Uri url = Uri.parse(
                  'https://www.linkedin.com/school/tarumt/');
              if (await canLaunchUrl(url)) {
                await launchUrl(url);
              } else {
                throw 'Could not launch $url';
              }
            },
            icon: const FaIcon(FontAwesomeIcons.linkedin,
                size: 20, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}