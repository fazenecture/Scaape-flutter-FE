import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart';
import 'package:scaape/screens/bottom_navigatin_bar.dart';
import 'package:scaape/screens/user_profile_screen.dart';
import 'package:scaape/utils/constants.dart';

class ChatDesc extends StatefulWidget {
  const ChatDesc({Key? key}) : super(key: key);
  static String id = 'chat_info';

  @override
  _ChatDescState createState() => _ChatDescState();
}

class _ChatDescState extends State<ChatDesc> {
  var noParticipants;

  Future<List<dynamic>> getScaapeParticipants(String sId) async {
    String url =
        'https://api.scaape.online/api/getAcceptedParticipant/ScaapeId=${sId}';

    var response = await get(Uri.parse(url));
    int statusCode = response.statusCode;
    print(statusCode);
    print(response.body.length);
    noParticipants = response.body.length;
    print(url);
    // print(json.decode(response.body));
    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    final chatInfo = ModalRoute.of(context)!.settings.arguments as Map;
    final FirebaseAuth auth = FirebaseAuth.instance;
    String scaapeId = chatInfo['ScaapeId'];
    String scaapeName = chatInfo['ScaapeName'];
    String scaapeImage = chatInfo['ScaapeImage'];
    String scaapeDesc = chatInfo['ScaapeDesc'];
    String scaapeDate = chatInfo['ScaapeDate'];
    String scaapeAdminId = chatInfo['ScaapeAdminId'];
    String authId = auth.currentUser!.uid;

    return Scaffold(
      backgroundColor: ScaapeTheme.kShimmerColor,
      resizeToAvoidBottomInset: false,
      body: FutureBuilder(
        future: getScaapeParticipants(scaapeId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            var data = snapshot.data;
            // print(data);
            print('darsadada  $data');

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Container(
                      // color: Colors.red,
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.24,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: NetworkImage("${scaapeImage}"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      height: MediaQuery.of(context).size.height * 0.24,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                              colors: [
                            ScaapeTheme.kShimmerColor.withOpacity(0.2),
                            ScaapeTheme.kShimmerColor.withOpacity(1),
                          ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter)),
                      child: Padding(
                        padding: EdgeInsets.only(
                            top: MediaQuery.of(context).size.height * 0.18,
                            left: MediaQuery.of(context).size.width * 0.09),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${scaapeName}',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Created By --, ${scaapeDate.toString().substring(0, 10)}',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 15,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: MediaQuery.of(context).size.width * 0.09),
                  child: Text(
                    scaapeDesc,
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(
                  height: 15,
                ),
                Divider(
                  height: 0,
                  thickness: 1,
                  indent: MediaQuery.of(context).size.height * 0.042,
                  endIndent: MediaQuery.of(context).size.height * 0.042,
                  // thickness: ,
                  color: ScaapeTheme.kPinkColor.withOpacity(0.2),
                ),
                Padding(
                  padding: EdgeInsets.only(
                      left: MediaQuery.of(context).size.width * 0.09,
                      top: MediaQuery.of(context).size.height * 0.014),
                  child: Text(
                    '${data.length} Participants',
                    style: TextStyle(
                        color: Colors.white.withOpacity(0.4),
                        fontSize: 12,
                        fontWeight: FontWeight.w400),
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                      shrinkWrap: true,

                      itemCount: snapshot.data.length,
                      itemBuilder: (context, index) {
                        if (data != []) {
                          String userName = data[index]['Name'];
                          String userImg = data[index]['ProfileImg'];
                          String userId = data[index]['InstaId'];
                          String UserUid = data[index]['UserId'];
                          print(authId);

                          return Padding(
                            padding: EdgeInsets.symmetric(horizontal: 10),
                            child: Column(
                              children: [
                                ListTile(
                                  onTap: () {
                                    String auth = FirebaseAuth
                                        .instance.currentUser!.uid;
                                    auth != UserUid
                                        ? Navigator.pushNamed(context,
                                        UserProfileScreen.id,
                                        arguments: {
                                          "UserId": "${UserUid}"
                                        })
                                        : null;
                                  },
                                  leading: CircleAvatar(
                                    backgroundImage: NetworkImage('$userImg'),
                                  ),
                                  title: UserUid == authId ? Text(
                                    'You',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15),
                                  ): Text(
                                    userName,
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w400,
                                        fontSize: 15),
                                  ),
                                  subtitle:  Text('@${userId}',
                                      style: TextStyle(
                                          color: Colors.white.withOpacity(0.7),
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13)),
                                  trailing: UserUid == scaapeAdminId ? Container(
                                    decoration: BoxDecoration(
                                      color: ScaapeTheme.kPinkColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5)),
                                      border: Border.all(
                                        color: ScaapeTheme.kPinkColor,
                                        width: 0.8
                                      )
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 12,vertical: 5),
                                      child: Text(
                                        'Admin',
                                        style: TextStyle(
                                          color: ScaapeTheme.kPinkColor,
                                          fontSize: 12
                                        ),
                                      ),
                                    ),
                                  ) : null,
                                ),
                                Divider(
                                  thickness: 0.45,
                                  indent: MediaQuery.of(context).size.height *
                                      0.042,
                                  endIndent:
                                      MediaQuery.of(context).size.height *
                                          0.042,
                                  color: Colors.white.withOpacity(0.1),
                                )
                              ],
                            ),
                          );
                        } else {
                          return Text('Wait!! Whatt??');
                        }
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Center(
                    child: MaterialButton(
                      elevation: 0,
                      splashColor: ScaapeTheme.kPinkColor.withOpacity(0.1),
                      highlightColor: ScaapeTheme.kPinkColor.withOpacity(0.1),
                      height: MediaQuery.of(context).size.height * 0.057,
                      minWidth: MediaQuery.of(context).size.width * 0.85,
                      color: ScaapeTheme.kShimmerColor,
                      shape: RoundedRectangleBorder(
                          side: BorderSide(
                              color: ScaapeTheme.kPinkColor, width: 1),
                          borderRadius: BorderRadius.circular(6)),
                      onPressed: () async {
                        try {
                          String url =
                              'https://api.scaape.online/api/DeleteParticipant';
                          Map<String, String> headers = {
                            "Content-type": "application/json"
                          };
                          String json =
                              '{"ScaapeId": "${scaapeId}","UserId": "${authId}"}';
                          var response = await post(Uri.parse(url),
                              headers: headers, body: json);
                          int statusCode = response.statusCode;
                          print(statusCode);

                          print(response.body);
                          Fluttertoast.showToast(
                            msg: "You left the Scaape",
                          );
                          Navigator.pushReplacementNamed(context, HomeScreen.id);


                        } catch (e) {
                          print(e);
                        }
                      },
                      child: const Text(
                        'Leave This Scaape',
                        style: const TextStyle(
                          color: ScaapeTheme.kPinkColor,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }
}

class Users extends StatelessWidget {
  Users(this.userImg, this.userName, this.userId);

  final String userImg;
  final String userName;
  final String userId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
          left: MediaQuery.of(context).size.width * 0.09,
          top: MediaQuery.of(context).size.height * 0.02),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage: NetworkImage('$userImg'),
              ),
              Padding(
                padding: EdgeInsets.only(
                    left: MediaQuery.of(context).size.width * 0.04),
                child: Column(
                  children: [
                    Text(
                      userName,
                      style: TextStyle(color: Colors.white),
                    ),
                    Text(userId,
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w300)),
                  ],
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
