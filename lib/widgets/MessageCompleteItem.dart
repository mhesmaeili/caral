import 'package:caralapp/model/Messages.dart';
import 'package:caralapp/pages/ReplyToMessages.dart';
import 'package:flutter/material.dart';

import '../CommonFunction.dart';

class MessageCompleteItem extends StatefulWidget {
  final Messages messages;

  const MessageCompleteItem(this.messages);

  @override
  _MessageCompleteItem createState() => _MessageCompleteItem();
}

class _MessageCompleteItem extends State<MessageCompleteItem> {
  var _loadedInitData = false;
  late int userId = 0;

  @override
  void didChangeDependencies() {
    if (!_loadedInitData) {
      CommonFunction.getSharedPreferences('USER_ID').then((value) {
        if (value.isNotEmpty) {
          setState(() {
            userId = int.parse(value);
          });
        }
      });
      _loadedInitData = true;
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    /*return Container(
      padding: EdgeInsets.only(left: 14,right: 14,top: 10,bottom: 10),
      child: Align(
        alignment: (widget.messages.FromUser_ID != null &&
            widget.messages.FromUser_ID == userId?Alignment.topRight:Alignment.topLeft),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: (widget.messages.FromUser_ID != null &&
                widget.messages.FromUser_ID == userId?Colors.orangeAccent[200]:Colors.grey.shade200),
          ),
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                widget.messages.Message,
                textAlign: TextAlign.right,
                style: TextStyle(fontSize: 15,fontFamily: 'IRANSANS', color: Color(0xFF171923)),
              ),
              Row(
                crossAxisAlignment: ,
                children: [
                  Text(
                    widget.messages.CreateDatePersian,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 11),
                  ),
                  widget.messages.FromUser_ID != null &&
                      widget.messages.FromUser_ID == userId
                      ? widget.messages.IsMessageSeen != null &&
                      widget.messages.IsMessageSeen!
                      ? Icon(
                    Icons.check,
                    size: 15,
                    color: Colors.blue,
                  )
                      : Icon(
                    Icons.check,
                    size: 15,
                    color: Colors.grey,
                  )
                      : Text(''),
                  widget.messages.FromUser_ID != null &&
                      widget.messages.FromUser_ID != userId &&
                      (widget.messages.ParentUserCarAssignMessage_ID == null || widget.messages.MessageTemplate_ID==14)
                      ? ElevatedButton(
                      child: Text('پاسخ',
                          style: TextStyle(
                            //fontFamily: 'IRANSANS',
                          )),
                      onPressed: () {
                        Navigator.of(context).pushNamed(
                            ReplyToMessages.routeName,
                            arguments: widget.messages);
                      })
                      : Text(''),
                ],
              ),
            ],
          ),
        ),
      ),
    );*/
    bool isMe=widget.messages.FromUser_ID != null &&
        widget.messages.FromUser_ID == userId;
    return SizedBox(
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
          bottomRight: isMe ? Radius.zero : Radius.circular(20),
          bottomLeft: !isMe ? Radius.zero : Radius.circular(20),
        )),
        color: widget.messages.FromUser_ID != null &&
                widget.messages.FromUser_ID == userId
            ? Colors.orangeAccent
            : Colors.white,
        margin: widget.messages.FromUser_ID != null &&
                widget.messages.FromUser_ID == userId
            ? EdgeInsets.only(left: 45, right: 5, top: 10, bottom: 10)
            : EdgeInsets.only(left: 5, right: 45, top: 10, bottom: 10),
        elevation: 5,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    widget.messages.Message,
                    textAlign: TextAlign.right,
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'IRANSANS',
                        color: Color(0xFF171923)),
                  ),
                  widget.messages.FromUser_ID != null &&
                          widget.messages.FromUser_ID != userId &&
                          (widget.messages.ParentUserCarAssignMessage_ID ==
                                  null ||
                              widget.messages.MessageTemplate_ID == 14)
                      ? ElevatedButton(
                          child: Text('پاسخ',
                              style: TextStyle(
                                fontFamily: 'IRANSANS',
                              )),
                          onPressed: () {
                            Navigator.of(context).pushNamed(
                                ReplyToMessages.routeName,
                                arguments: widget.messages);
                          })
                      : Text(''),
                ],
              ),
              subtitle: Row(
                children: [
                  Text(
                    widget.messages.CreateDatePersian,
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 11),
                  ),
                  widget.messages.FromUser_ID != null &&
                          widget.messages.FromUser_ID == userId
                      ? widget.messages.IsMessageSeen != null &&
                              widget.messages.IsMessageSeen!
                          ? Icon(
                              Icons.done_all,
                              size: 15,
                              color: Colors.blue,
                            )
                          : Icon(
                              Icons.check,
                              size: 15,
                              color: Colors.grey,
                            )
                      : Text(''),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
