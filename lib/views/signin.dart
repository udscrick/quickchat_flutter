import 'package:flutter/material.dart';
import '../services/auth.dart';

class SignIn extends StatefulWidget {
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('QuickChat'),
      ),
      body: Center(
        child: RaisedButton(
          color: Colors.blue ,
          shape: RoundedRectangleBorder(
  borderRadius: BorderRadius.circular(18.0),
  side: BorderSide(color: Colors.red)
),
          onPressed: (){
            AuthMethods().signInWIthGoogle(context);
          },
                  child: Container(
            child: Text(
              'Sign In With Google',
              style: TextStyle(fontSize: 16,color: Colors.white),
            ),
        
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
        ),
      ),
    );
  }
}
