import 'dart:convert';
import 'dart:ffi';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blur_bottom_bar/blur_bottom_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:recase/recase.dart';
import 'package:scaape/screens/add_scaape.dart';
import 'package:scaape/utils/constants.dart';
import 'package:shimmer/shimmer.dart';

import 'notification_page.dart';


class AllNotifications extends StatefulWidget {
  const AllNotifications({Key? key}) : super(key: key);

  static String id = 'all_notification';



  @override
  _AllNotificationsState createState() => _AllNotificationsState();
}

class _AllNotificationsState extends State<AllNotifications> {

  final FirebaseAuth auth = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    String authId = auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: ScaapeTheme.kBackColor,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.fromLTRB(15, 28, 15, 10),
          child: Column(
            children: [
              FutureBuilder(
                future: getActiveScaape(authId),
                builder: (BuildContext context, AsyncSnapshot snapshot){
                  if(snapshot.hasData){
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: <Widget>[
                              GestureDetector(
                                child: Icon(
                                  CupertinoIcons.back,
                                  color: Colors.white,
                                ),
                                onTap: (){
                                  Navigator.pop(context);
                                },
                              ),
                              SizedBox(
                                width: 8,
                              ),
                              Text(
                                'Active Scaapes (${snapshot.data.length})',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: BouncingScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            //var datas=snapshot.data;
                            var a = snapshot.data;
                            return Column(
                              children: [
                                GroupNotificationCard(
                                  a[index]["ScaapeImg"],
                                  a[index]['ScaapeName'],
                                  a[index]['count'].toString(),
                                  a[index]['Location'],
                                ),
                              ],
                            );
                          },
                        )
                      ],
                    );
                  }else{
                    return Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
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
                        ),
                        ActiveScaapeShimmer(),
                        ActiveScaapeShimmer(),
                        ActiveScaapeShimmer(),
                        ActiveScaapeShimmer(),
                      ],
                    );
                  }
                },
              )
            ],
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