import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:http/http.dart' as http;
import 'package:petitparser/context.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:fluster/fluster.dart';
import 'package:fluster/src/base_cluster.dart';
import 'package:fluster/src/clusterable.dart';



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

  List<dynamic> scaapeList = [];

  Future<List<dynamic>> scaapesLocator() async{
    String url;
    url ='https://api.scaape.online/api/getScaapes';
    print(url);
    http.Response response = await http.get(Uri.parse(url));
    var data = json.decode(response.body);
    int len = data.length;
    print(len);
    for(int i = 0; i <= len ; i++){
      double lat = data[i]['Lat'];
      double long = data[i]['Lng'];

      scaapeList.add(data);
    }




    // print(data);
    return scaapeList;

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
                locatePosition();
              },
              markers: getmarkers(),
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
  Set<Marker> getmarkers() { //markers to place on map
    setState(() {
      markers.add(Marker( //add first marker
        markerId: MarkerId(_kGooglePlex.toString()),
        position: LatLng(28.594313, 77.315015), //position of marker
        infoWindow: InfoWindow( //popup info
          title: 'Marker Title First ',
          snippet: 'My Custom Subtitle',
        ),
        icon: BitmapDescriptor.defaultMarker, //Icon for Marker
      ));
      //add more markers here
    });

    return markers;
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


