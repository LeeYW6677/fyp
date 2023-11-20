import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fyp/components/button.dart';
import 'package:fyp/components/dropDownList.dart';
import 'package:fyp/components/customTextField.dart';
import 'package:fyp/components/radioButton.dart';
import 'package:fyp/components/textfield.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget{
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final username = TextEditingController();
  final email = TextEditingController();
  final password = TextEditingController();
  final cfmPassword = TextEditingController();
  final ic = TextEditingController();
  final contact = TextEditingController();
  final List<String> dropdownOptions = ['RSW', 'RDS', 'RIT'];
  String _selectedGender = 'Male';
  String? _selectedProgramme = 'RSW';
  void signUserUp() async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
    try {
      if (password.text == cfmPassword.text) {
        final authResult = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email.text,
          password: password.text,
        );

        final user = authResult.user;
        if (user != null) {
          writeUserData();
        }
      } else {
        showErrorMessage("Password doesn't match!");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Dismiss the loading dialog
      showErrorMessage(e.code);
    }
  }

  void showErrorMessage(String message){
    showDialog(
      context: context, 
      builder: (context){
        return AlertDialog(
          title:Center(
            child:Text(
              message
            ),
          ),
        );
      },
    );
  }

void writeUserData() {
  final collection = FirebaseFirestore.instance.collection('users');

  collection.doc().set({
    'name': username.text,
    'email': email.text,
    'password': password.text,
    'gender': _selectedGender,
    'ic': ic.text,
    'contact': contact.text,
    'programme': _selectedProgramme
  });
}

  @override
  Widget build(BuildContext context){
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height:50),

              Image.asset(
                'lib/Images/tarumt.png',
                height: 120,
                ),

              const SizedBox(height: 50),

              Text(
                'Let\'s create an account',
                style: TextStyle(
                  color:Colors.grey[700],
                  fontSize: 16, 
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200, // Set a fixed width for labels
                      child: Text(
                        'Name:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: MyTextField(
                        controller: username,
                        hintText: 'Name',
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200, // Set a fixed width for labels
                      child: Text(
                        'Email:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: MyTextField(
                        controller: email,
                        hintText: 'Email',
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200, // Set a fixed width for labels
                      child: Text(
                        'Password:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: CustomTextField(
                        controller: password,
                        hintText: 'Password',
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200, // Set a fixed width for labels
                      child: Text(
                        'Confirm Password:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: CustomTextField(
                        controller: cfmPassword,
                        hintText: 'Confirm Password',
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200, // Set a fixed width for labels
                      child: Text(
                        'Gender:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: GenderSelection(
                        selectedGender: 'Male',
                        onChanged: (value) {
                          setState(() {
                            _selectedGender = value.toString();
                          });
                        },
                      ),
                      )
                    ],
                  ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200, // Set a fixed width for labels
                      child: Text(
                        'IC:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: MyTextField(
                        controller: ic,
                        hintText: 'IC',
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200, // Set a fixed width for labels
                      child: Text(
                        'Contact No:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: MyTextField(
                        controller: contact,
                        hintText: 'Contact No',
                      ),
                    )
                  ],
                ),
              ),
              
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    SizedBox(
                      width: 200, // Set a fixed width for labels
                      child: Text(
                        'Programme:',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: DropdownButton<String>(
                        value: _selectedProgramme, // Set the selected value
                        items: dropdownOptions.map((String option) {
                          return DropdownMenuItem<String>(
                            value: option,
                            child: Text(option),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedProgramme = newValue; // Update the selected value
                          });
                        },
                      )
                    )
                  ],
                ),
              ),
              const SizedBox(height:25),  

              Button(
                text: 'Sign up',
                onTap: signUserUp,
              ),

              const SizedBox(height: 50),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?'),
                  SizedBox(width: 4,),
                  GestureDetector(
                    onTap: widget.onTap,
                    child: const Text(
                      'Login now',
                      style: TextStyle(
                        color:Colors.blue,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                  )
                ],
              )
            ],
          )
        ),
        
      )
    );
  }
}