import 'dart:io' as io;

// import 'dart:html';
import 'dart:convert';
import 'package:async/async.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:get/get.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:scaape/screens/bottom_navigatin_bar.dart';
import 'package:scaape/utils/constants.dart';
import 'package:scaape/utils/location_class.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:scaape/utils/user_model.dart';

class CreateScaape extends StatefulWidget {
  const CreateScaape({Key? key}) : super(key: key);

  static String id = 'CreateScaape';

  @override
  _CreateScaapeState createState() => _CreateScaapeState();
}

class _CreateScaapeState extends State<CreateScaape> {
  io.File? _image;
  final picker = ImagePicker();
  final pickedImage = ImagePicker();
  var imageurl;
  DateTime dateTime = DateTime.now();

  final ImagePicker _picker = ImagePicker();
  var imageUrl;
  final FirebaseAuth auth = FirebaseAuth.instance;

  TextEditingController scaapeName = TextEditingController();
  TextEditingController scaapeDesc = TextEditingController();
  TextEditingController scaapeLocation = TextEditingController();
  TextEditingController scaapeDate = TextEditingController();
  TextEditingController scaapeActivity = TextEditingController();

  Location _location = Location();
  String longitude = '';
  String latitude = '';

  List<String> locationNames = [];
  List locationData = [];
  List loLat = [];
  List loLong = [];

  getCurrentLocation() async {
    Position position = await _location.getCurrentLocation();
    setState(() {
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
    print(latitude);
    print(longitude);
  }

  @override
  void initState() {
    getCurrentLocation();
    super.initState();
    scaapeDate.text = 'DD/MM/YYY';
  }

  var identifier = new Map();

  var nearbyPlaces;

  Future getNearby(String lat, String long) async {
    var _token = 'fsq3MPCrWAoSAAHkszVJzpf/ge+bsvu4MI+HptEWYMb+4BE=';

    http.Response response = await http.get(
        Uri.parse(
            'https://api.foursquare.com/v3/places/search?near=${lat}%2C${long}&limit=50'),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "$_token",
        });
    print(response.statusCode);
    locationNames.clear();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      print(response.body);
      nearbyPlaces = data;
      // print("hey $nearbyPlaces");
      print(data['results'].length);
      setState(() {
        for (int i = 0; i <= data['results'].length; i++) {
          var locationName = data['results'][i]['name'];
          var locationLat = data['results'][i]['geocodes']['main']['latitude'];
          var locationLong =
          data['results'][i]['geocodes']['main']['longitude'];

          print('$locationName   $locationLong');
          Map<String, dynamic> jsonData = {
            "locationName": locationName,
            "locationLat": locationLat,
            "locationLong": locationLong,
          };

          // identifier[i]["locationName"] = locationName;
          // identifier[i]["locationLat"] = locationLat;
          // identifier[i]["locationLong"] = locationLong;

          // print(JsonEncoder().convert(jsonData));
          locationData.add(JsonEncoder().convert(jsonData));
          print(locationData);

          // print(locationName);
          locationNames.add(locationName);
          // print(locationNames);
        }
      });
    } else {
      return locationNames;
    }
  }

  List<String> getSuggestions(String query) {
    List<String> matches = <String>[];
    matches.addAll(locationNames);

    matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
    return matches;
  }

  Future uploadImage() async {
    final pickedFile = await picker.getImage(
      source: ImageSource.gallery,
      imageQuality: 59,
    );
    setState(
          () {
        if (pickedFile != null) {
          _image = io.File(pickedFile.path);
          print("pickedFile.path");
        } else {
          print('No image selected');
        }
      },
    );

    var paths;
    try {
      String url = 'https://api.scaape.online/testUpload';
      var stream =
      new http.ByteStream(DelegatingStream.typed(_image!.openRead()));
      var length = await _image!.length();
      var request = MultipartRequest('POST', Uri.parse(url));

      var multipartFile = new http.MultipartFile('file', stream, length,
          filename: basename(_image!.path));
      request.files.add(multipartFile);
      var res = await request.send();
      print(res.statusCode);

      await res.stream.transform(utf8.decoder).listen((value) async {
        var data = jsonDecode(value);
        paths = data['path'].toString().substring(7);
        print(paths);
        imageurl = 'https://api.scaape.online/ftp/$paths';
        try {
          String url = 'https://api.scaape.online/api/UpdateVaccineCert';
          Map<String, String> headers = {"Content-type": "application/json"};
          String json =
              '{"VaccineCert":"${imageurl}","UserId":"${auth.currentUser!
              .uid}"}';
          http.Response response =
          await post(Uri.parse(url), headers: headers, body: json);

          int statusCode = response.statusCode;
          print(statusCode);
          print(response.body);
        } catch (e) {
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
  }

  final _formKey = GlobalKey<FormState>();

  Future<bool?> showWarning(BuildContext context) async =>
      showCupertinoDialog<bool>(context: context,
          barrierDismissible: true,
          builder: (context) => CupertinoAlertDialog(
        title: Text('Continue Creating Scaape?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500
        ),),
        content: Text('Stay on this screen to create your scaape!!'),
        actions: [
          CupertinoDialogAction(onPressed: (){
            Navigator.pushNamedAndRemoveUntil(context, HomeScreen.id, (route) => false);
          },

            child: Text('No',style: TextStyle(
                color: Colors.white
            ),),
          ),
          CupertinoDialogAction(onPressed: (){
            Navigator.pop(context,false);
          },
            // elevation: 0,
            // color: ScaapeTheme.kPinkColor.withOpacity(0.04),
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(3)
            // ),
            child: Text('Yes',style: TextStyle(
              color: ScaapeTheme.kPinkColor
            ),),
          )
        ],
      ));


  @override
  Widget build(BuildContext context) {
    final bool keyboardIsOpen = MediaQuery
        .of(context)
        .viewInsets
        .bottom != 0.0;
    final bottom = EdgeInsets
        .fromWindowPadding(
        WidgetsBinding.instance!.window.viewInsets,
        WidgetsBinding.instance!.window.devicePixelRatio)
        .bottom;
    var pref;
    return WillPopScope(
      onWillPop: () async {
        print('hello');
        final shouldPop = await showWarning(context);
        return shouldPop ?? false;
      },
      child: SafeArea(
        child: Scaffold(
          resizeToAvoidBottomInset: true,
          appBar: AppBar(
            leading: GestureDetector(
              onTap: (){
                Navigator.pushNamedAndRemoveUntil(context, HomeScreen.id, (route) => false);
              },
              child: Icon(
                CupertinoIcons.back,
                color: Colors.white,
              ),
            ),
            automaticallyImplyLeading: false,
            title: Row(
              children: [
                Image.asset(
                  'images/app-icon.png',
                  height: 30,
                  width: 30,
                ),
                const Text.rich(
                  TextSpan(
                    style: TextStyle(
                      fontFamily: 'Roboto',
                      fontSize: 22,
                      color: Color(0xfff5f6f9),
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
            foregroundColor: ScaapeTheme.kBackColor,
            backgroundColor: ScaapeTheme.kBackColor,
            shadowColor: ScaapeTheme.kBackColor.withOpacity(0.3),
            elevation: 0,
          ),
          body: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                      onTap: uploadImage,
                      child: Stack(
                        children: [
                          _image != null
                              ? Container(
                            width: double.infinity,
                            height:
                            MediaQuery
                                .of(context)
                                .size
                                .height * 0.2,
                            decoration: BoxDecoration(
                              // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35),bottomRight: Radius.circular(35)),
                              image: DecorationImage(
                                image: FileImage(
                                  _image!,
                                ),
                                // image:
                                //     imageUrl != null ? NetworkImage('imageUrl') : NetworkImage('https://picsum.photos/250?image=9'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                              : Container(
                            // color: Colors.red,
                            width: double.infinity,
                            height:
                            MediaQuery
                                .of(context)
                                .size
                                .height * 0.2,
                            child: Column(
                              children: [
                                const Icon(
                                  Icons.image_outlined,
                                  color: ScaapeTheme.kTextFieldBlue,
                                  size: 78,
                                ),
                                Text(
                                  'Tap to upload image',
                                  style: TextStyle(
                                      color: Colors.grey.withOpacity(0.8)),
                                )
                              ],
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.2,
                            decoration: BoxDecoration(
                              // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35),bottomRight: Radius.circular(35)),
                                gradient: LinearGradient(
                                    colors: [
                                      ScaapeTheme.kBackColor.withOpacity(0.2),
                                      ScaapeTheme.kBackColor,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter)),
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "What's your Scaape Name?",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            onChanged: (value) {},
                            controller: scaapeName,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Scaape Name';
                              }
                              return null;
                            },
                            cursorColor: ScaapeTheme.kPinkColor,
                            maxLines: 1,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                color: ScaapeTheme.kPinkColor,
                                fontSize: 0,
                              ),
                              fillColor: ScaapeTheme.kTextFieldBlue,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                      width: 1, color: ScaapeTheme.kPinkColor)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                      width: 0, color: Colors.transparent)),
                              border: InputBorder.none,
                              hintText: "Let's be creative while scaaping...",
                              hintStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.018,
                                color: const Color(0x5cffffff),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Explain your Scaape",
                          style: const TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            onChanged: (value) {},
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Scaape Description';
                              }
                              return null;
                            },
                            cursorColor: ScaapeTheme.kPinkColor,
                            maxLines: 2,
                            controller: scaapeDesc,
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                color: ScaapeTheme.kPinkColor,
                                fontSize: 0,
                              ),
                              fillColor: ScaapeTheme.kTextFieldBlue,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                      width: 1, color: ScaapeTheme.kPinkColor)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                      width: 0, color: Colors.transparent)),
                              border: InputBorder.none,
                              hintText:
                              "We want to know more about your Scaape...",
                              hintStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.018,
                                color: const Color(0x5cffffff),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Scaape Location",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TypeAheadFormField(
                            textFieldConfiguration: TextFieldConfiguration(
                              onTap: () {
                                getCurrentLocation();

                                getNearby(latitude, longitude);
                              },
                              controller: this.scaapeLocation,
                              cursorColor: ScaapeTheme.kPinkColor,

                              decoration:
                              InputDecoration(
                                fillColor: ScaapeTheme.kTextFieldBlue,
                                filled: true,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 20.0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0),
                                    borderSide: const BorderSide(
                                        width: 1,
                                        color: ScaapeTheme.kPinkColor)),
                                errorBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0),
                                    borderSide: const BorderSide(
                                        width: 0, color: Colors.transparent)),
                                border: InputBorder.none,
                                hintText: 'Scaape Location',
                                hintStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize:
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height * 0.018,
                                  color: const Color(0x5cffffff),
                                  fontWeight: FontWeight.w400,
                                ),),),
                            suggestionsCallback: (pattern) {
                              return getSuggestions(scaapeLocation.text);
                            },
                            itemBuilder: (context, String suggestion) {
                              print(suggestion);
                              return ListTile(
                                title: Text(suggestion),
                              );
                            },
                            transitionBuilder:
                                (context, suggestionsBox, controller) {
                              return suggestionsBox;
                            },
                            onSuggestionSelected: (String suggestion) {
                              this.scaapeLocation.text = suggestion;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        const Text.rich(
                          TextSpan(
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600),
                            children: [
                              TextSpan(
                                text: 'When are you planning this ',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600),
                              ),
                              TextSpan(
                                text: 'Scaape',
                                style: TextStyle(
                                  color: ScaapeTheme.kPinkColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          textHeightBehavior:
                          TextHeightBehavior(applyHeightToFirstAscent: false),
                          textAlign: TextAlign.left,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: TextFormField(
                            controller: scaapeDate,
                            onChanged: (value) {},
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter Scaape Date';
                              }
                              return null;
                            },
                            cursorColor: ScaapeTheme.kPinkColor,
                            maxLines: 1,
                            readOnly: true,
                            onTap: () async {
                              DatePicker.showDateTimePicker(context,
                                  showTitleActions: true,
                                  theme: DatePickerTheme(
                                      backgroundColor: ScaapeTheme.kBackColor,
                                      doneStyle: TextStyle(color: Colors.white),
                                      cancelStyle: TextStyle(
                                          color: Colors.white),
                                      itemStyle: TextStyle(
                                          color: Colors.white)),
                                  minTime: DateTime.now(),
                                  maxTime: DateTime(2021, 12, 31),
                                  onChanged: (date) {
                                    print('change $date');
                                  },
                                  onConfirm: (date) {
                                    print('confirm $date');
                                    dateTime = date;
                                    if (date != null) {
                                      print(
                                          date); //pickedDate output format => 2021-03-10 00:00:00.000
                                      String formattedDate =
                                      DateFormat('dd-MM-yyyy h:mm').format(
                                          date);
                                      print(
                                          formattedDate); //formatted date output using intl package =>  2021-03-16
                                      //you can implement different kind of Date Format here according to your requirement

                                      setState(() {
                                        scaapeDate.text = formattedDate;
                                        //set output date to TextField value.
                                      });
                                    } else {
                                      print("Date is not selected");
                                    }
                                    print("done");
                                  },
                                  currentTime: DateTime.now(),
                                  locale: LocaleType.en);
                            },
                            decoration: InputDecoration(
                              errorStyle: TextStyle(
                                color: ScaapeTheme.kPinkColor,
                                fontSize: 0,
                              ),
                              suffixIcon: const Icon(
                                Icons.event,
                                color: Colors.white,
                              ),
                              fillColor: ScaapeTheme.kTextFieldBlue,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 10.0, horizontal: 20.0),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                      width: 1, color: ScaapeTheme.kPinkColor)),
                              errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7.0),
                                  borderSide: const BorderSide(
                                      width: 0, color: Colors.transparent)),
                              border: InputBorder.none,
                              hintText: "Enter Scaape Date",
                              hintStyle: TextStyle(
                                fontFamily: 'Roboto',
                                fontSize:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.018,
                                color: const Color(0x5cffffff),
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        const Text(
                          "Select your Scaape",
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w600),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Container(
                            // width: MediaQuery.of(context).size.width*0.7,
                            width: double.infinity,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.06,
                            decoration: const BoxDecoration(
                              color: ScaapeTheme.kTextFieldBlue,
                              borderRadius: BorderRadius.all(
                                  Radius.circular(8)),
                            ),
                            child: pref == "Other, I will type it"
                                ? TextField(
                              decoration: InputDecoration(
                                suffixIcon: GestureDetector(
                                    child: const Icon(
                                      Icons.close,
                                    )),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 10.0, horizontal: 10.0),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(7.0),
                                    borderSide: BorderSide.none),
                                focusedBorder: OutlineInputBorder(
                                    borderRadius:
                                    BorderRadius.circular(7.0),
                                    borderSide: const BorderSide(
                                        width: 1,
                                        color: ScaapeTheme.kPinkColor)),
                                border: InputBorder.none,
                                hintText: "Your Preference",
                                hintStyle: TextStyle(
                                  fontFamily: 'Roboto',
                                  fontSize:
                                  MediaQuery
                                      .of(context)
                                      .size
                                      .height *
                                      0.02,
                                  color: const Color(0x5cffffff),
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              onChanged: (value) {
                                pref = value;
                                scaapeActivity.text = pref;
                                print(scaapeActivity.text);
                              },
                            )
                                : DropdownSearch<String>(
                                maxHeight:
                                MediaQuery
                                    .of(context)
                                    .size
                                    .height * 0.3,
                                popupBackgroundColor: ScaapeTheme.kBackColor,
                                popupShape: const RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.all(Radius.circular(8))),
                                dropdownSearchDecoration:
                                const InputDecoration(
                                    hintStyle:
                                    TextStyle(color: Colors.white),
                                    hintText: 'Select Your Activity',
                                    labelStyle:
                                    TextStyle(color: Colors.white),
                                    contentPadding: EdgeInsets.symmetric(
                                        vertical: 5.0, horizontal: 15.0),
                                    border: InputBorder.none),
                                mode: Mode.MENU,
                                showSelectedItems: true,
                                items: const [
                                  'Cycling',
                                  'Trekking',
                                  'Cafe',
                                  'Clubbing',
                                  'Gym',
                                  'Other, I will type it'
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    pref = value;
                                    scaapeActivity.text = pref;
                                    print(scaapeActivity.text);
                                  });
                                }),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery
                              .of(context)
                              .size
                              .height * 0.02,
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: MaterialButton(
                              // height: 50,
                              minWidth: double.infinity,
                              color: ScaapeTheme.kPinkColor,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              onPressed: () async {
                                try {
                                  print(scaapeDate.text);
                                  print(imageUrl);
                                  if (imageUrl != '' && _image != null) {
                                    if (_formKey.currentState!.validate() &&
                                        scaapeActivity.text != '' &&
                                        scaapeDate.text != '' &&
                                        scaapeLocation.text != '') {
                                      print(nearbyPlaces);
                                      var myLat;
                                      var myLong;
                                      for (int j = 0;
                                      j < nearbyPlaces['results'].length;
                                      j++) {
                                        if (nearbyPlaces['results'][j]['name'] ==
                                            scaapeLocation.text) {
                                          myLat = nearbyPlaces['results'][j]
                                          ['geocodes']['main']['latitude'];
                                          myLong = nearbyPlaces['results'][j]
                                          ['geocodes']['main']['longitude'];
                                          break;
                                        }
                                      }
                                      String url =
                                          'https://api.scaape.online/api/createScaape';
                                      Map<String, String> headers = {
                                        "Content-type": "application/json"
                                      };
                                      String json =
                                          '{"ScaapeId": "${DateTime
                                          .now()
                                          .millisecondsSinceEpoch}","UserId": "${auth
                                          .currentUser!
                                          .uid}","ScaapeName": "${scaapeName
                                          .text}","Description": "${scaapeDesc
                                          .text}","Location": "${scaapeLocation
                                          .text}","City": "${scaapeLocation
                                          .text}","ScaapeImg": "${imageurl}","Status": "true","Activity":"${scaapeActivity
                                          .text}","ScaapeDate": "${scaapeDate
                                          .text}","Lat":"$myLat","Lng":"$myLong"}';
                                      http.Response response = await post(
                                          Uri.parse(url),
                                          headers: headers,
                                          body: json);
                                      print(json);
                                      int statusCode = response.statusCode;
                                      print(statusCode);

                                      if (response.body != null ||
                                          response.statusCode == 200) {
                                        print(response.body);
                                        Fluttertoast.showToast(
                                          msg: "Succesfully created",
                                        );
                                        Navigator.pushNamedAndRemoveUntil(
                                            context,
                                            HomeScreen.id, (route) => false);
                                      }
                                    } else {
                                      Fluttertoast.showToast(
                                        msg: 'Enter all the Details',
                                        textColor: Colors.white,
                                        backgroundColor: ScaapeTheme
                                            .kSecondBlue,
                                      );
                                    }
                                  } else {
                                    Fluttertoast.showToast(
                                      msg: 'No Image Uploaded',
                                      textColor: Colors.white,
                                      backgroundColor: ScaapeTheme.kSecondBlue,
                                    );
                                  }
                                } catch (e) {
                                  Fluttertoast.showToast(
                                    msg: e.toString(),
                                    textColor: Colors.white,
                                    backgroundColor: ScaapeTheme.kSecondBlue,
                                  );
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 14),
                                child: const Text(
                                  'Create a Scaape',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
