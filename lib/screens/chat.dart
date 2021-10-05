import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:scaape/screens/usersChat.dart';

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
    return SafeArea(
      child: FutureBuilder(
        future: getActiveScaapes(authId),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if(snapshot.hasData){
            var a=snapshot.data;

            return SingleChildScrollView(
              child: Container(
                color: Color(0xFF222831),
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
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Color(0xFFFF4B2B).withOpacity(0.5),
                              radius: 22,
                              child: CircleAvatar(
                                backgroundColor: Colors.white,
                                backgroundImage: NetworkImage(a[index]['ScaapeImg']),
                                radius: 19,
                              ),
                            ),
                            title: Text(a[index]['ScaapeName']),
                            subtitle: Text("4 Messages"),
                            onTap: () {
                              Navigator.pushNamed(context, UserChat.id);
                            },
                          );
                        }),
                  ],
                ),
              ),
            );
          }
          else{
            return Center(child: CircularProgressIndicator(),);
          }
        },

      ),
    );
  }
}
Future<List<dynamic>> getActiveScaapes(String id)async{

  String url='http://65.0.121.93:4000/api/getScaapesById/UserId=2/Status=test';

  Response response=await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);
  print(response.body);
  print(json.decode(response.body));
  return json.decode(response.body);
}
