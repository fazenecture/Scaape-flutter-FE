import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:transparent_image/transparent_image.dart';
import 'package:http/http.dart';



class StaggeredVeiw extends StatefulWidget {
  @override
  _StaggeredVeiwState createState() => _StaggeredVeiwState();
}

var currentUser = FirebaseAuth.instance.currentUser;

getCurrentUser() async {
  if (currentUser != null) {
    return currentUser;
  }
}


class _StaggeredVeiwState extends State<StaggeredVeiw> {


  @override
  void initState() {
    super.initState();
    getImages();
  }

  getCurrentUser() async {
    if (currentUser != null) {
      return currentUser;
    }
  }



  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getImages(),
      builder: (BuildContext context, AsyncSnapshot snapshot) {
        if(snapshot.data!=null){
          return StaggeredGridView.countBuilder(
              physics: NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 12,
              itemCount: snapshot.data.length,
              itemBuilder: (context, index) {
                var fdata= snapshot.data[index]['PhotoUrl'];

                return Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.all(
                          Radius.circular(15))
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.all(
                        Radius.circular(15)),
                    child: FadeInImage.memoryNetwork(
                      placeholder: kTransparentImage,
                      image: fdata,fit: BoxFit.cover,),
                  ),
                );
              },
              staggeredTileBuilder: (index) {
                return StaggeredTile.count(1, index.isEven ? 0.8 : 1.2);
              }
          );
        }
        else{
          return Container(child:Text('do exception'));
        }
      },
    );
  }
}

Future<List<dynamic>> getImages() async{

  String url='http://65.0.121.93:4000/api/getUserPhotos/${currentUser!.uid}';
  print(url);
  Response response = await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);
  var data = json.decode(response.body);
  print(data[0]['PhotoUrl']);
  // return json.decode(response.body);
  return data;
}
