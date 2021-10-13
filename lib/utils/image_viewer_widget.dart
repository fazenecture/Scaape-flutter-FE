import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:scaape/utils/constants.dart';

class ImageViewer extends StatelessWidget {
  final String imageUrl;
  const ImageViewer({Key? key, this.imageUrl = ''}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Hero(
        tag: 'ProfilePhoto',
        child: PhotoView(
          tightMode: true,
          minScale: 0.5,
          loadingBuilder: (context, _) => Container(
              height: 80,
              width: 80,
              child: Center(child: CircularProgressIndicator())),
          backgroundDecoration: BoxDecoration(color: ScaapeTheme.kBackColor),
          imageProvider: NetworkImage(imageUrl),
        ),
      ),
    );
  }
}
