import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:scaape/utils/MessageStruc.dart';
import 'package:scaape/utils/messageBubble.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserChat extends StatefulWidget {
  const UserChat({Key? key}) : super(key: key);
  static String id = 'UserChat';
  @override
  _UserChatState createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  List<Message> messages = [];
  String _enteredMessage = '';
  final _controller = new TextEditingController();
  void addToList(String text, bool isMe,String ScaapeId) async {
    var user = FirebaseAuth.instance.currentUser;
    var check = isMe ? "yes" : "no";
    String? name = user!.displayName;
    String id = user.uid;
    try {
      FirebaseFirestore.instance.collection(ScaapeId).add({
        'text': _enteredMessage,
        'createdAt': Timestamp.now(),
        'isMe': check,
        'userId': id,
        'username': name,
      });
      setState(() {
        messages.add(Message(text: text, isMe: isMe, username: name));
      });
      _controller.clear();
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chats=ModalRoute.of(context)!.settings.arguments as Map;
    final FirebaseAuth auth = FirebaseAuth.instance;
    String ScaapeId=chats['ScaapeId'];


    return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text('Group Chat'),
          backgroundColor: Color(0xFF22242C),
        ),
        body: Container(
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                    child:
                        // ListView.builder(itemCount: messages.length,
                        //   reverse: true,
                        //   itemBuilder:(context, index) {
                        //     return MessageBubble(messages[messages.length-index-1].text,messages[messages.length-index-1].isMe);
                        //   },) ,
                        StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection(ScaapeId)
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    final chatDocs = snapshot.data!.docs;
                    var users = FirebaseAuth.instance.currentUser;

                    return ListView.builder(
                      itemCount: chatDocs.length,
                      reverse: true,
                      itemBuilder: (context, index) {
                        //return MessageBubble(messages[messages.length-index-1].text,messages[messages.length-index-1].isMe);
                        return MessageBubble(
                            chatDocs[index]['username'],
                            chatDocs[index]['text'],
                            chatDocs[index]['userId'] == users!.uid);
                      },
                    );
                  },
                )),
                Padding(
                  padding: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(23.0),
                      color: const Color(0xff393e46),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0x0a000000),
                          offset: Offset(0, 3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding:
                          const EdgeInsets.only(left: 12.0, right: 8, top: 5),
                      child: TextField(
                        controller: _controller,
                        onChanged: (value) {
                          //setState(() {
                          _enteredMessage = value;
                          //});
                        },
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Start Typing..',
                            hintStyle: TextStyle(
                              fontFamily: 'Roboto',
                              fontSize:
                                  MediaQuery.of(context).size.height * 0.018,
                              color: const Color(0x5cffffff),
                              fontWeight: FontWeight.w400,
                            ),
                            suffixIcon: IconButton(
                                color: Theme.of(context).primaryColor,
                                icon: Icon(Icons.send),
                                onPressed: () {
                                  setState(() {
                                    _enteredMessage.trim().isEmpty
                                        ? null
                                        : addToList(_enteredMessage, true,ScaapeId);
                                  });
                                  _controller.clear();
                                })),
                      ),
                    ),
                  ),
                ),
                // Container(
                //   margin: EdgeInsets.only(top: 8),
                //   padding: EdgeInsets.all(8),
                //   child: Row(children: [
                //     Expanded(child:
                //     TextField(decoration: InputDecoration(labelText: 'message...'),
                //       controller: _controller,
                //       onChanged: (value) {
                //         //setState(() {
                //           _enteredMessage=value;
                //         //});
                //       },)),
                //     IconButton(color: Theme.of(context).primaryColor,
                //         icon: Icon(Icons.send),
                //         onPressed:(){
                //           setState(() {
                //             _enteredMessage.trim().isEmpty?null:addToList(_enteredMessage,true);
                //           });
                //           _controller.clear();
                //         })
                //   ],),
                // ),
              ],
            ),
          ),
        ));
  }
}
