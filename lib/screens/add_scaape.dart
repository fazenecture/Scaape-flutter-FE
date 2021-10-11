import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:async/async.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:path/path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:scaape/screens/home_screen.dart';
import 'package:scaape/utils/constants.dart';

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
  DateTime dateTime = DateTime.now();
  List<bool> isSelected = [false, false, false];
  String ScaapeName = "", ScapeDescription = "", ScaapeLocation = "";
  Completer<GoogleMapController> _controller = Completer();
  double? lat;
  double? lon;
  bool loading = false;
  var pref;
  final Set<Marker> _markers = {};
  List<String> genderSelected = ['Male', 'Female', 'Both'];
  final FirebaseAuth auth = FirebaseAuth.instance;
  bool isLoading=false;
  String getPrefernce() {
    for (int i = 0; i < 3; i++) {
      if (isSelected[i]) {
        return genderSelected[i];
      }
    }
    return "Not selected";
  }

  Future<bool> _willPopCallback() async {
    // await showDialog or Show add banners or whatever
    // then
    AlertDialog(
      title: Text(
        'Not in mood to create a scaape?\nDo you still want to exit?'
      ),

    );

    return true; // return true if the route to be popped
  }

  @override
  Widget build(BuildContext context) {
    bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom != 0;
    var medq = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: (){
        return _willPopCallback();
      },
      child: Scaffold(
        // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        // floatingActionButton: Visibility(
        //   visible: !keyboardIsOpen,
        //   child: Padding(
        //     padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        //     child: MaterialButton(
        //       onPressed: () {},
        //       elevation: 0,
        //       textColor: Colors.white,
        //       splashColor: Colors.transparent,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.all(Radius.circular(7)),
        //       ),
        //       color: ScaapeTheme.kPinkColor,
        //       height: medq.height * 0.057,
        //       minWidth: double.infinity,
        //       child: Text(
        //         'Create Scaape',
        //         style: GoogleFonts.roboto(
        //             color: ScaapeTheme.kSecondTextCollor,
        //             fontSize: 17,
        //             fontWeight: FontWeight.w500),
        //       ),
        //     ),
        //   ),
        // ),
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          title: Row(
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
                        color: ScaapeTheme.kPinkColor,
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
          leading: IconButton(
            icon: Icon(CupertinoIcons.back, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, HomeScreen.id);
            },
          ),
          foregroundColor: ScaapeTheme.kBackColor,
          backgroundColor: ScaapeTheme.kBackColor,
          shadowColor: ScaapeTheme.kBackColor.withOpacity(0.3),
        ),
        body: isLoading?Center(child:CircularProgressIndicator()):
        SingleChildScrollView(
          scrollDirection: Axis.vertical,
          // keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.manual,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row(
                //   children: [
                //     Image.asset(
                //       'images/logo.png',
                //       height: 30,
                //       width: 30,
                //     ),
                //     Text.rich(
                //       TextSpan(
                //         style: TextStyle(
                //           fontFamily: 'Roboto',
                //           fontSize: 22,
                //           color: const Color(0xfff5f6f9),
                //         ),
                //         children: [
                //           TextSpan(
                //             text: 'Create a ',
                //             style: TextStyle(
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //           TextSpan(
                //             text: 'Scaape',
                //             style: TextStyle(
                //               color: ScaapeTheme.kPinkColor,
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //         ],
                //       ),
                //       textHeightBehavior:
                //           TextHeightBehavior(applyHeightToFirstAscent: false),
                //       textAlign: TextAlign.left,
                //     ),
                //   ],
                // ),
                SizedBox(
                  height: medq.height * 0.05,
                ),
                buildHeading(medq, 'What\'s your Scaape Name?'),
                SizedBox(
                  height: medq.height * 0.01,
                ),
                Container(
                  width: double.infinity,
                  // height: medq.height * 0.08,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(7.0),
                    color: const Color(0xff393e46),
                  ),
                  child: TextField(
                      onChanged: (text) {
                        ScaapeName = text;
                      },
                      cursorColor: ScaapeTheme.kPinkColor,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 20.0),
                        enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(7.0),
                            borderSide: BorderSide(
                                width: 1, color: ScaapeTheme.kPinkColor)),
                        border: InputBorder.none,
                        hintText: "Let's be creative while scaaping....",
                        hintStyle: TextStyle(
                          fontFamily: 'Roboto',
                          fontSize: medq.height * 0.02,
                          color: const Color(0x5cffffff),
                          fontWeight: FontWeight.w400,
                        ),
                      )),
                ),
                SizedBox(
                  height: 20,
                ),
                buildHeading(medq, 'Explain your Scaape'),
                SizedBox(
                  height: medq.height * 0.01,
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
                      ScapeDescription = value;
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
                      hintText: "We want to know more about your Scaape...",
                      hintStyle: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: medq.height * 0.02,
                        color: const Color(0x5cffffff),
                        fontWeight: FontWeight.w400,
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
                          textStyle: GoogleFonts.roboto(
                            fontSize: medq.height * 0.015,
                            color: ScaapeTheme.kPinkColor,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [],
                          isSelected: [],
                        ).fillColor),
                  ],
                  isSelected: isSelected,
                  selectedColor: ScaapeTheme.kPinkColor,
                  textStyle: GoogleFonts.roboto(
                    fontSize: medq.height * 0.015,
                    color: ScaapeTheme.kPinkColor,
                    fontWeight: FontWeight.w400,
                  ),
                  fillColor: ScaapeTheme.kPinkColor.withOpacity(0.2),
                  onPressed: (int index) {
                    setState(() {
                      isSelected = [false, false, false];
                      isSelected[index] = !isSelected[index];
                    });
                  },
                  borderRadius: BorderRadius.all(Radius.circular(7)),
                  borderWidth: 0,
                  renderBorder: false,
                ),

                SizedBox(
                  height: medq.height * 0.02,
                ),
                buildHeading(medq, 'When are you planning this Scaape?'),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: GestureDetector(
                      onTap: () {
                        DatePicker.showDateTimePicker(context,
                            showTitleActions: true,
                            theme: DatePickerTheme(
                                backgroundColor: ScaapeTheme.kBackColor,
                                doneStyle: TextStyle(color: Colors.white),
                                cancelStyle: TextStyle(color: Colors.white),
                                itemStyle: TextStyle(color: Colors.white)),
                            minTime: DateTime(2021, 6, 18),
                            maxTime: DateTime(2021, 12, 31), onChanged: (date) {
                              print('change $date');
                            }, onConfirm: (date) {
                              print('confirm $date');
                              dateTime = date;
                              print("done");
                            }, currentTime: DateTime.now(), locale: LocaleType.en);
                      },
                      child: Row(
                        children: [
                          Container(
                            width: medq.width * 0.5,
                            height: medq.height * 0.05,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(7.0),
                              color: ScaapeTheme.kSecondBlue,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  '${dateTime.day}/${dateTime.month}/${dateTime.year}',
                                  style: TextStyle(
                                    fontFamily: 'Roboto',
                                    fontSize: medq.height * 0.019,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Icon(CupertinoIcons.calendar)
                              ],
                            ),
                          ),
                        ],
                      )),
                ),
                SizedBox(
                  height: medq.height * 0.02,
                ),
                buildHeading(medq, 'Select Your Preference'),
                SizedBox(
                  height: medq.height * 0.012,
                ),
                Container(
                  width: medq.width*0.7,
                  height: medq.height*0.06,
                  decoration: BoxDecoration(
                    color: ScaapeTheme.kSecondBlue,
                    borderRadius: BorderRadius.all(Radius.circular(8)),

                  ),
                  child: pref == "Other, I will type it" ? TextField(
                  ) : DropdownSearch<String>(
                    maxHeight: medq.height*0.3,
                    popupBackgroundColor: ScaapeTheme.kBackColor,
                    popupShape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))
                    ),
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Select Your Preference',
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 5.0, horizontal: 15.0
                        ),
                        border: InputBorder.none),
                    mode: Mode.MENU,
                    showSelectedItems: true,
                    items: ['Cycling','Trekking', 'Cafe','Clubbing','Gym','Other, I will type it'],
                    onChanged: (value){
                      setState(() {
                        pref = value;
                        print(pref);
                      });
                    }
                  ),
                ),
                SizedBox(
                  height: medq.height * 0.02,
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
                          cursorColor: ScaapeTheme.kPinkColor,
                          onChanged: (value) {
                            ScaapeLocation = value;
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
                    GestureDetector(
                      onTap: () {},
                      child: Container(
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
                    ),
                    SizedBox(
                      width: medq.width * 0.36,
                    ),
                    GestureDetector(
                      onTap: () async {
                        print(DateTime.now().millisecondsSinceEpoch);
                        print(dateTime.toString().substring(0, 16));
                        if (ScaapeName.isEmpty ||
                            ScapeDescription.isEmpty ||
                            getPrefernce() == "Not selected" ||
                            ScaapeLocation.isEmpty||_image.isNull) {
                          Fluttertoast.showToast(
                            msg: "enter all details",
                          );
                        } else {
                          setState(() {
                            isLoading=true;
                          });
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
                                .listen((value) {
                              var data = jsonDecode(value);
                              paths = data['path'].toString().substring(7);
                              print(paths);
                            });
                          } catch (e) {
                            print(e);
                          }

                          var imageurl = 'https://api.scaape.online/ftp/$paths';
                          String url = 'https://api.scaape.online/api/createScaape';
                          Map<String, String> headers = {
                            "Content-type": "application/json"
                          };
                          String json =
                              '{"ScaapeId": "${DateTime.now().millisecondsSinceEpoch}","UserId": "${auth.currentUser!.uid}","ScaapeName": "${ScaapeName}","Description": "${ScapeDescription}","ScaapePref": "${getPrefernce()}","Location": "${ScaapeLocation}","ScaapeImg": "${imageurl}","Status": "true","ScaapeDate": "${dateTime.toString().substring(0, 16)}"}';
                          http.Response response = await post(Uri.parse(url),
                              headers: headers, body: json);
                          //print(user.displayName);
                          int statusCode = response.statusCode;
                          print(statusCode);
                          print(response.body);
                          Fluttertoast.showToast(
                            msg: "Succesfully created",
                          );
                          setState(() {
                            isLoading=false;
                          });
                          Navigator.pushNamedAndRemoveUntil(context,HomeScreen.id, (route) => false);
                        }

                      },
                      child: Container(
                        height: medq.height * 0.054,
                        width: medq.width * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18.0),
                          color: ScaapeTheme.kPinkColor,
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
                            textHeightBehavior: TextHeightBehavior(
                                applyHeightToFirstAscent: false),
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
            fontSize: medq.height * 0.015,
            color: Colors.white,
            fontWeight: FontWeight.w400,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Padding buildHeading(Size medq, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 10.0, bottom: 4),
      child: Text(
        text,
        style: GoogleFonts.roboto(
          fontSize: medq.height * 0.02,
          color: ScaapeTheme.kSecondTextCollor,
        ),
        textAlign: TextAlign.left,
      ),
    );
  }
}
