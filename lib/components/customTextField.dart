import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool hiding;
  final bool showIcon;
  final Icon? icon;
  final int width;
  final String? Function(String?)? validator;
  final String? errorText;

  CustomTextField({
    required this.controller,
    required this.hintText,
    this.width = 300,
    this.hiding = false,
    this.showIcon = false,
    this.icon,
    this.validator,
    this.errorText
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = false;

  @override
  void initState() {
    super.initState();
    obscureText = widget.hiding; // Initialize based on the widget's hiding property
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextFormField(
        controller: widget.controller,
        obscureText: obscureText, // Use the obscureText property here
        decoration: InputDecoration(
          hintText: widget.hintText,
          errorText: widget.errorText,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
            width: 1, color: Colors.grey),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Colors.blue,
            ),
          ),
          errorBorder: const OutlineInputBorder(
             borderSide: BorderSide(
              width: 1,
              color: Colors.red,
            ),
          ),
          focusedErrorBorder: const OutlineInputBorder(
             borderSide: BorderSide(
              width: 1,
              color: Colors.red,
            ),
          ),
          prefixIcon: widget.showIcon ? widget.icon : null,
          suffixIcon: widget.hiding
              ? IconButton(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  icon: obscureText
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText; // Toggle the state
                    });
                  },
                )
              : null,
        ),
        validator: widget.validator,
      ),
    );
  }
}


