import 'package:flutter/material.dart';

class drawer extends StatelessWidget {
  const drawer({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () {},
                shape: const Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 219, 219, 219),
                  ),
                )),
            ListTile(
                leading: const Icon(Icons.people),
                title: const Text('Society'),
                onTap: () {},
                shape: const Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 219, 219, 219),
                  ),
                )),
            ListTile(
                leading: const Icon(Icons.event),
                title: const Text('Event'),
                onTap: () {},
                shape: const Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 219, 219, 219),
                  ),
                )),
            ListTile(
                leading: const Icon(Icons.money),
                title: const Text('Claim'),
                onTap: () {},
                shape: const Border(
                  bottom: BorderSide(
                    color: Color.fromARGB(255, 219, 219, 219),
                  ),
                )),
          ],
        ),
      ),
    );
  }
}