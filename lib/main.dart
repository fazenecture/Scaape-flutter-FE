import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:scaape/screens/explore_page.dart';
import 'package:scaape/screens/onBoarding2_screen.dart';
import 'package:scaape/screens/user_profile_screen.dart';
import 'package:scaape/screens/allNotification_screen.dart';
import 'package:scaape/screens/chat_screen.dart';
import 'package:scaape/screens/onBoarding1_screen.dart';
import 'package:scaape/screens/dashboard_screen.dart';
import 'package:scaape/screens/bottom_navigatin_bar.dart';
import 'package:scaape/screens/notification_screen.dart';
import 'package:scaape/screens/profile_screen.dart';
import 'package:scaape/screens/dashboard_screen.dart';
import 'package:scaape/screens/signIn_screen.dart';
import 'package:scaape/screens/onBoarding0_screen.dart';
import 'package:scaape/screens/addScaape_screen.dart';
import 'package:scaape/screens/user_chat_screen.dart';
import 'package:scaape/utils/constants.dart';
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
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    String version = packageInfo.version;
    String code = packageInfo.buildNumber;
    print(version);
    print(code);
    User? currentUser;
    currentUser = _auth.currentUser;
    return currentUser;
  }



  Future<List<dynamic>> getUserDetails()async{
    User? currentUser;
    currentUser = _auth.currentUser;
    // currentUser!.uid;
    String url='https://api.scaape.online/api/getUserDetails/${currentUser!.uid}';
    // print(url);
    Response response=await get(Uri.parse(url));
    int statusCode = response.statusCode;
    // print(json.decode(response.body));


    return json.decode(response.body);
  }



  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        backgroundColor: ScaapeTheme.kBackColor,
        scaffoldBackgroundColor: ScaapeTheme.kBackColor,
        textTheme: TextTheme(
          subtitle1: TextStyle(color: Color(0xFFFFFFFF), fontFamily: 'Roboto'),
        ),
      ),
      home: FutureBuilder(
          future: getUserDetails(),
          builder: (context, snapshot) {
          if (snapshot.data != []) {
            return HomeScreen();
          } else {
            return OnBoarding();
           }
          return OnBoarding();
          },
      ),
      routes: {
        UserProfileScreen.id:(context)=>UserProfileScreen(),
        Onboarding2.id:(context)=>Onboarding2(),
        UserChat.id:(context)=>UserChat(),
        ScaapeChat.id:(context)=>ScaapeChat(),
        AddScaape.id:(context)=>AddScaape(),
        HomePageView.id:(context)=>HomeScreen(),
        OnBoarding.id:(context)=>OnBoarding(),
        ProfileScreen.id: (context) => ProfileScreen(),
        HomePageView.id: (context) => HomePageView(),
        HomeScreen.id: (context) => HomeScreen(),
        SignInScreen.id: (context) => SignInScreen(),
        GenderSelectionPage.id: (context) => GenderSelectionPage(),
        AllNotifications.id: (context) => AllNotifications(),
        NotificationScreen.id: (context) => NotificationScreen(),
        ExplorePage.id: (context)=> ExplorePage(),
      },
      // home: HomeScreen(),
    );
  }
}
