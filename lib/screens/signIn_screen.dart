import 'dart:convert';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:rive/rive.dart';

import 'package:http/http.dart';
import 'package:scaape/networking/google_signin.dart';
import 'package:scaape/screens/onBoarding1_screen.dart';
import 'package:scaape/screens/bottom_navigatin_bar.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:scaape/utils/constants.dart';

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

  bool checkNew = false;
  // AdditionalUserInfo isNewUser = AdditionalUserInfo(isNewUser: isNewUser)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ScaapeTheme.kBackColor,
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
                  'animations/space.riv',
                  // fit: BoxFit.cover,
                ),
              ),
              SizedBox(
                height: 50,
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
                        color: ScaapeTheme.kPinkColor),
                  ),
                ],
              ),
              SizedBox(
                height: 10,
              ),
              MaterialButton(
                onPressed: () async {
                  User? user =
                      await Authentication.signInWithGoogle(context: context);
                  print(user);
                  print('user');
                  if (user != null) {
                    var data=await getUserDetails(user.uid);
                    if(data.length==0){
                      try{

                        Navigator.pushNamed(context,GenderSelectionPage.id,arguments: {
                          'UUID':'${user.uid}',
                          'Email' : '${user.email}',
                          'Name': '${user.displayName}',
                          'ProfileImage': '${user.photoURL}',
                          'Vaccine': false,
                          'Verified': false,
                          'TutorialStatus': true,
                        } );
                      }
                      catch(e){
                        print(e);
                      }
                    }
                    else{
                      Navigator.pushNamedAndRemoveUntil(
                          context, HomeScreen.id, (route) => false, arguments: {
                        'TutorialStatus': false
                      });
                    }

                  } else {
                    Fluttertoast.showToast(msg: "error in Signing Up",);
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
              // MaterialButton(
              //   onPressed: () {
              //     Navigator.pushNamed(context, GenderSelectionPage.id) ;
              //   },
              //   height: 60,
              //   minWidth: double.infinity,
              //   color: Color(0xFF393E46),
              //   shape: RoundedRectangleBorder(
              //       borderRadius: BorderRadius.circular(13)),
              //   elevation: 0,
              //   child: ListTile(
              //     leading: Image.asset(
              //       'images/facebook-icon.png',
              //       height: 33,
              //       width: 33,
              //     ),
              //     title: Text(
              //       'Sign In with Facebook',
              //       style: TextStyle(color: Colors.white, fontSize: 16),
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

Future<List<dynamic>> getUserDetails(String id)async{


  String url='https://api.scaape.online/api/getUserDetails/${id}';
  print(url);
  Response response=await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);
  print(json.decode(response.body));
  return json.decode(response.body);
}