import 'package:flutter/material.dart';
import 'package:scaape/screens/usersChat.dart';

class ScaapeChat extends StatefulWidget {
  const ScaapeChat({Key? key}) : super(key: key);
  static String id = 'chat';

  @override
  _ScaapeChatState createState() => _ScaapeChatState();
}

class _ScaapeChatState extends State<ScaapeChat> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          color: Color(0xFF222831),
          margin: EdgeInsets.fromLTRB(15, 58, 15, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Icon(
                      Icons.notification_important_outlined,
                      color: Colors.white,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Social Messages',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 26,
                      ),
                    ),
                  ],
                ),
              ),
              ListView.builder(
                  shrinkWrap: true,
                  itemCount: 5,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: Icon(Icons.add_a_photo_sharp),
                      title: Text("hello"),
                      subtitle: Text("4 Messages"),
                      onTap: () {
                        Navigator.pushNamed(context, UserChat.id);
                      },
                    );
                  }),
            ],
          ),
        ),
      ),
    );
  }
}
