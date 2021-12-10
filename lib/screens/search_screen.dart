import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flappy_search_bar_ns/flappy_search_bar_ns.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:recase/recase.dart';
import 'package:scaape/screens/user_profile_screen.dart';
import 'package:scaape/utils/constants.dart';

import 'create_scaape.dart';

class SearchPage extends StatefulWidget {
  static String id = 'Search_Page';

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<String> locationNames = [];
  List scaapeData = [];
  List loLat = [];
  List loLong = [];
  TextEditingController scaapeNameSearch = TextEditingController();

  var identifier = new Map();

  var nearbyPlaces;

  Future getNearby(id) async {


    String url = 'https://api.scaape.online/api/getScaapesWithAuth/UserId=${id}';
    http.Response response =
        await http.get(Uri.parse(url));
    print(response.statusCode);
    locationNames.clear();
    scaapeData.clear();

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      // print(response.body);
      return data;
    } else {
      return null;
    }
  }

  // List<String> getSuggestions(String query) {
  //   List<String> matches = <String>[];
  //   matches.addAll(locationNames);
  //
  //   matches.retainWhere((s) => s.toLowerCase().contains(query.toLowerCase()));
  //   return matches;
  // }

  List results = [];

  @override
  void initState() {
    _focusNodes.forEach((node){
      node.addListener(() {
        setState(() {});
      });
    });

    super.initState();
    scaapeNameSearch = TextEditingController();
  }

  void setResults(String query) {
    // print('heea');
    results = scaapeData
        .where((elem) =>
            elem['ScaapeName']
                .toString()
                .toLowerCase()
                .contains(query.toLowerCase()) ||
            elem['City'].toString().toLowerCase().contains(query.toLowerCase()))
        .toList();
    // print(results);
  }

  String query = '';
  var uid;
  List<FocusNode> _focusNodes = [
    FocusNode(),
    FocusNode(),
  ];

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    uid = auth.currentUser!.uid;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        foregroundColor: Colors.transparent,
        backgroundColor: ScaapeTheme.kBackColor,
        shadowColor: ScaapeTheme.kSecondBlue,
        elevation: 1,
        leading: GestureDetector(
          onTap: (){
            Navigator.pop(context);
          },
          child: Icon(
            CupertinoIcons.back,
            color: Colors.white,
          ),
        ),
        title: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                'Scaape Search',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 22,
                ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pushReplacementNamed(context, CreateScaape.id);
                },
                child: Icon(
                  Icons.add_rounded,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
      body: SafeArea(
        child: FutureBuilder(
          future: getNearby(auth.currentUser!.uid),
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            // print('furredata ${snapshot.data}');

            var data = snapshot.data;
            // print(data);
            if(ConnectionState.waiting == snapshot.connectionState){
              return Center(
                child: CircularProgressIndicator(
                  color: ScaapeTheme.kPinkColor,
                ),
              );
            }else{
              if(snapshot.hasData){
                return Container(
                  color: ScaapeTheme.kBackColor,
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          focusNode: _focusNodes[0],
                          controller: scaapeNameSearch,
                          cursorColor: ScaapeTheme.kPinkColor,
                          maxLines: 1,
                          decoration: InputDecoration(
                            errorStyle: TextStyle(
                              color: ScaapeTheme.kPinkColor,
                              fontSize: 0,
                            ),
                            suffixIcon: Icon(
                              Icons.search,
                              color: _focusNodes[0].hasFocus ? ScaapeTheme.kPinkColor : Colors.grey,
                            ),
                            focusColor: ScaapeTheme.kPinkColor,
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
                                    width: 0.7, color: ScaapeTheme.kPinkColor)),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: const BorderSide(
                                    width: 0, color: Colors.transparent)),
                            border: InputBorder.none,
                            hintText: "Search for Scaapes...",
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
                          onChanged: (v) {
                            setState(() {
                              query = v;
                              setResults(query);
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: data.length,
                          itemBuilder: (context, index) {
                            print('hello');
                            String scaapeNameforSearch = data[index]['ScaapeName'].toString();
                            String scaapeCityforSearch = data[index]['Location'].toString();
                            if (scaapeNameforSearch.toLowerCase().contains(scaapeNameSearch.text) ||
                                scaapeCityforSearch.toLowerCase().contains(scaapeNameSearch.text)) {
                              var scaapesId = data[index]['ScaapeId'];
                              var scaapeDesc = data[index]['Description'].toString();
                              var scaapeImg =  data[index]['ScaapeImg'];
                              var scaapeAdmin = data[index]['AdminName'].toString();
                              var scaapeDate = data[index]['ScaapeDate'].toString();
                              var scaapeAdminImg = data[index]['AdminDP'].toString();
                              var scaapeCity = data[index]['City'].toString();
                              var scaapeName  = data[index]['ScaapeName'].toString();
                              var scaapeLocation = data[index]['Location'].toString();
                              var scaapeCount =  data[index]['count'].toString();
                              var adminInsta =  data[index]['AdminInsta'].toString();
                              var present =  data[index]['isPresent'];
                              var admin =  data[index]['Admin'];
                              return ListTile(
                                hoverColor: ScaapeTheme.kShimmerColor,
                                focusColor: ScaapeTheme.kShimmerColor,
                                leading: CircleAvatar(
                                  backgroundImage: NetworkImage(scaapeImg),
                                ),
                                title: Text(scaapeName.toString().sentenceCase, style: TextStyle(
                                    color: Colors.white
                                ),),
                                subtitle: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.location_on_outlined,color: Colors.white,size: 14,),
                                    Text(scaapeLocation, style: TextStyle(
                                        color: ScaapeTheme.kSecondTextCollor,
                                        fontSize: 12
                                    ),),
                                  ],
                                ),
                                onTap: () {
                                    showMaterialModalBottomSheet(
                                        backgroundColor: ScaapeTheme.kBackColor,
                                        context: context,
                                        elevation: 13,
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(16),
                                                topLeft: Radius.circular(16))),
                                        builder: (context) => Container(
                                          height: MediaQuery.of(context).size.height * 0.7,
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Stack(
                                                children: [
                                                  Container(

                                                    height: MediaQuery.of(context).size.height * 0.4,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.only(
                                                          topRight: Radius.circular(16),
                                                          topLeft: Radius.circular(16)),
                                                      color: Colors.white,
                                                      image: DecorationImage(
                                                        image: NetworkImage(scaapeImg),
                                                        fit: BoxFit.cover,
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: MediaQuery.of(context).size.height * 0.4,
                                                    decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.only(
                                                            topRight: Radius.circular(16),
                                                            topLeft: Radius.circular(16)),
                                                        gradient: LinearGradient(
                                                            colors: [
                                                              ScaapeTheme.kBackColor.withOpacity(0.2),
                                                              ScaapeTheme.kBackColor
                                                            ],
                                                            begin: Alignment.topCenter,
                                                            end: Alignment.bottomCenter)),
                                                  ),
                                                  Align(
                                                    alignment: Alignment.topCenter,
                                                    child: Padding(
                                                      padding: const EdgeInsets.all(10.0),
                                                      child: Container(
                                                        height: 5.5,
                                                        width: MediaQuery.of(context).size.width * 0.13,
                                                        decoration: BoxDecoration(
                                                            color: Colors.white,
                                                            borderRadius: BorderRadius.all(
                                                                Radius.circular(34))),
                                                      ),
                                                    ),
                                                  ),
                                                  Container(
                                                    height: MediaQuery.of(context).size.height * 0.56,
                                                    child: Column(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Padding(
                                                          padding: EdgeInsets.symmetric(
                                                              horizontal: 23, vertical: 18),
                                                          child: Column(
                                                            mainAxisSize: MainAxisSize.min,
                                                            crossAxisAlignment:
                                                            CrossAxisAlignment.start,
                                                            children: [
                                                              Row(
                                                                crossAxisAlignment:
                                                                CrossAxisAlignment.start,
                                                                mainAxisAlignment:
                                                                MainAxisAlignment.spaceBetween,
                                                                children: [
                                                                  Container(
                                                                    width: MediaQuery.of(context).size.width * 0.6,
                                                                    child: Text(
                                                                      '${scaapeName.toString().sentenceCase}',
                                                                      style: GoogleFonts.lato(
                                                                          fontSize: 24,
                                                                          fontWeight:
                                                                          FontWeight.w500),
                                                                      maxLines: 2,
                                                                      softWrap: true,
                                                                      overflow: TextOverflow.clip,
                                                                    ),
                                                                  ),
                                                                  Container(
                                                                    child: Row(
                                                                      children: [
                                                                        Icon(Icons.group_outlined),
                                                                        Text(
                                                                          scaapeCount.toString(),
                                                                          style: GoogleFonts.lato(
                                                                              fontSize: 21,
                                                                              fontWeight:
                                                                              FontWeight.w500),
                                                                        )
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              ),
                                                              SizedBox(
                                                                height: MediaQuery.of(context).size.height * 0.014,
                                                              ),
                                                              GestureDetector(
                                                                onTap: () {
                                                                  String auth = FirebaseAuth
                                                                      .instance.currentUser!.uid;
                                                                  auth != uid
                                                                      ? Navigator.pushNamed(context,
                                                                      UserProfileScreen.id,
                                                                      arguments: {
                                                                        "UserId": "${uid}"
                                                                      })
                                                                      : null;
                                                                },
                                                                child: Container(
                                                                  decoration: BoxDecoration(
                                                                    borderRadius: BorderRadius.all(
                                                                        Radius.circular(8)),
                                                                  ),
                                                                  width: MediaQuery.of(context).size.width * 0.56,
                                                                  child: Row(
                                                                    children: [
                                                                      Container(
                                                                        decoration: BoxDecoration(
                                                                            gradient: LinearGradient(
                                                                                colors: [
                                                                                  Color(0xFFFF416C),
                                                                                  Color(0xFFFF4B2B)
                                                                                ],
                                                                                begin: Alignment
                                                                                    .topCenter,
                                                                                end: Alignment
                                                                                    .bottomCenter),
                                                                            shape: BoxShape.circle),
                                                                        height: 42,
                                                                        width: 42,
                                                                        child: CircleAvatar(
                                                                          // radius: 33,
                                                                          backgroundColor:
                                                                          Color(0xFFFF4B2B)
                                                                              .withOpacity(0),
                                                                          child: CircleAvatar(
                                                                            backgroundImage:
                                                                            NetworkImage(
                                                                                '${scaapeAdminImg}'),
                                                                            backgroundColor:
                                                                            Colors.transparent,
                                                                            // radius: 34,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                        width: 8,
                                                                      ),
                                                                      Column(
                                                                        crossAxisAlignment:
                                                                        CrossAxisAlignment.start,
                                                                        mainAxisAlignment:
                                                                        MainAxisAlignment.center,
                                                                        children: [
                                                                          Container(
                                                                            width: MediaQuery.of(context).size.width * 0.24,
                                                                            child: Text(
                                                                              '${scaapeAdmin.titleCase}',
                                                                              maxLines: 1,
                                                                              softWrap: true,
                                                                              overflow:
                                                                              TextOverflow.clip,
                                                                              style:
                                                                              GoogleFonts.poppins(
                                                                                fontSize: 13,
                                                                                fontWeight:
                                                                                FontWeight.w500,
                                                                              ),
                                                                              textAlign:
                                                                              TextAlign.left,
                                                                            ),
                                                                          ),
                                                                          Text(
                                                                            '${scaapeDate.toString().substring(0,10)}',
                                                                            maxLines: 1,
                                                                            style:
                                                                            GoogleFonts.poppins(
                                                                                fontSize: 10,
                                                                                fontWeight:
                                                                                FontWeight
                                                                                    .w400),
                                                                          ),
                                                                        ],
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: MediaQuery.of(context).size.height * 0.02,
                                                              ),
                                                              Container(
                                                                decoration: BoxDecoration(
                                                                  borderRadius: BorderRadius.all(
                                                                      Radius.circular(8)),
                                                                ),
                                                                width: MediaQuery.of(context).size.width * 0.75,
                                                                child: SingleChildScrollView(
                                                                  scrollDirection: Axis.vertical,
                                                                  child: Text(
                                                                    '${scaapeDesc.length > 80 ? scaapeDesc.substring(0, 80) : scaapeDesc.sentenceCase}',
                                                                    maxLines: 4,
                                                                    overflow: TextOverflow.ellipsis,
                                                                    softWrap: true,
                                                                    style: GoogleFonts.nunitoSans(
                                                                      fontSize: 17,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              SizedBox(
                                                                height: MediaQuery.of(context).size.height * 0.006,
                                                              ),
                                                              Row(
                                                                mainAxisAlignment:
                                                                MainAxisAlignment.start,
                                                                children: [
                                                                  Icon(
                                                                    Icons.location_on_outlined,
                                                                    size: 12,
                                                                  ),
                                                                  Text(
                                                                    '${scaapeLocation.sentenceCase}',
                                                                    maxLines: 1,
                                                                    style: GoogleFonts.poppins(
                                                                        fontSize: 10,
                                                                        fontWeight: FontWeight.w400),
                                                                  )
                                                                ],
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  Container(
                                                    height: MediaQuery.of(context).size.height * 0.67,
                                                    child: Align(
                                                      alignment: Alignment.bottomCenter,
                                                      child: Padding(
                                                          padding: const EdgeInsets.symmetric(
                                                              vertical: 12, horizontal: 19),
                                                          child: (present == "True" ||
                                                              present == "true" ||
                                                              admin == "True" ||
                                                              admin == "true")
                                                              ? MaterialButton(
                                                            onPressed: null,
                                                            elevation: 0,
                                                            textColor: Colors.white,
                                                            splashColor: Colors.transparent,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.all(
                                                                  Radius.circular(7)),
                                                            ),
                                                            disabledColor: ScaapeTheme
                                                                .kPinkColor
                                                                .withOpacity(0.15),
                                                            disabledTextColor:
                                                            ScaapeTheme.kPinkColor,
                                                            color: ScaapeTheme.kPinkColor
                                                                .withOpacity(0.2),
                                                            height: MediaQuery.of(context).size.height * 0.065,
                                                            minWidth: double.infinity,
                                                            child: Text(
                                                              'YOU HAVE ALREADY JOINED',
                                                              style: GoogleFonts.roboto(
                                                                  color: ScaapeTheme.kPinkColor,
                                                                  fontSize: 17,
                                                                  fontWeight: FontWeight.w500),
                                                            ),
                                                          )
                                                              : MaterialButton(
                                                            onPressed: () async {

                                                              final FirebaseAuth auth =
                                                                  FirebaseAuth.instance;
                                                              String url =
                                                                  'https://api.scaape.online/api/createParticipant';
                                                              Map<String, String> headers = {
                                                                "Content-type":
                                                                "application/json"
                                                              };
                                                              String json =
                                                                  '{"ScaapeId": "${scaapesId}","UserId": "${auth.currentUser!.uid}","TimeStamp": "${DateTime.now().millisecondsSinceEpoch}","Accepted":"0"}';
                                                              http.Response response =
                                                              await post(Uri.parse(url),
                                                                  headers: headers,
                                                                  body: json);
                                                              //print(user.displayName);
                                                              int statusCode =
                                                                  response.statusCode;
                                                              // print(statusCode);
                                                              // print(response.body);
                                                              Fluttertoast.showToast(
                                                                msg: "Succesfully joined",
                                                              );
                                                              // fun();
                                                            },
                                                            elevation: 0,
                                                            textColor: Colors.white,
                                                            splashColor: ScaapeTheme.kPinkColor,
                                                            shape: RoundedRectangleBorder(
                                                              borderRadius: BorderRadius.all(
                                                                  Radius.circular(7)),
                                                            ),
                                                            color: ScaapeTheme.kPinkColor,
                                                            height: MediaQuery.of(context).size.height * 0.065,
                                                            minWidth: double.infinity,
                                                            child: Text(
                                                              'JOIN THIS SCAAPE',
                                                              style: GoogleFonts.roboto(
                                                                  color: Colors.white,
                                                                  fontSize: 17,
                                                                  fontWeight: FontWeight.w500),
                                                            ),
                                                          )),
                                                    ),
                                                  )
                                                ],
                                              )
                                            ],
                                          ),
                                        ));

                                },
                              );
                            } else {
                              return Container();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                );
              }else{
                return Text(
                  "Looks There Some Issue"
                );
              }
            }
          },
        ),
      ),
    );
  }
}
