import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:scaape/screens/homePage.dart';
import 'package:scaape/screens/home_screen.dart';
import 'package:scaape/utils/constants.dart';

class Onboarding2 extends StatefulWidget {
  const Onboarding2({Key? key}) : super(key: key);
  static String id = 'onBoarding2';

  @override
  _Onboarding2State createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2> {
  File? _image;
  String? _base64;
  List? imagesList;
  final picker = ImagePicker();
  String Instagram = '';
  bool isLoading = false;
  String Bio='';

  @override
  Widget build(BuildContext context) {
    final signInData = ModalRoute.of(context)!.settings.arguments as Map;
    var medq = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: isLoading
            ? Center(
          child: CircularProgressIndicator(),
        )
            : SingleChildScrollView(
              child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 40, 25, 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        // color: Colors.grey,
                        width: double.infinity,
                        height: MediaQuery.of(context).size.height * 0.13,
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: 'Too Close to \n',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize:
                                MediaQuery.of(context).size.height / 25,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            TextSpan(
                              text: 'Scapping!\n',
                              style: TextStyle(
                                color: ScaapeTheme.kPinkColor,
                                fontSize:
                                MediaQuery.of(context).size.height / 25,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            TextSpan(
                              text:
                              "We would love to see you in person \n but we can't wait",
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize:
                                MediaQuery.of(context).size.height / 59,
                                fontWeight: FontWeight.w300,
                              ),
                            )
                          ]),
                        ),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      RichText(
                          text: TextSpan(children: [
                            TextSpan(
                              text: "Upload your ",
                              style: TextStyle(
                                color: Color(0xFFFFFFFF),
                                fontSize:
                                MediaQuery.of(context).size.height / 46,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: "Photo",
                              style: TextStyle(
                                color: ScaapeTheme.kPinkColor,
                                fontSize:
                                MediaQuery.of(context).size.height / 46,
                                fontWeight: FontWeight.w500,
                              ),
                            )
                          ])),
                      SizedBox(
                        height: 10,
                      ),
                      // Row(
                      //   children: [
                      //     Padding(
                      //       padding: const EdgeInsets.all(3.0),
                      //       child: GestureDetector(
                      //         onTap: () async {
                      //           final pickedFile = await picker.getImage(
                      //               source: ImageSource.gallery);
                      //           setState(
                      //                 () {
                      //               if (pickedFile != null) {
                      //                 _image = File(pickedFile.path);
                      //                 _base64 = base64Encode(
                      //                     _image!.readAsBytesSync());
                      //                 print(pickedFile.path);
                      //               } else {
                      //                 print('No image selected');
                      //               }
                      //             },
                      //           );
                      //         },
                      //         // child: buildButtons(
                      //         //     medq, "Upload Image", 0.36, Color(0xff393e46)),
                      //         child: Card(
                      //           color: Color(0xFF393E46),
                      //           shape: RoundedRectangleBorder(
                      //               borderRadius:
                      //               BorderRadius.circular(10)),
                      //           child: Container(
                      //             height:
                      //             MediaQuery.of(context).size.height *
                      //                 0.115,
                      //             width:
                      //             MediaQuery.of(context).size.height *
                      //                 0.115,
                      //             child: Icon(
                      //               Icons.add,
                      //               size: 75,
                      //               color: Colors.grey,
                      //             ),
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //     Padding(
                      //       padding: const EdgeInsets.all(3.0),
                      //       child: Card(
                      //         color: Color(0xFF393E46),
                      //         shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10)),
                      //         child: Container(
                      //           height: MediaQuery.of(context).size.height *
                      //               0.115,
                      //           width: MediaQuery.of(context).size.height *
                      //               0.115,
                      //         ),
                      //       ),
                      //     ),
                      //     Padding(
                      //       padding: const EdgeInsets.all(3.0),
                      //       child: Card(
                      //         color: Color(0xFF393E46),
                      //         shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(10)),
                      //         child: Container(
                      //           height: MediaQuery.of(context).size.height *
                      //               0.115,
                      //           width: MediaQuery.of(context).size.height *
                      //               0.115,
                      //         ),
                      //       ),
                      //     ),
                      //   ],
                      // ),
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () async {
                              final pickedFile =
                              await picker.getImage(source: ImageSource.gallery);
                              setState(
                                    () {
                                  if (pickedFile != null) {
                                    _image = File(pickedFile.path);
                                    _base64 = base64Encode(_image!.readAsBytesSync());
                                    print(pickedFile.path);
                                  } else {
                                    print('No image selected');
                                  }
                                },
                              );
                            },
                            child: buildButtons(
                                medq, "Upload Image", 0.36, Color(0xff393e46)),
                          ),
                          _base64 == null
                              ? Container()
                              : Icon(
                            Icons.done,
                            color: Colors.green,
                          ),
                        ],
                      ),
                      SizedBox(height: 40),
                      Container(
                          child: Text(
                            'Instagram',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 46,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        child: TextField(
                            cursorColor: ScaapeTheme.kPinkColor,
                            onChanged: (value) {
                              Instagram = value;
                            },
                            decoration: InputDecoration(
                              focusColor: Color(0xFF222831),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 15.0, horizontal: 20),
                              // border: new OutlineInputBorder(
                              //   borderRadius: new BorderRadius.circular(15.0),
                              // ),
                              focusedBorder: OutlineInputBorder(

                                borderRadius: BorderRadius.all(
                                    Radius.circular(9.0)),
                                borderSide: const BorderSide(
                                    color: ScaapeTheme.kPinkColor, width: 1.5),),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.all(
                                    Radius.circular(9.0)),
                                borderSide: const BorderSide(
                                    color: Colors.transparent, width: 0.0),
                              ),
                              hintText: "Enter your instagram",
                              filled: true,
                              hintStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize: medq.height * 0.02,
                                color: const Color(0x5cffffff),
                                fontWeight: FontWeight.w400,
                              ),
                            )),
                      ),
                      SizedBox(
                        height: 40,
                      ),
                      Container(
                          child: Text(
                            'Bio',
                            style: TextStyle(
                              fontSize: MediaQuery.of(context).size.height / 46,
                              fontWeight: FontWeight.w500,
                            ),
                          )),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        // height: medq.height * 0.15,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(7.0),
                          color: const Color(0xff393e46),
                        ),
                        child: TextField(
                          onChanged: (value) {
                            Bio = value;
                          },
                          cursorColor: ScaapeTheme.kPinkColor,
                          maxLines: 5,
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                            enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: BorderSide.none),
                            focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: BorderSide(
                                    width: 1, color: ScaapeTheme.kPinkColor)),
                            border: InputBorder.none,
                            hintText: "We want to know more about you",
                            hintStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize: medq.height * 0.02,
                              color: const Color(0x5cffffff),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 8.0),
                      //   child: Container(
                      //     width: medq.width * 0.8,
                      //     decoration: BoxDecoration(
                      //       borderRadius: BorderRadius.circular(7.0),
                      //       color: const Color(0xff393e46),
                      //     ),
                      //     // child: Padding(
                      //     //   padding: const EdgeInsets.only(left: 12.0),
                      //     //   child: TextField(
                      //     //       onChanged: (value) {
                      //     //         Instagram=value;
                      //     //       },
                      //     //       decoration: InputDecoration(
                      //     //
                      //     //         border: InputBorder.none,
                      //     //         hintText: "Location",
                      //     //         hintStyle: TextStyle(
                      //     //
                      //     //           fontFamily: 'Roboto',
                      //     //           fontSize: medq.height * 0.02,
                      //     //           color: const Color(0x5cffffff),
                      //     //           fontWeight: FontWeight.w300,
                      //     //         ),
                      //     //       )),
                      //     // ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.1,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.15,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 25),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0x3BFF4265)),
                          child: Center(
                            child: Icon(Icons.arrow_back_ios),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      GestureDetector(
                        onTap: () async {
                          if (Instagram.isEmpty||_image.isNull||Bio.isEmpty) {
                            Fluttertoast.showToast(
                              msg: "enter all details",
                            );
                          } else {
                            print(signInData['UserId']);

                            var paths;

                            try {
                              String url = 'http://65.0.121.93:4000/testUpload';
                              var stream = new http.ByteStream(
                                  DelegatingStream.typed(_image!.openRead()));
                              var length = await _image!.length();
                              var request = MultipartRequest('POST', Uri.parse(url));

                              var multipartFile = new http.MultipartFile(
                                  'file', stream, length, filename: basename(_image!
                                  .path));
                              request.files.add(multipartFile);
                              var res = await request.send();
                              print(res.statusCode);
                              Fluttertoast.showToast(msg: "Please wait",);
                              await res.stream.transform(utf8.decoder).listen((
                                  value) {
                                var data = jsonDecode(value);
                                paths = data['path'].toString().substring(7);
                                print(paths);
                              });
                              var imageurls = 'http://65.0.121.93:4000/ftp/$paths';
                              String urls =
                                  'http://65.0.121.93:4000/api/createUser';
                              Map<String, String> headers = {
                                "Content-type": "application/json"
                              };
                              String json =
                                  '{"UserId": "${signInData['UserId']}","EmailId": "${signInData['EmailId']}","BirthDate": "${signInData['BirthDate']}","Gender": "${signInData['BirthDate']}","Name": "${signInData['Name']}","ProfileImg": "${imageurls}","InstaId": "${Instagram}","Vaccine": "true","Bio":"${Bio}"}';

                              http.Response response = await post(
                                  Uri.parse(urls),
                                  headers: headers,
                                  body: json);
                              //print(user.displayName);
                              int statusCode = response.statusCode;
                              print(statusCode);
                              print(response.body);

                            }
                            catch (e) {
                              print(e);
                            }

                            Navigator.pushNamedAndRemoveUntil(
                                context, HomeScreen.id, (route) => false);
                          }
                        },
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          padding: EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: ScaapeTheme.kPinkColor),
                          child: Center(
                            child: Text(
                              'Next',
                              style: TextStyle(fontSize: 20),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                )
              ],
          ),
        ),
            ),
      ),
    );
  }
}

Container buildButtons(Size medq, String text, double widthfac, Color) {
  return Container(
    width: medq.width * widthfac,
    height: medq.height * 0.05,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(7.0),
      color: Color,
    ),
    child: Center(
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: medq.height * 0.02,
          color: Colors.white,
          fontWeight: FontWeight.w300,
        ),
      ),
    ),
  );
}

