import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_connect/http/src/response/response.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:scaape/screens/chat_screen.dart';
import 'package:scaape/screens/dashboard_screen.dart';
import 'package:scaape/screens/user_chat_screen.dart';
import 'package:scaape/utils/colorsonar.dart';
import 'package:scaape/utils/constants.dart';
import 'package:video_player/video_player.dart';
import 'package:video_stream/camera.dart';
import 'package:wakelock/wakelock.dart';




GlobalKey _key2 = GlobalKey();



class CameraExampleHome extends StatefulWidget {
  const CameraExampleHome({Key? key}) : super(key: key);


  @override
  _CameraExampleHomeState createState() {
    return _CameraExampleHomeState();
  }
}

/// Returns a suitable camera icon for [direction].
IconData getCameraLensIcon(CameraLensDirection direction) {
  switch (direction) {
    case CameraLensDirection.back:
      return Icons.camera_rear;
    case CameraLensDirection.front:
      return Icons.camera_front;
    case CameraLensDirection.external:
      return Icons.camera;
  }
}

void logError(String code, String message) =>
    print('Error: $code\nError Message: $message');

class _CameraExampleHomeState extends State<CameraExampleHome>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? controller =
  CameraController(cameras == null ? cameras[1] : cameras[0], ResolutionPreset.low);
  String? imagePath;
  String? videoPath;
  String? url;
  VideoPlayerController? videoController;
  late VoidCallback videoPlayerListener;
  bool enableAudio = true;
  bool useOpenGL = true;
  String streamURL = "rtmp://stream.scaape.online:1935/live/test?key=supersecret";
  bool streaming = false;
  String? cameraDirection;

  Timer? _timer;

  @override
  void initState() {
    _initialize();
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  Future<void> _initialize() async {
    streaming = false;
    cameraDirection = 'front';
    // controller = CameraController(cameras[1], Resolution.high);
    await controller!.initialize();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // App state changed before we got the chance to initialize.
    if (controller == null || !controller!.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
    } else if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        onNewCameraSelected(controller!.description!);
      }
    }
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  toggleCameraDirection() async {
    if (cameraDirection == 'front') {
      if (controller != null) {
        await controller?.dispose();
      }
      controller = CameraController(
        cameras[0],
        ResolutionPreset.low,
        enableAudio: enableAudio,
        androidUseOpenGL: useOpenGL,
      );

      // If the controller is updated then update the UI.
      controller!.addListener(() {
        if (mounted) setState(() {});
        if (controller!.value.hasError) {
          showInSnackBar('Camera error ${controller!.value.errorDescription}');
          if (_timer != null) {
            _timer!.cancel();
            _timer = null;
          }
          Wakelock.disable();
        }
      });

      try {
        await controller!.initialize();
      } on CameraException catch (e) {
        _showCameraException(e);
      }

      if (mounted) {
        setState(() {});
      }
      cameraDirection = 'back';
    } else {
      if (controller != null) {
        await controller!.dispose();
      }
      controller = CameraController(
        cameras[1],
        ResolutionPreset.low,
        enableAudio: enableAudio,
        androidUseOpenGL: useOpenGL,
      );

      // If the controller is updated then update the UI.
      controller!.addListener(() {
        if (mounted) setState(() {});
        if (controller!.value.hasError) {
          showInSnackBar('Camera error ${controller!.value.errorDescription}');
          if (_timer != null) {
            _timer!.cancel();
            _timer = null;
          }
          Wakelock.disable();
        }
      });

      try {
        await controller!.initialize();
      } on CameraException catch (e) {
        _showCameraException(e);
      }

      if (mounted) {
        setState(() {});
      }
      cameraDirection = 'front';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      resizeToAvoidBottomInset: true,
      key: _scaffoldKey,
      body: SingleChildScrollView(
        child: Stack(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height,
              color: Colors.black,
              child: Center(
                child: _cameraPreviewWidget(),
              ),
            ),
            Positioned(
              top: 0.0,
              left: 0.0,
              right: 0.0,
              child: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0.0,
                title: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      ColorSonar(
                        contentAreaRadius: 3.0,
                        waveFall: 5.3,
                        innerWaveColor: Colors.red,
                        contentAreaColor: Colors.red,
                        middleWaveColor: Colors.red.withOpacity(0.5),
                        outerWaveColor: Colors.red.withOpacity(0.1),
                        child: CircleAvatar(
                          radius: 3,
                          backgroundColor: Colors.red,
                        ),

                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Text('Live',
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 15
                      ),),
                    ],
                  ),
                ),
                actions: [
                  streaming == true
                      ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: MaterialButton(
                    onPressed: () => onStopButtonPressed(),
                    child: Text(
                        'End',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.white,
                          fontWeight: FontWeight.normal,
                        ),
                    ),
                  ),
                      ) :
                  //Start Stream Button
                  TextButton(
                    onPressed: () => onVideoStreamingButtonPressed(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.videocam),
                        SizedBox(width: 10),
                        Text(
                          'Start Stream',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  //toggle camera
                  // Padding(
                  //   padding: const EdgeInsets.all(10.0),
                  //   child: IconButton(
                  //     color: Theme.of(context).primaryColor,
                  //     icon: const Icon(Icons.switch_video),
                  //     tooltip: 'Switch Camera',
                  //     onPressed: () {
                  //       toggleCameraDirection();
                  //     },
                  //   ),
                  // ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.3)
                  ),
                  child: IconButton(
                    color: Colors.white,
                    icon: Icon(Icons.cameraswitch_rounded),
                    tooltip: 'Switch Camera',
                    onPressed: () {
                      toggleCameraDirection();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Display the preview from the camera (or a message if the preview is not available).
  Widget _cameraPreviewWidget() {
    final size = MediaQuery.of(context).size;
    final deviceRatio = size.width / size.height;
    if (controller == null || !controller!.value.isInitialized) {
      return Center(
        child: CircularProgressIndicator(
          color: ScaapeTheme.kPinkColor,
        ),
      );
    } else {
      return Stack(
        children: [
          Center(
            child: Transform.scale(
              scale: controller!.value.aspectRatio/deviceRatio,
              child: AspectRatio(
                aspectRatio: controller!.value.aspectRatio,
                child: CameraPreview(controller!),
              ),
            ),
          ),
        ],
      );
    }
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

  void showInSnackBar(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void onNewCameraSelected(CameraDescription? cameraDescription) async {
    if (controller != null) {
      await controller!.dispose();
    }
    if (cameraDescription == null) {
      print('cameraDescription is null');
    }
    controller = CameraController(
      cameraDescription,
      ResolutionPreset.low,
      enableAudio: enableAudio,
      androidUseOpenGL: useOpenGL,
    );

    // If the controller is updated then update the UI.
    controller!.addListener(() {
      if (mounted) setState(() {});
      if (controller!.value.hasError) {
        showInSnackBar('Camera error ${controller!.value.errorDescription}');
        if (_timer != null) {
          _timer!.cancel();
          _timer = null;
        }
        Wakelock.disable();
      }
    });

    try {
      await controller!.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  void onVideoStreamingButtonPressed() {
    startVideoStreaming().then((url) {
      if (mounted) {
        setState(() {
          streaming = true;
        });
      }
      if (url!.isNotEmpty) showInSnackBar('Streaming video to $url');
      Wakelock.enable();
    });
  }

  void onStopButtonPressed() {
    stopVideoStreaming().then((_) {
      if (mounted) {
        setState(() {
          streaming = false;
        });
      }
      showInSnackBar('Streaming to: $url');
    });
    Wakelock.disable();
  }

  void onPauseStreamingButtonPressed() {
    pauseVideoStreaming().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Streaming paused');
    });
  }

  void onResumeStreamingButtonPressed() {
    resumeVideoStreaming().then((_) {
      if (mounted) setState(() {});
      showInSnackBar('Streaming resumed');
    });
  }

  Future<String?> startVideoStreaming() async {
    if (!controller!.value.isInitialized) {
      showInSnackBar('Error: select a camera first.');
      return null;
    }

    // Open up a dialog for the url
    String myUrl = streamURL;

    try {
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
      url = myUrl;
      await controller!.startVideoStreaming(url!, androidUseOpenGL: false);
      // _timer = Timer.periodic(Duration(seconds: 1), (timer) async {
      //   var stats = await controller!.getStreamStatistics();
      //   print(stats);
      // });
    } on CameraException catch (e) {
      _showCameraException(e);
      return null;
    }
    return url;
  }

  Future<void> stopVideoStreaming() async {
    try {
      await controller!.stopVideoStreaming();
      if (_timer != null) {
        _timer!.cancel();
        _timer = null;
      }
    } on CameraException catch (e) {
      _showCameraException(e);
      return;
    }
  }

  Future<void> pauseVideoStreaming() async {
    if (!controller!.value.isStreamingVideoRtmp) {
      return;
    }

    try {
      await controller!.pauseVideoStreaming();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  Future<void> resumeVideoStreaming() async {
    try {
      await controller!.resumeVideoStreaming();
    } on CameraException catch (e) {
      _showCameraException(e);
      rethrow;
    }
  }

  void _showCameraException(CameraException e) {
    logError(e.code, e.description);
    showInSnackBar('Error: ${e.code}\n${e.description}');
  }
}

final FirebaseAuth auth = FirebaseAuth.instance;
String authId=auth.currentUser!.uid;


class CameraApp extends StatefulWidget {
  const CameraApp({Key? key}) : super(key: key);
  static String id = 'live';
  @override
  State<CameraApp> createState() => _CameraAppState();
}

class _CameraAppState extends State<CameraApp> {

  @override
  void initState() {
    // TODO: implement initState

    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      showModalBottomSheet(context: context, builder: (BuildContext context) {
        return Container(
          child: FutureBuilder(
            future: getActiveScaapes(authId),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if(snapshot.hasData){
                var a=snapshot.data;

                return SingleChildScrollView(
                  child: Container(
                    // color: ScaapeTheme.kBackColor,
                    margin: EdgeInsets.fromLTRB(10, 15,10, 10),
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data.length,
                        itemBuilder: (context, index) {
                          return a[index]['Accepted']== 1 ? Column(
                            children: [
                              ListTile(
                                leading: CircleAvatar(
                                  backgroundColor: ScaapeTheme.kSecondBlue,
                                  backgroundImage: NetworkImage(a[index]['ScaapeImg']),
                                  radius: 26,
                                ),
                                title: Text(a[index]['ScaapeName']),
                                subtitle: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on_outlined,
                                      size: 13,
                                    ),
                                    SizedBox(
                                      width: 3,
                                    ),
                                    Text(
                                      '${a[index]['Location']}',
                                      maxLines: 1,
                                      style: GoogleFonts.poppins(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400),
                                    )
                                  ],
                                ),
                                onTap: () {
                                  Navigator.pushNamed(context, UserChat.id,arguments:{
                                    "ScaapeId":"${a[index]['ScaapeId']}",
                                    "ScaapeName":"${a[index]['ScaapeName']}",
                                    "ScaapeImage":"${a[index]['ScaapeImg']}",
                                    "ScaapeDate":"${a[index]['ScaapeDate']}",
                                    "ScaapeDesc":"${a[index]['Description']}",
                                    "ScaapeAdminId":"${a[index]['AdminUserId']}",

                                  });
                                },
                                // selectedTileColor: ScaapeTheme.kSecondBlue,
                                focusColor: ScaapeTheme.kSecondBlue,
                                selectedTileColor: ScaapeTheme.kSecondBlue,
                                hoverColor: ScaapeTheme.kSecondBlue,
                              ),
                              Divider(
                                endIndent: 34,
                                indent: 68,
                              ),
                            ],
                          ):Container();
                        }),
                  ),
                );
              }
              else{
                return Container(
                    color: ScaapeTheme.kBackColor,
                    margin: EdgeInsets.fromLTRB(10, 15,10, 10),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          OutsideChatShimmer(),
                          OutsideChatShimmer(),
                          OutsideChatShimmer(),
                          OutsideChatShimmer(),
                          OutsideChatShimmer(),
                          OutsideChatShimmer(),
                          OutsideChatShimmer(),
                          OutsideChatShimmer(),
                          OutsideChatShimmer(),
                        ],
                      ),
                    )
                );
              }
            },

          ),
        );
      });
    });
    getCam();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
     home : cameras != [] ?CameraExampleHome() : CircularProgressIndicator(
       color: ScaapeTheme.kPinkColor,
     ),
    );
  }
}

List<CameraDescription> cameras = [];

Future<void> getCam() async {



  // Fetch the available cameras before initializing the app.
  try {
    WidgetsFlutterBinding.ensureInitialized();
    cameras = await availableCameras();
  } on CameraException catch (e) {
    logError(e.code, e.description);
  }
  // runApp(const CameraApp());
}


Future<List<dynamic>> getActiveScaapes(String id)async{

  String url='https://api.scaape.online/api/getUserScaapes/UserId=${id}';

  var response=await get(Uri.parse(url));
  int statusCode = response.statusCode;
  print(statusCode);
  print(response.body);
  print(json.decode(response.body));
  return json.decode(response.body);
}
