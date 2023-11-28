import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ScheduleScreen(),
    );
  }
}

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Program> programs = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Schedule'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: programs.length,
              itemBuilder: (context, index) {
                return ProgramItem(
                  program: programs[index],
                  onDelete: () {
                    _deleteProgram(index);
                  },
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () {
              _addProgram();
            },
            child: Text('Add Program'),
          ),
        ],
      ),
    );
  }

  void _addProgram() async {
    DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(DateTime.now().year + 1),
    );

    if (selectedDate != null) {
      TimeOfDay? selectedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (selectedTime != null) {
        String? details = await _showDetailsInputDialog();

        if (details != null) {
          Program newProgram = Program(
            date: selectedDate,
            time: selectedTime,
            details: details,
          );

          setState(() {
            programs.add(newProgram);
          });
        }
      }
    }
  }

  Future<String?> _showDetailsInputDialog() async {
    TextEditingController detailsController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Program Details'),
          content: TextField(
            controller: detailsController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Enter details...',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context, detailsController.text);
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, null);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteProgram(int index) {
    setState(() {
      programs.removeAt(index);
    });
  }
}

class Program {
  final DateTime date;
  final TimeOfDay time;
  final String details;

  Program({required this.date, required this.time, required this.details});
}

class ProgramItem extends StatelessWidget {
  final Program program;
  final VoidCallback onDelete;

  const ProgramItem({Key? key, required this.program, required this.onDelete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text('Date: ${program.date.toLocal()}'),
      subtitle: Text('Time: ${program.time.format(context)}'),
      onTap: () {
        _showDetailsDialog(context, program.details);
      },
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }

  Future<void> _showDetailsDialog(BuildContext context, String details) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Program Details'),
          content: Text(details),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
