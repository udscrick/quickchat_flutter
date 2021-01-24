import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:quickchat/helpers/sharedpref_helper.dart';
import 'package:quickchat/services/database.dart';
import 'package:quickchat/views/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthMethods{
  final FirebaseAuth auth = FirebaseAuth.instance;

getCurrentUser()async {
  return await auth.currentUser;
}

signInWIthGoogle(BuildContext context)async {
 final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
 final GoogleSignIn _googleSignIn = GoogleSignIn();

 final GoogleSignInAccount googleSignInAccount = await _googleSignIn.signIn();
 final GoogleSignInAuthentication googleSignInAuthentication = await googleSignInAccount.authentication;
 final AuthCredential credential = GoogleAuthProvider.credential(
   idToken: googleSignInAuthentication.idToken,
   accessToken: googleSignInAuthentication.accessToken

 );

 UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
 
 User userDetails = userCredential.user;

 if(userCredential!=null){

   SharedPreferenceHelper().saveUserEmail(userDetails.email);
   SharedPreferenceHelper().saveUserId(userDetails.uid);
   SharedPreferenceHelper().saveUserName(userDetails.email.replaceAll("@gmail.com", ""));
   SharedPreferenceHelper().saveDisplayName(userDetails.displayName);
   SharedPreferenceHelper().saveUserProfileUrl(userDetails.photoURL);

   Map<String,dynamic> userInfoMap = {
     "email": userDetails.email,
     "username": userDetails.email.replaceAll("@gmail.com", ""),
     "name": userDetails.displayName,
     "imgUrl": userDetails.photoURL
   };
   
   DatabaseMethods().addUserToDB(userDetails.uid, userInfoMap).then((value){
     Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> Home()));
   });
 }

 }

 Future signOut() async{
   final GoogleSignIn _googleSignIn = GoogleSignIn();
   SharedPreferences pref = await SharedPreferences.getInstance();
   pref.clear();
   await _googleSignIn.disconnect();
   await auth.signOut();
 }

}