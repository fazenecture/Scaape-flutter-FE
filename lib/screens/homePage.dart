import 'dart:convert';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_card_swipper/flutter_card_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scaape/utils/constants.dart';
import 'package:scaape/utils/location.dart';
import 'package:scaape/utils/ui_components.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:recase/recase.dart';

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
  bool _enabled = true;
  var dbRef = FirebaseDatabase.instance.reference().child('Scaapes');
  final FirebaseAuth auther = FirebaseAuth.instance;
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
    Size medq = MediaQuery.of(context).size;
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
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10),
                    child: Row(
                      children: [
                        Image(
                          image: AssetImage('images/logo.png'),
                          height: 38,
                          width: 38,
                        ),
                        SizedBox(
                          width: medq.width * 0.009,
                        ),
                        Text(
                          'Scaape',
                          style: TextStyle(
                            fontFamily: 'TheSecret',
                            fontSize: medq.height * 0.045,
                            color: const Color(0xffffffff),
                          ),
                          textAlign: TextAlign.left,
                        ),
                      ],
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
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFF262930),
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(22))),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_pin,
                                        size: 23,
                                        color: ScaapeTheme.kPinkColor,
                                      ),
                                      Text(
                                        '${snap.data}',
                                        style: GoogleFonts.poppins(
                                          fontSize: medq.height * 0.0145,
                                          color: const Color(0xffffffff),
                                        ),
                                        // style: TextStyle(
                                        //   fontSize: medq.height * 0.025,
                                        //   color: const Color(0xffffffff),
                                        //
                                        // ),
                                        textAlign: TextAlign.left,
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          } else {
                            return Image(
                              image:
                              AssetImage('animations/location-loader.gif'),
                              height: 60,
                              width: 60,
                            );
                          }
                        }
                      })
                ],
              ),
              // SearchBoxContainer(medq: medq.height),
              SizedBox(
                height: 10,
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF416C),
                                    Color(0xFFFF4B2B)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              shape: BoxShape.circle),
                          height: 69,
                          width: 69,
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: Color(0xFFFF4B2B).withOpacity(0),
                            child: CircleAvatar(
                              backgroundImage:
                              AssetImage('images/profile-photo.jpg'),
                              backgroundColor: Colors.transparent,
                              radius: 31,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          'Cycling',
                          style: GoogleFonts.lato(
                            color: Color(0xFFF5F6F9),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: medq.width * 0.02,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF416C),
                                    Color(0xFFFF4B2B)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              shape: BoxShape.circle),
                          height: 69,
                          width: 69,
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: Color(0xFFFF4B2B).withOpacity(0),
                            child: CircleAvatar(
                              backgroundImage:
                              AssetImage('images/profile-photo.jpg'),
                              backgroundColor: Colors.transparent,
                              radius: 31,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          'Cycling',
                          style: GoogleFonts.lato(
                            color: Color(0xFFF5F6F9),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: medq.width * 0.02,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF416C),
                                    Color(0xFFFF4B2B)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              shape: BoxShape.circle),
                          height: 69,
                          width: 69,
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: Color(0xFFFF4B2B).withOpacity(0),
                            child: CircleAvatar(
                              backgroundImage:
                              AssetImage('images/profile-photo.jpg'),
                              backgroundColor: Colors.transparent,
                              radius: 31,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          'Cycling',
                          style: GoogleFonts.lato(
                            color: Color(0xFFF5F6F9),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: medq.width * 0.02,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF416C),
                                    Color(0xFFFF4B2B)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              shape: BoxShape.circle),
                          height: 69,
                          width: 69,
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: Color(0xFFFF4B2B).withOpacity(0),
                            child: CircleAvatar(
                              backgroundImage:
                              AssetImage('images/profile-photo.jpg'),
                              backgroundColor: Colors.transparent,
                              radius: 31,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          'Cycling',
                          style: GoogleFonts.lato(
                            color: Color(0xFFF5F6F9),
                          ),
                        )
                      ],
                    ),
                    SizedBox(
                      width: medq.width * 0.02,
                    ),
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFFF416C),
                                    Color(0xFFFF4B2B)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                              shape: BoxShape.circle),
                          height: 69,
                          width: 69,
                          child: CircleAvatar(
                            radius: 33,
                            backgroundColor: Color(0xFFFF4B2B).withOpacity(0),
                            child: CircleAvatar(
                              backgroundImage:
                              AssetImage('images/profile-photo.jpg'),
                              backgroundColor: Colors.transparent,
                              radius: 31,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 6,
                        ),
                        Text(
                          'Cycling',
                          style: GoogleFonts.lato(
                            color: Color(0xFFF5F6F9),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 9,
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

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Divider(
                  thickness: 0.2,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.0),
                            color: ScaapeTheme.kPinkColor.withOpacity(0.14)
                          // gradient: LinearGradient(
                          //   begin: Alignment(0.0, -1.0),
                          //   end: Alignment(0.0, 1.0),
                          //   colors: [const Color(0x24ff416c), const Color(0x24ff4b2b)],
                          //   stops: [0.0, 1.0],
                          // ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 19, vertical: 9),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 3.0),
                                // child: Icon(
                                //   icon,
                                //   size: 20,
                                //   color: ScaapeTheme.kPinkColor,
                                // ),
                                child: Image.asset(
                                  'images/trending.png',
                                  height: 25,
                                  width: 25,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Text(
                                'Trending',
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  color: ScaapeTheme.kPinkColor,
                                ),
                                // style: TextStyle(
                                //   fontFamily: 'Roboto',
                                //   fontSize: 12,
                                //   color: const ScaapeTheme.kPinkColor,
                                // ),
                                textAlign: TextAlign.left,
                              )
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: medq.width * 0.03,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14.0),
                          color: Color(0xFF393E46),
                          // gradient: LinearGradient(
                          //   begin: Alignment(0.0, -1.0),
                          //   end: Alignment(0.0, 1.0),
                          //   colors: [const Color(0x24ff416c), const Color(0x24ff4b2b)],
                          //   stops: [0.0, 1.0],
                          // ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 19, vertical: 9),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 3.0),
                                // child: Icon(
                                //   icon,
                                //   size: 20,
                                //   color: ScaapeTheme.kPinkColor,
                                // ),
                                child: Image.asset(
                                  'images/trending.png',
                                  height: 25,
                                  width: 25,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Text(
                                'Trending',
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  color: ScaapeTheme.kPinkColor,
                                ),
                                // style: TextStyle(
                                //   fontFamily: 'Roboto',
                                //   fontSize: 12,
                                //   color: const ScaapeTheme.kPinkColor,
                                // ),
                                textAlign: TextAlign.left,
                              )
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14.0),
                            color: ScaapeTheme.kPinkColor.withOpacity(0.14)
                          // gradient: LinearGradient(
                          //   begin: Alignment(0.0, -1.0),
                          //   end: Alignment(0.0, 1.0),
                          //   colors: [const Color(0x24ff416c), const Color(0x24ff4b2b)],
                          //   stops: [0.0, 1.0],
                          // ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 19, vertical: 9),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(right: 3.0),
                                // child: Icon(
                                //   icon,
                                //   size: 20,
                                //   color: ScaapeTheme.kPinkColor,
                                // ),
                                child: Image.asset(
                                  'images/trending.png',
                                  height: 25,
                                  width: 25,
                                  fit: BoxFit.fill,
                                ),
                              ),
                              Text(
                                'Trending',
                                style: GoogleFonts.lato(
                                  fontSize: 15,
                                  color: ScaapeTheme.kPinkColor,
                                ),
                                // style: TextStyle(
                                //   fontFamily: 'Roboto',
                                //   fontSize: 12,
                                //   color: const ScaapeTheme.kPinkColor,
                                // ),
                                textAlign: TextAlign.left,
                              )
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),

              // FutureBuilder(
              //   future: dbRef.once(),
              //   builder: (_, AsyncSnapshot snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return Center(
              //         child: Padding(
              //           padding: const EdgeInsets.all(10.0),
              //           child: Container(
              //             height: medq.height,
              //             width: medq.width,
              //             child: Column(
              //               children: <Widget>[
              //                 Expanded(
              //                   child: Shimmer.fromColors(
              //                     baseColor: Colors.white38,
              //                     highlightColor: Colors.white70,
              //                     enabled: _enabled,
              //                     child: ListView.builder(
              //                       itemBuilder: (_, __) => Padding(
              //                         padding: const EdgeInsets.only(bottom: 8.0),
              //                         child: Container(
              //                           decoration: BoxDecoration(
              //                               color: Color(0x5cffffff),
              //                               borderRadius:
              //                                   BorderRadius.circular(20)),
              //                           width: medq.width * 0.94,
              //                           height: medq.height * 0.3,
              //                         ),
              //                       ),
              //                       itemCount: 6,
              //                     ),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       );
              //     } else {
              //       if (snapshot.data.value != null) {
              //         List timeStampList = [];
              //         List valueList = [];
              //         var data = snapshot.data.value;
              //         data.forEach((key, value) {
              //           timeStampList.add(key);
              //           valueList.add(value);
              //         });
              //         return Column(
              //           children: valueList.map<Widget>((element) {
              //             return GestureDetector(
              //               onTap: _showBottomSheet,
              //               child: TrendingCards(
              //                   imageUrl: element["Image"],
              //                   medq: medq,
              //                   description: element["Desc"],
              //                   title: element["Name"]),
              //             );
              //           }).toList(),
              //         );
              //
              //         // return GestureDetector(
              //         //   onTap: _showBottomSheet,
              //         //   child: TrendingCards(
              //         //     medq: medq,
              //         //     title: 'Road Trip',
              //         //     description:
              //         //         'Lorem ipsum dolor sit amet,\n consectetur adipiscing elit,\nsed do eiusmod tempor incididunt ut …..',
              //         //     username: '@pasissontraveller',
              //         //   ),
              //         // );
              //       } else {
              //         return Text('Sorry We Encountered an Error');
              //       }
              //     }
              //   },
              // ),

              FutureBuilder(
                future: getScapesByAuth(auther.currentUser!.uid),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  print(auther.currentUser!.uid);
                  if(snapshot.hasData){
                    var a=snapshot.data;
                    print(a);
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      //itemCount: 1,
                      itemCount: snapshot.data.length,
                      shrinkWrap: true,
                      itemBuilder:(context, index) {
                        return HomeCard((){setState(() {});},
                            medq,a[index]["ScaapeImg"],a[index]["ScaapeName"],a[index]["Description"],a[index]["Location"],a[index]['UserId'],
                            a[index]["ScaapeId"],a[index]["ScaapePref"],a[index]["Admin"],a[index]["isPresent"],
                            a[index]["ScaapeDate"],a[index]["AdminName"],a[index]["AdminEmail"],a[index]["AdminDP"],a[index]["AdminGender"]);
                      },
                    );
                  }
                  else{
                    return Center(child: CircularProgressIndicator(),);
                  }
                },
              ),


              SizedBox(
                height: 50,
              )

            ],
          ),
        ),
      ),
    );
  }
  Future<List<dynamic>> getScapesByAuth(String id)async{


    String url='http://65.0.121.93:4000/api/getScaapesWithAuth/UserId=${id}';
    Response response=await get(Uri.parse(url));
    int statusCode = response.statusCode;
    print(statusCode);
    //print(json.decode(response.body));
    return json.decode(response.body);
  }
  _showBottomSheet() {
    double _sigmaX = 0.0; // from 0-10
    double _sigmaY = 0.0; // from 0-10
    double _opacity = 0.1; // from 0-1.0

    showMaterialModalBottomSheet(
      // expand: true,
      context: context,
      builder: (context) => Container(
        color: Color(0xff161A20),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.80,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.fill,
                alignment: Alignment.topCenter,
                image: NetworkImage(
                  "https://images.unsplash.com/photo-1600699260196-aca47e6d2125?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=748&q=80",
                ),
              ),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(23),
                topRight: Radius.circular(23),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   decoration: BoxDecoration(
                //     image: DecorationImage(
                //       fit: BoxFit.fill,
                //       image: NetworkImage(
                //         "https://images.unsplash.com/photo-1600699260196-aca47e6d2125?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=748&q=80",
                //       ),
                //     ),
                //   ),
                //   height: MediaQuery.of(context).size.height / 2,
                //   child: BackdropFilter(
                //     filter: ImageFilter.blur(
                //       sigmaX: _sigmaX,
                //       sigmaY: _sigmaY,
                //     ),
                //     child: Container(
                //       color: Colors.black.withOpacity(_opacity),
                //     ),
                //   ),
                // ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      height: 5,
                      width: 40,
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black38,
                              offset: Offset(-2, 0),
                              blurRadius: 10,
                            )
                          ],
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ),
                // SizedBox(
                //   height: MediaQuery.of(context).size.height * 0.35,
                // ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, left: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: Color(0xFFFF4B2B).withOpacity(0.5),
                        child: CircleAvatar(
                          backgroundImage:
                          AssetImage('images/profile-photo.jpg'),
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
                              fontSize:
                              MediaQuery.of(context).size.height * 0.03,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '@pasissontraveller',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize:
                              MediaQuery.of(context).size.height * 0.02,
                              color: const Color(0xfff5f6f9),
                              fontWeight: FontWeight.w500,
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
                      fontWeight: FontWeight.w600,
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
                      fontWeight: FontWeight.normal,
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
                          fontWeight: FontWeight.w400,
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
                  padding:
                  const EdgeInsets.only(top: 8.0, left: 10, bottom: 10),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: Color(0xFFFF4B2B).withOpacity(0.5),
                        child: CircleAvatar(
                          backgroundImage:
                          AssetImage('images/profile-photo.jpg'),
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
                              fontSize:
                              MediaQuery.of(context).size.height * 0.02,
                              color: const Color(0xfff5f6f9),
                              fontWeight: FontWeight.w400,
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
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  HomeCard(this.fun,this.medq,this.ScapeImage,this.ScapeName,this.ScapeDescription,
      this.Location,this.uid,this.scapeId,this.pref,this.admin,this.present,this.date,this.adminName,this.adminEmail,this.adminDp,this.adminGender);
  Function fun;
  final Size medq;
  String ScapeImage,ScapeName,ScapeDescription,Location,uid,scapeId,pref,admin,date,present,adminName,adminEmail,adminDp,adminGender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Container(
        height: medq.height * 0.3,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(8)),
          image: DecorationImage(
            image: NetworkImage(ScapeImage),
            fit: BoxFit.cover,
          ),
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
                gradient: LinearGradient(
                    colors: [
                      Color(0xFF1C1C1C).withOpacity(0.3),
                      Color(0xFF141414).withOpacity(0.87)
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment:CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20,vertical:18),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ScapeName.sentenceCase}',
                        style: GoogleFonts.lato(
                            fontSize: 21,
                            fontWeight: FontWeight.w500
                        ),


                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(8)),

                        ),
                        width: medq.width*0.56,
                        child: Text(
                          '${ScapeDescription.length>80?ScapeDescription.substring(0,80):ScapeDescription.sentenceCase}',
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,

                          style: GoogleFonts.nunitoSans(
                            fontSize: 12,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  child: BackdropFilter(
                    filter:
                    ImageFilter.blur(sigmaX: 17.0, sigmaY: 17.0),
                    child: Container(
                      height: medq.height * 0.07,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(8),
                            bottomRight: Radius.circular(8)),
                        color: Color(0xFF1C1C1C).withOpacity(0.89),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20),
                        child: Row(
                          mainAxisAlignment:
                          MainAxisAlignment.spaceBetween,
                          crossAxisAlignment:
                          CrossAxisAlignment.center,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            Color(0xFFFF416C),
                                            Color(0xFFFF4B2B)
                                          ],
                                          begin: Alignment.topCenter,
                                          end:
                                          Alignment.bottomCenter),
                                      shape: BoxShape.circle),
                                  height: 42,
                                  width: 42,
                                  child: CircleAvatar(
                                    // radius: 33,
                                    backgroundColor: Color(0xFFFF4B2B)
                                        .withOpacity(0),
                                    child: CircleAvatar(
                                      backgroundImage: NetworkImage('${adminDp}'),
                                      backgroundColor:
                                      Colors.transparent,
                                      // radius: 34,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: medq.width* 0.24,
                                      child: Text(
                                        '${adminName.titleCase}',
                                        maxLines: 1,
                                        softWrap: true,
                                        overflow: TextOverflow.clip,
                                        style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          size: 12,
                                        ),
                                        Text(
                                          '${Location.sentenceCase}',
                                          maxLines: 1,
                                          style: GoogleFonts.poppins(
                                              fontSize: 10,
                                              fontWeight:
                                              FontWeight.w400),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            (present=="True"||present=="true"||admin=="True"||admin=="true")?
                            OutlinedButton(
                              child: Text('    Join    '),
                              style: OutlinedButton.styleFrom(

                                primary: ScaapeTheme.kPinkColor,
                                side: BorderSide(
                                    color: ScaapeTheme.kPinkColor,
                                    width: 1),
                              ),
                              onPressed: () async{
                                String url='http://65.0.121.93:4000//api/createParticipant';
                                Map<String, String> headers = {
                                  "Content-type": "application/json"
                                };
                                String json = '{"ScaapeId": "${scapeId}","UserId": "${uid}","TimeStamp": "${DateTime.now().millisecondsSinceEpoch}","Accepted":"${1}"}';
                                http.Response response = await post(Uri.parse(url), headers: headers, body: json);
                                //print(user.displayName);
                                int statusCode = response.statusCode;
                                print(statusCode);
                                print(response.body);
                                Fluttertoast.showToast(msg: "Succesfully joined",);
                                fun();
                              },
                            )
                                :
                            OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  primary: ScaapeTheme.kPinkColor,
                                  side: BorderSide(
                                      color: ScaapeTheme.kPinkColor,
                                      width: 1),
                                ),
                                onPressed: () {
                                },
                                child: Text('  Joined  '))
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ScaapeTheme.kBackColor

// import 'dart:convert';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_card_swipper/flutter_card_swiper.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:scaape/utils/location.dart';
// import 'package:scaape/utils/ui_components.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;

// class HomePageView extends StatefulWidget {
//   static String id = 'homePage';
//   @override
//   _HomePageViewState createState() => _HomePageViewState();
// }

// class _HomePageViewState extends State<HomePageView> {
//   Location _location = Location();
//   String longitude = '';
//   String latitude = '';
//   String cityName = '';
//   var dbRef = FirebaseDatabase.instance.reference().child('Scaapes');

//   getCurrentLocation() async {
//     Position position = await _location.getCurrentLocation();
//     setState(() {
//       latitude = position.latitude.toString();
//       longitude = position.longitude.toString();
//     });
//     print(latitude);

//   }

//   getCityNameFromLatLong(String lat, String long) async {
//     http.Response response = await http.get(Uri.parse(
//         'http://api.openweathermap.org/geo/1.0/reverse?lat=$lat&lon=$long&limit=1&appid=0bc99a1469e0265da6ffacbf340e4e35'));
//     if (response.statusCode == 200) {
//       var data = jsonDecode(response.body);
//       return data[0]['name'];
//     } else {
//       return null;
//     }
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     getCurrentLocation();
//   }

//   @override
//   Widget build(BuildContext context) {
//     double medq = MediaQuery.of(context).size.height;
//     // initState(){
//     //   super.initState();
//     //   if (_auth != null) {
//     //   print('jdncd');
//     //   }
//     //   else{
//     //
//     //   }
//     // }
//     final _auth = FirebaseAuth.instance;
//     Future<User?> getCurrentUser() async {
//       FirebaseAuth.instance.authStateChanges().listen((User? user) {
//         if (user == null) {
//           print('User is currently signed out!');
//         } else {
//           print(user.email);
//           print(user.photoURL);
//           print(user.phoneNumber);
//           print('User is signed in!');
//           print(user.displayName);
//         }
//       });
//     }

//     return SafeArea(
//       child: SingleChildScrollView(
//         physics: BouncingScrollPhysics(),
//         child: Column(
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Padding(
//                   padding: const EdgeInsets.only(top: 5, bottom: 5, left: 10),
//                   child: Text(
//                     'Scaape',
//                     style: TextStyle(
//                       fontFamily: 'TheSecret',
//                       fontSize: medq * 0.055,
//                       color: const Color(0xffffffff),
//                     ),
//                     textAlign: TextAlign.left,
//                   ),
//                 ),
//                 FutureBuilder(
//                     future: getCityNameFromLatLong(latitude, longitude),
//                     builder: (context, snap) {
//                       if (snap.connectionState == ConnectionState.waiting) {
//                         return Image(
//                           image: AssetImage('animations/location-loader.gif'),
//                           height: 60,
//                           width: 60,
//                         );
//                       } else {
//                         if (snap.hasData) {
//                           return Padding(
//                             padding: const EdgeInsets.only(
//                                 top: 5, bottom: 5, right: 10),
//                             child: Row(
//                               children: [
//                                 Text(
//                                   '${snap.data}',
//                                   style: TextStyle(
//                                     fontSize: medq * 0.025,
//                                     color: const Color(0xffffffff),
//                                   ),
//                                   textAlign: TextAlign.left,
//                                 ),
//                                 Icon(
//                                   Icons.location_pin,
//                                   size: 30,
//                                   color: ScaapeTheme.kPinkColor,
//                                 ),
//                               ],
//                             ),
//                           );
//                         } else {
//                           return Image(
//                             image: AssetImage('animations/location-loader.gif'),
//                             height: 60,
//                             width: 60,
//                           );
//                         }
//                       }
//                     })
//               ],
//             ),
//             SearchBoxContainer(medq: medq),
//             SizedBox(
//               height: 10,
//             ),

//             FutureBuilder(
//               future: dbRef.once(),
//               builder: (_, AsyncSnapshot snapshot) {
//                 if (snapshot.connectionState == ConnectionState.waiting) {
//                   return CircularProgressIndicator();
//                 } else {
//                   if (snapshot.data.value != null) {
//                     List list = [];
//                     List timeStampList = [];
//                     List valueList = [];
//                     var data = snapshot.data.value;
//                     print(list);
//                     data.forEach((key, value) {
//                       timeStampList.add(key);
//                       valueList.add(value);
//                     });
//                     // return Column(children: valueList.map<Widget>((){}),)
//                     return Container(
//                       height: medq * 0.9,
//                       child: ListView.builder(
//                           itemCount: data.length,
//                           itemBuilder: (context, index) {
//                             return GestureDetector(
//                               onTap: _showBottomSheet,
//                               child: TrendingCards(
//                                 medq: medq,
//                                 title: valueList[index]["Name"],
//                                 imageUrl: valueList[index]["Image"],
//                                 description: valueList[index]["Desc"],
//                               ),
//                             );
//                           }),
//                     );
//                     // return GestureDetector(
//                     //   onTap: _showBottomSheet,
//                     //   child: TrendingCards(
//                     //     medq: medq,
//                     //     title: 'Road Trip',
//                     //     description:
//                     //         'Lorem ipsum dolor sit amet,\n consectetur adipiscing elit,\nsed do eiusmod tempor incididunt ut …..',
//                     //     username: '@pasissontraveller',
//                     //   ),
//                     // );
//                   } else {
//                     return Text('Sorry We Encountered an Error');
//                   }
//                 }
//               },
//             ),
//             SizedBox(
//               height: 50,
//             )
//           ],
//         ),
//       ),
//     );
//   }

//   _showBottomSheet() {
//     showMaterialModalBottomSheet(
//       // expand: true,
//       context: context,
//       builder: (context) => Container(
//         height: MediaQuery.of(context).size.height * 0.80,
//         child: SingleChildScrollView(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 height: MediaQuery.of(context).size.height / 2,
//                 child: Image.network(
//                   "http://via.placeholder.com/350x150",
//                   fit: BoxFit.fill,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 20.0, left: 10),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 28,
//                       backgroundColor: Color(0xFFFF4B2B).withOpacity(0.5),
//                       child: CircleAvatar(
//                         backgroundImage: AssetImage('images/profile-photo.jpg'),
//                         backgroundColor: Colors.transparent,
//                         radius: 25,
//                       ),
//                     ),
//                     SizedBox(
//                       width: 5,
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Road Trip',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: MediaQuery.of(context).size.height * 0.03,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Text(
//                           '@pasissontraveller',
//                           style: TextStyle(
//                             fontFamily: 'Roboto',
//                             fontSize: MediaQuery.of(context).size.height * 0.02,
//                             color: const Color(0xfff5f6f9),
//                             fontWeight: FontWeight.w300,
//                           ),
//                           textAlign: TextAlign.left,
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0, left: 10),
//                 child: Text(
//                   'Dhriti Sharma',
//                   style: TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: MediaQuery.of(context).size.height * 0.022,
//                     color: const Color(0xfff5f6f9),
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 5.0, left: 10),
//                 child: Text(
//                   'Lorem ipsum dolor sit amet, consectetur \nadipiscing elit, sed do eiusmod tempor \nincididunt ut labore.',
//                   style: TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: MediaQuery.of(context).size.height * 0.024,
//                     color: const Color(0xfff5f6f9),
//                     fontWeight: FontWeight.w300,
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 5.0, left: 10),
//                 child: Row(
//                   children: [
//                     Icon(Icons.location_pin),
//                     Text(
//                       'Delhi, India',
//                       style: TextStyle(
//                         fontFamily: 'Roboto',
//                         fontSize: MediaQuery.of(context).size.height * 0.024,
//                         color: const Color(0xfff5f6f9),
//                         fontWeight: FontWeight.w300,
//                       ),
//                       textAlign: TextAlign.left,
//                     )
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 16.0, left: 10),
//                 child: Text(
//                   'People Joined',
//                   style: TextStyle(
//                     fontFamily: 'Roboto',
//                     fontSize: MediaQuery.of(context).size.height * 0.024,
//                     color: const Color(0xfff5f6f9),
//                   ),
//                   textAlign: TextAlign.left,
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 8.0, left: 10),
//                 child: Row(
//                   children: [
//                     CircleAvatar(
//                       radius: 22,
//                       backgroundColor: Color(0xFFFF4B2B).withOpacity(0.5),
//                       child: CircleAvatar(
//                         backgroundImage: AssetImage('images/profile-photo.jpg'),
//                         backgroundColor: Colors.transparent,
//                         radius: 20,
//                       ),
//                     ),
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Dhriti',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize:
//                                 MediaQuery.of(context).size.height * 0.023,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Text(
//                           '@pasissontraveller',
//                           style: TextStyle(
//                             fontFamily: 'Roboto',
//                             fontSize: MediaQuery.of(context).size.height * 0.02,
//                             color: const Color(0xfff5f6f9),
//                             fontWeight: FontWeight.w300,
//                           ),
//                           textAlign: TextAlign.left,
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ),

//               // Swiper(
//               //   itemBuilder:
//               //       (BuildContext context, int index) {
//               //     return new Image.network(
//               //       "http://via.placeholder.com/350x150",
//               //       fit: BoxFit.fill,
//               //     );
//               //   },
//               //   itemCount: 3,
//               //   pagination: new SwiperPagination(),
//               //   control: new SwiperControl(),
//               // ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ScaapeTheme.kBackColor
