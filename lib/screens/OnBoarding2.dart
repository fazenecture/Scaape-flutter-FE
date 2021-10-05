import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
class Onboarding2 extends StatefulWidget {
  const Onboarding2({Key? key}) : super(key: key);
  static String id = 'onBoarding';
  @override
  _Onboarding2State createState() => _Onboarding2State();
}

class _Onboarding2State extends State<Onboarding2> {
  File? _image;
  String? _base64;
  List? imagesList;
  final picker = ImagePicker();
  String Instagram='';
  @override
  Widget build(BuildContext context) {
    var medq = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
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
            ),
            SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Container(
                width: medq.width * 0.8,
                //height: medq.height * 0.08,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(7.0),
                  color: const Color(0xff393e46),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 12.0),
                  child: TextField(
                      onChanged: (value) {
                        Instagram=value;
                      },
                      decoration: InputDecoration(

                        border: InputBorder.none,
                        hintText: "Location",
                        hintStyle: TextStyle(

                          fontFamily: 'Roboto',
                          fontSize: medq.height * 0.02,
                          color: const Color(0x5cffffff),
                          fontWeight: FontWeight.w300,
                        ),
                      )),
                ),
              ),
            ),
            SizedBox(height: 30),
            Container(
              width: MediaQuery.of(context).size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.15,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0x3BFF4265)
                      ),
                      child: Center(
                        child: Icon(Icons.arrow_back_ios),
                      ),
                    ),
                  ),
                  SizedBox(width: 15,),
                  GestureDetector(
                    onTap: () async{

                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.25,
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Color(0xFFFF4265)
                      ),
                      child: Center(
                        child: Text('Next', style: TextStyle(fontSize: 20),),
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
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
