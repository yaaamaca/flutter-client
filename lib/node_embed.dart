import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yaaamaca_flutter_client/config.dart';
import 'package:yaaamaca_flutter_client/node_view.dart';
import 'package:yaaamaca_flutter_client/user_view.dart';
import 'package:yaaamaca_flutter_client/yaamaca_api.dart';

class NodeEmbed extends StatefulWidget {
  final String nodeId;
  NodeEmbed({Key? key, required this.nodeId}) : super(key: key);

  @override
  _NodeEmbedState createState() => _NodeEmbedState(nodeId: this.nodeId);
}

class _NodeEmbedState extends State<NodeEmbed> {
  final String nodeId;
  _NodeEmbedState({required this.nodeId}) : super();
  bool _showValues = false;
  String? _author;
  String? _content;
  String? _type;
  int? _childCount;

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
  }

  @override
  Widget build(BuildContext context) {
    if (!this._showValues)
      return Container(
        child: LinearProgressIndicator(),
      );
    final author = this._author;
    final content = this._content;
    final type = this._type;

    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (BuildContext context) {
                return NodeView(nodeId: this.nodeId);
              },
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 3, 6, 3),
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: Row(
                  children: [
                    Icon(
                      typeIcon(this._type ?? ""),
                      size: 18,
                    ),
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
              ),
              ...(typeShowEmbedChildren(this._type ?? "")
                  ? [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                        child: embedChildren(),
                      ),
                    ]
                  : [])
            ],
          ),
        ),
      ),
    );
  }

  Widget embedChildren() {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: this._childCount ?? 0,
      itemBuilder: (context, i) {
        return FutureBuilder(
          future: apiRequestGet(
              "/node/${this.nodeId}/children?index_from=$i&index_to=$i"),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return LinearProgressIndicator();
            if (snapshot.hasError) return Text("something went wrong");
            final snapData = snapshot.data as String?;
            if (snapData == null) return Text("something went wrong here");
            List<dynamic> snap = jsonDecode(snapData) as List<dynamic>;
            if (snap.isEmpty) return Text("something went wrong here aswell");
            final childId = snap[0];
            return NodeEmbed(nodeId: childId);
          },
        );
      },
    );
  }
}
