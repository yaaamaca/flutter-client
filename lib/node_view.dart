import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:yaaamaca_flutter_client/node_embed.dart';
import 'package:yaaamaca_flutter_client/user_view.dart';
import 'package:yaaamaca_flutter_client/yaamaca_api.dart';

class NodeView extends StatefulWidget {
  final String nodeId;
  NodeView({Key? key, required this.nodeId}) : super(key: key);

  @override
  _NodeViewState createState() => _NodeViewState(nodeId: this.nodeId);
}

class _NodeViewState extends State<NodeView> {
  final String nodeId;
  _NodeViewState({required this.nodeId}) : super();
  bool _showValues = false;
  String? _author;
  String? _content;
  String? _type;
  int? _childCount;

  WebSocketChannel? _events;

  @override
  void initState() {
    super.initState();
    apiRequestGet("/node/${this.nodeId}?content=1").then((js) {
      if (js == null) return;
      final jr = jsonDecode(js);
      setState(() {
        this._author = jr["author"];
        this._content = jr["content"];
        this._type = jr["type"];
        this._childCount = jr["child_count"];
        this._showValues = true;
      });
    });
    this._events = WebSocketChannel.connect(Uri.parse(
      "ws://lolcalhorst:1269/node/${this.nodeId}/events",
    ));
    this._events!.stream.listen((event) {
      print(event);
    });
  }

  void sendMessage(String content) {
    print("message sent!");
    apiRequestPost(
      "/create_node",
      jsonEncode({
        "parent": this.nodeId,
        "content": content,
        "type": "message",
      }),
    );
  }

  Widget sendMessageWidget(BuildContext context) {
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
                onSubmitted: (value) {
                  this.sendMessage(value);
                  controller.clear();
                },
              ),
            ),
            IconButton(
              onPressed: () {
                this.sendMessage(controller.text);
                controller.clear();
              },
              icon: Icon(Icons.send),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!this._showValues)
      return Scaffold(
        appBar: AppBar(title: Text("loading")),
        body: LinearProgressIndicator(),
      );
    final author = this._author;
    final content = this._content;
    final type = this._type;

    return Scaffold(
      appBar: AppBar(
        actions: actions(context),
        title: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Text(content != null ? "$content " : "<loading>"),
            ),
            Row(
              children: [
                Text("by ", style: TextStyle(fontSize: 10)),
                author != null
                    ? UserEmbed(userId: author, small: true)
                    : Text("<loading>"),
              ],
            )
          ],
        ),
      ),
      body: Container(
        child: Column(
          children: [
            type != null ? Text(type) : Text("<loading>"),
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: this._childCount ?? 0,
                itemBuilder: (context, i) {
                  return FutureBuilder(
                    future: apiRequestGet(
                        "/node/${this.nodeId}/children?index_from=$i&index_to=$i"),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) return LinearProgressIndicator();
                      if (snapshot.hasError)
                        return Text("something went wrong");
                      final snapData = snapshot.data as String?;
                      if (snapData == null)
                        return Text("something went wrong here");
                      List<dynamic> snap =
                          jsonDecode(snapData) as List<dynamic>;
                      if (snap.isEmpty)
                        return Text("something went wrong here aswell");
                      final childId = snap[0];
                      return NodeEmbed(nodeId: childId);
                    },
                  );
                },
              ),
            ),
            ...(this._type == "channel"
                ? [this.sendMessageWidget(context)]
                : [])
          ],
        ),
      ),
    );
  }

  List<Widget> actions(BuildContext context) {
    List<Widget> l = [];
    if (this._type == "channel_group")
      l.add(IconButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              var name = "";
              return AlertDialog(
                content: Column(
                  children: [
                    Text("Please give your new channel a name."),
                    TextField(
                      autocorrect: false,
                      onChanged: (value) => name = value,
                    )
                  ],
                ),
                actions: [
                  TextButton(
                    child: Text("Create channel"),
                    onPressed: () {
                      // todo create a channel
                      Navigator.pop(context);
                    },
                  )
                ],
              );
            },
          );
        },
        icon: Icon(Icons.add),
      ));
    return l;
  }
}
