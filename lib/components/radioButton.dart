import 'package:flutter/material.dart';

class GenderSelection extends StatefulWidget {
  final String selectedGender;
  final ValueChanged<String> onChanged;

  GenderSelection({required this.selectedGender, required this.onChanged});

  @override
  _GenderSelectionState createState() => _GenderSelectionState();
}

class _GenderSelectionState extends State<GenderSelection> {
   String _groupValue = '';

  @override
  void initState() {
    _groupValue = widget.selectedGender;
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: Row(
            children: <Widget>[
              Radio(
                value: 'Male',
                groupValue: _groupValue,
                onChanged: (value) {
                  setState(() {
                    _groupValue = value.toString();
                    widget.onChanged(value.toString());
                  });
                },
              ),
              Text('Male'),
            ],
          ),
        ),
        Expanded(
          child: Row(
            children: <Widget>[
              Radio(
                value: 'Female',
                groupValue: _groupValue,
                onChanged: (value) {
                  setState(() {
                    _groupValue = value.toString();
                    widget.onChanged(value.toString());
                  });
                },
              ),
              Text('Female'),
            ],
          ),
        ),
      ],
    );
  }
}