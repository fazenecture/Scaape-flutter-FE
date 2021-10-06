import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rive/rive.dart';

import 'package:http/http.dart';
import 'package:scaape/networking/google_signin.dart';
import 'package:scaape/screens/gender_selection.dart';
import 'package:scaape/screens/home_screen.dart';
import 'package:firebase_database/firebase_database.dart';

class SignInScreen extends StatefulWidget {
  static String id = 'signin_screen';

  @override
  _SignInScreenState createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  GoogleSignInAccount? _currentUser;
  var dbref = FirebaseDatabase.instance.reference().child('UserDetails');
  var _auth = FirebaseAuth.instance;
  final databaseReference = FirebaseDatabase.instance.reference();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF222831),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 27),
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: MediaQuery.of(context).size.height * 0.6,
                width: double.infinity,
                child: RiveAnimation.asset(
                  'animations/space-man.riv',
                  // fit: BoxFit.cover,
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Image.asset(
                    'images/logo.png',
                    height: 35,
                    width: 35,
                  ),
                  SizedBox(
                    width: 4,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        'Start to',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Let\'s escape with',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    width: 20,
                  ),
                  Text(
                    'Scaape',
                    style: TextStyle(
                        fontFamily: 'TheSecret',
                        fontSize: 58,
                        color: Color(0xFFFF4265)),
                  ),
                ],
              ),
              MaterialButton(
                onPressed: () async {
                  User? user =
                      await Authentication.signInWithGoogle(context: context);
                  if (user != null) {
                    // databaseReference.child("UserDetails").child("${user.uid}").set({
                    //   'Email' : '${user.email}',
                    //   'Name': '${user.displayName}',
                    //   'Profileimage': '${user.photoURL}',
                    //   'Vaccine': false,
                    //   'Verified': false
                    // });
                    try{
                      // String url='http://65.0.121.93/api/createUser';
                      // Map<String,String> headers={"Content-type":"application/json"};
                      // String json='{"UserId": "${user.uid}","EmailId": "${user.email}","BirthDate": "783783","Gender": "Male","Name": "${user.displayName}","ProfileImg": "${user.photoURL}","InstaId": "sgvsed","Vaccine": true}';
                      // Response response=await put(Uri.parse(url),headers:headers,body:json);
                      // print(user.displayName);
                      // int statusCode = response.statusCode;
                      // print(statusCode);
                      // print(response.body);
                      Navigator.pushNamed(context,GenderSelectionPage.id,arguments: {
                        'UUID':'${user.uid}',
                        'Email' : '${user.email}',
                        'Name': '${user.displayName}',
                        'ProfileImage': '${user.photoURL}',
                        'Vaccine': false,
                        'Verified': false
                      } );
                    }
                    catch(e){
                      print(e);


                    }


                  } else {
                    print('Kuch to gadbad hai');
                  }
                },
                height: 60,
                minWidth: double.infinity,
                color: Color(0xFF393E46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
                elevation: 0,
                child: ListTile(
                  leading: Image.asset(
                    'images/google-icon.png',
                    height: 33,
                    width: 33,
                  ),
                  title: Text(
                    'Sign In with Google',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: () {
                  Navigator.pushNamed(context, GenderSelectionPage.id) ;
                },
                height: 60,
                minWidth: double.infinity,
                color: Color(0xFF393E46),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(13)),
                elevation: 0,
                child: ListTile(
                  leading: Image.asset(
                    'images/facebook-icon.png',
                    height: 33,
                    width: 33,
                  ),
                  title: Text(
                    'Sign In with Facebook',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
