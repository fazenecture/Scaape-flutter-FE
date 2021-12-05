import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:scaape/utils/constants.dart';
import 'package:bubble/bubble.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(this.userName,this.message,this.isMe);
  final String userName;
  final String message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;
    String authId = auth.currentUser!.uid;


    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment:
        isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          ),
          Bubble(
            margin: isMe ? BubbleEdges.fromLTRB(80, 1, 0, 1) : BubbleEdges.fromLTRB(0, 1, 80, 1),
            color:isMe?ScaapeTheme.kPinkColor.withOpacity(0.2):
            ScaapeTheme.kSecondBlue.withOpacity(0.6),
            nip: isMe ? BubbleNip.rightTop : BubbleNip.leftTop,
            child: Padding(
              padding: const EdgeInsets.all(3.0),

              child: Column(
                crossAxisAlignment: isMe? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  isMe ? Text(
                    'You',
                    style: TextStyle(
                        color: Colors.white,
                        // backgroundColor: Color(0xFF2A6551),
                        fontSize: 12,
                        fontWeight: FontWeight.w800
                    ),
                  ) : Text(
                    '$userName',
                    style: TextStyle(
                        color: Colors.white,
                        // backgroundColor: Color(0xFF2A6551),
                        fontSize: 12,
                        fontWeight: FontWeight.w800
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 6,bottom: 6),
                    child: Text(
                      '$message',
                      textAlign: isMe ? TextAlign.right : TextAlign.left,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  // Text(
                  //   '$currentTime',
                  //   style: TextStyle(
                  //       color: Colors.white,
                  //       fontStyle: FontStyle.italic,
                  //       fontSize: 9
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// children: [
// Container(
// decoration: BoxDecoration(
// color:isMe?ScaapeTheme.kPinkColor.withOpacity(0.2):
// ScaapeTheme.kSecondBlue.withOpacity(0.6),
// borderRadius: BorderRadius.only(
// topLeft: Radius.circular(12),
// topRight: Radius.circular(12),
// bottomLeft:!isMe?Radius.circular(0):Radius.circular(12),
// bottomRight: isMe?Radius.circular(0):Radius.circular(12),
// )),
// // width: 140,
// padding: EdgeInsets.symmetric(vertical: 10,horizontal: 16),
// margin: EdgeInsets.symmetric(vertical: 14,horizontal: 16),
// child: Column(crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
// children: [
// Padding(
// padding: const EdgeInsets.fromLTRB(0 , 4, 0, 4),
// child: isMe?Container():Text(userName,style:TextStyle(fontWeight:FontWeight.bold,
// color:isMe?ScaapeTheme.kSecondTextCollor:
// ScaapeTheme.kSecondTextCollor),),
// ),
// Text(message,textAlign: isMe?TextAlign.end:TextAlign.start,
// softWrap: false,
// maxLines: 4,
// overflow: TextOverflow.ellipsis,
// style: TextStyle(
// color:isMe?ScaapeTheme.kSecondTextCollor:
// ScaapeTheme.kSecondTextCollor),),],)
// ),
// ],