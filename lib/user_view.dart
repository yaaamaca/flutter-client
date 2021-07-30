import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:yaaamaca_flutter_client/yaamaca_api.dart';

class UserEmbed extends StatefulWidget {
  final String userId;
  final bool small;
  UserEmbed({Key? key, required this.userId, this.small = false})
      : super(key: key);

  @override
  _UserEmbedState createState() => _UserEmbedState(
        userId: this.userId,
        small: this.small,
      );
}

class _UserEmbedState extends State<UserEmbed> {
  final String userId;
  final bool small;
  _UserEmbedState({required this.userId, required this.small}) : super();

  String? _name;

  @override
  void initState() {
    super.initState();
    apiRequestGet("/user/${this.userId}").then((js) {
      if (js == null) return;
      final jr = jsonDecode(js);
      setState(() {
        this._name = jr["name"];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final name = this._name;
    return Row(
      children: [
        (name != null)
            ? Text(
                name,
                style: TextStyle(fontSize: this.small ? 10 : 20),
              )
            : Text(
                "<loading>",
                style: TextStyle(fontSize: this.small ? 10 : 20),
              ),
      ],
    );
  }
}
