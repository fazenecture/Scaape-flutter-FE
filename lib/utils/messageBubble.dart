import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:scaape/utils/constants.dart';

class MessageBubble extends StatelessWidget {
  MessageBubble(this.userName,this.message,this.isMe);
  final String userName;
  final String message;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Row(
          mainAxisAlignment: isMe?MainAxisAlignment.end:MainAxisAlignment.start,
          children: [
            Container(
                decoration: BoxDecoration(
                    color:isMe?ScaapeTheme.kPinkColor.withOpacity(0.3):
                    ScaapeTheme.kSecondBlue.withOpacity(0.6),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomLeft:!isMe?Radius.circular(0):Radius.circular(12),
                      bottomRight: isMe?Radius.circular(0):Radius.circular(12),
                    )),
                width: 140,
                padding: EdgeInsets.symmetric(vertical: 10,horizontal: 16),
                margin: EdgeInsets.symmetric(vertical: 14,horizontal: 16),
                child: Column(crossAxisAlignment: isMe?CrossAxisAlignment.end:CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0 , 4, 0, 4),
                      child: isMe?Container():Text(userName,style:TextStyle(fontWeight:FontWeight.bold,
                          color:isMe?ScaapeTheme.kSecondTextCollor:
                          ScaapeTheme.kSecondTextCollor),),
                    ),
                    Text(message,textAlign: isMe?TextAlign.end:TextAlign.start,
                      style: TextStyle(
                          color:isMe?ScaapeTheme.kSecondTextCollor:
                          ScaapeTheme.kSecondTextCollor),),],)
            ),
          ],
        ),
      ],
      overflow: Overflow.visible,
    );
  }
}