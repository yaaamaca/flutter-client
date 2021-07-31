import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:yaaamaca_flutter_client/config.dart';
import 'package:yaaamaca_flutter_client/node_embed.dart';
import 'package:yaaamaca_flutter_client/send_message.dart';
import 'package:yaaamaca_flutter_client/user_view.dart';
import 'package:yaaamaca_flutter_client/yaamaca_api.dart';
import 'package:flutter/services.dart';

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

  WebSocket? _events;

  void sendRequest() {
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
  }

  @override
  void initState() {
    super.initState();
    sendRequest();
    WebSocket.connect(
      "ws://lolcalhorst:1269/node/${this.nodeId}/subscribe",
    ).then((ws) {
      this._events = ws;
      this._events!.listen((event) {
        sendRequest();
      });
      this._events!.add("a");
    });
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
    final reverse = typeReveseView(this._type ?? "");

    return Scaffold(
      appBar: AppBar(
        actions: appBarActions(context),
        title: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Row(
                children: [
                  Icon(typeIcon(this._type)),
                  Text(content != null ? " $content " : " <loading>"),
                ],
              ),
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
            Expanded(
              child: ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                itemCount: this._childCount ?? 0,
                reverse: reverse,
                itemBuilder: (context, j) {
                  final i = reverse ? ((this._childCount ?? 0) - j - 1) : j;
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
            ...typeSendMessage(this._type ?? "")
                ? [MessageSendWidget(nodeId: nodeId)]
                : []
          ],
        ),
      ),
    );
  }

  void createChannelDialog(BuildContext context, String type) {
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
                  apiRequestPost(
                    "/create_node",
                    jsonEncode({
                      "parent": this.nodeId,
                      "content": name,
                      "type": type,
                    }),
                  );
                  Navigator.pop(context);
                },
              )
            ],
          );
        });
  }

  List<Widget> appBarActions(BuildContext context) {
    return [
      PopupMenuButton<Function()>(
        onSelected: (fn) => fn(),
        itemBuilder: (context) {
          List<PopupMenuItem<Function()>> l = [];
          l.add(PopupMenuItem(
            value: () {
              Clipboard.setData(ClipboardData(text: this.nodeId));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Copied: ${this.nodeId}"),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            child: Text("Copy node id"),
          ));
          if (typeSendChannel(this._type ?? ""))
            l.addAll([
              PopupMenuItem(
                value: () => createChannelDialog(context, "channel.message"),
                child: Text("Create message channel"),
              ),
              PopupMenuItem(
                value: () => createChannelDialog(context, "channel.voice"),
                child: Text("Create voice channel"),
              ),
            ]);
          if (typeSendChannelGroup(this._type ?? ""))
            l.add(PopupMenuItem(
              value: () => createChannelDialog(context, "channel_group"),
              child: Text("Create channel group"),
            ));
          return l;
        },
      ),
    ];
  }
}
