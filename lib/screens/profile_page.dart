import 'dart:ui';
import 'package:scaape/screens/imageScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blur_bottom_bar/blur_bottom_bar.dart';

class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  var currentUser = FirebaseAuth.instance.currentUser;
  getCurrentUser() async {
    if (currentUser != null) {
      return currentUser;
    }
  }

  String stringmani(String? values) {
    String? value = values;
    String? newString = value!.substring(0, value.indexOf('=') + 1) + 's700-c';
    return newString;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.only(bottom: 30),
          color: Color(0xFF22242C),
          child: FutureBuilder(
              future: getCurrentUser(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  var data = snapshot.data;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Stack(
                        children: [
                          Container(
                            height: 300,
                            width: double.infinity,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    bottomRight: Radius.circular(55),
                                    bottomLeft: Radius.circular(55))),
                            child: Image.asset(
                              'images/home-image.jpg',
                              fit: BoxFit.fitWidth,
                            ),
                          ),
                          Center(
                            child: Container(
                              margin: EdgeInsets.fromLTRB(10, 180, 2, 2),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Color(0xFFFF416C),
                                      image: DecorationImage(
                                          image: AssetImage(
                                              'images/pink-back.png'),
                                          fit: BoxFit.fill),
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 25,
                                            color: Color(0xFFFF4B2B)
                                                .withOpacity(0.43),
                                            spreadRadius: 7)
                                      ],
                                    ),
                                    child: BackdropFilter(
                                      filter: ImageFilter.blur(
                                        sigmaY: 120,
                                        sigmaX: 120,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    height: 200,
                                    width: 200,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(
                                            blurRadius: 25,
                                            color: Color(0xFFFF416C)
                                                .withOpacity(0.2),
                                            spreadRadius: 7)
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 140,
                                      backgroundColor:
                                          Color(0xFFFF4B2B).withOpacity(0.5),
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => ImageViewer(
                                                imageUrl:
                                                    '${stringmani(currentUser!.photoURL)}',
                                              ),
                                            ),
                                          );
                                        },
                                        child: Hero(
                                          tag: 'ProfilePhoto',
                                          child: CircleAvatar(
                                            backgroundImage: NetworkImage(
                                                '${stringmani(currentUser!.photoURL)}'),
                                            backgroundColor: Colors.transparent,
                                            radius: 92,
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            '${currentUser!.displayName}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Image.asset(
                            'images/tick.png',
                            height: 28,
                            width: 28,
                          ),
                        ],
                      ),
                      // Text(
                      //   '@passionatetraveler',
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.w400,
                      //     color: Colors.white,
                      //     fontSize: 14,
                      //   ),
                      // ),
                      SizedBox(
                        height: 50,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  '133',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  'Scaapes Hosted',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(
                              children: <Widget>[
                                Text(
                                  '233',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 22,
                                  ),
                                ),
                                SizedBox(
                                  height: 6,
                                ),
                                Text(
                                  'Scaapes Joined',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.symmetric(horizontal: 60),
                      //   child: MaterialButton(
                      //     onPressed: () {},
                      //     color: Color(0xFF393E46),
                      //     height: 47,
                      //     minWidth: 190,
                      //     shape: RoundedRectangleBorder(
                      //         borderRadius: BorderRadius.circular(12)),
                      //     child: Row(
                      //       mainAxisAlignment: MainAxisAlignment.center,
                      //       children: <Widget>[
                      //         Icon(
                      //           Icons.edit,
                      //           color: Colors.white,
                      //           size: 20,
                      //         ),
                      //         SizedBox(
                      //           width: 10,
                      //         ),
                      //         Text(
                      //           'Edit Profile',
                      //           style: TextStyle(
                      //             color: Colors.white,
                      //           ),
                      //         )
                      //       ],
                      //     ),
                      //   ),
                      // ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 40, vertical: 15),
                        child: Divider(
                          thickness: 0.4,
                          color: Color(0xFFFF416C).withOpacity(0.4),
                        ),
                      ),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 7),
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image: AssetImage('images/home-image.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 7),
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image: AssetImage('images/home-image.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 7, horizontal: 7),
                              child: Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  image: DecorationImage(
                                    image: AssetImage('images/home-image.jpg'),
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      )
                    ],
                  );
                } else {
                  return Text('data');
                }
              }),
        ),
      ),
    );
  }
}
