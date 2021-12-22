
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:async/async.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart';
import 'package:path/path.dart';
import 'package:scaape/screens/user_config_screens.dart';
import 'package:scaape/utils/image_viewer_widget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:scaape/screens/signIn_screen.dart';
import 'package:scaape/utils/constants.dart';
import '../utils/staggered_view_widget.dart';


class ProfileScreen extends StatefulWidget {
  static String id = 'profile_screen';

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _selectedIndex = 0;




  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  var currentUser = FirebaseAuth.instance.currentUser;
  getCurrentUser() async {
    print("idhar arha h");
    try{
      if (currentUser != null) {
        return currentUser;
      }
    }catch(e){
      print("Hello $e");
    }
  }



  String stringmani(String? values) {
    String? value = values;
    String? newString = value!.substring(0, value.indexOf('=') + 1) + 's700-c';
    return newString;
  }
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  File? _image;
  final picker = ImagePicker();
  final pickedImage = ImagePicker();
  var proImg;
  var proName;
  var proInsta;
  var proEmail;


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      floatingActionButtonLocation: FloatingActionButtonLocation.endTop,
      floatingActionButton: IconButton(icon: Icon(Icons.menu_rounded,size: 26,),
        onPressed: ()async{
          // Scaffold.of(context).openEndDrawer();
          Navigator.pushNamed(context, UserConfigScreen.id, arguments:{
            "UserImg": "$proImg",
            "UserName": "$proName",
            "UserInsta": "$proInsta",
            "UserEmail": "$proEmail"
          });
          // await FirebaseAuth.instance.signOut();
          // Navigator.pushNamedAndRemoveUntil(context, SignInScreen.id, (route) => false);

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

        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(bottom: 30),
          color: ScaapeTheme.kBackColor,
          child: SingleChildScrollView(
            child: FutureBuilder(
                future: getUserDetails(currentUser!.uid),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if(ConnectionState.waiting == snapshot.connectionState){
                    return Container(
          height: MediaQuery.of(context).size.height,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: ScaapeTheme.kPinkColor,
                        ),
                      ),
                    );
                  }else{
                    if (snapshot.hasData) {
                      var data = snapshot.data[0];
                      proImg = data['ProfileImg'];
                      proName = data['Name'];
                      proInsta = data['InstaId'];
                      proEmail = data['EmailId'];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Stack(
                            children: [
                              // Container(
                              //   height: 300,
                              //   width: double.infinity,
                              //   decoration: BoxDecoration(
                              //       color: Colors.red,
                              //       borderRadius: BorderRadius.only(
                              //           bottomRight: Radius.circular(55),
                              //           bottomLeft: Radius.circular(55))),
                              //   // child: Image.asset(
                              //   //   'images/home-image.jpg',
                              //   //   fit: BoxFit.fitWidth,
                              //   // ),
                              // ),
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
                                              print("this is user image = $proImg");
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

                              data['Vaccine']==1?Image.asset(
                                'images/tick.png',
                                height: 28,
                                width: 28,
                              ):Text(""),
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
                                  padding: const EdgeInsets.fromLTRB(80, 10,80,0),
                                  child: Text('${data['Bio']}',textAlign: TextAlign.center,),
                                ),
                                (data['Vaccine']==0)&&(data['UserId']==currentUser!.uid)?
                                Padding(
                                  padding: const EdgeInsets.only(left: 80,right: 80),
                                  child: Row(
                                    children: [
                                      Text('To get verified Badge',textAlign: TextAlign.center,),
                                      TextButton(
                                        child: Text("Click Here"),
                                        onPressed: () async {
                                          final pickedFile =
                                          await picker.getImage(source: ImageSource.gallery);
                                          setState(
                                                () {
                                              if (pickedFile != null) {
                                                _image = File(pickedFile.path);
                                                print(pickedFile.path);
                                              } else {
                                                print('No image selected');
                                              }
                                            },
                                          );
                                          var paths;
                                          try {
                                            String url = 'https://api.scaape.online/testUpload';
                                            var stream = new http.ByteStream(
                                                DelegatingStream.typed(_image!.openRead()));
                                            var length = await _image!.length();
                                            var request =
                                            MultipartRequest('POST', Uri.parse(url));

                                            var multipartFile = new http.MultipartFile(
                                                'file', stream, length,
                                                filename: basename(_image!.path));
                                            request.files.add(multipartFile);
                                            var res = await request.send();
                                            print(res.statusCode);

                                            await res.stream
                                                .transform(utf8.decoder)
                                                .listen((value) async {
                                              var data = jsonDecode(value);
                                              paths = data['path'].toString().substring(7);
                                              print(paths);
                                              var imageurl = 'https://api.scaape.online/ftp/$paths';
                                              try{
                                                String url = 'https://api.scaape.online/api/UpdateVaccineCert';
                                                Map<String, String> headers = {
                                                  "Content-type": "application/json"
                                                };
                                                String json ='{"VaccineCert":"${imageurl}","UserId":"${currentUser!.uid}"}';
                                                http.Response response = await post(Uri.parse(url),
                                                    headers: headers, body: json);

                                                int statusCode = response.statusCode;
                                                print(statusCode);
                                                print(response.body);
                                              }catch(e){
                                                print(e);
                                              }
                                              print(imageurl);
                                              Fluttertoast.showToast(
                                                msg: "Uploaded successfully",
                                              );
                                            });
                                          } catch (e) {
                                            print(e);
                                          }
                                        },
                                      )
                                    ],
                                  ),
                                ):Text("")
                              ]
                          ),

                          SizedBox(
                            height: 30,
                          ),
                          //       ListView(
                          //         children: [
                          //           CarouselSlider(items:
                          // [
                          //   Container(
                          //             child: Text('sda'),
                          //           ),
                          //   Container(
                          //     child: Text('dasda'),
                          //   ),
                          //   Container(
                          //     child: Text('qwrqwrwq'),
                          //   ),
                          //   Container(
                          //     child: Text('jtyjyt'),
                          //   ),
                          // ],
                          // options: CarouselOptions(
                          // height: 20.0,
                          // // enlargeCenterPage: true,
                          // autoPlay: true,
                          // aspectRatio: 16 / 9,
                          // autoPlayCurve: Curves.fastOutSlowIn,
                          // enableInfiniteScroll: true,
                          // autoPlayAnimationDuration: Duration(milliseconds: 800),
                          // viewportFraction: 0.8,
                          // )
                          //           )
                          // ],
                          //       ),
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
                          // MaterialButton(onPressed: (){},
                          //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
                          //   color: Color(0xff393E46),
                          //   minWidth: 200,
                          //   child:  Row(mainAxisSize: MainAxisSize.min,
                          //     children: [Icon(Icons.edit) ,
                          //       Text('Edit Profile',
                          //           style: new TextStyle(fontSize: 14.0, color: Colors.white)),
                          //     ],
                          //   ),
                          // ),
                          SizedBox(
                            height: 5,
                          ),

                          // Padding(
                          //   padding: const EdgeInsets.symmetric(horizontal: 60),
                          //   child: MaterialButton(
                          //     onPressed: () {},
                          //     color: Color(0xFF393E46),
                          //     height: 47,
                          //     minWidth: 190,
                          //     shape: RoundedRectangleBorder(
                          //         borderRadius: BorderRadius.circular(12)),
                          //     child: Row(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: <Widget>[
                          //         Icon(
                          //           Icons.edit,
                          //           color: Colors.white,
                          //           size: 20,
                          //         ),
                          //         SizedBox(
                          //           width: 10,
                          //         ),
                          //         Text(
                          //           'Edit Profile',
                          //           style: TextStyle(
                          //             color: Colors.white,
                          //           ),
                          //         )
                          //       ],
                          //     ),
                          //   ),
                          // ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 15),
                            child: Divider(
                              thickness: 0.4,
                              color: Color(0xFFFF416C).withOpacity(0.4),
                            ),
                          ),
                          // Row(
                          //   children: <Widget>[
                          // Expanded(
                          //   child: Padding(
                          //     padding: const EdgeInsets.symmetric(
                          //         vertical: 7, horizontal: 7),
                          //     child: Container(
                          //       height: 200,
                          //       decoration: BoxDecoration(
                          //         color: Colors.white,
                          //         image: DecorationImage(
                          //           image: AssetImage('images/home-image.jpg'),
                          //           fit: BoxFit.cover,
                          //         ),
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Expanded(
                          //   child: Padding(
                          //     padding: const EdgeInsets.symmetric(
                          //         vertical: 7, horizontal: 7),
                          //     child: Container(
                          //       height: 200,
                          //       decoration: BoxDecoration(
                          //         color: Colors.white,
                          //         image: DecorationImage(
                          //           image: AssetImage('images/home-image.jpg'),
                          //           fit: BoxFit.cover,
                          //         ),
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          // Expanded(
                          //   child: Padding(
                          //     padding: const EdgeInsets.symmetric(
                          //         vertical: 7, horizontal: 7),
                          //     child: Container(
                          //       height: 200,
                          //       decoration: BoxDecoration(
                          //         color: Colors.white,
                          //         image: DecorationImage(
                          //           image: AssetImage('images/home-image.jpg'),
                          //           fit: BoxFit.cover,
                          //         ),
                          //         borderRadius: BorderRadius.circular(12),
                          //       ),
                          //     ),
                          //   ),
                          // ),
                          //   ],
                          // ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: StaggeredVeiw(currentUser!.uid),
                          ),
                          SizedBox(
                            height: 20,
                          )
                        ],
                      );
                    } else {
                      return Container();
                    }
                  }
                }),
          ),
        ),
      ),
    );
  }
}
Future<List<dynamic>> getUserDetails(String id)async{

  String url='https://api.scaape.online/api/getUserDetails/${id}';
  print(url);
  Response response=await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);

  return json.decode(response.body);
}

