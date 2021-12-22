// import 'package:better_player/better_player.dart';
// import 'package:video_player/video_player.dart';
// import 'package:flutter/material.dart';
//
// void main() {
//
//   runApp(VideoApp());
// }
//
// class VideoApp extends StatefulWidget {
//
//   static String id = 'Video_app';
//
//   @override
//   _VideoAppState createState() => _VideoAppState();
// }
//
// class _VideoAppState extends State<VideoApp> {
//   late VideoPlayerController _controller;
//
//   late BetterPlayerController _betterPlayerController;
//
//
//   @override
//   void initState() {
//     super.initState();
//     BetterPlayerDataSource betterPlayerDataSource = BetterPlayerDataSource(
//         BetterPlayerDataSourceType.network,
//         "http://stream.scaape.online/hls/test.m3u8");
//     _betterPlayerController = BetterPlayerController(
//         BetterPlayerConfiguration(),
//         betterPlayerDataSource: betterPlayerDataSource);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return  AspectRatio(
//       aspectRatio: 16 / 9,
//       child: BetterPlayer(
//         controller: _betterPlayerController,
//       ),
//     );
//   }
//
//   @override
//   void dispose() {
//     super.dispose();
//     _controller.dispose();
//   }
// }