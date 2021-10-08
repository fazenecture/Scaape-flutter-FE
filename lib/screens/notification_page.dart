import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:blur_bottom_bar/blur_bottom_bar.dart';

import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:scaape/utils/constants.dart';
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

    String authId=auth.currentUser!.uid;
    return SafeArea(
        child: FutureBuilder(
          future: getActiveScaape(authId),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            print("future");
            print(snapshot);
            if(snapshot.data!=null){
              print("future2");
              var a=snapshot.data;

              //print(a);

              return Container(
                color: ScaapeTheme.kBackColor,
                margin: EdgeInsets.fromLTRB(15, 58, 15, 10),
                child: SingleChildScrollView(
                  child: ListView(
                    shrinkWrap: true,
                    //crossAxisAlignment: CrossAxisAlignment.start,
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
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Active Scaapes',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w400),
                        ),
                      ),
                      ListView.builder(
                      shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          //var datas=snapshot.data;
                        return GroupNotificationCard(a[index]["ScaapeImg"],a[index]['ScaapeName'],a[index]['count'].toString(),a[index]['Location'],);
                      },),

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
                            style: TextStyle(
                              color: ScaapeTheme.kPinkColor,
                              fontSize: 18,
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
                          builder: (BuildContext context, AsyncSnapshot snapshot) {

                              if(snapshot.data!=null){
                                var a=snapshot.data;
                                print("last");
                                print(a);
                                return ListView.builder(
                                  itemCount:snapshot.data.length,
                                   shrinkWrap: true,
                                  scrollDirection: Axis.vertical,
                                    itemBuilder: (context, index) {
                                      return RecentRequestCard((){
                                        setState(() {

                                        });
                                      },a[index]['ScaapeId'],a[index]['UserId'],a[index]['Name'],a[index]['Location'],a[index]['DP']);
                                    },);
                              }
                              else{
                                return Center(child: CircularProgressIndicator(),);
                              }
                          },)
                    ],
                  ),
                ),
              );
            }
            else{
              return Center(child: CircularProgressIndicator());
            }
          },

        ),
      );

  }
}
Future<List<dynamic>> getActiveScaape(String id)async{

  String url='http://65.0.121.93:4000/api/getScaapesById/UserId=${id}/Status=true';
  http://65.0.121.93:4000/api/getRecentRequest/UserId=2
  Response response=await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);
  //print(response.body);
  //print(json.decode(response.body));
  return json.decode(response.body);
}
Future<List<dynamic>> getRecentRequest(String id)async{

  //String url='http://65.0.121.93:4000/api/getRecentRequest/UserId=${id}';
  String url='http://65.0.121.93:4000/api/getRecentRequest/UserId=${id}';
  print(url);
  Response response=await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);

  return json.decode(response.body);
}

// Recent Request Card
class RecentRequestCard extends StatelessWidget {
  String Scaapeid,userId,Name,location,ImageUrl;
  Function func;
  RecentRequestCard(this.func,this.Scaapeid,this.userId,this.Name,this.location,this.ImageUrl);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
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
                    Text(
                      '${Name}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(
                      height: 2,
                    ),
                    Text(
                      '@${location}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              children: <Widget>[
                Container(
                  height: 37,
                  width: 84,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                      Color(0xFFFF416C).withOpacity(0.2),
                      Color(0xFFFF4B2B).withOpacity(0.2)
                    ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: MaterialButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    onPressed: () async{

                      String url='http://65.0.121.93:4000/api/UpdateParticipant';
                      Map<String,String> headers={"Content-type":"application/json"};
                      String json='{"UserId":"${userId}","Accepted": "1","ScaapeId":"${Scaapeid}"}';
                      http.Response response=await post(Uri.parse(url),headers:headers,body:json);
                      int statusCode = response.statusCode;
                      print(statusCode);
                      print(response.body);
                      func();


                    },
                    child: Text(
                      'Accept',
                      style: TextStyle(color: Color(0xFFFF4B2B), fontSize: 15),
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
                    onPressed: () async{
                      try{

                        String url='http://65.0.121.93:4000/api/DeleteParticipant';
                        Map<String,String> headers={"Content-type":"application/json"};
                        String json='{"ScaapeId": "${Scaapeid}","UserId": "${userId}"}';
                        http.Response response=await post(Uri.parse(url),headers:headers,body:json);
                        int statusCode = response.statusCode;
                        print(statusCode);

                        print(response.body);
                        func();
                      }catch(e){
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
  GroupNotificationCard(this.imageUrl,this.ScaapeName,this.count,this.location);
  String imageUrl,ScaapeName,count,location;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Container(
        height: 91,
        decoration: BoxDecoration(
          color: Color(0xFF393E46),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: <Widget>[
              CircleAvatar(
                backgroundColor: Color(0xFFFF4B2B).withOpacity(0.5),
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
                  Text(
                    '@${location}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
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
