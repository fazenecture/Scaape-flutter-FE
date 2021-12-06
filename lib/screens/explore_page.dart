import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import 'package:petitparser/context.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluster/fluster.dart';
import 'package:fluster/src/base_cluster.dart';
import 'package:fluster/src/clusterable.dart';
import 'package:scaape/utils/scaapeData.dart';

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
  void initState() {
    scaapesLocator();
  }

  // Map<double,double> scaapeList ={};
  List<Scaapedata> scaapeList = [];




  Future<List<Scaapedata>> scaapesLocator() async {
    String url;
    url = 'https://api.scaape.online/api/getScaapes';
    print(url);
    http.Response response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);
    int len = data.length;
    print("htis i lens");
    print(len);
    setState(() {
      for (int i = 0; i < len; i++) {
        double lat = data[i]['Lat'];
        double long = data[i]['Lng'];
        String img = data[i]['ScaapeImg'];
        String scaapeName = data[i]['ScaapeName'];
        String scaapeLocation = data[i]['Location'];
        print(i);
        // print(lat.toString);
        // scaapeList[lat] = long;
        scaapeList.add(Scaapedata(
            lat: lat,
            lon: long,
            imgURL: img,
            sLocation: scaapeLocation,
            sName: scaapeName));

        // print(scaapeList[lat]);
        // scaapeList.add(data);
      }
    });

    // scaapeList[17.3850] = 78.4867;
    print("this is ");
    // print(scaapeList);

    // print(data);
    getmarkers();
    return scaapeList;
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
              padding: EdgeInsets.symmetric(
                  vertical: MediaQuery.of(context).size.height * 0.06),
              onMapCreated: (GoogleMapController controller) {
                _controllerGoogleMap.complete(controller);
                newGoogleMapController = controller;
                loadMap();
                locatePosition();
              },
              onLongPress: (value) {
                print(value);
              },
              markers: markers.map((e) => e).toSet(),
            ),
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
  Future<void> getmarkers() async {
    //markers to place on map
    int cnt = 0;

    for (Scaapedata data in scaapeList) {
      final http.Response response = await http.get(Uri.parse(data.imgURL));

      cnt++;
      print('This is image URL${data.imgURL}');
      // print("this is key $key");
      // print("this is value $value");
      markers.add(Marker(
          //add first marker
          markerId: MarkerId(cnt.toString()),
          position: LatLng(data.lat, data.lon),
          infoWindow: InfoWindow(
            title: data.sName,
            snippet: data.sLocation,
          ),
          icon: BitmapDescriptor.fromBytes(response.bodyBytes) //Icon for Marker
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
