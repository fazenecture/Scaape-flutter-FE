import 'dart:convert';
import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blur_bottom_bar/blur_bottom_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';
import 'package:scaape/screens/create_scaape.dart';
import 'package:scaape/screens/user_profile_screen.dart';
import 'package:scaape/screens/addScaape_screen.dart';
import 'package:scaape/screens/allNotification_screen.dart';
import 'package:scaape/screens/dashboard_screen.dart';
import 'package:scaape/utils/constants.dart';
import 'package:shimmer/shimmer.dart';

import 'bottom_navigatin_bar.dart';

class NotificationScreen extends StatefulWidget {
  static String id = 'notification_screen';

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    String authId = auth.currentUser!.uid;
    Size medq = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.transparent,
        backgroundColor: ScaapeTheme.kBackColor,
        shadowColor: ScaapeTheme.kSecondBlue,
        elevation: 1,
        leading: IconButton(
          onPressed: (){
            Navigator.pushReplacementNamed(context, HomeScreen.id);

          },
          icon: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Notification Center',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pushReplacementNamed(context, CreateScaape.id);
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
      body: SafeArea(
          child: Container(
            height: MediaQuery.of(context).size.height,
            child: FutureBuilder(
              future: getActiveScaape(authId),
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                print("future");
                print(snapshot);
                if (snapshot.hasData) {
                  print("future2");
                  var a = snapshot.data;
                  print(snapshot.data.length);
                  //print(a);
                  return Container(
                    color: ScaapeTheme.kBackColor,
                    margin: EdgeInsets.fromLTRB(15, 0, 15, 10),
                    child: Column(
                      //crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(vertical: 10),
                        //   child: Row(
                        //     mainAxisAlignment: MainAxisAlignment.start,
                        //     children: <Widget>[
                        //       Icon(
                        //         Icons.notification_important_outlined,
                        //         color: Colors.white,
                        //       ),
                        //       SizedBox(
                        //         width: 8,
                        //       ),
                        //       Text(
                        //         'Notification Center',
                        //         style: TextStyle(
                        //           color: Colors.white,
                        //           fontWeight: FontWeight.w600,
                        //           fontSize: 26,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Active Scaapes (${snapshot.data.length})',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              snapshot.data.length > 2 ? TextButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(ScaapeTheme.kPinkColor.withOpacity(0.2)),
                                ),
                                onPressed: (){
                                  Navigator.pushNamed(context, AllNotifications.id);
                                },
                                child: Text(
                                  'See all',
                                  style: GoogleFonts.roboto(
                                    color: ScaapeTheme.kPinkColor,

                                    fontSize: 16,
                                  ),
                                ),
                              ): Container(),
                            ],
                          ),
                        ),
                        snapshot.data.length >= 1
                            ? ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                scrollDirection: Axis.vertical,
                                itemCount: snapshot.data.length >= 2 ? 2 : 1,
                                itemBuilder: (context, index) {
                                  //var datas=snapshot.data;
                                  return Column(
                                    children: [
                                      GestureDetector(
                                        onTap:(){
                                          // if ((auth.currentUser!.uid) != uid) {
                                          //   onClick(a[index]['ScaapeId']);
                                          // }

                                          showMaterialModalBottomSheet(
                                              backgroundColor: ScaapeTheme.kBackColor,
                                              context: context,
                                              elevation: 13,
                                              shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.only(
                                                      topRight: Radius.circular(16),
                                                      topLeft: Radius.circular(16))),
                                              builder: (context) => Container(
                                                height: MediaQuery.of(context).size.height * 0.7,
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Stack(
                                                      children: [
                                                        Container(
                                                          height: medq.height * 0.4,
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topRight: Radius.circular(16),
                                                                topLeft: Radius.circular(16)),
                                                            color: Colors.white,
                                                            image: DecorationImage(
                                                              image: NetworkImage(a[index]["ScaapeImg"]),
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
                                                                            '${a[index]['ScaapeName'].toString().sentenceCase}',
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
                                                                                a[index]['count'].toString(),
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
                                                                          '${a[index]['Description'].toString().length > 80 ? a[index]['Description'].toString().substring(0, 80) : a[index]['Description'].toString().sentenceCase}',
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
                                                                          '${a[index]['Location']}',
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
                                                          height: MediaQuery.of(context).size.height * 0.67,
                                                          child: Align(
                                                            alignment: Alignment.bottomCenter,
                                                            child: Padding(
                                                                padding: const EdgeInsets.symmetric(
                                                                    vertical: 12, horizontal: 19),
                                                                child: MaterialButton(
                                                                  onPressed: () async{
                                                                    try {
                                                                      setState(() async{
                                                                        String url =
                                                                            'https://api.scaape.online/api/DeleteScaape';
                                                                        Map<String, String> headers = {
                                                                          "Content-type": "application/json"
                                                                        };
                                                                        String json =
                                                                            '{"ScaapeId": "${a[index]['ScaapeId']}","UserId": "${a[index]['UserId']}"}';
                                                                        http.Response response = await post(Uri.parse(url),
                                                                            headers: headers, body: json);
                                                                        int statusCode = response.statusCode;
                                                                        print(statusCode);
                                                                        Navigator.pop(context);
                                                                        // getActiveScaape(authId);
                                                                        // Navigator.of(context).push(new MaterialPageRoute(builder: (context) => NotificationScreen())).whenComplete(retrieveData);
                                                                        // Navigator.of(context).pushNamedAndRemoveUntil(NotificationScreen.id, (Route<dynamic> route) => false);
                                                                        // Navigator.pushReplacementNamed(context, NotificationScreen.id);
                                                                        Navigator.pushReplacementNamed(context, HomeScreen.id);
                                                                        Fluttertoast.showToast(msg: 'Scaape Deleted');

                                                                        print(response.body);
                                                                      });

                                                                    } catch (e) {
                                                                      print(e);
                                                                    }


                                                                  },
                                                                  elevation: 0,
                                                                  textColor: Colors.white,
                                                                  splashColor: Colors.transparent,
                                                                  shape: RoundedRectangleBorder(
                                                                    borderRadius: BorderRadius.all(
                                                                        Radius.circular(7)),
                                                                    side: BorderSide(
                                                                      color: ScaapeTheme.kSecondBlue
                                                                    )
                                                                  ),
                                                                  disabledColor: ScaapeTheme
                                                                      .kPinkColor
                                                                      .withOpacity(0.15),
                                                                  disabledTextColor:
                                                                  Colors.transparent,
                                                                  color: Colors.transparent,
                                                                  height: medq.height * 0.06,
                                                                  minWidth: double.infinity,
                                                                  child: Text(
                                                                    'DELETE SCAAPE',
                                                                    style: GoogleFonts.roboto(
                                                                        color: ScaapeTheme.kSecondBlue,
                                                                        fontSize: 15,
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
                                        child: GroupNotificationCard(
                                          a[index]["ScaapeImg"],
                                          a[index]['ScaapeName'],
                                          a[index]['count'].toString(),
                                          a[index]['Location'],
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              )
                            : Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.16,
                                decoration: BoxDecoration(
                                  color: ScaapeTheme.kSecondBlue.withOpacity(0.5),
                                  borderRadius: BorderRadius.all(Radius.circular(12))
                                ),
                                child: MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(12))
                                  ),
                                  elevation: 0,
                                  onPressed: (){
                                    Navigator.pushNamed(context, CreateScaape.id);
                                  },
                                  child: Container(
                                    child: Center(
                                      child: Text(
                                        'No Active Scaapes\nTap Here To Create A New Scaape',
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.roboto(
                                          fontSize: 15,
                                          color: ScaapeTheme.kSecondTextCollor.withOpacity(0.7)
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                        SizedBox(
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              'Recent Request',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            Text(
                              'See all',
                              style: GoogleFonts.roboto(
                                color: ScaapeTheme.kPinkColor,

                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        // Column(
                        //   children: <Widget>[
                        //     RecentRequestCard(),
                        //     RecentRequestCard(),
                        //   ],
                        // ),
                        FutureBuilder(
                          future: getRecentRequest(authId),
                          builder:
                              (BuildContext context, AsyncSnapshot snapshot) {

                            if(snapshot.hasData){
                              if (snapshot.data.length != 0) {
                                var a = snapshot.data;
                                print("last");
                                print(a);
                                return Expanded(
                                  child: Padding(
                                    padding:  EdgeInsets.only(bottom: 40),
                                    child: ListView.builder(
                                      primary: false,

                                      itemCount: snapshot.data.length,
                                      shrinkWrap: true,
                                      // physics: NeverScrollableScrollPhysics(),
                                      // scrollDirection: Axis.vertical,
                                      itemBuilder: (context, index) {
                                        return a[index]['UserId'] == authId
                                            ? Container()
                                            : RecentRequestCard(() {
                                          setState(() {});
                                        },
                                            a[index]['ScaapeId'],
                                            a[index]['UserId'],
                                            a[index]['Name'],
                                            a[index]['Location'],
                                            a[index]['DP'],
                                            a[index]['Accepted']);
                                      },
                                    ),
                                  ),
                                );
                              } else {
                                return Container(
                                  height: MediaQuery.of(context).size.height*0.4,
                                  child:Center(
                                    child: Text(
                                      'No Recent Requests',
                                      style: GoogleFonts.roboto(
                                          fontSize: 15,
                                          color: ScaapeTheme.kSecondTextCollor.withOpacity(0.7)
                                      ),
                                    ),
                                  ),
                                );
                              }
                            }
                            else{
                              return Container(
                                // color: Colors.white,
                                height: MediaQuery.of(context).size.height*0.4,
                                child:Center(
                                  child: Text(
                                    'No Recent Requests',
                                    style: GoogleFonts.roboto(
                                        fontSize: 15,
                                        color: ScaapeTheme.kSecondTextCollor.withOpacity(0.7)

                                    ),
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                } else {
                  return Container(
                    margin: EdgeInsets.fromLTRB(15, 58, 15, 10),
                    height: MediaQuery.of(context).size.height,
                    color: ScaapeTheme.kBackColor,
                    width: MediaQuery.of(context).size.width,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[
                            Icon(
                              Icons.notification_important_outlined,
                              color: Colors.white,
                            ),
                            SizedBox(
                              width: 8,
                            ),
                            Text(
                              'Notification Center',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 26,
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Active Scaapes',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              // TextButton(
                              //   style: ButtonStyle(
                              //     overlayColor: MaterialStateProperty.all(ScaapeTheme.kPinkColor.withOpacity(0.2)),
                              //   ),
                              //   onPressed: null,
                              //   child: Text(
                              //     'See all',
                              //     style: GoogleFonts.roboto(
                              //       color: ScaapeTheme.kPinkColor,
                              //
                              //       fontSize: 16,
                              //     ),
                              //   ),
                              // ),
                            ],
                          ),
                        ),
                        ActiveScaapeShimmer(),
                        ActiveScaapeShimmer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              Text(
                                'Recent Requests',
                                style: GoogleFonts.roboto(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              TextButton(
                                style: ButtonStyle(
                                  overlayColor: MaterialStateProperty.all(ScaapeTheme.kPinkColor.withOpacity(0.2)),
                                ),
                                onPressed: null,
                                child: Text(
                                  'See all',
                                  style: GoogleFonts.roboto(
                                    color: ScaapeTheme.kPinkColor,

                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        RecentRequestShimmer(),
                        RecentRequestShimmer(),
                        RecentRequestShimmer(),
                      ],
                    ),
                  );
                }
              },
            ),
          ),
        ),
    );
  }
}

class RecentRequestShimmer extends StatelessWidget {
  const RecentRequestShimmer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        child: Shimmer.fromColors(
          baseColor: ScaapeTheme.kShimmerColor.withOpacity(0.1),
          highlightColor: ScaapeTheme.kShimmerTextColor,
          period: Duration(milliseconds: 1900),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Row(

                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: ScaapeTheme.kShimmerTextColor,
                    radius: 22,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        color: ScaapeTheme.kShimmerTextColor,
                        height: 20,
                        width: MediaQuery.of(context).size.width * 0.35,
                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Container(
                        color: ScaapeTheme.kShimmerTextColor,
                        height: 15,
                        width: MediaQuery.of(context).size.width * 0.19,
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: <Widget>[
                  Container(
                    height: 37,
                    width: 76,
                    color: ScaapeTheme.kShimmerTextColor,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Container(
                    height: 37,
                    width: 34,
                    color: ScaapeTheme.kShimmerTextColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ActiveScaapeShimmer extends StatelessWidget {
  const ActiveScaapeShimmer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF393E46).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Shimmer.fromColors(
            baseColor: ScaapeTheme.kShimmerColor.withOpacity(0.1),
            highlightColor: ScaapeTheme.kShimmerTextColor,
            period: Duration(milliseconds: 1900),
            child: Row(
              children: <Widget>[
                CircleAvatar(
                  backgroundColor: ScaapeTheme.kShimmerTextColor,
                  radius: 35,
                ),
                SizedBox(
                  width: 14,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      color: ScaapeTheme.kShimmerTextColor,
                      height: 25,
                      width: MediaQuery.of(context).size.width * 0.38,
                    ),
                    SizedBox(
                      height: 4,
                    ),
                    Container(
                      color: ScaapeTheme.kShimmerTextColor,
                      height: 20,
                      width: MediaQuery.of(context).size.width * 0.28,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Container(
                        color: ScaapeTheme.kShimmerTextColor,
                        height: 17,
                        width: MediaQuery.of(context).size.width * 0.18,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<List<dynamic>> getActiveScaape(String id) async {
  String url =
      'https://api.scaape.online/api/getScaapesById/UserId=${id}/Status=true';
  http: //65.0.121.93:4000/api/getRecentRequest/UserId=2
  Response response = await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);
  //print(response.body);
  //print(json.decode(response.body));
  return json.decode(response.body);
}

Future<List<dynamic>> getRecentRequest(String id) async {
  //String url='https://api.scaape.online/api/getRecentRequest/UserId=${id}';
  String url = 'https://api.scaape.online/api/getRecentRequest/UserId=${id}';
  print(url);
  Response response = await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);

  return json.decode(response.body);
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
    print("Sucesfully uploaded on click");
  } catch (e) {
    print(e);
  }
}





// Recent Request Card
class RecentRequestCard extends StatelessWidget {
  String Scaapeid, userId, Name, location, ImageUrl;
  int accepted;
  Function func;

  
  
  RecentRequestCard(this.func, this.Scaapeid, this.userId, this.Name,
      this.location, this.ImageUrl, this.accepted);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context,
                    UserProfileScreen.id,
                    arguments: {
                      "UserId": "${userId}"
                    });
              },
              child: Row(

                children: <Widget>[
                  CircleAvatar(
                    backgroundColor: Color(0xFFFF4B2B).withOpacity(0.5),
                    radius: 22,
                    child: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage: NetworkImage(ImageUrl),
                      radius: 19,
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Name.length > 13 ? Text(
                        '${Name.substring(0,13).titleCase}...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,

                      ): Text(
                        '${Name.titleCase}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                        overflow: TextOverflow.ellipsis,

                      ),
                      SizedBox(
                        height: 2,
                      ),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 12,
                          ),
                          location.length > 21 ? Text(
                            '${location.substring(0,21).sentenceCase}...',
                            maxLines: 1,
                            style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          ): Text(
                            '${location.sentenceCase}',
                            maxLines: 1,
                            style: GoogleFonts.roboto(
                                fontSize: 12,
                                fontWeight: FontWeight.w400),
                          )
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Row(
              children: <Widget>[
                Container(
                  height: 37,
                  // width: 84,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xFFFF416C).withOpacity(0.16),
                      Color(0xFFFF4B2B).withOpacity(0.16)
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () async {
                      if (accepted != 1) {
                        String url =
                            'https://api.scaape.online/api/UpdateParticipant';
                        Map<String, String> headers = {
                          "Content-type": "application/json"
                        };
                        String json =
                            '{"UserId":"${userId}","Accepted":true,"ScaapeId":"${Scaapeid}"}';
                        http.Response response = await post(Uri.parse(url),
                            headers: headers, body: json);
                        int statusCode = response.statusCode;
                        print(statusCode);
                        print(response.body);
                        func();
                      } else {
                        print("pressed");
                      }
                    },
                    child: Text(
                      accepted == 1 ? "Accepted" : 'Accept',
                      style: TextStyle(color: ScaapeTheme.kPinkColor, fontSize: 15),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                MaterialButton(
                    height: 37,
                    minWidth: 23,
                    color: Color(0xFF393E46),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () async {
                      try {
                        String url =
                            'https://api.scaape.online/api/DeleteParticipant';
                        Map<String, String> headers = {
                          "Content-type": "application/json"
                        };
                        String json =
                            '{"ScaapeId": "${Scaapeid}","UserId": "${userId}"}';
                        http.Response response = await post(Uri.parse(url),
                            headers: headers, body: json);
                        int statusCode = response.statusCode;
                        print(statusCode);

                        print(response.body);
                        func();
                      } catch (e) {
                        print(e);
                      }
                    },
                    child: Icon(
                      Icons.close,
                      size: 18,
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// Card Below Active Scaapes
class GroupNotificationCard extends StatelessWidget {
  GroupNotificationCard(
      this.imageUrl, this.ScaapeName, this.count, this.location);

  String imageUrl, ScaapeName, count, location;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFF393E46),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: ScaapeTheme.kPinkColor.withOpacity(0.5),
                radius: 35,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  backgroundImage: NetworkImage(imageUrl),
                  radius: 30,
                ),
              ),
              SizedBox(
                width: 14,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    '${ScaapeName}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                    ),
                  ),
                  SizedBox(
                    height: 4,
                  ),
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                      ),
                      Text(
                        '${location.sentenceCase}',
                        maxLines: 1,
                        style: GoogleFonts.roboto(
                            fontSize: 14,
                            fontWeight: FontWeight.w400),
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.group_outlined,
                          color: Colors.white,
                        ),
                        SizedBox(
                          width: 3,
                        ),
                        Text(
                          '${count}',
                          style: TextStyle(color: Colors.white, fontSize: 21),
                        ),
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
