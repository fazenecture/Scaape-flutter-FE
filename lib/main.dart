import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:scaape/screens/OnBoarding2.dart';
import 'package:scaape/screens/UserProfile.dart';
import 'package:scaape/screens/all_notifications.dart';
import 'package:scaape/screens/chat.dart';
import 'package:scaape/screens/gender_selection.dart';
import 'package:scaape/screens/homePage.dart';
import 'package:scaape/screens/home_screen.dart';
import 'package:scaape/screens/notification_page.dart';
import 'package:scaape/screens/profile_page.dart';
import 'package:scaape/screens/homePage.dart';
import 'package:scaape/screens/signIn_page.dart';
import 'package:scaape/screens/onboardingScreen.dart';
import 'package:scaape/screens/add_scaape.dart';
import 'package:scaape/screens/usersChat.dart';
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
    User? currentUser;
    currentUser = _auth.currentUser;
    return currentUser;
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
      home: //Login(),
          FutureBuilder(
          future: getCurrentUser(),
          builder: (context, snapshot) {
          if (snapshot.hasData) {
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
      },
      // home: HomeScreen(),
    );
  }
}
