import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:petitparser/context.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluster/fluster.dart';
import 'package:fluster/src/base_cluster.dart';
import 'package:fluster/src/clusterable.dart';
import 'package:recase/recase.dart';
import 'package:scaape/screens/dashboard_screen.dart';
import 'package:scaape/screens/user_profile_screen.dart';
import 'package:scaape/utils/constants.dart';
import 'package:scaape/utils/scaapeData.dart';

import 'dart:ui' as ui;

class ExplorePage extends StatefulWidget {
  const ExplorePage({Key? key}) : super(key: key);
  static String id = 'explorePage';

  @override
  _ExplorePageState createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  Completer<GoogleMapController> _controllerGoogleMap = Completer();
  late GoogleMapController newGoogleMapController;

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  static final CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );

  late double laitutde;
  late double longitude;

  GlobalKey _key2 = GlobalKey();

  @override
  void initState() {
    scaapesLocator();
  }

  // Map<double,double> scaapeList ={};
  List<Scaapedata> scaapeList = [];
  Future<List<Scaapedata>> scaapesLocator() async {
    String url;
    String uid = FirebaseAuth.instance.currentUser!.uid;
    url =
    'https://api.scaape.online/api/getTrendingScaapesWithAuth/UserId=${uid}';
    print(url);
    http.Response response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);
    int len = data.length;
    print("htis i lens");
    print(len);
    for (int i = 0; i < len; i++) {
      double lat = data[i]['Lat'];
      double long = data[i]['Lng'];
      String img = data[i]['ScaapeImg'];
      String title = data[i]['ScaapeName'];
      String subTitle = data[i]["Location"];
      int clickCount = data[i]["count"];
      String profileDP = data[i]["AdminDP"];
      String name = data[i]["AdminName"];
      String instaId = data[i]["AdminInsta"];
      String description = data[i]["Description"];
      String scaapeId = data[i]["ScaapeId"];
      String userId = data[i]["UserId"];
      String isPresent = data[i]["isPresent"];
      String admin = data[i]["Admin"];

      print(i);
      // print(lat.toString);
      // scaapeList[lat] = long;
      scaapeList.add(Scaapedata(
          lat: lat,
          lon: long,
          scaapeImg: img,
          scaapeName: title,
          location: subTitle,
          clickCount: clickCount,
          profileDP: profileDP,
          name: name,
          InstaID: instaId,
          Description: description,
          admin: admin,
          isPresent: isPresent,
          UID: userId,
          scaapeId: scaapeId));

      // print(scaapeList[lat]);
      // scaapeList.add(data);
    }
    // scaapeList[17.3850] = 78.4867;
    print("this is ");
    // print(scaapeList);

    // print(data);
    getmarkers();
    return scaapeList;
  }

  Future<BitmapDescriptor> convertImageFileToCustomBitmapDescriptor(
      File imageFile,
      {int size = 180,
        bool addBorder = false,
        Color borderColor = Colors.white,
        double borderSize = 10,
        String title = "NO title",
        Color titleColor = Colors.black,
        Color titleBackgroundColor = Colors.white}) async {
    final ui.PictureRecorder pictureRecorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(pictureRecorder);
    final Paint paint = Paint()..color;
    final TextPainter textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );
    final double radius = size / 2;

    //make canvas clip path to prevent image drawing over the circle
    final Path clipPath = Path();
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        Radius.circular(100)));
    clipPath.addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
        Radius.circular(500)));
    canvas.clipPath(clipPath);

    //paintImage
    final Uint8List imageUint8List = await imageFile.readAsBytes();
    final ui.Codec codec = await ui.instantiateImageCodec(imageUint8List);
    final ui.FrameInfo imageFI = await codec.getNextFrame();
    paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
        image: imageFI.image,
        fit: BoxFit.fill);

    if (addBorder) {
      //draw Border
      paint..color = borderColor;
      paint..style = PaintingStyle.stroke;
      paint..strokeWidth = borderSize;
      canvas.drawCircle(Offset(radius, radius), radius, paint);
    }

    if (title != null) {
      if (title.length > 9) {
        title = title.substring(0, 9);
      }
      //draw Title background
      paint..color = titleBackgroundColor;
      paint..style = PaintingStyle.fill;
      canvas.drawRRect(
          RRect.fromRectAndRadius(
              Rect.fromLTWH(0, size * 8 / 10, size.toDouble(), size * 3 / 10),
              Radius.circular(500)),
          paint);

      //draw Title
      textPainter.text = TextSpan(
          text: title,
          style: TextStyle(
            fontSize: radius / 2.5,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ));
      textPainter.layout();
      textPainter.paint(
          canvas,
          Offset(radius - textPainter.width / 2,
              size * 9.5 / 10 - textPainter.height / 2));
    }

    //convert canvas as PNG bytes
    final _image = await pictureRecorder
        .endRecording()
        .toImage(size, (size * 1.1).toInt());
    final data = await _image.toByteData(format: ui.ImageByteFormat.png);

    //convert PNG bytes as BitmapDescriptor
    return BitmapDescriptor.fromBytes(data!.buffer.asUint8List());
  }

  Future<File> urlToFile(String imageUrl) async {
// generate random number.
    var rng = new Random();
// get temporary directory of device.
    Directory tempDir = await getTemporaryDirectory();
// get temporary path from temporary directory.
    String tempPath = tempDir.path;
// create a new file in temporary path with random file name.
    File file = new File('$tempPath' + (rng.nextInt(100)).toString() + '.png');
// call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
    return file;
  }

  void locatePosition() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      laitutde = position.latitude;
      longitude = position.longitude;

      LatLng latLaPosition = LatLng(position.latitude, position.longitude);

      CameraPosition cameraPosition =
      new CameraPosition(target: latLaPosition, zoom: 14);
      newGoogleMapController
          .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      print(longitude);
      print(laitutde);
    } catch (e) {
      print(e);
      print('kuch problem h');
    }
  }

  void setMap(String mapStyle) {
    newGoogleMapController.setMapStyle(mapStyle);
  }

  void loadMap() {
    getJsonFile('mapJson/nigh.json').then(setMap);
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }



  Future<List<dynamic>> getGeoScaapes(
      String id,double lat, double long) async {
    String url;
    print("enter");
    // print(val.isEmpty);
    url = 'https://api.scaape.online/api/getGeoScaapes';
    // print(url);
    final body = {
      "minLat":lat,
      "minLong":long,
      "UserId":"4wxqMpdJzJWkxgoIOeFaSjmBKy33"
    };
    final headers = {HttpHeaders.contentTypeHeader: 'application/json'};
    var response = await post(Uri.parse(url),body: json.encode(body),headers:headers );
    int statusCode = response.statusCode;
    // print(statusCode);
    //print(json.decode(response.body));
    print(statusCode);
    print(response.body);
    return json.decode(response.body);
  }



  final Set<Marker> markers = new Set();

  static const currentZoom = 10;
  @override
  Widget build(BuildContext context) {
    Size medq = MediaQuery.of(context).size;

    return Container(
      child: GoogleMap(
        zoomControlsEnabled: false,
        zoomGesturesEnabled: true,
        initialCameraPosition: _kGooglePlex,
        mapType: MapType.normal,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        padding: EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.5),
        onMapCreated: (GoogleMapController controller) {
          _controllerGoogleMap.complete(controller);
          newGoogleMapController = controller;
          loadMap();
          locatePosition();
        },
        onLongPress: (value) {
          print(value);
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
                child: FutureBuilder(
                  future: getGeoScaapes(
                      FirebaseAuth.instance.currentUser!.uid, value.latitude,value.longitude),
                  builder: (BuildContext context, AsyncSnapshot snapshot) {
                    // print(auther.currentUser!.uid);

                    if (snapshot.hasData) {
                      var a = snapshot.data;
                      // print(a);
                      print("theis is length${snapshot.data.length}");
                      if(snapshot.data.length == 0){
                        return Center(child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: ScaapeTheme.kPinkColor),
                            borderRadius: BorderRadius.circular(8)),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text('No Nearbuy Scaapes', style: TextStyle(fontSize: 20, color: ScaapeTheme.kPinkColor),),
                          ),));
                      }else{
                        return ListView.builder(
                          // physics: NeverScrollableScrollPhysics(),
                          //itemCount: 1,
                          itemCount: snapshot.data.length,
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return HomeCard(() {
                              setState(() {});
                            },
                                medq,
                                a[index]["ScaapeImg"],
                                a[index]["ScaapeName"],
                                a[index]["Description"],
                                a[index]["Location"],
                                a[index]['UserId'],
                                a[index]["ScaapeId"],
                                a[index]["ScaapePref"],   ///
                                a[index]["Admin"],
                                a[index]["isPresent"],
                                a[index]["ScaapeDate"],
                                a[index]["AdminName"],
                                a[index]["AdminEmail"],
                                a[index]["AdminDP"],
                                a[index]["AdminGender"],
                                a[index]["ScaapeDate"],
                                a[index]["count"],
                                _key2
                            );
                          },
                        );
                      }

                    } else {
                      return CircularProgressIndicator(color: ScaapeTheme.kPinkColor);
                    }
                  },
                ),
              ));
        },
        markers: markers.map((e) => e).toSet(),
      ),
    );
  }



  Future<void> getmarkers() async {
    //markers to place on map
    int cnt = 0;

    for (Scaapedata data in scaapeList) {
      // final http.Response response = await http.get(Uri.parse(data.imgURL));
      File im = await urlToFile(data.scaapeImg);

      BitmapDescriptor v = await convertImageFileToCustomBitmapDescriptor(im,
          title: data.scaapeName);
      cnt++;
      print('This is image URL${data.scaapeImg}');
      // print("this is key $key");
      // print("this is value $value");
      markers.add(Marker(
        //add first marker
          markerId: MarkerId(cnt.toString()),
          position: LatLng(data.lat, data.lon), //position of marker
          infoWindow: InfoWindow(
            //popup info
            title: data.scaapeName,
            snippet: data.location,
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
                            // key: tKey,
                            height:
                            MediaQuery.of(context).size.height * 0.4,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(16),
                                  topLeft: Radius.circular(16)),
                              color: Colors.white,
                              image: DecorationImage(
                                image: NetworkImage(data.scaapeImg),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Container(
                            height:
                            MediaQuery.of(context).size.height * 0.4,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(16),
                                    topLeft: Radius.circular(16)),
                                gradient: LinearGradient(
                                    colors: [
                                      ScaapeTheme.kBackColor
                                          .withOpacity(0.2),
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
                                width: MediaQuery.of(context).size.width *
                                    0.13,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(34))),
                              ),
                            ),
                          ),
                          Container(
                            height:
                            MediaQuery.of(context).size.height * 0.56,
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
                                            width: MediaQuery.of(context)
                                                .size
                                                .width *
                                                0.6,
                                            child: Text(
                                              '${data.scaapeName}',
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
                                                  data.clickCount
                                                      .toString(),
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
                                        height: MediaQuery.of(context)
                                            .size
                                            .height *
                                            0.014,
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          String auth = FirebaseAuth
                                              .instance.currentUser!.uid;
                                          auth != data.UID
                                              ? Navigator.pushNamed(context,
                                              UserProfileScreen.id,
                                              arguments: {
                                                "UserId":
                                                "${data.UID}"
                                              })
                                              : null;
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(8)),
                                          ),
                                          width: MediaQuery.of(context)
                                              .size
                                              .width *
                                              0.56,
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
                                                        data.profileDP),
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
                                                CrossAxisAlignment
                                                    .start,
                                                mainAxisAlignment:
                                                MainAxisAlignment
                                                    .center,
                                                children: [
                                                  Container(
                                                    width: MediaQuery.of(
                                                        context)
                                                        .size
                                                        .width *
                                                        0.24,
                                                    child: Text(
                                                      '${data.name}',
                                                      maxLines: 1,
                                                      softWrap: true,
                                                      overflow:
                                                      TextOverflow.clip,
                                                      style: GoogleFonts
                                                          .poppins(
                                                        fontSize: 13,
                                                        fontWeight:
                                                        FontWeight.w500,
                                                      ),
                                                      textAlign:
                                                      TextAlign.left,
                                                    ),
                                                  ),
                                                  Text(
                                                    '@${data.InstaID}',
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
                                        height: MediaQuery.of(context)
                                            .size
                                            .height *
                                            0.02,
                                      ),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8)),
                                        ),
                                        width: MediaQuery.of(context)
                                            .size
                                            .width *
                                            0.75,
                                        child: SingleChildScrollView(
                                          scrollDirection: Axis.vertical,
                                          child: Text(
                                            '${data.Description.length > 80 ? data.Description.substring(0, 80) : data.Description}',
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
                                        height: MediaQuery.of(context)
                                            .size
                                            .height *
                                            0.006,
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
                                            '${data.location}',
                                            maxLines: 1,
                                            style: GoogleFonts.poppins(
                                                fontSize: 10,
                                                fontWeight:
                                                FontWeight.w400),
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
                            height:
                            MediaQuery.of(context).size.height * 0.67,
                            child: Align(
                              alignment: Alignment.bottomCenter,
                              child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 12, horizontal: 19),
                                  child: (data.isPresent == "True" ||
                                      data.isPresent == "true" ||
                                      data.admin == "True" ||
                                      data.admin == "true")
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
                                    height: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.065,
                                    minWidth: double.infinity,
                                    child: Text(
                                      'YOU HAVE ALREADY JOINED',
                                      style: GoogleFonts.roboto(
                                          color:
                                          ScaapeTheme.kPinkColor,
                                          fontSize: 17,
                                          fontWeight:
                                          FontWeight.w500),
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
                                          '{"ScaapeId": "${data.scaapeId}","UserId": "${auth.currentUser!.uid}","TimeStamp": "${DateTime.now().millisecondsSinceEpoch}","Accepted":"0"}';
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
                                    splashColor:
                                    ScaapeTheme.kPinkColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(7)),
                                    ),
                                    color: ScaapeTheme.kPinkColor,
                                    height: MediaQuery.of(context)
                                        .size
                                        .height *
                                        0.065,
                                    minWidth: double.infinity,
                                    child: Text(
                                      'JOIN THIS SCAAPE',
                                      style: GoogleFonts.roboto(
                                          color: Colors.white,
                                          fontSize: 17,
                                          fontWeight:
                                          FontWeight.w500),
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
          icon: v //Icon for Marker
      ));
    }
    setState(() {
      print("list of marker is $markers");
    });
    // scaapeList.forEach((key, value) {
    //
    // });
    //add more markers here
  }
}

class MapMarker extends Clusterable {
  String? locationName;
  String? thumbnailSrc;

  MapMarker(
      {this.locationName,
        latitude,
        longitude,
        this.thumbnailSrc,
        isCluster = false,
        clusterId,
        pointsSize,
        markerId,
        childMarkerId})
      : super(
  latitude: latitude,
  longitude: longitude,
  isCluster: isCluster,
  clusterId: clusterId,
  pointsSize: pointsSize,
  markerId: markerId,
  childMarkerId: childMarkerId);
}


class HomeCard extends StatelessWidget {
  HomeCard(
      this.fun,
      this.medq,
      this.ScapeImage,
      this.ScapeName,
      this.ScapeDescription,
      this.Location,
      this.uid,
      this.scapeId,
      this.pref,   ///
      this.admin,  ///
      this.present,
      this.date,
      this.adminName,
      this.adminEmail,
      this.adminDp,
      this.adminGender,
      this.adminInsta,
      this.count,this.tKey);

  Function fun;
  final Size medq;
  String ScapeImage,
      ScapeName,
      ScapeDescription,
      Location,
      uid,
      scapeId,
      pref,
      admin,
      date,
      present,
      adminName,
      adminEmail,
      adminDp,
      adminGender,
      adminInsta;
  int count;
  Key tKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      child: GestureDetector(
        onTap: () async {
          //TODO:call on click
          final FirebaseAuth auth = FirebaseAuth.instance;
          if ((auth.currentUser!.uid) != uid) {
            onClick(scapeId);
          }
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
                          key: tKey,
                          height: medq.height * 0.4,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                topRight: Radius.circular(16),
                                topLeft: Radius.circular(16)),
                            color: Colors.white,
                            image: DecorationImage(
                              image: NetworkImage(ScapeImage),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          height: medq.height * 0.4,
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
                              width: medq.width * 0.13,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(34))),
                            ),
                          ),
                        ),
                        Container(
                          height: medq.height * 0.56,
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
                                          width: medq.width * 0.6,
                                          child: Text(
                                            '${ScapeName.sentenceCase}',
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
                                                count.toString(),
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
                                      height: medq.height * 0.014,
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
                                        width: medq.width * 0.56,
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
                                                      '${adminDp}'),
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
                                                  width: medq.width * 0.24,
                                                  child: Text(
                                                    '${adminName.titleCase}',
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
                                                  '@${adminInsta.substring(0, 10)}',
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
                                      height: medq.height * 0.02,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(8)),
                                      ),
                                      width: medq.width * 0.75,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Text(
                                          '${ScapeDescription.length > 80 ? ScapeDescription.substring(0, 80) : ScapeDescription.sentenceCase}',
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
                                      height: medq.height * 0.006,
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
                                          '${Location.sentenceCase}',
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
                                  height: medq.height * 0.065,
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
                                        '{"ScaapeId": "${scapeId}","UserId": "${auth.currentUser!.uid}","TimeStamp": "${DateTime.now().millisecondsSinceEpoch}","Accepted":"0"}';
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
                                    fun();
                                  },
                                  elevation: 0,
                                  textColor: Colors.white,
                                  splashColor: ScaapeTheme.kPinkColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(7)),
                                  ),
                                  color: ScaapeTheme.kPinkColor,
                                  height: medq.height * 0.065,
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
        child: Container(
          height: medq.height * 0.3,
          decoration: BoxDecoration(
            color: ScaapeTheme.kBackColor,
            borderRadius: BorderRadius.all(Radius.circular(8)),
            image: DecorationImage(
              image: NetworkImage(ScapeImage),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                  gradient: LinearGradient(colors: [
                    Color(0xFF1C1C1C).withOpacity(0.3),
                    Color(0xFF141414).withOpacity(0.87)
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
                ),
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${ScapeName.sentenceCase}',
                          style: GoogleFonts.lato(
                              fontSize: 21, fontWeight: FontWeight.w500),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(8)),
                          ),
                          width: medq.width * 0.56,
                          child: Text(
                            '${ScapeDescription.length > 80 ? ScapeDescription.substring(0, 80) : ScapeDescription.sentenceCase}',
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                            style: GoogleFonts.nunitoSans(
                              fontSize: 12,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      String auth = FirebaseAuth.instance.currentUser!.uid;
                      auth != uid
                          ? Navigator.pushNamed(context, UserProfileScreen.id,
                          arguments: {"UserId": "${uid}"})
                          : null;
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8)),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 17.0, sigmaY: 17.0),
                        child: Container(
                          height: medq.height * 0.07,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8)),
                            color: Color(0xFF1C1C1C).withOpacity(0.89),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFFF416C),
                                                Color(0xFFFF4B2B)
                                              ],
                                              begin: Alignment.topCenter,
                                              end: Alignment.bottomCenter),
                                          shape: BoxShape.circle),
                                      height: 42,
                                      width: 42,
                                      child: CircleAvatar(
                                        // radius: 33,
                                        backgroundColor:
                                        Color(0xFFFF4B2B).withOpacity(0),
                                        child: CircleAvatar(
                                          backgroundImage:
                                          NetworkImage('${adminDp}'),
                                          backgroundColor: Colors.transparent,
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
                                          width: medq.width * 0.24,
                                          child: Text(
                                            '${adminName.titleCase}',
                                            maxLines: 1,
                                            softWrap: true,
                                            overflow: TextOverflow.clip,
                                            style: GoogleFonts.poppins(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            textAlign: TextAlign.left,
                                          ),
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
                                              '${Location.sentenceCase}',
                                              maxLines: 1,
                                              style: GoogleFonts.poppins(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w400),
                                            )
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                (present == "True" ||
                                    present == "true" ||
                                    admin == "True" ||
                                    admin == "true")
                                    ? OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      primary: ScaapeTheme.kPinkColor,
                                      side: BorderSide(
                                          color: ScaapeTheme.kPinkColor,
                                          width: 1),
                                    ),
                                    onPressed: () {},
                                    child: Text('  Joined  '))
                                    : OutlinedButton(
                                  child: Text('    Join    '),
                                  style: OutlinedButton.styleFrom(
                                    primary: ScaapeTheme.kPinkColor,
                                    side: BorderSide(
                                        color: ScaapeTheme.kPinkColor,
                                        width: 1),
                                  ),
                                  onPressed: () async {
                                    final FirebaseAuth auth =
                                        FirebaseAuth.instance;
                                    String url =
                                        'https://api.scaape.online/api/createParticipant';
                                    Map<String, String> headers = {
                                      "Content-type": "application/json"
                                    };
                                    String json =
                                        '{"ScaapeId": "${scapeId}","UserId": "${auth.currentUser!.uid}","TimeStamp": "${DateTime.now().millisecondsSinceEpoch}","Accepted":"0"}';
                                    http.Response response = await post(
                                        Uri.parse(url),
                                        headers: headers,
                                        body: json);
                                    //print(user.displayName);
                                    int statusCode = response.statusCode;
                                    // print(statusCode);
                                    // print(response.body);
                                    Fluttertoast.showToast(
                                      msg: "Succesfully joined",
                                    );
                                    fun();
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
void onClick(String ScapeId) async {
  try {
    String url = 'https://api.scaape.online/api/OnClick';
    Map<String, String> headers = {"Content-type": "application/json"};
    String json = '{"ScaapeId": "${ScapeId}"}';
    http.Response response =
    await post(Uri.parse(url), headers: headers, body: json);

    int statusCode = response.statusCode;
    // print(statusCode);
    // print(response.body);
    // print("Sucesfully uploaded on click");
  } catch (e) {
    // print(e);
  }
}



