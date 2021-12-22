import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scaape/screens/bottom_navigatin_bar.dart';
import 'package:scaape/screens/signIn_screen.dart';
import 'package:scaape/utils/constants.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:switcher_button/switcher_button.dart';
import 'package:share/share.dart';
import 'package:http/http.dart';
import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';

class UserConfigScreen extends StatefulWidget {

  static String id = 'user_config';

  @override
  _UserConfigScreenState createState() => _UserConfigScreenState();
}

class _UserConfigScreenState extends State<UserConfigScreen> {

  final FirebaseAuth auther = FirebaseAuth.instance;


  @override
  Widget build(BuildContext context) {
    final userInfo = ModalRoute.of(context)!.settings.arguments as Map;
    String userImg = userInfo['UserImg'];
    String userName = userInfo['UserName'];
    String userInsta = userInfo['UserInsta'];
    String userEmail = userInfo['UserEmail'];
    print("this is usr image = $userImg");
    String text =
        'https://play.google.com/store/apps/details?id=com.scaapers.scaape';
    String subject = 'Join now';
    Future<void>? _launched;
    return Scaffold(
      backgroundColor: ScaapeTheme.kShimmerColor,
      // resizeToAvoidBottomInset: false,
      appBar: AppBar(
        toolbarHeight: 45,
        leading: IconButton(
          onPressed: (){
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_outlined,
          ),
        ),
        title: Text('Setting'),
        backgroundColor: ScaapeTheme.kShimmerColor,
        shadowColor: Colors.transparent,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            // height: MediaQuery.of(context).size.height * 0.13,
            // width: double.infinity,
            child: CircleAvatar(
              backgroundImage: NetworkImage(userImg),
              radius: 60,
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 10, bottom: 2),
            child: Text(
              '$userName',
              style: TextStyle(fontSize: 20, color: Colors.white),
            ),
          ),
          Text(
            '$userInsta',
            style: TextStyle(
                color: ScaapeTheme.kPinkColor, fontWeight: FontWeight.w400),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: MaterialButton(
              onPressed: () {},
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(20.0))),
              child: Text(
                'Edit Profile',
                style: TextStyle(color: Colors.white),
              ),
              color: ScaapeTheme.kPinkColor,
            ),
          ),
          Divider(
            height: 13,
            thickness: 1,
            indent: 39,
            endIndent: 39,
            color: ScaapeTheme.kPinkColor.withOpacity(0.3),
          ),
          GestureDetector(
            onTap: () async {
              final url =
                  'https://play.google.com/store/apps/details?id=com.scaapers.scaape';

              if (await canLaunch(url)) {
                await launch(
                  url,
                  forceSafariVC: false,
                );
              }
            },
            child: settingOptions(
              name: 'Join us',
              display: Icons.groups_outlined,
            ),
          ),
          Row(
            children: [
              settingOptions(
                name: 'Newsletter',
                display: Icons.article_outlined,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 38),
                child: SwitcherButton(
                  offColor: ScaapeTheme.kSecondBlue,
                  onChange: (value) async{
                      String url = 'https://api.scaape.online/api/newsletter';
                      Map<String, String> headers = {"Content-type": "application/json"};
                      String json = '{"Email":"$userEmail","Name":"$userName","Message":""}';
                      http.Response response = await post(Uri.parse(url), headers: headers, body: json);
                      int statuscode = response.statusCode;
                      print(statuscode);
                      print(response.body);
                      },
                  onColor: ScaapeTheme.kPinkColor,
                  size: 48,
                ),
              )
            ],
          ),
          GestureDetector(
            onTap: () async{
              String url = 'https://api.scaape.online/api/UpdateTutorial';
              Map<String, String> headers = {"Content-type": "application/json"};
              String json =
                  '{"showTutorial": 1, "UserId" : "${auther.currentUser!.uid}" }';
              http.Response response =
              await post(Uri.parse(url), headers: headers, body: json);
              int statuscode = response.statusCode;
              print(statuscode);
              print(response.body);
              print("ShowTutorial ACtivated");
              Navigator.pushReplacementNamed(context, HomeScreen.id);
            },
            child: settingOptions(
              name: 'Show Tutorials',
              display: Icons.contact_support_outlined,
            ),
          ),
          // settingOptions(name: 'Show Tutorials', display:  Icons.contact_support_outlined,),
          GestureDetector(
            onTap: () async {
              final url = 'https://scaape.online';

              if (await canLaunch(url)) {
                await launch(
                  url,
                  forceSafariVC: false,
                );
              }
            },
            child: settingOptions(
              name: 'About Us',
              display: Icons.info_outlined,
            ),
          ),
          GestureDetector(
              onTap: () {
                final RenderObject? box = context.findRenderObject();
                Share.share(
                  text,
                  subject: subject,
                  // sharePositionOrigin:
                  // box.localToGlobal(Offset.zero) &
                  // box.size
                );
              },
              child: settingOptions(
                name: 'Invite a Friend',
                display: Icons.share_outlined,
              )),
          settingOptions(
            name: 'Report a Bug',
            display: Icons.bug_report_outlined,
          ),
          // settingOptions(name: 'Delete account', display: Icons.delete_outlined,),
          // settingOptions(name: 'Log Out', display: Icons.logout_outlined,),
          Padding(
            padding:
            EdgeInsets.only(top: MediaQuery.of(context).size.height * 0.03),
            child: Center(
              child: MaterialButton(
                height: MediaQuery.of(context).size.height * 0.057,
                minWidth: MediaQuery.of(context).size.width * 0.85,
                color: ScaapeTheme.kShimmerColor,
                shape: RoundedRectangleBorder(
                    side: BorderSide(color: ScaapeTheme.kPinkColor, width: 1),
                    borderRadius: BorderRadius.circular(6)),
                onPressed: () async {
                  await FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, SignInScreen.id, (route) => false);
                },
                child: const Text(
                  'Log Out',
                  style: const TextStyle(
                    color: ScaapeTheme.kPinkColor,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class settingOptions extends StatelessWidget {
  settingOptions({required this.name, required this.display});

  String name;
  IconData display;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 35),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              display,
              color: Colors.white,
              size: 29,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15),
              child: Text(
                name,
                style: TextStyle(color: Colors.white, fontSize: 21),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
