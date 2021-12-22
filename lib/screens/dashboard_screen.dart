import 'dart:convert';
import 'dart:ffi';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:custom_refresh_indicator/custom_refresh_indicator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_card_swipper/flutter_card_swiper.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:get/get_utils/src/extensions/string_extensions.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:progressive_image/progressive_image.dart';
import 'package:scaape/screens/chat_screen.dart';
import 'package:scaape/screens/create_scaape.dart';
import 'package:scaape/screens/search_screen.dart';
import 'package:scaape/screens/user_profile_screen.dart';
import 'package:scaape/screens/view_live_stream.dart';
import 'package:scaape/utils/constants.dart';
import 'package:scaape/utils/location_class.dart';
import 'package:dashed_circle/dashed_circle.dart';
import 'package:scaape/utils/ui_components.dart';
import 'package:geolocator/geolocator.dart';
import 'package:badges/badges.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:recase/recase.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'addScaape_screen.dart';
import 'live_streaming.dart';

class HomePageView extends StatefulWidget {
  static String id = 'homePage';

  @override
  _HomePageViewState createState() => _HomePageViewState();
}

class _HomePageViewState extends State<HomePageView>
    with TickerProviderStateMixin {
  final FirebaseAuth auth = FirebaseAuth.instance;
  IndicatorState? _prevState;
  Location _location = Location();
  String longitude = '';
  String latitude = '';
  String cityName = '';
  bool _enabled = true;
  String val = "";
  var dbRef = FirebaseDatabase.instance.reference().child('Scaapes');
  final FirebaseAuth auther = FirebaseAuth.instance;
  bool trending = false;
  bool recent = false;
  bool forYou = false;
  bool showFilter = false;
  late Animation gap;
  late Animation<double> base;
  late Animation<double> reverse;
  late AnimationController controller;
  late AnimationController controllerCafe;
  late AnimationController controllerTrek;
  late AnimationController controllerGym;
  late AnimationController controllerClub;
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = [];

  GlobalKey key = GlobalKey();
  GlobalKey _key1 = GlobalKey();
  GlobalKey _key2 = GlobalKey();
  GlobalKey _key3 = GlobalKey();

  getCurrentLocation() async {
    Position position = await _location.getCurrentLocation();
    setState(() {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
    // print(latitude);
  }
  String userProImage ='';

  Future<int> getUserDetails() async {
    String url =
        'https://api.scaape.online/api/getUserDetails/${auther.currentUser!
        .uid}';
    // print(url);
    http.Response response = await get(Uri.parse(url));
    int statusCode = response.statusCode;
    print("hello");
    var data = json.decode(response.body);

    print(data);
    var tStatus = await data[0]["showTutorial"];
    setState(() async{
      userProImage = await data[0]["ProfileImg"];
      print(userProImage);
    });
    print(tStatus);
    // if(tStatus){
    //   return true;
    // }else{
    //   return false;
    // }
    return tStatus;
  }
  Future getUserImage() async {
    String url =
        'https://api.scaape.online/api/getUserDetails/${auther.currentUser!
        .uid}';
    // print(url);
    http.Response response = await get(Uri.parse(url));
    int statusCode = response.statusCode;
    print("hello");
    var data = json.decode(response.body);

    print(data);
      userProImage = await data[0]["ProfileImg"];
      print(userProImage);

    // if(tStatus){
    //   return true;
    // }else{
    //   return false;
    // }
    return userProImage;
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
    controller =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    controllerCafe =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    controllerTrek =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    controllerClub =
        AnimationController(vsync: this, duration: Duration(seconds: 4));
    controllerGym =
        AnimationController(vsync: this, duration: Duration(seconds: 4));

    base = CurvedAnimation(parent: controller, curve: Curves.easeOut);
    reverse = Tween<double>(begin: 0.0, end: -1.0).animate(base);
    gap = Tween<double>(begin: 3.0, end: 0.0).animate(base)
      ..addListener(() {
        setState(() {});
      });
    // controller.forward();

    getUserImage().then((value){
      setState(() {
        userProImage = value;
      });
    });

    getUserDetails().then((value) {
      print(value);
      if (value == 1) {
        print("HOgaa");
        setState(() {
          initTargets();
          WidgetsBinding.instance!.addPostFrameCallback(_layout);
        });
      }
    });

    super.initState();
    getCurrentLocation();
  }

  //tutorial coach initTarget Function

  void _layout(_) {
    Future.delayed(Duration(milliseconds: 100));
    showTutorial();
  }

  void showTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: Colors.pink,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () async {
        String url = 'https://api.scaape.online/api/UpdateTutorial';
        Map<String, String> headers = {"Content-type": "application/json"};
        String json =
            '{"showTutorial": 0, "UserId" : "${auther.currentUser!.uid}" }';
        http.Response response =
        await post(Uri.parse(url), headers: headers, body: json);
        int statuscode = response.statusCode;
        print(statuscode);
        print(response.body);

        print("finish");
      },
      onClickTarget: (target) {
        print('onClickTarget: $target');
      },
      onSkip: () async {
        String url = 'https://api.scaape.online/api/UpdateTutorial';
        Map<String, String> headers = {"Content-type": "application/json"};
        String json =
            '{"showTutorial": 0, "UserId" : "${auther.currentUser!.uid}" }';
        http.Response response =
        await post(Uri.parse(url), headers: headers, body: json);
        int statuscode = response.statusCode;
        print(statuscode);
        print(response.body);
        print("skip");
      },
      onClickOverlay: (target) {
        print('onClickOverlay: $target');
      },
    )
      ..show();
  }

  void initTargets() {
    targets.add(TargetFocus(
      identify: "Target 0",
      keyTarget: _key1,
      color: ScaapeTheme.kSecondBlue,
      contents: [
        TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Click Here!!",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Text(
                    "To get started with your scaape",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.Circle,
      radius: 5,
    ));
    targets.add(TargetFocus(
      identify: "Target 1",
      keyTarget: _key2,
      color: ScaapeTheme.kSecondBlue,
      contents: [
        TargetContent(
            align: ContentAlign.bottom,
            child: Container(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Search your way",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 20.0),
                  ),
                  Text(
                    "Search for your fav Scaape",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ))
      ],
      shape: ShapeLightFocus.Circle,
      radius: 5,
    ));
  }


  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  static const _offsetToArmed = 150.0;


  PageController pageController = PageController(initialPage: 0);
  int pageChanged = 0;

  TextEditingController searchScaape = TextEditingController();
  var uid;


  bool _renderCompleteState = false;
  static const _indicatorSize = 150.0;
  final _helper = IndicatorStateHelper();
  ScrollDirection prevScrollDirection = ScrollDirection.idle;









  @override
  Widget build(BuildContext context) {
    uid = auth.currentUser!.uid;
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    Size medq = MediaQuery
        .of(context)
        .size;
    return ScrollConfiguration(
      behavior: ScrollBehavior(),
      child: GlowingOverscrollIndicator(
        color: ScaapeTheme.kBackColor.withOpacity(0.001),
        axisDirection: AxisDirection.left,
        child: PageView(
          controller: pageController,
          pageSnapping: true,
          scrollDirection: Axis.horizontal,
          physics: ClampingScrollPhysics(),
          onPageChanged: (index) {
            pageChanged = index;
            print(pageChanged);
          },
          children: [
            Scaffold(
              appBar: AppBar(
                automaticallyImplyLeading: false,
                foregroundColor: Colors.transparent,
                backgroundColor: ScaapeTheme.kBackColor,
                shadowColor: ScaapeTheme.kSecondBlue,
                elevation: 1,
                title: Padding(
                  padding: const EdgeInsets.only(top: 20, bottom: 0, left: 0),
                  child: Row(
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image(
                        image: AssetImage('images/logo.png'),
                        height: 32,
                        width: 32,
                      ),
                      SizedBox(
                        width: medq.width * 0.02,
                      ),
                      Text(
                        'Scaape',
                        style: TextStyle(
                          fontFamily: 'TheSecret',
                          fontSize: medq.height * 0.036,
                          color: const Color(0xffffffff),
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ],
                  ),
                ),
                actions: [
                  IconButton(
                      onPressed: () {
                        pageController.animateToPage(pageChanged + 2,
                            duration: Duration(milliseconds: 250),
                            curve: Curves.bounceInOut);
                      },
                      icon: Icon(
                        Icons.send_rounded,
                        color: ScaapeTheme.kSecondTextCollor,
                      ))
                ],
              ),
              body: CustomRefreshIndicator(
                offsetToArmed: _indicatorSize,
                child: SingleChildScrollView(
                  physics: BouncingScrollPhysics(),
                  keyboardDismissBehavior:
                  ScrollViewKeyboardDismissBehavior.onDrag,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 10, horizontal: 19),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, CameraApp.id);
                                },
                                child: TopCircleCards(
                                  circleImg: CircleAvatar(
                                    backgroundImage: AssetImage('images/dummy_image.png'),
                                    // backgroundColor: Colors.transparent,
                                    foregroundImage: NetworkImage(userProImage),
                                    radius: 31,
                                  ),
                                  text: 'You',
                                  base: base,
                                  controller: controller,
                                  reverse: reverse,
                                  backgroundColor: controller.isAnimating
                                      ? ScaapeTheme.kPinkColor.withOpacity(0)
                                      : ScaapeTheme.kPinkColor.withOpacity(0.8),
                                  dashes: controller.isAnimating ? 25 : 0,
                                )),
                            GestureDetector(
                                onTap: () {
                                  // Navigator.pushNamed(context, VideoApp.id);
                                },
                                child: TopCircleCards(
                                  circleImg: CircleAvatar(
                                    backgroundImage: AssetImage('images/dummy_image.png'),
                                    // backgroundColor: Colors.transparent,
                                    foregroundImage: NetworkImage(userProImage),
                                    radius: 31,
                                  ),
                                  text: 'You',
                                  base: base,
                                  controller: controller,
                                  reverse: reverse,
                                  backgroundColor: controller.isAnimating
                                      ? ScaapeTheme.kPinkColor.withOpacity(0)
                                      : ScaapeTheme.kPinkColor.withOpacity(0.8),
                                  dashes: controller.isAnimating ? 25 : 0,
                                )),

                          ],
                        ),
                        Container(
                          width: MediaQuery
                              .of(context)
                              .size
                              .width,
                          height: 65,
                          child: Row(
                            children: [
                              Flexible(
                                flex: 5,
                                child: TextFormField(
                                  key: _key2,
                                  onTap: () {
                                    Navigator.pushNamed(context, SearchPage.id);
                                  },
                                  onChanged: (value) {},
                                  controller: searchScaape,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter Scaape Name';
                                    }
                                    return null;
                                  },
                                  autofocus: false,
                                  readOnly: true,
                                  cursorColor: ScaapeTheme.kPinkColor,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    errorStyle: TextStyle(
                                      color: ScaapeTheme.kPinkColor,
                                      fontSize: 0,
                                    ),
                                    fillColor: ScaapeTheme.kTextFieldBlue,
                                    filled: true,
                                    contentPadding: const EdgeInsets.symmetric(
                                        vertical: 10.0, horizontal: 20.0),
                                    enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(7.0),
                                        borderSide: BorderSide.none),
                                    focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(7.0),
                                        borderSide: const BorderSide(
                                            width: 1,
                                            color: ScaapeTheme.kPinkColor)),
                                    errorBorder: OutlineInputBorder(
                                        borderRadius:
                                        BorderRadius.circular(7.0),
                                        borderSide: const BorderSide(
                                            width: 0,
                                            color: Colors.transparent)),
                                    border: InputBorder.none,
                                    hintText: "Search for Scaapes...",
                                    hintStyle: TextStyle(
                                      fontFamily: 'Roboto',
                                      fontSize:
                                      MediaQuery
                                          .of(context)
                                          .size
                                          .height *
                                          0.018,
                                      color: const Color(0x5cffffff),
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 14,
                              ),
                              Flexible(
                                  flex: 1,
                                  child: MaterialButton(
                                    onPressed: () {
                                      setState(() {
                                        if (showFilter == true) {
                                          showFilter = false;
                                        } else {
                                          showFilter = true;
                                        }
                                      });
                                    },
                                    color: ScaapeTheme.kPinkColor,
                                    height: 45,
                                    elevation: 0,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                    child: Icon(Icons.filter_list),
                                  ))
                            ],
                          ),
                        ),
                        // Filter Buttons
                        showFilter
                            ? Padding(
                          padding:
                          const EdgeInsets.symmetric(horizontal: 5),
                          child: Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  recent = false;
                                  forYou = false;
                                  trending = !trending;
                                  val = '';
                                  setState(() {});
                                },
                                child: TopCards(
                                  border: (trending)
                                      ? Border.all(
                                      color: ScaapeTheme.kPinkColor)
                                      : Border.all(
                                      color: Colors.transparent),
                                  medq: medq,
                                  img: Image.asset(
                                    'images/trend.png',
                                    height: medq.height * 0.02,
                                    // width: medq.width * 0.03,
                                    fit: BoxFit.fill,
                                  ),
                                  text: 'Trending',
                                  color: trending
                                      ? ScaapeTheme.kPinkColor
                                      .withOpacity(0.2)
                                      : ScaapeTheme.kSecondBlue,
                                  textcolor:
                                  ScaapeTheme.kSecondTextCollor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  trending = false;
                                  recent = !recent;
                                  forYou = false;
                                  val = '';
                                  setState(() {});
                                },
                                child: TopCards(
                                  medq: medq,
                                  border: recent
                                      ? Border.all(
                                      color: ScaapeTheme.kPinkColor)
                                      : Border.all(
                                      color: Colors.transparent),
                                  img: Image.asset(
                                    'images/recent.png',
                                    height: medq.height * 0.017,
                                    // width: medq.width * 0.03,
                                    fit: BoxFit.fill,
                                  ),
                                  text: 'Recent',
                                  color: recent
                                      ? ScaapeTheme.kPinkColor
                                      .withOpacity(0.2)
                                      : ScaapeTheme.kSecondBlue,
                                  textcolor:
                                  ScaapeTheme.kSecondTextCollor,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  trending = false;
                                  recent = false;
                                  forYou = !forYou;
                                  val = '';
                                  setState(() {});
                                },
                                child: TopCards(
                                  medq: medq,
                                  border: forYou
                                      ? Border.all(
                                      color: ScaapeTheme.kPinkColor)
                                      : Border.all(
                                      color: Colors.transparent),
                                  img: Image.asset(
                                    'images/recommendation.png',
                                    height: medq.height * 0.02,
                                    // width: medq.width * 0.03,
                                    fit: BoxFit.fill,
                                  ),
                                  text: 'For you',
                                  color: forYou
                                      ? ScaapeTheme.kPinkColor
                                      .withOpacity(0.2)
                                      : ScaapeTheme.kSecondBlue,
                                  textcolor:
                                  ScaapeTheme.kSecondTextCollor,
                                ),
                              ),
                            ],
                          ),
                        )
                            : Container(),
                        // Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   children: [
                        //
                        //     FutureBuilder(
                        //         future: getCityNameFromLatLong(latitude, longitude),
                        //         builder: (context, snap) {
                        //           if (snap.connectionState == ConnectionState.waiting) {
                        //             return Image(
                        //               image:
                        //                   AssetImage('animations/location-loader.gif'),
                        //               height: 60,
                        //               width: 60,
                        //             );
                        //           } else {
                        //             if (snap.hasData) {
                        //               return Padding(
                        //                 padding: const EdgeInsets.only(
                        //                     top: 5, bottom: 5, right: 10),
                        //                 child: Container(
                        //                   decoration: BoxDecoration(
                        //                       color: Color(0xFF262930),
                        //                       borderRadius: BorderRadius.all(
                        //                           Radius.circular(22))),
                        //                   child: Padding(
                        //                     padding: const EdgeInsets.symmetric(
                        //                         horizontal: 12, vertical: 6),
                        //                     child: Row(
                        //                       children: [
                        //                         Icon(
                        //                           Icons.location_pin,
                        //                           size: 23,
                        //                           color: ScaapeTheme.kPinkColor,
                        //                         ),
                        //                         Text(
                        //                           '${snap.data}',
                        //                           style: GoogleFonts.poppins(
                        //                             fontSize: medq.height * 0.0145,
                        //                             color: const Color(0xffffffff),
                        //                           ),
                        //                           // style: TextStyle(
                        //                           //   fontSize: medq.height * 0.025,
                        //                           //   color: const Color(0xffffffff),
                        //                           //
                        //                           // ),
                        //                           textAlign: TextAlign.left,
                        //                         )
                        //                       ],
                        //                     ),
                        //                   ),
                        //                 ),
                        //               );
                        //             } else {
                        //               return Image(
                        //                 image: AssetImage(
                        //                     'animations/location-loader.gif'),
                        //                 height: 60,
                        //                 width: 60,
                        //               );
                        //             }
                        //           }
                        //         })
                        //   ],
                        // ),
                        // SearchBoxContainer(medq: medq.height),
                        SizedBox(
                          height: 16,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, CreateScaape.id);
                          },
                          child: Container(
                            key: _key1,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: CachedNetworkImage(
                                imageUrl:
                                "https://scaape.online/scaape-banner.png",
                                fit: BoxFit.contain,
                              ),
                            ),
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.182,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: ScaapeTheme.kPinkColor,
                              borderRadius: BorderRadius.circular(16),
                              // image: DecorationImage(
                              //   image: NetworkImage(
                              //       'https://scaape.online/scaape-banner.png'),
                              //   fit: BoxFit.contain,
                              // )
                            ),
                          ),
                        ),

                        // Trending Scaapes
                        // SingleChildScrollView(
                        //   scrollDirection: Axis.horizontal,
                        //   child: Row(
                        //     children: [
                        //       GestureDetector(
                        //           onTap: () {
                        //             val = "Cycling";
                        //             trending = false;
                        //             recent = false;
                        //             forYou = false;
                        //             controller = AnimationController(
                        //               vsync: this,
                        //               duration: Duration(seconds: 3),
                        //             );
                        //             base = CurvedAnimation(
                        //                 parent: controller, curve: Curves.easeIn);
                        //             reverse = Tween<double>(begin: 0.0, end: -1.0)
                        //                 .animate(base);
                        //             gap = Tween<double>(begin: 4.0, end: 0.0)
                        //                 .animate(base)
                        //               ..addListener(() {
                        //                 setState(() {});
                        //               });
                        //             controller.forward();
                        //
                        //             setState(() {});
                        //           },
                        //           child: TopCircleCards(
                        //             circleImg: CircleAvatar(
                        //               backgroundImage: NetworkImage(
                        //                   'https://images.unsplash.com/photo-1541625247055-1a61cfa6a591?ixid=MnwxMjA3fDB8MHxzZWFyY2h8NXx8Y3ljbGluZ3xlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'),
                        //               // backgroundColor: Colors.transparent,
                        //               radius: 31,
                        //             ),
                        //             text: 'Cycling',
                        //             base: base,
                        //             controller: controller,
                        //             reverse: reverse,
                        //             backgroundColor: controller.isAnimating
                        //                 ? ScaapeTheme.kPinkColor.withOpacity(0)
                        //                 : ScaapeTheme.kPinkColor.withOpacity(0.8),
                        //             dashes: controller.isAnimating ? 25 : 0,
                        //           )),
                        //       GestureDetector(
                        //           onTap: () {
                        //             val = "Cafe";
                        //             trending = false;
                        //             recent = false;
                        //             forYou = false;
                        //             controllerCafe = AnimationController(
                        //               vsync: this,
                        //               duration: Duration(seconds: 3),
                        //             );
                        //             base = CurvedAnimation(
                        //                 parent: controllerCafe, curve: Curves.easeIn);
                        //             reverse = Tween<double>(begin: 0.0, end: -1.0)
                        //                 .animate(base);
                        //             gap = Tween<double>(begin: 4.0, end: 0.0)
                        //                 .animate(base)
                        //               ..addListener(() {
                        //                 setState(() {});
                        //               });
                        //             controllerCafe.forward();
                        //
                        //             setState(() {});
                        //           },
                        //           child: TopCircleCards(
                        //             circleImg: CircleAvatar(
                        //               backgroundImage: NetworkImage(
                        //                   'https://images.unsplash.com/photo-1445116572660-236099ec97a0?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y2FmZXxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'),
                        //               // backgroundColor: Colors.transparent,
                        //               radius: 31,
                        //             ),
                        //             text: 'Cafe',
                        //             base: base,
                        //             controller: controllerCafe,
                        //             reverse: reverse,
                        //             backgroundColor: controllerCafe.isAnimating
                        //                 ? ScaapeTheme.kPinkColor.withOpacity(0)
                        //                 : ScaapeTheme.kPinkColor.withOpacity(0.8),
                        //             dashes: controllerCafe.isAnimating ? 25 : 0,
                        //           )),
                        //       GestureDetector(
                        //           onTap: () {
                        //             val = "Trekking";
                        //             trending = false;
                        //             recent = false;
                        //             forYou = false;
                        //             controllerTrek = AnimationController(
                        //               vsync: this,
                        //               duration: Duration(seconds: 3),
                        //             );
                        //             base = CurvedAnimation(
                        //                 parent: controllerTrek, curve: Curves.easeIn);
                        //             reverse = Tween<double>(begin: 0.0, end: -1.0)
                        //                 .animate(base);
                        //             gap = Tween<double>(begin: 4.0, end: 0.0)
                        //                 .animate(base)
                        //               ..addListener(() {
                        //                 setState(() {});
                        //               });
                        //             controllerTrek.forward();
                        //
                        //             setState(() {});
                        //           },
                        //           child: TopCircleCards(
                        //             // key: _key2,
                        //             circleImg: CircleAvatar(
                        //               backgroundImage: NetworkImage(
                        //                   'https://images.unsplash.com/photo-1568454537842-d933259bb258?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dHJla2tpbmd8ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'),
                        //               // backgroundColor: Colors.transparent,
                        //               radius: 31,
                        //             ),
                        //             text: 'Trekking',
                        //             base: base,
                        //             controller: controllerTrek,
                        //             reverse: reverse,
                        //             backgroundColor: controllerTrek.isAnimating
                        //                 ? ScaapeTheme.kPinkColor.withOpacity(0)
                        //                 : ScaapeTheme.kPinkColor.withOpacity(0.8),
                        //             dashes: controllerTrek.isAnimating ? 25 : 0,
                        //           )),
                        //       GestureDetector(
                        //           onTap: () {
                        //             val = "Gym";
                        //             trending = false;
                        //             recent = false;
                        //             forYou = false;
                        //             controllerGym = AnimationController(
                        //               vsync: this,
                        //               duration: Duration(seconds: 3),
                        //             );
                        //             base = CurvedAnimation(
                        //                 parent: controllerGym, curve: Curves.easeIn);
                        //             reverse = Tween<double>(begin: 0.0, end: -1.0)
                        //                 .animate(base);
                        //             gap = Tween<double>(begin: 4.0, end: 0.0)
                        //                 .animate(base)
                        //               ..addListener(() {
                        //                 setState(() {});
                        //               });
                        //             controllerGym.forward();
                        //
                        //             setState(() {});
                        //           },
                        //           child: TopCircleCards(
                        //
                        //             key: _key1,
                        //             circleImg: CircleAvatar(
                        //               backgroundImage: NetworkImage(
                        //                   'https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTF8fGJlYWNofGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'),
                        //               // backgroundColor: Colors.transparent,
                        //               radius: 31,
                        //             ),
                        //             text: 'Gym',
                        //             base: base,
                        //             controller: controllerGym,
                        //             reverse: reverse,
                        //             backgroundColor: controllerGym.isAnimating
                        //                 ? ScaapeTheme.kPinkColor.withOpacity(0)
                        //                 : ScaapeTheme.kPinkColor.withOpacity(0.8),
                        //             dashes: controllerGym.isAnimating ? 25 : 0,
                        //           )),
                        //       GestureDetector(
                        //           onTap: () {
                        //             val = "Club";
                        //             trending = false;
                        //             recent = false;
                        //             forYou = false;
                        //             controllerClub = AnimationController(
                        //               vsync: this,
                        //               duration: Duration(seconds: 3),
                        //             );
                        //             base = CurvedAnimation(
                        //                 parent: controllerClub, curve: Curves.easeIn);
                        //             reverse = Tween<double>(begin: 0.0, end: -1.0)
                        //                 .animate(base);
                        //             gap = Tween<double>(begin: 4.0, end: 0.0)
                        //                 .animate(base)
                        //               ..addListener(() {
                        //                 setState(() {});
                        //               });
                        //             controllerClub.forward();
                        //
                        //             setState(() {});
                        //           },
                        //           child: TopCircleCards(
                        //             circleImg: CircleAvatar(
                        //               backgroundImage: NetworkImage(
                        //                   'https://images.unsplash.com/photo-1581968902132-d27ba6dd8b77?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTF8fGNsdWJiaW5nfGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'),
                        //               // backgroundColor: Colors.transparent,
                        //               radius: 31,
                        //             ),
                        //             text: 'Club',
                        //             base: base,
                        //             controller: controllerClub,
                        //             reverse: reverse,
                        //             backgroundColor: controllerClub.isAnimating
                        //                 ? ScaapeTheme.kPinkColor.withOpacity(0)
                        //                 : ScaapeTheme.kPinkColor.withOpacity(0.8),
                        //             dashes: controllerClub.isAnimating ? 25 : 0,
                        //           )),
                        //       // GestureDetector(
                        //       //     onTap: () {
                        //       //       val = "Cafe";
                        //       //       trending = false;
                        //       //       recent = false;
                        //       //       forYou = false;
                        //       //       controllerCafe = AnimationController(
                        //       //         vsync: this,
                        //       //         duration: Duration(seconds: 3),
                        //       //       );
                        //       //       base = CurvedAnimation(
                        //       //           parent: controllerCafe, curve: Curves.easeIn);
                        //       //       reverse = Tween<double>(begin: 0.0, end: -1.0)
                        //       //           .animate(base);
                        //       //       gap = Tween<double>(begin: 4.0, end: 0.0)
                        //       //           .animate(base)
                        //       //         ..addListener(() {
                        //       //           setState(() {});
                        //       //         });
                        //       //       controllerCafe.forward();
                        //       //
                        //       //       setState(() {});
                        //       //     },
                        //       //     child: TopCircleCards(
                        //       //       base: base,
                        //       //       controller: controllerCafe,
                        //       //       reverse: r everse,
                        //       //       backgroundColor: controllerCafe.isAnimating
                        //       //           ? ScaapeTheme.kPinkColor.withOpacity(0)
                        //       //           : ScaapeTheme.kPinkColor.withOpacity(0.8),
                        //       //       dashes: controllerCafe.isAnimating ? 25 : 0,
                        //       //     )),
                        //
                        //       //cricle conmment started
                        //       // GestureDetector(
                        //       //   onTap: () {
                        //       //     val = "Cafe";
                        //       //     trending = false;
                        //       //     recent = false;
                        //       //     forYou = false;
                        //       //     setState(() {
                        //       //
                        //       //     });
                        //       //   },
                        //       //   child: CircleCards(
                        //       //     circleImg: CircleAvatar(
                        //       //       backgroundImage: NetworkImage(
                        //       //           'https://images.unsplash.com/photo-1445116572660-236099ec97a0?ixid=MnwxMjA3fDB8MHxzZWFyY2h8Mnx8Y2FmZXxlbnwwfHwwfHw%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'),
                        //       //       // backgroundColor: Colors.transparent,
                        //       //       radius: 31,
                        //       //     ),
                        //       //     text: 'Cafe',
                        //       //     base: base,
                        //       //     reverse: reverse,
                        //       //     gap: gap.value,
                        //       //   ),
                        //       // ),
                        //       // GestureDetector(
                        //       //   onTap: () {
                        //       //     val = "Trekking";
                        //       //     trending = false;
                        //       //     recent = false;
                        //       //     forYou = false;
                        //       //     setState(() {
                        //       //
                        //       //     });
                        //       //   },
                        //       //   child: CircleCards(
                        //       //     circleImg: CircleAvatar(
                        //       //       backgroundImage: NetworkImage(
                        //       //           'https://images.unsplash.com/photo-1568454537842-d933259bb258?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MXx8dHJla2tpbmd8ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'),
                        //       //       // backgroundColor: Colors.transparent,
                        //       //       radius: 31,
                        //       //     ),
                        //       //     text: 'Trekking',
                        //       //     base: base,
                        //       //     reverse: reverse,
                        //       //     gap: gap.value,
                        //       //   ),
                        //       // ),
                        //       // GestureDetector(
                        //       //   onTap: () {
                        //       //     trending = false;
                        //       //     recent = false;
                        //       //     forYou = false;
                        //       //     val = "Gym";
                        //       //     setState(() {
                        //       //
                        //       //     });
                        //       //   },
                        //       //   child: CircleCards(
                        //       //     circleImg: CircleAvatar(
                        //       //       backgroundImage: NetworkImage(
                        //       //           'https://images.unsplash.com/photo-1506953823976-52e1fdc0149a?ixid=MnwxMjA3fDB8MHxzZWFyY2h8MTF8fGJlYWNofGVufDB8fDB8fA%3D%3D&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'),
                        //       //       // backgroundColor: Colors.transparent,
                        //       //       radius: 31,
                        //       //     ),
                        //       //     text: 'Gym',
                        //       //     base: base,
                        //       //     reverse: reverse,
                        //       //     gap: gap.value,
                        //       //   ),
                        //       // ),
                        //
                        //       //commentn ends for now
                        //
                        //       // GestureDetector(
                        //       //   onTap: () {
                        //       //     trending=false;
                        //       //     recent=false;
                        //       //     forYou=false;
                        //       //     val="Concert";
                        //       //     setState(() {
                        //       //
                        //       //     });
                        //       //   },
                        //       //   child: CircleCards(
                        //       //     circleImg: CircleAvatar(
                        //       //       backgroundImage: NetworkImage(
                        //       //           'https://images.unsplash.com/photo-1516450360452-9312f5e86fc7?ixid=MnwxMjA3fDB8MHxzZWFyY2h8N3x8cGFydHl8ZW58MHx8MHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60'),
                        //       //       // backgroundColor: Colors.transparent,
                        //       //       radius: 31,
                        //       //     ),
                        //       //     text: 'Concert',
                        //       //   ),
                        //       // ),
                        //     ],
                        //   ),
                        // ),
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

                        //TODO delete
                        // SingleChildScrollView(
                        //   scrollDirection: Axis.horizontal,
                        //   physics: BouncingScrollPhysics(),
                        //   child: Padding(
                        //     padding: const EdgeInsets.all(8.0),
                        //     child: Row(
                        //       mainAxisSize: MainAxisSize.max,
                        //       // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //       children: <Widget>[
                        //         Container(
                        //           decoration: BoxDecoration(
                        //               borderRadius: BorderRadius.circular(14.0),
                        //               color: ScaapeTheme.kPinkColor.withOpacity(0.14)
                        //             // gradient: LinearGradient(
                        //             //   begin: Alignment(0.0, -1.0),
                        //             //   end: Alignment(0.0, 1.0),
                        //             //   colors: [const Color(0x24ff416c), const Color(0x24ff4b2b)],
                        //             //   stops: [0.0, 1.0],
                        //             // ),
                        //           ),
                        //           child: Padding(
                        //             padding: const EdgeInsets.symmetric(
                        //                 horizontal: 19, vertical: 9),
                        //             child: Row(
                        //               mainAxisSize: MainAxisSize.min,
                        //               children: [
                        //                 Padding(
                        //                   padding: const EdgeInsets.only(right: 3.0),
                        //                   // child: Icon(
                        //                   //   icon,
                        //                   //   size: 20,
                        //                   //   color: ScaapeTheme.kPinkColor,
                        //                   // ),
                        //                   child: Image.asset(
                        //                     'images/trending.png',
                        //                     height: 25,
                        //                     width: 25,
                        //                     fit: BoxFit.fill,
                        //                   ),
                        //                 ),
                        //                 Text(
                        //                   'Trending',
                        //                   style: GoogleFonts.lato(
                        //                     fontSize: 15,
                        //                     color: ScaapeTheme.kPinkColor,
                        //                   ),
                        //                   // style: TextStyle(
                        //                   //   fontFamily: 'Roboto',
                        //                   //   fontSize: 12,
                        //                   //   color: const ScaapeTheme.kPinkColor,
                        //                   // ),
                        //                   textAlign: TextAlign.left,
                        //                 )
                        //               ],
                        //             ),
                        //           ),
                        //         ),
                        //         SizedBox(
                        //           width: medq.width * 0.03,
                        //         ),
                        //       ],
                        //     ),
                        //   ),
                        // ),

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
                        SizedBox(
                          height: 7,
                        ),
                        FutureBuilder(
                          future: getScapesByAuth(auther.currentUser!.uid,
                              trending, recent, forYou, val),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {
                            // print(auther.currentUser!.uid);
                            if (snapshot.hasData) {
                              var a = snapshot.data;

                              // print(a);
                              return ListView.builder(
                                physics: NeverScrollableScrollPhysics(),
                                //itemCount: 1,
                                itemCount: snapshot.data.length,
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  var test = snapshot.data[index]['Scaape'];

                                  return test == 'Trending'
                                      ? Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8),
                                    child: Container(
                                      child: Column(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                        MainAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            'Trending Scaapes',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight:
                                                FontWeight.w500),
                                          ),
                                          SizedBox(
                                            height: 12,
                                          ),
                                          Container(
                                            height: MediaQuery
                                                .of(context)
                                                .size
                                                .height *
                                                0.3,
                                            width: double.infinity,
                                            child: FutureBuilder(
                                              future: getTrendingScaapes(
                                                  auther
                                                      .currentUser!.uid),
                                              builder:
                                                  (BuildContext context,
                                                  AsyncSnapshot
                                                  snapshot) {
                                                if (snapshot.hasData) {
                                                  var tData =
                                                      snapshot.data;
                                                  return ListView.builder(
                                                      itemCount: snapshot
                                                          .data.length,
                                                      scrollDirection:
                                                      Axis.horizontal,
                                                      itemBuilder:
                                                          (context,
                                                          index) {
                                                        var tScaapeName =
                                                        tData[index][
                                                        'ScaapeName'];
                                                        var tScaapeImage =
                                                        tData[index][
                                                        'ScaapeImg'];
                                                        var tScaapeLocation =
                                                        tData[index][
                                                        'Location']
                                                            .toString();
                                                        var tScaapeId =
                                                        tData[index][
                                                        'ScaapeId'];
                                                        var tScaapeDesc =
                                                        tData[index][
                                                        'Description']
                                                            .toString();
                                                        var tSAdminName =
                                                        tData[index][
                                                        'AdminName']
                                                            .toString();
                                                        var tScaapeCount =
                                                        tData[index][
                                                        'count']
                                                            .toString();
                                                        var tSAdminImg = tData[
                                                        index]
                                                        [
                                                        'AdminDP']
                                                            .toString();
                                                        var tSAdminInsta =
                                                        tData[index][
                                                        'AdminInsta']
                                                            .toString();
                                                        var tScaapeDate =
                                                        tData[index][
                                                        'ScaapeDate']
                                                            .toString();
                                                        var present = tData[
                                                        index]
                                                        ['isPresent'];
                                                        var admin =
                                                        tData[index]
                                                        ['Admin'];

                                                        return Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .all(
                                                              8.0),
                                                          child:
                                                          GestureDetector(
                                                            onTap: () {
                                                              showModalBottomSheet<
                                                                  dynamic>(
                                                                  isScrollControlled:
                                                                  true,
                                                                  backgroundColor:
                                                                  ScaapeTheme
                                                                      .kBackColor,
                                                                  elevation:
                                                                  13,
                                                                  shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius
                                                                          .only(
                                                                          topRight: Radius
                                                                              .circular(
                                                                              16),
                                                                          topLeft: Radius
                                                                              .circular(
                                                                              16))),
                                                                  context:
                                                                  context,
                                                                  builder:
                                                                      (
                                                                      context) {
                                                                    return StatefulBuilder(
                                                                      builder:
                                                                          (
                                                                          BuildContext context,
                                                                          StateSetter setState) {
                                                                        return Container(
                                                                          height: MediaQuery
                                                                              .of(
                                                                              context)
                                                                              .size
                                                                              .height *
                                                                              0.7,
                                                                          child: Column(
                                                                            mainAxisAlignment: MainAxisAlignment
                                                                                .start,
                                                                            crossAxisAlignment: CrossAxisAlignment
                                                                                .start,
                                                                            children: [
                                                                              Stack(
                                                                                children: [
                                                                                  Container(
                                                                                    height: MediaQuery
                                                                                        .of(
                                                                                        context)
                                                                                        .size
                                                                                        .height *
                                                                                        0.4,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: BorderRadius
                                                                                          .only(
                                                                                          topRight: Radius
                                                                                              .circular(
                                                                                              16),
                                                                                          topLeft: Radius
                                                                                              .circular(
                                                                                              16)),
                                                                                      color: Colors
                                                                                          .white,
                                                                                      image: DecorationImage(
                                                                                        image: NetworkImage(
                                                                                            tScaapeImage),
                                                                                        fit: BoxFit
                                                                                            .cover,
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    height: MediaQuery
                                                                                        .of(
                                                                                        context)
                                                                                        .size
                                                                                        .height *
                                                                                        0.4,
                                                                                    decoration: BoxDecoration(
                                                                                        borderRadius: BorderRadius
                                                                                            .only(
                                                                                            topRight: Radius
                                                                                                .circular(
                                                                                                16),
                                                                                            topLeft: Radius
                                                                                                .circular(
                                                                                                16)),
                                                                                        gradient: LinearGradient(
                                                                                            colors: [
                                                                                              ScaapeTheme
                                                                                                  .kBackColor
                                                                                                  .withOpacity(
                                                                                                  0.2),
                                                                                              ScaapeTheme
                                                                                                  .kBackColor
                                                                                            ],
                                                                                            begin: Alignment
                                                                                                .topCenter,
                                                                                            end: Alignment
                                                                                                .bottomCenter)),
                                                                                  ),
                                                                                  Align(
                                                                                    alignment: Alignment
                                                                                        .topCenter,
                                                                                    child: Padding(
                                                                                      padding: const EdgeInsets
                                                                                          .all(
                                                                                          10.0),
                                                                                      child: Container(
                                                                                        height: 5.5,
                                                                                        width: MediaQuery
                                                                                            .of(
                                                                                            context)
                                                                                            .size
                                                                                            .width *
                                                                                            0.13,
                                                                                        decoration: BoxDecoration(
                                                                                            color: Colors
                                                                                                .white,
                                                                                            borderRadius: BorderRadius
                                                                                                .all(
                                                                                                Radius
                                                                                                    .circular(
                                                                                                    34))),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    height: MediaQuery
                                                                                        .of(
                                                                                        context)
                                                                                        .size
                                                                                        .height *
                                                                                        0.56,
                                                                                    child: Column(
                                                                                      mainAxisAlignment: MainAxisAlignment
                                                                                          .end,
                                                                                      crossAxisAlignment: CrossAxisAlignment
                                                                                          .start,
                                                                                      children: [
                                                                                        Padding(
                                                                                          padding: EdgeInsets
                                                                                              .symmetric(
                                                                                              horizontal: 23,
                                                                                              vertical: 18),
                                                                                          child: Column(
                                                                                            mainAxisSize: MainAxisSize
                                                                                                .min,
                                                                                            crossAxisAlignment: CrossAxisAlignment
                                                                                                .start,
                                                                                            children: [
                                                                                              Row(
                                                                                                crossAxisAlignment: CrossAxisAlignment
                                                                                                    .start,
                                                                                                mainAxisAlignment: MainAxisAlignment
                                                                                                    .spaceBetween,
                                                                                                children: [
                                                                                                  Container(
                                                                                                    width: MediaQuery
                                                                                                        .of(
                                                                                                        context)
                                                                                                        .size
                                                                                                        .width *
                                                                                                        0.6,
                                                                                                    child: Text(
                                                                                                      '${tScaapeName
                                                                                                          .toString()
                                                                                                          .sentenceCase}',
                                                                                                      style: GoogleFonts
                                                                                                          .lato(
                                                                                                          fontSize: 24,
                                                                                                          fontWeight: FontWeight
                                                                                                              .w500),
                                                                                                      maxLines: 2,
                                                                                                      softWrap: true,
                                                                                                      overflow: TextOverflow
                                                                                                          .clip,
                                                                                                    ),
                                                                                                  ),
                                                                                                  Container(
                                                                                                    child: Row(
                                                                                                      children: [
                                                                                                        Icon(
                                                                                                            Icons
                                                                                                                .group_outlined),
                                                                                                        Text(
                                                                                                          tScaapeCount
                                                                                                              .toString(),
                                                                                                          style: GoogleFonts
                                                                                                              .lato(
                                                                                                              fontSize: 21,
                                                                                                              fontWeight: FontWeight
                                                                                                                  .w500),
                                                                                                        )
                                                                                                      ],
                                                                                                    ),
                                                                                                  )
                                                                                                ],
                                                                                              ),
                                                                                              SizedBox(
                                                                                                height: MediaQuery
                                                                                                    .of(
                                                                                                    context)
                                                                                                    .size
                                                                                                    .height *
                                                                                                    0.014,
                                                                                              ),
                                                                                              GestureDetector(
                                                                                                onTap: () {
                                                                                                  String auth = FirebaseAuth
                                                                                                      .instance
                                                                                                      .currentUser!
                                                                                                      .uid;
                                                                                                  auth !=
                                                                                                      uid
                                                                                                      ? Navigator
                                                                                                      .pushNamed(
                                                                                                      context,
                                                                                                      UserProfileScreen
                                                                                                          .id,
                                                                                                      arguments: {
                                                                                                        "UserId": "${uid}"
                                                                                                      })
                                                                                                      : null;
                                                                                                },
                                                                                                child: Container(
                                                                                                  decoration: BoxDecoration(
                                                                                                    borderRadius: BorderRadius
                                                                                                        .all(
                                                                                                        Radius
                                                                                                            .circular(
                                                                                                            8)),
                                                                                                  ),
                                                                                                  width: MediaQuery
                                                                                                      .of(
                                                                                                      context)
                                                                                                      .size
                                                                                                      .width *
                                                                                                      0.56,
                                                                                                  child: Row(
                                                                                                    children: [
                                                                                                      Container(
                                                                                                        decoration: BoxDecoration(
                                                                                                            gradient: LinearGradient(
                                                                                                                colors: [
                                                                                                                  Color(
                                                                                                                      0xFFFF416C),
                                                                                                                  Color(
                                                                                                                      0xFFFF4B2B)
                                                                                                                ],
                                                                                                                begin: Alignment
                                                                                                                    .topCenter,
                                                                                                                end: Alignment
                                                                                                                    .bottomCenter),
                                                                                                            shape: BoxShape
                                                                                                                .circle),
                                                                                                        height: 42,
                                                                                                        width: 42,
                                                                                                        child: CircleAvatar(
                                                                                                          // radius: 33,
                                                                                                          backgroundColor: Color(
                                                                                                              0xFFFF4B2B)
                                                                                                              .withOpacity(
                                                                                                              0),
                                                                                                          child: CircleAvatar(
                                                                                                            backgroundImage: NetworkImage(
                                                                                                                '${tSAdminImg}'),
                                                                                                            backgroundColor: Colors
                                                                                                                .transparent,
                                                                                                            // radius: 34,
                                                                                                          ),
                                                                                                        ),
                                                                                                      ),
                                                                                                      SizedBox(
                                                                                                        width: 8,
                                                                                                      ),
                                                                                                      Column(
                                                                                                        crossAxisAlignment: CrossAxisAlignment
                                                                                                            .start,
                                                                                                        mainAxisAlignment: MainAxisAlignment
                                                                                                            .center,
                                                                                                        children: [
                                                                                                          Container(
                                                                                                            width: MediaQuery
                                                                                                                .of(
                                                                                                                context)
                                                                                                                .size
                                                                                                                .width *
                                                                                                                0.24,
                                                                                                            child: Text(
                                                                                                              '${tSAdminName
                                                                                                                  .titleCase}',
                                                                                                              maxLines: 1,
                                                                                                              softWrap: true,
                                                                                                              overflow: TextOverflow
                                                                                                                  .clip,
                                                                                                              style: GoogleFonts
                                                                                                                  .poppins(
                                                                                                                fontSize: 13,
                                                                                                                fontWeight: FontWeight
                                                                                                                    .w500,
                                                                                                              ),
                                                                                                              textAlign: TextAlign
                                                                                                                  .left,
                                                                                                            ),
                                                                                                          ),
                                                                                                          Text(
                                                                                                            '${tScaapeDate
                                                                                                                .toString()
                                                                                                                .substring(
                                                                                                                0,
                                                                                                                10)}',
                                                                                                            maxLines: 1,
                                                                                                            style: GoogleFonts
                                                                                                                .poppins(
                                                                                                                fontSize: 10,
                                                                                                                fontWeight: FontWeight
                                                                                                                    .w400),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                height: MediaQuery
                                                                                                    .of(
                                                                                                    context)
                                                                                                    .size
                                                                                                    .height *
                                                                                                    0.02,
                                                                                              ),
                                                                                              Container(
                                                                                                decoration: BoxDecoration(
                                                                                                  borderRadius: BorderRadius
                                                                                                      .all(
                                                                                                      Radius
                                                                                                          .circular(
                                                                                                          8)),
                                                                                                ),
                                                                                                width: MediaQuery
                                                                                                    .of(
                                                                                                    context)
                                                                                                    .size
                                                                                                    .width *
                                                                                                    0.75,
                                                                                                child: SingleChildScrollView(
                                                                                                  scrollDirection: Axis
                                                                                                      .vertical,
                                                                                                  child: Text(
                                                                                                    '${tScaapeDesc
                                                                                                        .length >
                                                                                                        80
                                                                                                        ? tScaapeDesc
                                                                                                        .substring(
                                                                                                        0,
                                                                                                        80)
                                                                                                        : tScaapeDesc
                                                                                                        .sentenceCase}',
                                                                                                    maxLines: 4,
                                                                                                    overflow: TextOverflow
                                                                                                        .ellipsis,
                                                                                                    softWrap: true,
                                                                                                    style: GoogleFonts
                                                                                                        .nunitoSans(
                                                                                                      fontSize: 17,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ),
                                                                                              SizedBox(
                                                                                                height: MediaQuery
                                                                                                    .of(
                                                                                                    context)
                                                                                                    .size
                                                                                                    .height *
                                                                                                    0.006,
                                                                                              ),
                                                                                              Row(
                                                                                                mainAxisAlignment: MainAxisAlignment
                                                                                                    .start,
                                                                                                children: [
                                                                                                  Icon(
                                                                                                    Icons
                                                                                                        .location_on_outlined,
                                                                                                    size: 12,
                                                                                                  ),
                                                                                                  Text(
                                                                                                    '${tScaapeLocation
                                                                                                        .sentenceCase}',
                                                                                                    maxLines: 1,
                                                                                                    style: GoogleFonts
                                                                                                        .poppins(
                                                                                                        fontSize: 10,
                                                                                                        fontWeight: FontWeight
                                                                                                            .w400),
                                                                                                  )
                                                                                                ],
                                                                                              ),
                                                                                            ],
                                                                                          ),
                                                                                        ),
                                                                                      ],
                                                                                    ),
                                                                                  ),
                                                                                  Container(
                                                                                    height: MediaQuery
                                                                                        .of(
                                                                                        context)
                                                                                        .size
                                                                                        .height *
                                                                                        0.67,
                                                                                    child: Align(
                                                                                      alignment: Alignment
                                                                                          .bottomCenter,
                                                                                      child: Padding(
                                                                                          padding: const EdgeInsets
                                                                                              .symmetric(
                                                                                              vertical: 12,
                                                                                              horizontal: 19),
                                                                                          child: (present ==
                                                                                              "True" ||
                                                                                              present ==
                                                                                                  "true" ||
                                                                                              admin ==
                                                                                                  "True" ||
                                                                                              admin ==
                                                                                                  "true")
                                                                                              ? MaterialButton(
                                                                                            onPressed: null,
                                                                                            elevation: 0,
                                                                                            textColor: Colors
                                                                                                .white,
                                                                                            splashColor: Colors
                                                                                                .transparent,
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius
                                                                                                  .all(
                                                                                                  Radius
                                                                                                      .circular(
                                                                                                      7)),
                                                                                            ),
                                                                                            disabledColor: ScaapeTheme
                                                                                                .kPinkColor
                                                                                                .withOpacity(
                                                                                                0.15),
                                                                                            disabledTextColor: ScaapeTheme
                                                                                                .kPinkColor,
                                                                                            color: ScaapeTheme
                                                                                                .kPinkColor
                                                                                                .withOpacity(
                                                                                                0.2),
                                                                                            height: MediaQuery
                                                                                                .of(
                                                                                                context)
                                                                                                .size
                                                                                                .height *
                                                                                                0.065,
                                                                                            minWidth: double
                                                                                                .infinity,
                                                                                            child: Text(
                                                                                              'YOU HAVE ALREADY JOINED',
                                                                                              style: GoogleFonts
                                                                                                  .roboto(
                                                                                                  color: ScaapeTheme
                                                                                                      .kPinkColor,
                                                                                                  fontSize: 17,
                                                                                                  fontWeight: FontWeight
                                                                                                      .w500),
                                                                                            ),
                                                                                          )
                                                                                              : MaterialButton(
                                                                                            onPressed: () async {
                                                                                              final FirebaseAuth auth = FirebaseAuth
                                                                                                  .instance;
                                                                                              String url = 'https://api.scaape.online/api/createParticipant';
                                                                                              Map<
                                                                                                  String,
                                                                                                  String> headers = {
                                                                                                "Content-type": "application/json"
                                                                                              };
                                                                                              String json = '{"ScaapeId": "${tScaapeId}","UserId": "${auth
                                                                                                  .currentUser!
                                                                                                  .uid}","TimeStamp": "${DateTime
                                                                                                  .now()
                                                                                                  .millisecondsSinceEpoch}","Accepted":"0"}';
                                                                                              http
                                                                                                  .Response response = await post(
                                                                                                  Uri
                                                                                                      .parse(
                                                                                                      url),
                                                                                                  headers: headers,
                                                                                                  body: json);
                                                                                              //print(user.displayName);
                                                                                              int statusCode = response
                                                                                                  .statusCode;
                                                                                              // print(statusCode);
                                                                                              // print(response.body);
                                                                                              Fluttertoast
                                                                                                  .showToast(
                                                                                                msg: "Succesfully joined",
                                                                                              );
                                                                                              // fun();
                                                                                            },
                                                                                            elevation: 0,
                                                                                            textColor: Colors
                                                                                                .white,
                                                                                            splashColor: ScaapeTheme
                                                                                                .kPinkColor,
                                                                                            shape: RoundedRectangleBorder(
                                                                                              borderRadius: BorderRadius
                                                                                                  .all(
                                                                                                  Radius
                                                                                                      .circular(
                                                                                                      7)),
                                                                                            ),
                                                                                            color: ScaapeTheme
                                                                                                .kPinkColor,
                                                                                            height: MediaQuery
                                                                                                .of(
                                                                                                context)
                                                                                                .size
                                                                                                .height *
                                                                                                0.065,
                                                                                            minWidth: double
                                                                                                .infinity,
                                                                                            child: Text(
                                                                                              'JOIN THIS SCAAPE',
                                                                                              style: GoogleFonts
                                                                                                  .roboto(
                                                                                                  color: Colors
                                                                                                      .white,
                                                                                                  fontSize: 17,
                                                                                                  fontWeight: FontWeight
                                                                                                      .w500),
                                                                                            ),
                                                                                          )),
                                                                                    ),
                                                                                  )
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                    );
                                                                  });
                                                            },
                                                            child:
                                                            Container(
                                                              decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius
                                                                      .circular(
                                                                      12),
                                                                  image: DecorationImage(
                                                                      image: NetworkImage(
                                                                          tScaapeImage),
                                                                      fit: BoxFit
                                                                          .cover),
                                                                  gradient: LinearGradient(
                                                                      colors: [
                                                                        ScaapeTheme
                                                                            .kShimmerColor
                                                                            .withOpacity(
                                                                            0.5),
                                                                        ScaapeTheme
                                                                            .kShimmerColor
                                                                            .withOpacity(
                                                                            1),
                                                                      ],
                                                                      begin: Alignment
                                                                          .topCenter,
                                                                      end: Alignment
                                                                          .bottomCenter)),
                                                              width: MediaQuery
                                                                  .of(context)
                                                                  .size
                                                                  .width *
                                                                  0.39,
                                                              child:
                                                              Stack(
                                                                children: [
                                                                  Container(
                                                                    decoration:
                                                                    BoxDecoration(
                                                                        color: ScaapeTheme
                                                                            .kBackColor
                                                                            .withOpacity(
                                                                            0.4)),
                                                                  ),
                                                                  Padding(
                                                                    padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        8.0),
                                                                    child:
                                                                    Column(
                                                                      crossAxisAlignment:
                                                                      CrossAxisAlignment
                                                                          .start,
                                                                      mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .end,
                                                                      children: [
                                                                        Text(
                                                                          tScaapeName
                                                                              .toString()
                                                                              .sentenceCase,
                                                                          style: TextStyle(
                                                                              fontSize: 16,
                                                                              fontWeight: FontWeight
                                                                                  .w500),
                                                                        ),
                                                                        Row(
                                                                          children: [
                                                                            Icon(
                                                                              Icons
                                                                                  .location_on_outlined,
                                                                              color: Colors
                                                                                  .white,
                                                                              size: 13,
                                                                            ),
                                                                            tScaapeLocation
                                                                                .length >
                                                                                13
                                                                                ? Text(
                                                                              '${tScaapeLocation
                                                                                  .substring(
                                                                                  0,
                                                                                  13)}...',
                                                                              style: TextStyle(
                                                                                  fontWeight: FontWeight
                                                                                      .w400,
                                                                                  fontSize: 13),
                                                                              overflow: TextOverflow
                                                                                  .ellipsis,
                                                                              softWrap: true,
                                                                              maxLines: 1,
                                                                            )
                                                                                : Text(
                                                                              '${tScaapeLocation
                                                                                  .sentenceCase}',
                                                                              style: TextStyle(
                                                                                  fontWeight: FontWeight
                                                                                      .w400,
                                                                                  fontSize: 13),
                                                                              overflow: TextOverflow
                                                                                  .ellipsis,
                                                                            ),
                                                                          ],
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      });
                                                } else {
                                                  return Container();
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      height: MediaQuery
                                          .of(context)
                                          .size
                                          .height *
                                          0.34,
                                      width: double.infinity,
                                    ),
                                  )
                                      : HomeCard(() {
                                    setState(() {});
                                  },
                                      medq,
                                      a[index]["ScaapeImg"],
                                      a[index]["ScaapeName"],
                                      a[index]["Description"],
                                      a[index]["Location"],
                                      a[index]['UserId'],
                                      a[index]["ScaapeId"],
                                      a[index]["ScaapePref"],
                                      a[index]["Admin"],
                                      a[index]["isPresent"],
                                      a[index]["ScaapeDate"],
                                      a[index]["AdminName"],
                                      a[index]["AdminEmail"],
                                      a[index]["AdminDP"],
                                      a[index]["AdminGender"],
                                      a[index]["ScaapeDate"],
                                      a[index]["count"],
                                      _key2);
                                },
                              );
                            } else {
                              return Column(
                                children: [
                                  ShimmerCard(medq: medq),
                                  ShimmerCard(medq: medq),
                                  ShimmerCard(medq: medq),
                                ],
                              );
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
                // onRefresh: () => Future.delayed(const Duration(seconds: 3)),
                onRefresh: () =>
                    Future.delayed(const Duration(seconds: 2)).then((value) {
                      setState(() {});
                    }),
                completeStateDuration: const Duration(seconds: 1),
                builder: (BuildContext context,
                    Widget child,
                    IndicatorController controller,) {
                  return Stack(
                    children: <Widget>[
                      AnimatedBuilder(
                        animation: controller,
                        builder: (BuildContext context, Widget? _) {
                          _helper.update(controller.state);
                          print(controller.state);
                          if (controller.scrollingDirection ==
                              ScrollDirection.reverse &&
                              prevScrollDirection == ScrollDirection.forward) {
                            controller.stopDrag();
                          }


                          prevScrollDirection = controller.scrollingDirection;


                          /// set [_renderCompleteState] to true when controller.state become completed
                          if (_helper.didStateChange(
                              to: IndicatorState.complete)) {
                            _renderCompleteState = true;

                            /// set [_renderCompleteState] to false when controller.state become idle
                          } else if (_helper.didStateChange(
                              to: IndicatorState.idle)) {
                            _renderCompleteState = false;
                          }
                          final containerHeight = controller.value *
                              _indicatorSize;

                          return controller.state != IndicatorState.idle
                              ? Container(
                            alignment: Alignment.center,
                            height: containerHeight,
                            child: OverflowBox(
                              maxHeight: 40,
                              minHeight: 40,
                              maxWidth: 40,
                              minWidth: 40,
                              alignment: Alignment.center,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                alignment: Alignment.center,
                                child: _renderCompleteState
                                    ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                )
                                    : SizedBox(
                                  height: 30,
                                  width: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor:
                                    AlwaysStoppedAnimation(
                                        ScaapeTheme.kPinkColor),
                                    value:
                                    controller.isDragging || controller.isArmed
                                        ? controller.value.clamp(0.0, 1.0)
                                        : null,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: _renderCompleteState
                                      ? ScaapeTheme.kPinkColor
                                      : ScaapeTheme.kShimmerColor,
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                          )
                              : Container();
                        },
                      ),
                      AnimatedBuilder(
                        builder: (context, _) {
                          return Transform.translate(
                            offset: Offset(
                                0.0, controller.value * _indicatorSize),
                            child: child,
                          );
                        },
                        animation: controller,
                      ),
                    ],
                  );
                },
              ),
            ),

            // Scaape Chat
            Scaffold(
              appBar: AppBar(
                foregroundColor: Colors.transparent,
                backgroundColor: ScaapeTheme.kBackColor,
                shadowColor: ScaapeTheme.kSecondBlue,
                elevation: 1,
                leading: IconButton(
                  splashColor: Colors.transparent,
                  splashRadius: 0.1,
                  icon: Icon(
                    CupertinoIcons.back,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    pageController.animateToPage(pageChanged - 2,
                        duration: Duration(milliseconds: 250),
                        curve: Curves.bounceInOut);
                  },
                ),
                title: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        'Social Messages',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 22,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushReplacementNamed(
                              context, CreateScaape.id);
                        },
                        child: Icon(
                          Icons.add_rounded,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              body: ScaapeChat(),
            ),
          ],
        ),
      ),
    );
  }

  Future<List<dynamic>> getScapesByAuth(String id, bool trend, bool rec,
      bool forU, String val) async {
    String url;
    // print("enter");
    // print(val.isEmpty);
    url =
    'https://api.scaape.online/api/getScaapesWithAuthAndScaape/UserId=${id}';
    if (val.isNotEmpty) {
      url =
      'https://api.scaape.online/api/getPrefScaapesWithAuth/UserId=${id}/Pref=${val}';
      // print("stories");
    } else {
      if (trend) {
        url =
        'https://api.scaape.online/api/getTrendingScaapesWithAuth/UserId=${id}';
        // print("trend clicked");
      } else if (rec) {
        url =
        'https://api.scaape.online/api/getLatestScaapesWithAuth/UserId=${id}';
        // print("recent clicked");
        // print("recent clicked");
      }
    }
    // print(url);
    var response = await get(Uri.parse(url));
    int statusCode = response.statusCode;
    // print(statusCode);
    //print(json.decode(response.body));
    return json.decode(response.body);
  }

  Future<List<dynamic>> getTrendingScaapes(String id) async {
    String url;
    // print("enter");
    // print(val.isEmpty);
    url =
    'https://api.scaape.online/api/getTrendingScaapesWithAuth/UserId=${id}';
    // print("trend clicked");
    // print(url);
    var response = await get(Uri.parse(url));
    int statusCode = response.statusCode;
    // print(statusCode);
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
      builder: (context) =>
          Container(
            color: Color(0xff161A20),
            child: SingleChildScrollView(
              physics: BouncingScrollPhysics(),
              child: Container(
                height: MediaQuery
                    .of(context)
                    .size
                    .height * 0.80,
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
                              AssetImage('images/dummy_image.png'),
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
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.03,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '@pasissontraveller',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize:
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.02,
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
                          fontSize: MediaQuery
                              .of(context)
                              .size
                              .height * 0.022,
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
                          fontSize: MediaQuery
                              .of(context)
                              .size
                              .height * 0.024,
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
                              fontSize: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.024,
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
                          fontSize: MediaQuery
                              .of(context)
                              .size
                              .height * 0.024,
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
                              AssetImage('images/dummy_image.png'),
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
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.023,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '@pasissontraveller',
                                style: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize:
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.02,
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

class TopCircleCards extends StatelessWidget {
  const TopCircleCards({Key? key,
    required this.base,
    required this.controller,
    required this.reverse,
    required this.backgroundColor,
    required this.dashes,
    required this.text,
    required this.circleImg})
      : super(key: key);

  final Animation<double> base;
  final AnimationController controller;
  final Animation<double> reverse;
  final dashes;
  final Color backgroundColor;
  final String text;
  final CircleAvatar circleImg;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //     colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter),
                shape: BoxShape.circle),
            height: 69,
            width: 69,
            child: RotationTransition(
              turns: base,
              child: DashedCircle(
                dashes: dashes,
                color: ScaapeTheme.kPinkColor,
                child: RotationTransition(
                  turns: reverse,
                  child: Badge(
                    toAnimate: false,
                    position: BadgePosition(
                      bottom: 0,
                      end: 0
                    ),
                    elevation: 5,
                    badgeContent: Icon(
                      CupertinoIcons.plus,
                      color: Colors.white,
                      size: 13,
                    ),
                    badgeColor: ScaapeTheme.kPinkColor,
                    child: CircleAvatar(
                      radius: 34,
                      backgroundColor: backgroundColor,
                      child: circleImg,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            text,
            style: GoogleFonts.lato(
              color: Color(0xFFF5F6F9),
            ),
          )
        ],
      ),
    );
  }
}

class _Cloud {
  static const _light = Color(0xFF96CDDE);
  static const _dark = Color(0xFF6AABBF);
  static const _normal = Color(0xFFACCFDA);

  static const _assets = [
    "images/cloud1.png",
    "images/cloud2.png",
    "images/cloud3.png",
    "images/cloud4.png",
  ];

  AnimationController? controller;
  final Color? color;
  final AssetImage? image;
  final double? width;
  final double? dy;
  final double? initialValue;
  final Duration? duration;

  _Cloud({
    this.color,
    this.image,
    this.width,
    this.dy,
    this.initialValue,
    this.duration,
  });
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({
    Key? key,
    required this.medq,
  }) : super(key: key);

  final Size medq;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: Container(
        height: medq.height * 0.25,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            color: ScaapeTheme.kShimmerColor),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  child: Shimmer.fromColors(
                    baseColor: ScaapeTheme.kShimmerColor.withOpacity(0.1),
                    highlightColor: ScaapeTheme.kShimmerTextColor,
                    period: Duration(milliseconds: 1900),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          color: ScaapeTheme.kShimmerTextColor,
                          height: 23,
                          width: medq.width * 0.35,
                        ),
                        SizedBox(
                          height: 4,
                        ),
                        Container(
                          color: ScaapeTheme.kShimmerTextColor,
                          height: 16,
                          width: medq.width * 0.25,
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Container(
                          color: ScaapeTheme.kShimmerTextColor,
                          height: 16,
                          width: medq.width * 0.28,
                        ),
                        SizedBox(
                          height: 2,
                        ),
                        Container(
                          color: ScaapeTheme.kShimmerTextColor,
                          height: 16,
                          width: medq.width * 0.2,
                        ),
                      ],
                    ),
                  ),
                ),
                Shimmer.fromColors(
                  baseColor: ScaapeTheme.kShimmerColor.withOpacity(0.1),
                  highlightColor: ScaapeTheme.kShimmerTextColor,
                  period: Duration(milliseconds: 1900),
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(8),
                        bottomRight: Radius.circular(8)),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 17.0, sigmaY: 17.0),
                      child: Container(
                        height: medq.height * 0.07,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(8),
                              bottomRight: Radius.circular(8)),
                          color: ScaapeTheme.kShimmerTextColor.withOpacity(0.4),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration:
                                    BoxDecoration(shape: BoxShape.circle),
                                    height: 42,
                                    width: 42,
                                    child: CircleAvatar(
                                      // radius: 33,
                                      backgroundColor:
                                      Color(0xFFFF4B2B).withOpacity(0),
                                      child: CircleAvatar(
                                        backgroundColor:
                                        ScaapeTheme.kShimmerTextColor,
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
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: medq.width * 0.24,
                                        height: 12,
                                        color: ScaapeTheme.kShimmerTextColor,
                                      ),
                                      SizedBox(
                                        height: 2,
                                      ),
                                      Container(
                                        width: medq.width * 0.14,
                                        height: 12,
                                        color: ScaapeTheme.kShimmerTextColor,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              Container(
                                width: medq.width * 0.2,
                                height: 29,
                                color: ScaapeTheme.kShimmerTextColor,
                              ),
                            ],
                          ),
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

class CircleCards extends StatelessWidget {
  const CircleCards({required this.text,
    required this.circleImg,
    required this.gap,
    required this.reverse,
    required this.base});

  final String text;
  final CircleAvatar circleImg;
  final Animation<double> base;
  final Animation<double> reverse;
  final Animation gap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              // gradient: LinearGradient(
              //     colors: [Color(0xFFFF416C), Color(0xFFFF4B2B)],
              //     begin: Alignment.topCenter,
              //     end: Alignment.bottomCenter),
                shape: BoxShape.circle),
            height: 69,
            width: 69,
            child: RotationTransition(
              turns: base,
              child: DashedCircle(
                dashes: 40,
                color: ScaapeTheme.kPinkColor,
                child: RotationTransition(
                  turns: reverse,
                  child: CircleAvatar(
                    radius: 33,
                    backgroundColor: Color(0xFFFF4B2B).withOpacity(0),
                    child: circleImg,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 6,
          ),
          Text(
            '$text',
            style: GoogleFonts.lato(
              color: Color(0xFFF5F6F9),
            ),
          )
        ],
      ),
    );
  }
}

class TopCards extends StatelessWidget {
  const TopCards({Key? key,
    required this.medq,
    required this.color,
    required this.img,
    required this.text,
    required this.textcolor,
    required this.border})
      : super(key: key);

  final Size medq;
  final String text;
  final Color color;
  final Image img;
  final Color textcolor;
  final Border border;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8, horizontal: 5),
      child: Container(
        // height: 34,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14.0),
            border: border,
            color: color
          // gradient: LinearGradient(
          //   begin: Alignment(0.0, -1.0),
          //   end: Alignment(0.0, 1.0),
          //   colors: [const Color(0x24ff416c), const Color(0x24ff4b2b)],
          //   stops: [0.0, 1.0],
          // ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: EdgeInsets.only(right: 4),
                child: img,
              ),
              Text(
                '$text',
                style: GoogleFonts.lato(
                  fontSize: medq.height * 0.015,
                  color: textcolor,
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
    );
  }
}

class HomeCard extends StatelessWidget {
  HomeCard(this.fun,
      this.medq,
      this.ScapeImage,
      this.ScapeName,
      this.ScapeDescription,
      this.Location,
      this.uid,
      this.scapeId,
      this.pref,
      this.admin,
      this.present,
      this.date,
      this.adminName,
      this.adminEmail,
      this.adminDp,
      this.adminGender,
      this.adminInsta,
      this.count,
      this.tKey);

  Function fun;
  final Size medq;
  String ScapeImage,
      ScapeName,
      ScapeDescription,
      Location,
      uid,
      scapeId,
      pref,
      admin,
      date,
      present,
      adminName,
      adminEmail,
      adminDp,
      adminGender,
      adminInsta;
  int count;
  Key tKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 0),
      child: GestureDetector(
        onTap: () async {
          //TODO:call on click
          final FirebaseAuth auth = FirebaseAuth.instance;
          if ((auth.currentUser!.uid) != uid) {
            onClick(scapeId);
          }
          showMaterialModalBottomSheet(
              backgroundColor: ScaapeTheme.kBackColor,
              context: context,
              elevation: 13,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                      topRight: Radius.circular(16),
                      topLeft: Radius.circular(16))),
              builder: (context) =>
                  Container(
                    height: MediaQuery
                        .of(context)
                        .size
                        .height * 0.7,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Container(
                              key: tKey,
                              height: medq.height * 0.4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    topLeft: Radius.circular(16)),
                                color: Colors.white,
                                image: DecorationImage(
                                  image: NetworkImage(ScapeImage),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Container(
                              height: medq.height * 0.4,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(16),
                                      topLeft: Radius.circular(16)),
                                  gradient: LinearGradient(
                                      colors: [
                                        ScaapeTheme.kBackColor.withOpacity(0.2),
                                        ScaapeTheme.kBackColor
                                      ],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter)),
                            ),
                            Align(
                              alignment: Alignment.topCenter,
                              child: Padding(
                                padding: const EdgeInsets.all(10.0),
                                child: Container(
                                  height: 5.5,
                                  width: medq.width * 0.13,
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(34))),
                                ),
                              ),
                            ),
                            Container(
                              height: medq.height * 0.56,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: 23, vertical: 18),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              width: medq.width * 0.6,
                                              child: Text(
                                                '${ScapeName.sentenceCase}',
                                                style: GoogleFonts.lato(
                                                    fontSize: 24,
                                                    fontWeight:
                                                    FontWeight.w500),
                                                maxLines: 2,
                                                softWrap: true,
                                                overflow: TextOverflow.clip,
                                              ),
                                            ),
                                            Container(
                                              child: Row(
                                                children: [
                                                  Icon(Icons.group_outlined),
                                                  Text(
                                                    count.toString(),
                                                    style: GoogleFonts.lato(
                                                        fontSize: 21,
                                                        fontWeight:
                                                        FontWeight.w500),
                                                  )
                                                ],
                                              ),
                                            )
                                          ],
                                        ),
                                        SizedBox(
                                          height: medq.height * 0.014,
                                        ),
                                        GestureDetector(
                                          onTap: () {
                                            String auth = FirebaseAuth
                                                .instance.currentUser!.uid;
                                            auth != uid
                                                ? Navigator.pushNamed(context,
                                                UserProfileScreen.id,
                                                arguments: {
                                                  "UserId": "${uid}"
                                                })
                                                : null;
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8)),
                                            ),
                                            width: medq.width * 0.56,
                                            child: Row(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                      gradient: LinearGradient(
                                                          colors: [
                                                            Color(0xFFFF416C),
                                                            Color(0xFFFF4B2B)
                                                          ],
                                                          begin: Alignment
                                                              .topCenter,
                                                          end: Alignment
                                                              .bottomCenter),
                                                      shape: BoxShape.circle),
                                                  height: 42,
                                                  width: 42,
                                                  child: CircleAvatar(
                                                    // radius: 33,
                                                    backgroundColor:
                                                    Color(0xFFFF4B2B)
                                                        .withOpacity(0),
                                                    child: CircleAvatar(
                                                      backgroundImage:
                                                      NetworkImage(
                                                          '${adminDp}'),
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
                                                      width: medq.width * 0.24,
                                                      child: Text(
                                                        '${adminName
                                                            .titleCase}',
                                                        maxLines: 1,
                                                        softWrap: true,
                                                        overflow:
                                                        TextOverflow.clip,
                                                        style:
                                                        GoogleFonts.poppins(
                                                          fontSize: 13,
                                                          fontWeight:
                                                          FontWeight.w500,
                                                        ),
                                                        textAlign:
                                                        TextAlign.left,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${adminInsta.substring(
                                                          0, 10)}',
                                                      maxLines: 1,
                                                      style:
                                                      GoogleFonts.poppins(
                                                          fontSize: 10,
                                                          fontWeight:
                                                          FontWeight
                                                              .w400),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: medq.height * 0.02,
                                        ),
                                        Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                          ),
                                          width: medq.width * 0.75,
                                          child: SingleChildScrollView(
                                            scrollDirection: Axis.vertical,
                                            child: Text(
                                              '${ScapeDescription.length > 80
                                                  ? ScapeDescription.substring(
                                                  0, 80)
                                                  : ScapeDescription
                                                  .sentenceCase}',
                                              maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                              softWrap: true,
                                              style: GoogleFonts.nunitoSans(
                                                fontSize: 17,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          height: medq.height * 0.006,
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
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: MediaQuery
                                  .of(context)
                                  .size
                                  .height * 0.67,
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 12, horizontal: 19),
                                    child: (present == "True" ||
                                        present == "true" ||
                                        admin == "True" ||
                                        admin == "true")
                                        ? MaterialButton(
                                      onPressed: null,
                                      elevation: 0,
                                      textColor: Colors.white,
                                      splashColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7)),
                                      ),
                                      disabledColor: ScaapeTheme
                                          .kPinkColor
                                          .withOpacity(0.15),
                                      disabledTextColor:
                                      ScaapeTheme.kPinkColor,
                                      color: ScaapeTheme.kPinkColor
                                          .withOpacity(0.2),
                                      height: medq.height * 0.065,
                                      minWidth: double.infinity,
                                      child: Text(
                                        'YOU HAVE ALREADY JOINED',
                                        style: GoogleFonts.roboto(
                                            color: ScaapeTheme.kPinkColor,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )
                                        : MaterialButton(
                                      onPressed: () async {
                                        final FirebaseAuth auth =
                                            FirebaseAuth.instance;
                                        String url =
                                            'https://api.scaape.online/api/createParticipant';
                                        Map<String, String> headers = {
                                          "Content-type":
                                          "application/json"
                                        };
                                        String json =
                                            '{"ScaapeId": "${scapeId}","UserId": "${auth
                                            .currentUser!
                                            .uid}","TimeStamp": "${DateTime
                                            .now()
                                            .millisecondsSinceEpoch}","Accepted":"0"}';
                                        http.Response response =
                                        await post(Uri.parse(url),
                                            headers: headers,
                                            body: json);
                                        //print(user.displayName);
                                        int statusCode =
                                            response.statusCode;
                                        // print(statusCode);
                                        // print(response.body);
                                        Fluttertoast.showToast(
                                          msg: "Succesfully joined",
                                        );
                                        fun();
                                      },
                                      elevation: 0,
                                      textColor: Colors.white,
                                      splashColor: ScaapeTheme.kPinkColor,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(7)),
                                      ),
                                      color: ScaapeTheme.kPinkColor,
                                      height: medq.height * 0.065,
                                      minWidth: double.infinity,
                                      child: Text(
                                        'JOIN THIS SCAAPE',
                                        style: GoogleFonts.roboto(
                                            color: Colors.white,
                                            fontSize: 17,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    )),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ));
        },
        child: Container(
          height: medq.height * 0.3,
          decoration: BoxDecoration(
            color: ScaapeTheme.kBackColor,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            image: DecorationImage(
              image: NetworkImage(ScapeImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(8)),

                child: ProgressiveImage(

                  thumbnail: NetworkImage(ScapeImage),
                  image: NetworkImage(ScapeImage),
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: null,
                  height: medq.height * 0.3,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  gradient: LinearGradient(colors: [
                    Color(0xFF1C1C1C).withOpacity(0.3),
                    Color(0xFF141414).withOpacity(0.87)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
              ),
              Positioned(
                right: 12,
                top: 12,
                child: Container(
                  decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.all(Radius.circular(8))),
                  height: MediaQuery
                      .of(context)
                      .size
                      .height * 0.07,
                  width: MediaQuery
                      .of(context)
                      .size
                      .width * 0.15,
                  child: Center(
                    child: RichText(
                      text: TextSpan(
                          text: '${date.toString().substring(0, 2)}',
                          style: TextStyle(
                              fontSize: 23,
                              color: ScaapeTheme.kPinkColor,
                              fontWeight: FontWeight.bold),
                          children: [
                            TextSpan(
                              text: date.toString().substring(3, 5) == '12'
                                  ? '\nDec'
                                  : date.toString().substring(3, 5) == '11'
                                  ? '\nNov'
                                  : date.toString().substring(3, 5) == '10'
                                  ? '\nOct'
                                  : date.toString().substring(3, 5) ==
                                  '09'
                                  ? '\nSep'
                                  : date
                                  .toString()
                                  .substring(3, 5) ==
                                  '08'
                                  ? '\nAug'
                                  : date.toString().substring(
                                  3, 5) ==
                                  '07'
                                  ? '\nJul'
                                  : date
                                  .toString()
                                  .substring(
                                  3, 5) ==
                                  '06'
                                  ? '\nJun'
                                  : date
                                  .toString()
                                  .substring(
                                  3,
                                  5) ==
                                  '05'
                                  ? '\nMay'
                                  : date.toString().substring(
                                  3,
                                  5) ==
                                  '04'
                                  ? '\nApr'
                                  : date.toString().substring(
                                  3,
                                  5) ==
                                  '03'
                                  ? '\nMar'
                                  : date.toString().substring(3, 5) == '02'
                                  ? '\nFeb'
                                  : date.toString().substring(3, 5) == '01'
                                  ? '\nJan'
                                  : '',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: ScaapeTheme.kBackColor,
                                  fontWeight: FontWeight.w400),
                            )
                          ]),
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ScapeName.sentenceCase}',
                          style: GoogleFonts.lato(
                              fontSize: 21, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          width: medq.width * 0.56,
                          child: Text(
                            '${ScapeDescription.length > 80 ? ScapeDescription
                                .substring(0, 80) : ScapeDescription
                                .sentenceCase}',
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
                  GestureDetector(
                    onTap: () {
                      String auth = FirebaseAuth.instance.currentUser!.uid;
                      auth != uid
                          ? Navigator.pushNamed(context, UserProfileScreen.id,
                          arguments: {"UserId": "${uid}"})
                          : null;
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 17.0, sigmaY: 17.0),
                        child: Container(
                          height: medq.height * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                            color: Color(0xFF1C1C1C).withOpacity(0.89),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                              end: Alignment.bottomCenter),
                                          shape: BoxShape.circle),
                                      height: 42,
                                      width: 42,
                                      child: CircleAvatar(
                                        // radius: 33,
                                        backgroundColor:
                                        Color(0xFFFF4B2B).withOpacity(0),
                                        child: CircleAvatar(
                                          backgroundImage:
                                          NetworkImage('${adminDp}'),
                                          backgroundColor: Colors.transparent,
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
                                          width: medq.width * 0.24,
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
                                            Container(
                                              width: medq.width * 0.35,
                                              child: Text(
                                                '${Location.sentenceCase}',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: GoogleFonts.poppins(
                                                    fontSize: 10,
                                                    fontWeight: FontWeight
                                                        .w400),
                                              ),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                (present == "True" ||
                                    present == "true" ||
                                    admin == "True" ||
                                    admin == "true")
                                    ? OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      primary: ScaapeTheme.kPinkColor,
                                      side: BorderSide(
                                          color: ScaapeTheme.kPinkColor,
                                          width: 1),
                                    ),
                                    onPressed: () {},
                                    child: Text('  Joined  '))
                                    : OutlinedButton(
                                  child: Text('    Join    '),
                                  style: OutlinedButton.styleFrom(
                                    primary: ScaapeTheme.kPinkColor,
                                    side: BorderSide(
                                        color: ScaapeTheme.kPinkColor,
                                        width: 1),
                                  ),
                                  onPressed: () async {
                                    final FirebaseAuth auth =
                                        FirebaseAuth.instance;
                                    String url =
                                        'https://api.scaape.online/api/createParticipant';
                                    Map<String, String> headers = {
                                      "Content-type": "application/json"
                                    };
                                    String json =
                                        '{"ScaapeId": "${scapeId}","UserId": "${auth
                                        .currentUser!
                                        .uid}","TimeStamp": "${DateTime
                                        .now()
                                        .millisecondsSinceEpoch}","Accepted":"0"}';
                                    http.Response response = await post(
                                        Uri.parse(url),
                                        headers: headers,
                                        body: json);
                                    //print(user.displayName);
                                    int statusCode = response.statusCode;
                                    // print(statusCode);
                                    // print(response.body);
                                    Fluttertoast.showToast(
                                      msg: "Succesfully joined",
                                    );
                                    fun();
                                  },
                                )
                              ],
                            ),
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
      ),
    );
  }
}

void onClick(String ScapeId) async {
  try {
    String url = 'https://api.scaape.online/api/OnClick';
    Map<String, String> headers = {"Content-type": "application/json"};
    String json = '{"ScaapeId": "${ScapeId}"}';
    http.Response response =
    await post(Uri.parse(url), headers: headers, body: json);

    int statusCode = response.statusCode;
    // print(statusCode);
    // print(response.body);
    // print("Sucesfully uploaded on click");
  } catch (e) {
    // print(e);
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
// import 'package:scaape/utils/location_class.dart';
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
//                         backgroundImage: AssetImage('images/dummy_image.png'),
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
//                         backgroundImage: AssetImage('images/dummy_image.png'),
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
