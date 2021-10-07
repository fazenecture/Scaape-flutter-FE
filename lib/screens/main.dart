import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scaape/screens/gender_selection.dart';
import 'package:scaape/screens/homePage.dart';
import 'package:scaape/screens/home_screen.dart';
import 'package:scaape/screens/profile_page.dart';
import 'package:scaape/screens/signIn_page.dart';
import 'package:scaape/screens/onboardingScreen.dart';
import 'package:get/get.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _auth = FirebaseAuth.instance;
  Future<User?> getCurrentUser() async {
    User? currentUser;
    currentUser = _auth.currentUser;
    return currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        backgroundColor: Color(0xFF22242C),
        scaffoldBackgroundColor: Color(0xFF22242C),
        textTheme: TextTheme(
          subtitle1: TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'Roboto'),
        ),
      ),
      home: //Login(),
          FutureBuilder(
        future: getCurrentUser(),
        builder: (context, snapshot) {
          // if (snapshot.hasData) {
          //   return HomeScreen();
          // } else {
            return OnBoarding();
          //}
        },
      ),
      routes: {
        OnBoarding.id:(context)=>OnBoarding(),
        ProfileScreen.id: (context) => ProfileScreen(),
        HomePageView.id: (context) => HomePageView(),
        HomeScreen.id: (context) => HomeScreen(),
        SignInScreen.id: (context) => SignInScreen(),
        GenderSelectionPage.id: (context) => GenderSelectionPage(),
      },
      // home: HomeScreen(),
    );
  }
}
