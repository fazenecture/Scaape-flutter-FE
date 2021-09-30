import 'package:flutter/material.dart';
import 'package:scaape/utils/MessageStruc.dart';
import 'package:scaape/utils/messageBubble.dart';
class UserChat extends StatefulWidget {
  const UserChat({Key? key}) : super(key: key);
  static String id = 'UserChat';
  @override
  _UserChatState createState() => _UserChatState();
}

class _UserChatState extends State<UserChat> {
  List<Message> messages=[

  ];
  String _enteredMessage='';
  final _controller=new TextEditingController();
  addToList(String text,bool isMe) async {
    setState(() {
      messages.add(Message(text: text, isMe: isMe));
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: Column(children: <Widget>[
            Expanded(child:ListView.builder(itemCount: messages.length,
              reverse: true,
              itemBuilder:(context, index) {
                return MessageBubble(messages[messages.length-index-1].text,messages[messages.length-index-1].isMe);
              },) ,),
            Container(
              margin: EdgeInsets.only(top: 8),
              padding: EdgeInsets.all(8),
              child: Row(children: [
                Expanded(child:
                TextField(decoration: InputDecoration(labelText: 'message...'),
                  controller: _controller,
                  onChanged: (value) {
                    setState(() {
                      _enteredMessage=value;
                    });
                  },)),
                IconButton(color: Theme.of(context).primaryColor,
                    icon: Icon(Icons.send),
                    onPressed:(){
                      setState(() {
                        _enteredMessage.trim().isEmpty?null:addToList(_enteredMessage,true);
                      });
                      _controller.clear();
                    })
              ],),
            ),
          ],),
        )
    );
  }
}
