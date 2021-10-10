import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:scaape/screens/usersChat.dart';
import 'package:recase/recase.dart';
import 'package:scaape/utils/constants.dart';
import 'package:shimmer/shimmer.dart';

class ScaapeChat extends StatefulWidget {
  const ScaapeChat({Key? key}) : super(key: key);
  static String id = 'chat';

  @override
  _ScaapeChatState createState() => _ScaapeChatState();
}

class _ScaapeChatState extends State<ScaapeChat> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String authId=auth.currentUser!.uid;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Container(
        child: FutureBuilder(
          future: getActiveScaapes(authId),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if(snapshot.hasData){
              var a=snapshot.data;

              return SingleChildScrollView(
                child: Container(
                  // color: ScaapeTheme.kBackColor,
                  margin: EdgeInsets.fromLTRB(15, 58, 15, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
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
                              'Social Messages',
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
                          itemCount: snapshot.data.length,
                          itemBuilder: (context, index) {
                            return a[index]['Accepted']==1?Column(
                              children: [
                                ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: ScaapeTheme.kSecondBlue,
                                    backgroundImage: NetworkImage(a[index]['ScaapeImg']),
                                    radius: 26,
                                  ),
                                  title: Text(a[index]['ScaapeName']),
                                  subtitle: Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        size: 13,
                                      ),
                                      SizedBox(
                                        width: 3,
                                      ),
                                      Text(
                                        '${a[index]['Location']}',
                                        maxLines: 1,
                                        style: GoogleFonts.poppins(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w400),
                                      )
                                    ],
                                  ),
                                  onTap: () {
                                    Navigator.pushNamed(context, UserChat.id,arguments:{
                                      "ScaapeId":"${a[index]['ScaapeId']}",
                                      "ScaapeName":"${a[index]['ScaapeName']}"
                                    });
                                  },
                                  // selectedTileColor: ScaapeTheme.kSecondBlue,
                                  focusColor: ScaapeTheme.kSecondBlue,
                                  selectedTileColor: ScaapeTheme.kSecondBlue,
                                  hoverColor: ScaapeTheme.kSecondBlue,
                                ),
                                Divider(
                                  endIndent: 34,
                                  indent: 68,
                                ),
                              ],
                            ):Text("");
                          }),
                    ],
                  ),
                ),
              );
            }
            else{
              return Container(
                  color: ScaapeTheme.kBackColor,
                  margin: EdgeInsets.fromLTRB(15, 58, 15, 10),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

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
                                'Social Messages',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 26,
                                ),
                              ),
                            ],
                          ),
                        ),
                        OutsideChatShimmer(),
                        OutsideChatShimmer(),
                        OutsideChatShimmer(),
                        OutsideChatShimmer(),
                        OutsideChatShimmer(),
                        OutsideChatShimmer(),
                        OutsideChatShimmer(),
                        OutsideChatShimmer(),
                        OutsideChatShimmer(),
                      ],
                    ),
                  )
              );
            }
          },

        ),
      ),
    );
  }
}

class OutsideChatShimmer extends StatelessWidget {
  const OutsideChatShimmer({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Shimmer.fromColors(
                  baseColor: ScaapeTheme.kShimmerColor.withOpacity(0.9),
                  highlightColor: ScaapeTheme.kShimmerTextColor,
                  period: Duration(milliseconds: 1900),
                  child: Container(
                    decoration:
                    BoxDecoration(shape: BoxShape.circle),
                    // height: 62,
                    // width: 62,
                    child: CircleAvatar(
                      radius: 26,
                      backgroundColor:
                      ScaapeTheme.kShimmerTextColor,
                      // radius: 34,
                    ),
                  ),
                ),
                SizedBox(
                  width: 8,
                ),
                Shimmer.fromColors(
                  baseColor: ScaapeTheme.kShimmerColor.withOpacity(0.9),
                  highlightColor: ScaapeTheme.kShimmerTextColor,
                  period: Duration(milliseconds: 1900),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.45,
                        height: 18,
                        color: ScaapeTheme.kShimmerTextColor,
                      ),
                      SizedBox(
                        height: 3,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.24,
                        height: 15,
                        color: ScaapeTheme.kShimmerTextColor,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(
              endIndent: 34,
              indent: 68,
            ),
          ],
        ),
      ),
    );
  }
}
Future<List<dynamic>> getActiveScaapes(String id)async{

  String url='https://api.scaape.online/api/getUserScaapes/UserId=${id}';

  Response response=await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);
  print(response.body);
  print(json.decode(response.body));
  return json.decode(response.body);
}
