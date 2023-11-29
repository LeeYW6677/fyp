
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

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
        title: const Text('Schedule'),
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
            child: const Text('Add Program'),
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
        Program newProgram = Program(
          date: selectedDate,
          time: selectedTime,
          details: "Program details...",
        );

        setState(() {
          programs.add(newProgram);
        });
      }
    }
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
        // Add navigation to a detailed view if needed
      },
      trailing: IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onDelete,
      ),
    );
  }
}
