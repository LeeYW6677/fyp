import 'package:flutter/material.dart';

class Programme extends StatelessWidget {
  final List<String> programOptions = ['RSW', 'RIT', 'RDS'];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Program Selection'),
        ),
        body: ProgramSelection(options: programOptions),
      ),
    );
  }
}

class ProgramSelection extends StatefulWidget {
  final List<String> options;

  ProgramSelection({required this.options});

  @override
  _ProgramSelectionState createState() => _ProgramSelectionState();
}

class _ProgramSelectionState extends State<ProgramSelection> {
  String selectedProgram = 'RSW';

  @override
  void initState() {
    super.initState();
    // Set an initial value for selectedProgram (e.g., the first program in the list)
    selectedProgram = widget.options.isNotEmpty ? widget.options[0] : '';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          DropdownButton<String>(
            value: selectedProgram,
            onChanged: (String? newValue) {
              setState(() {
                selectedProgram = newValue!;
              });
            },
            items: widget.options.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}