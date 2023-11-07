import 'package:flutter/material.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool hiding;
  final bool showIcon;
  final Icon? icon;
  final int width;

  CustomTextField({
    required this.controller,
    required this.hintText,
    this.width = 300,
    this.hiding = false,
    this.showIcon = false,
    this.icon,
  });

  @override
  _CustomTextFieldState createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  bool obscureText = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: widget.controller,
        obscureText: widget.hiding ? true : obscureText,
        decoration: InputDecoration(
          hintText: widget.hintText,
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(
            width: 1, color: Colors.grey), //<-- SEE HERE
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(
              width: 1,
              color: Colors.blue,
            ),
          ),
          prefixIcon: widget.showIcon ? widget.icon : null,
          suffixIcon: widget.hiding
              ? IconButton(
                  padding: const EdgeInsetsDirectional.only(end: 12.0),
                  icon: obscureText
                      ? const Icon(Icons.visibility_off)
                      : const Icon(Icons.visibility),
                  onPressed: () {
                    setState(() {
                      obscureText = !obscureText;
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }
}

