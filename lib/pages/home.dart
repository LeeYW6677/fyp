import 'package:flutter/material.dart';
import 'package:fyp/components/drawer.dart';
import 'package:fyp/components/footer.dart';
import 'package:fyp/components/header.dart';
import 'package:fyp/reponsive.dart';

class Home extends StatelessWidget {
  Home({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      drawer: !Responsive.isDesktop(context) ? const drawer() : null,
      body: SafeArea(
        child: Row(
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(
                child: drawer(),
              ),
            Expanded(
              flex: 5,
              child: Container(),
            ),
          ],
        ),
      ),
      bottomNavigationBar: !Responsive.isMobile(context) ? const Footer() : null,
    );
  }
}

