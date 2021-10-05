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

class AddScaape extends StatefulWidget {
  double? latitude;
  double? longitude;
  static String id = 'AddScape';
  @override
  _AddScaapeState createState() => _AddScaapeState();
}

class _AddScaapeState extends State<AddScaape> {
  File? _image;
  String? _base64;
  List? imagesList;
  final picker = ImagePicker();
  DateTime dateTime=DateTime.now();
  List<bool> isSelected = [false, false, false];
  String ScaapeName="",ScapeDescription="",ScaapeLocation="";
  Completer<GoogleMapController> _controller = Completer();
  double? lat;
  double? lon;
  bool loading=false;
  final Set<Marker> _markers = {};
  List<String> genderSelected =['Male','Female','Both'];
  final FirebaseAuth auth = FirebaseAuth.instance;
  String getPrefernce() {
    for(int i=0;i<3;i++){
      if(isSelected[i]){
        return genderSelected[i];
      }
    }
    return "Not selected";
  }
  @override
  Widget build(BuildContext context) {
    var medq = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(left: 25, top: 50),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Image.asset(
                  'images/logo.png',
                  height: 30,
                  width: 30,
                ),
                Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 22,
                      color: const Color(0xfff5f6f9),
                    ),
                    children: [
                      TextSpan(
                        text: 'Create a ',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: 'Scaape',
                        style: TextStyle(
                          color: const Color(0xffff4265),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  textHeightBehavior:
                      TextHeightBehavior(applyHeightToFirstAscent: false),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
            SizedBox(
              height: 40,
            ),
            buildHeading(medq, 'What\'s your Scaape Name?'),
            SizedBox(
              height: 20,
            ),
            Container(
              width: medq.width * 0.8,
              height: medq.height * 0.08,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0),
                color: const Color(0xff393e46),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: TextField(
                  onChanged: (text){
                    ScaapeName=text;
                  },
                    decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Let's be creative while scaaping....",
                  hintStyle: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: medq.height * 0.02,
                    color: const Color(0x5cffffff),
                    fontWeight: FontWeight.w300,
                  ),
                )),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            buildHeading(medq, 'Explain your Scaape'),
            SizedBox(
              height: 20,
            ),
            Container(
              width: medq.width * 0.84,
              height: medq.height * 0.2,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7.0),
                color: const Color(0xff393e46),
              ),
              child: Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: TextField(
                  onChanged: (value) {
                    ScapeDescription=value;
                  },
                  decoration: InputDecoration(

                    border: InputBorder.none,
                    hintText: "We want to know more about your Scaape...",
                    hintStyle: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: medq.height * 0.02,
                      color: const Color(0x5cffffff),
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            buildHeading(medq, 'I would like to Scaape with'),
            SizedBox(
              height: 10,
            ),
            ToggleButtons(
              children: [
                buildButtons(
                    medq,
                    'Men',
                    0.23,
                    ToggleButtons(
                      children: [],
                      isSelected: [],
                    ).fillColor),
                buildButtons(
                    medq,
                    'Women',
                    0.23,
                    ToggleButtons(
                      children: [],
                      isSelected: [],
                    ).fillColor),
                buildButtons(
                    medq,
                    "I'm good with anyone",
                    0.38,
                    ToggleButtons(
                      children: [],
                      isSelected: [],
                    ).fillColor),
              ],
              isSelected: isSelected,
              selectedColor: Colors.red,
              fillColor: Color(0xffff4265),
              onPressed: (int index) {
                setState(() {
                  isSelected = [false, false, false];
                  isSelected[index] = !isSelected[index];
                });
              },
              borderRadius: BorderRadius.zero,
              borderWidth: 0,
              renderBorder: false,
            ),

            SizedBox(
              height: 20,
            ),
            buildHeading(medq, 'When are you planning this Scaape?'),
            SizedBox(
              width: 20,
            ),
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: GestureDetector(
                  onTap: () {
                    DatePicker.showDateTimePicker(context,
                        showTitleActions: true,
                        theme: DatePickerTheme(
                            backgroundColor: Color(0xFF222831),
                            doneStyle: TextStyle(color: Colors.white),
                            cancelStyle: TextStyle(color: Colors.white),
                            itemStyle: TextStyle(color: Colors.white)),
                        minTime: DateTime(2021, 6, 18),
                        maxTime: DateTime(2021, 12, 31), onChanged: (date) {
                      print('change $date');
                    }, onConfirm: (date) {
                      print('confirm $date');
                      dateTime=date;
                      print("done");
                    }, currentTime: DateTime.now(), locale: LocaleType.en);
                  },
                  child: buildButtons(
                      medq, "DD/MM/YYYY", 0.38, Color(0xff393e46))),
            ),
            buildHeading(medq, 'Scaape Location(optional)'),
            SizedBox(
              width: 20,
            ),
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
                      ScaapeLocation=value;
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

            buildHeading(medq, 'Upload Scaape Image'),
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
            SizedBox(
              height: medq.height * 0.1,
            ),
            Row(
              children: [
                Container(
                  height: medq.height * 0.06,
                  width: medq.width * 0.2,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18.0),
                    color: const Color(0x3bff4265),
                  ),
                  child: Center(
                    child: Icon(Icons.arrow_back_ios),
                  ),
                ),
                SizedBox(
                  width: medq.width * 0.36,
                ),
                GestureDetector(
                  onTap: () async{
                    //print(dateTime.toString().substring(0,16));
                    var paths;
                    try{
                      String url='http://65.0.121.93:4000/testUpload';
                      var stream = new http.ByteStream(DelegatingStream.typed(_image!.openRead()));
                      var length = await _image!.length();
                      var request=MultipartRequest('POST',Uri.parse(url));

                      var multipartFile = new http.MultipartFile('file', stream, length, filename: basename(_image!.path));
                      request.files.add(multipartFile);
                      var res=await request.send();
                      print(res.statusCode);

                      await res.stream.transform(utf8.decoder).listen((value) {
                        var data=jsonDecode(value);
                        paths=data['path'].toString().substring(7);
                        print(paths);
                      });
                    }
                    catch(e){
                      print(e);
                    }

                    var imageurl='http://65.0.121.93:4000/ftp/$paths';
                    String url='http://65.0.121.93:4000/api/createScaape';
                    Map<String,String> headers={"Content-type":"application/json"};
                    String json='{"ScaapeId": "${DateTime.now()}","UserId": "${auth.currentUser!.uid}","ScaapeName": "${ScaapeName}","Description": "${ScapeDescription}","ScaapePref": "${getPrefernce()}","Location": "${ScaapeLocation}","ScaapeImg": "${imageurl}","Status": "true","ScaapeDate": "${dateTime.toString().substring(0,16)}"}';
                    http.Response response=await post(Uri.parse(url),headers:headers,body:json);
                    //print(user.displayName);
                    int statusCode = response.statusCode;
                    print(statusCode);
                    print(response.body);

                    },
                  child: Container(
                    height: medq.height * 0.054,
                    width: medq.width * 0.3,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18.0),
                      color: const Color(0xffff4265),
                    ),
                    child: Center(
                      child: Text(
                        'Post',
                        style: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: medq.height * 0.02,
                          color: const Color(0xd4ffffff),
                          height: 1.25,
                        ),
                        textHeightBehavior:
                            TextHeightBehavior(applyHeightToFirstAscent: false),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: medq.height * 0.15,
            ),
          ],
        ),
      ),
    );
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

  Padding buildHeading(Size medq, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Roboto',
          fontSize: medq.height * 0.023,
          color: const Color(0xfff5f6f9),
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
