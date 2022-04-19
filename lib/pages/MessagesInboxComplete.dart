import 'package:caralapp/model/Messages.dart';
import 'package:caralapp/widgets/MessageCompleteItem.dart';
import 'package:flutter/material.dart';

import '/widgets/MainDrawer.dart';

class MessagesInboxComplete extends StatefulWidget {
  static const routeName = '/MessagesInboxComplete';

  const MessagesInboxComplete({Key? key}) : super(key: key);

  @override
  _MessagesInboxComplete createState() => _MessagesInboxComplete();
}

class _MessagesInboxComplete extends State<MessagesInboxComplete> {
  List<Messages> messagesList = [];
  var _loadedInitData = false;
  var _floatingActionButtonVisible = true;
  final ScrollController _controller = ScrollController();

  @override
  void initState() {
    super.initState();
  }

// This is what you're looking for!
  void _scrollDown() {
    _controller.animateTo(
      _controller.position.maxScrollExtent,
      duration: Duration(seconds: 2),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    messagesList = ModalRoute.of(context)!.settings.arguments as List<Messages>;
    messagesList.sort((a, b) => a.CreateDate.compareTo(b.CreateDate));
    //messagesList = messagesList.reversed.toList();
    return Scaffold(
      floatingActionButton: Visibility(
        visible: _floatingActionButtonVisible,
        child: FloatingActionButton(
          onPressed: _scrollDown,
          backgroundColor: Theme.of(context).primaryColor,
          child: Icon(
            Icons.keyboard_arrow_down,
            color: Colors.white,
          ),
        ),
      ),
      appBar: AppBar(
        title: Text('کارال'),
        centerTitle: true,
      ),
      body: messagesList != null && messagesList.isNotEmpty
          ? NotificationListener(
              child: ListView.builder(
                  //reverse: true,
                  //shrinkWrap: true,
                  controller: _controller,
                  itemCount: messagesList.length,
                  itemBuilder: (ctx, i) =>
                      MessageCompleteItem(messagesList[i])),
              onNotification: (notification) {
                if (_controller.hasClients &&
                    _controller.offset < _controller.position.maxScrollExtent) {
                  setState(() {
                    _floatingActionButtonVisible = true;
                  });
                } else {
                  setState(() {
                    _floatingActionButtonVisible = false;
                  });
                }
                return false;
              },
            )
          : Center(
              child: SizedBox(
                width: 40,
                child: CircularProgressIndicator(
                  color: Theme.of(context).accentColor,
                  semanticsLabel: 'در حال بارگذاری',
                ),
              ),
            ),
      endDrawer: MainDrawer(),
    );
  }
}
