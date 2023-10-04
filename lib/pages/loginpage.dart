import 'package:flutter/material.dart';
import 'package:fyp/components/button.dart';
import 'package:fyp/components/tile.dart';

class LoginPage extends StatelessWidget{
  const LoginPage({super.key});

  void signUserIn(){

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
                'Welcome back, you\'ve been missed!',
                style: TextStyle(
                  color:Colors.grey[700],
                  fontSize: 16, 
                ),
              ),
              
              const Padding(
                padding: EdgeInsets.symmetric(horizontal:50.0),
                child: SizedBox(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Username"
                    ),
                  ),
                ),
              ),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal:50.0),
                child: SizedBox(
                  child: TextField(
                    obscureText: true,
                    decoration: InputDecoration(
                      hintText: "Password"
                    ),
                  ),
                ),
              ),

              const SizedBox(height:25),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal:25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end ,
                  children: [
                    Text(
                      'Forgot Password?',
                      style: TextStyle(color:Colors.grey),
                      
                    ),
                  ],
                ),
              ),

              const SizedBox(height:25),

              Button(
                onTap: signUserIn,
              ),

              const SizedBox(height: 50),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color:Colors.grey,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        'or Continue with'
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        thickness: 0.5,
                        color:Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Tile(imagePath: 'lib/Images/google.png'),
                  

                ]
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Not a member?'),
                  SizedBox(width: 4,),
                  Text(
                    'Register now',
                    style: TextStyle(
                      color:Colors.blue,
                      fontWeight: FontWeight.bold
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