import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:petitparser/context.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluster/fluster.dart';
import 'package:fluster/src/base_cluster.dart';
import 'package:fluster/src/clusterable.dart';
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

  @override
  void initState(){
    scaapesLocator();
  }

  // Map<double,double> scaapeList ={};
  List<Scaapedata> scaapeList = [];
  Future<List<Scaapedata>> scaapesLocator() async{
    String url;
    url ='https://api.scaape.online/api/getScaapes';
    print(url);
    http.Response response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);
    int len = data.length;
    print("htis i lens");
    print(len);
    for(int i = 0; i < len ; i++){
      double lat = data[i]['Lat'];
      double long = data[i]['Lng'];
      String img = data[i]['ScaapeImg'];
      String title = data[i]['ScaapeName'];
      String subTitle = data[i]["Location"];
      print(i);
      // print(lat.toString);
      // scaapeList[lat] = long;
      scaapeList.add(Scaapedata(lat: lat, lon: long, imgURL:img ,title:title,subTitle: subTitle ));

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

  Future<BitmapDescriptor> convertImageFileToCustomBitmapDescriptor(File imageFile,
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
    final _image =
    await pictureRecorder.endRecording().toImage(size, (size * 1.1).toInt());
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
    File file = new File('$tempPath'+ (rng.nextInt(100)).toString() +'.png');
// call http.get method and pass imageUrl into it to get response.
    http.Response response = await http.get(Uri.parse(imageUrl));
// write bodyBytes received in response to file.
    await file.writeAsBytes(response.bodyBytes);
// now return the file which is created with random name in
// temporary directory and image bytes from response is written to // that file.
    return file;
  }


  void locatePosition () async{

    try{
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      laitutde = position.latitude;
      longitude = position.longitude;

      LatLng latLaPosition = LatLng(position.latitude, position.longitude);


      CameraPosition cameraPosition = new CameraPosition(target: latLaPosition, zoom: 14);
      newGoogleMapController.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));

      print(longitude);
      print(laitutde);
    }
    catch(e){
      print(e);
      print('kuch problem h');
    }
  }


  void setMap(String mapStyle) {
    newGoogleMapController.setMapStyle(mapStyle);
  }
  void loadMap(){
    getJsonFile('mapJson/nigh.json').then(setMap);
  }
  Future<String> getJsonFile(String path) async{
    return await rootBundle.loadString(path);
  }
  final Set<Marker> markers = new Set();


  static const currentZoom = 10;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Stack(
          children: [
            GoogleMap(
              zoomControlsEnabled: true,
              zoomGesturesEnabled: true,
              initialCameraPosition: _kGooglePlex,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              padding: EdgeInsets.only(top: MediaQuery.of(context).size.height*0.5),
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                loadMap();
                locatePosition();
              },
              onLongPress: (value){
                print(value);
              },
              markers: markers.map((e) => e).toSet(),
            ),
            Center(
              child: MaterialButton(
                color: Colors.black,
                child: Text(
                    'Press to Pres'
                ),
                onPressed: () async{
                  scaapesLocator().then((value){
                    print(value);
                  });
                },
              ),
            )



          ],
        ),
      ),




    );
  }
  // Future<Uint8List> getUint8List(var image) async {
  //
  //   // ByteData byteData = await image.;
  //   // return byteData.buffer.asUint8List();
  // }
  Future<void> getmarkers() async { //markers to place on map
    int cnt = 0;

    for(Scaapedata data in scaapeList){
      // final http.Response response = await http.get(Uri.parse(data.imgURL));
      File im = await urlToFile(data.imgURL);

      BitmapDescriptor v = await convertImageFileToCustomBitmapDescriptor(im,title: data.title);
      cnt++;
      print('This is image URL${data.imgURL}');
      // print("this is key $key");
      // print("this is value $value");
      markers.add(Marker( //add first marker
          markerId: MarkerId(cnt.toString()),
          position: LatLng(data.lat, data.lon), //position of marker
          infoWindow: InfoWindow( //popup info
            title: data.title,
            snippet: data.subTitle,
          ),

          icon: v//Icon for Marker
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


