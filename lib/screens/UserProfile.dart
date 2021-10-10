import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart';
import 'package:scaape/screens/imageScreen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Staggered_Veiw.dart';


class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: IconButton(icon: Icon(Icons.menu,size: 35,),
        onPressed: (){
          Scaffold.of(context).openEndDrawer();
        },
      ),
      endDrawer: Container(
        width: MediaQuery.of(context).size.width * 0.56,
        child: Drawer(

            child:Column(

              children: [
                ListTile(

                )
              ],
            )
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(bottom: 30),
            color: Color(0xFF222831),
            child: FutureBuilder(
                future: getUserDetails(currentUser!.uid),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    var data = snapshot.data[0];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Stack(
                          children: [

                            Center(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(10, 40, 2, 2),
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
                                        // radius: 10,
                                        backgroundColor:
                                        Color(0xFFFF4B2B).withOpacity(0.5),
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => ImageViewer(
                                                  imageUrl:
                                                  '${data['ProfileImg']}',
                                                ),
                                              ),
                                            );
                                          },
                                          child: Hero(
                                            tag: 'ProfilePhoto',
                                            child: CircleAvatar(
                                              backgroundImage: NetworkImage(
                                                  '${data['ProfileImg']}'),
                                              backgroundColor: Colors.transparent,
                                              radius: 93,
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
                          height: 15,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Text(
                              '${data['Name']}',
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
                        Column(
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                child: Text('@${data['InstaId']}', style: TextStyle(
                                    color: Colors.white,fontSize: 12
                                ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 80,vertical: 10),
                                child: Text('${data['Bio']}',textAlign: TextAlign.center,),
                              ),
                            ]
                        ),

                        SizedBox(
                          height: 30,
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: <Widget>[
                                  Text(
                                    '${data['ScaapesCreated']}',
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
                                    '${data['ScaapesJoined']}',
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
                          height: 25,
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          child: Divider(
                            thickness: 0.4,
                            color: Color(0xFFFF416C).withOpacity(0.4),
                          ),
                        ),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: StaggeredVeiw(),
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
      ),
    );
  }
}
Future<List<dynamic>> getUserDetails(String id)async{

  String url='http://65.0.121.93:4000/api/getUserDetails/${id}';
  print(url);
  Response response=await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);

  return json.decode(response.body);
}

