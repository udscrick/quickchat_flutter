import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import './services/auth.dart';

import 'views/signin.dart';
import 'views/home.dart';

void main()async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.red,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: FutureBuilder(
        future: AuthMethods().getCurrentUser(),
        builder: (context,AsyncSnapshot<dynamic> snapshot){
          if(snapshot.hasData)//If we are logged in
          {
            return Home();
          }
          else{
            return SignIn();
          }
        },
      ),
    );
  }
}

