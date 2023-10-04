import 'package:flutter/material.dart';

class Button extends StatelessWidget {

  final Function()? onTap;
  const Button({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration:const BoxDecoration(color: Color.fromARGB(255, 207, 44, 44)),
        child: const Center(
          child: Text(
            "Sign in",
            style:TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold
    
            ),
          ),
        )
      ),
    );
  }
}