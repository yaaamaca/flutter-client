import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yaaamaca_flutter_client/yaamaca_api.dart';

class MessageSendWidget extends StatefulWidget {
  final String nodeId;
  MessageSendWidget({Key? key, required this.nodeId}) : super(key: key);

  @override
  _MessageSendWidgetState createState() =>
      _MessageSendWidgetState(nodeId: this.nodeId);
}

class _MessageSendWidgetState extends State<MessageSendWidget> {
  final String nodeId;
  _MessageSendWidgetState({required this.nodeId}) : super();

  @override
  void initState() {
    super.initState();
  }

  void sendTextMessage(String content) {
    print("message sent!");
    apiRequestPost(
      "/create_node",
      jsonEncode({
        "parent": this.nodeId,
        "content": content,
        "type": "message.text",
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController();
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                autocorrect: true,
                controller: controller,
                decoration: InputDecoration(
                  hintText: "send a message here",
                  hintStyle: TextStyle(color: Colors.purple.shade300),
                ),
                onSubmitted: (value) {
                  this.sendTextMessage(value);
                  controller.clear();
                },
              ),
            ),
            IconButton(
              onPressed: () {
                this.sendTextMessage(controller.text);
                controller.clear();
              },
              icon: Icon(Icons.send),
            )
          ],
        ),
      ),
    );
  }
}
