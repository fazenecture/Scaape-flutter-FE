import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swipper/flutter_card_swiper.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scaape/utils/location.dart';
import 'package:scaape/utils/ui_components.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class HomePageView extends StatefulWidget {
  static String id = 'homePage';
  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView> {
  Location _location = Location();
  String longitude = '';
  String latitude = '';
  String cityName = '';
  var dbRef = FirebaseDatabase.instance.reference().child('Scaapes');

  getCurrentLocation() async {
    Position position = await _location.getCurrentLocation();
    setState(() {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
    print(latitude);

  }

  getCityNameFromLatLong(String lat, String long) async {
    http.Response response = await http.get(Uri.parse(
        'http://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$long&limit=1&appid=0bc99a1469e0265da6ffacbf340e4e35'));
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      return data[0]['name'];
    } else {
      return null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    double medq = MediaQuery.of(context).size.height;
    // initState(){
    //   super.initState();
    //   if (_auth != null) {
    //   print('jdncd');
    //   }
    //   else{
    //
    //   }
    // }
    final _auth = FirebaseAuth.instance;
    Future<User?> getCurrentUser() async {
      FirebaseAuth.instance.authStateChanges().listen((User? user) {
        if (user == null) {
          print('User is currently signed out!');
        } else {
          print(user.email);
          print(user.photoURL);
          print(user.phoneNumber);
          print('User is signed in!');
          print(user.displayName);
        }
      });
    }

    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10),
                  child: Text(
                    'Scaape',
                    style: TextStyle(
                      fontFamily: 'TheSecret',
                      fontSize: medq * 0.055,
                      color: const Color(0xffffffff),
                    ),
                    textAlign: TextAlign.left,
                  ),
                ),
                FutureBuilder(
                    future: getCityNameFromLatLong(latitude, longitude),
                    builder: (context, snap) {
                      if (snap.connectionState == ConnectionState.waiting) {
                        return Image(
                          image: AssetImage('animations/location-loader.gif'),
                          height: 60,
                          width: 60,
                        );
                      } else {
                        if (snap.hasData) {
                          return Padding(
                            padding: const EdgeInsets.only(
                                top: 5, bottom: 5, right: 10),
                            child: Row(
                              children: [
                                Text(
                                  '${snap.data}',
                                  style: TextStyle(
                                    fontSize: medq * 0.025,
                                    color: const Color(0xffffffff),
                                  ),
                                  textAlign: TextAlign.left,
                                ),
                                Icon(
                                  Icons.location_pin,
                                  size: 30,
                                  color: Color(0xFFFF4265),
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Image(
                            image: AssetImage('animations/location-loader.gif'),
                            height: 60,
                            width: 60,
                          );
                        }
                      }
                    })
              ],
            ),
            SearchBoxContainer(medq: medq),
            SizedBox(
              height: 10,
            ),
            // SingleChildScrollView(
            //   scrollDirection: Axis.horizontal,
            //   physics: BouncingScrollPhysics(),
            //   child: Padding(
            //     padding: const EdgeInsets.all(8.0),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //       children: [
            //         HomeButtons(
            //           medq: medq,
            //           icon: FontAwesomeIcons.chartLine,
            //           buttontext: 'Trending',
            //         ),
            //         SizedBox(
            //           width: 10,
            //         ),
            //         HomeButtons(
            //           medq: medq,
            //           icon: FontAwesomeIcons.history,
            //           buttontext: 'Recent',
            //         ),
            //         SizedBox(
            //           width: 10,
            //         ),
            //         HomeButtons(
            //           medq: medq,
            //           icon: FontAwesomeIcons.thumbsUp,
            //           buttontext: 'Recommended',
            //         ),
            //         SizedBox(
            //           width: 10,
            //         ),
            //       ],
            //     ),
            //   ),
            // ),
            FutureBuilder(
              future: dbRef.once(),
              builder: (_, AsyncSnapshot snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                } else {
                  if (snapshot.data.value != null) {
                    List list = [];
                    List timeStampList = [];
                    List valueList = [];
                    var data = snapshot.data.value;
                    print(list);
                    data.forEach((key, value) {
                      timeStampList.add(key);
                      valueList.add(value);
                    });
                    // return Column(children: valueList.map<Widget>((){}),)
                    return Container(
                      height: medq * 0.9,
                      child: ListView.builder(
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            return GestureDetector(
                              onTap: _showBottomSheet,
                              child: TrendingCards(
                                medq: medq,
                                title: valueList[index]["Name"],
                                imageUrl: valueList[index]["Image"],
                                description: valueList[index]["Desc"],
                              ),
                            );
                          }),
                    );
                    // return GestureDetector(
                    //   onTap: _showBottomSheet,
                    //   child: TrendingCards(
                    //     medq: medq,
                    //     title: 'Road Trip',
                    //     description:
                    //         'Lorem ipsum dolor sit amet,\n consectetur adipiscing elit,\nsed do eiusmod tempor incididunt ut …..',
                    //     username: '@pasissontraveller',
                    //   ),
                    // );
                  } else {
                    return Text('Sorry We Encountered an Error');
                  }
                }
              },
            ),
            SizedBox(
              height: 50,
            )
          ],
        ),
      ),
    );
  }

  _showBottomSheet() {
    showMaterialModalBottomSheet(
      // expand: true,
      context: context,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.80,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: MediaQuery.of(context).size.height / 2,
                child: Image.network(
                  "http://via.placeholder.com/350x150",
                  fit: BoxFit.fill,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 20.0, left: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Color(0xFFFF4B2B).withOpacity(0.5),
                      child: CircleAvatar(
                        backgroundImage: AssetImage('images/profile-photo.jpg'),
                        backgroundColor: Colors.transparent,
                        radius: 25,
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Road Trip',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: MediaQuery.of(context).size.height * 0.03,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '@pasissontraveller',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            color: const Color(0xfff5f6f9),
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.left,
                        )
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 10),
                child: Text(
                  'Dhriti Sharma',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: MediaQuery.of(context).size.height * 0.022,
                    color: const Color(0xfff5f6f9),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, left: 10),
                child: Text(
                  'Lorem ipsum dolor sit amet, consectetur \nadipiscing elit, sed do eiusmod tempor \nincididunt ut labore.',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: MediaQuery.of(context).size.height * 0.024,
                    color: const Color(0xfff5f6f9),
                    fontWeight: FontWeight.w300,
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 5.0, left: 10),
                child: Row(
                  children: [
                    Icon(Icons.location_pin),
                    Text(
                      'Delhi, India',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: MediaQuery.of(context).size.height * 0.024,
                        color: const Color(0xfff5f6f9),
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.left,
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0, left: 10),
                child: Text(
                  'People Joined',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: MediaQuery.of(context).size.height * 0.024,
                    color: const Color(0xfff5f6f9),
                  ),
                  textAlign: TextAlign.left,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFFF4B2B).withOpacity(0.5),
                      child: CircleAvatar(
                        backgroundImage: AssetImage('images/profile-photo.jpg'),
                        backgroundColor: Colors.transparent,
                        radius: 20,
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dhriti',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize:
                                MediaQuery.of(context).size.height * 0.023,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          '@pasissontraveller',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: MediaQuery.of(context).size.height * 0.02,
                            color: const Color(0xfff5f6f9),
                            fontWeight: FontWeight.w300,
                          ),
                          textAlign: TextAlign.left,
                        )
                      ],
                    ),
                  ],
                ),
              ),

              // Swiper(
              //   itemBuilder:
              //       (BuildContext context, int index) {
              //     return new Image.network(
              //       "http://via.placeholder.com/350x150",
              //       fit: BoxFit.fill,
              //     );
              //   },
              //   itemCount: 3,
              //   pagination: new SwiperPagination(),
              //   control: new SwiperControl(),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// Color(0xff222831)
