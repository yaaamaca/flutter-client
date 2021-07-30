import 'dart:convert';

import 'package:http/http.dart' as http;

Future<String?> apiRequestGet(String path) async {
  final resp = await http.get(
    Uri.parse("http://lolcalhorst:1269$path"),
    headers: Map.from(
      {"authorization": "this-is-very-secure-indeed"},
    ),
  );
  if (resp.statusCode < 200 || resp.statusCode >= 300) {
    print("request failed: " + resp.body);
    return null;
  }
  return resp.body;
}

Future<String?> apiRequestPost(String path, String body) async {
  final resp = await http.post(
    Uri.parse("http://lolcalhorst:1269$path"),
    body: body,
    headers: Map.from({
      "content-type": "application/json",
      "authorization": "this-is-very-secure-indeed",
    }),
  );
  if (resp.statusCode < 200 || resp.statusCode >= 300) {
    print("request failed: " + resp.body);
    return null;
  }
  return resp.body;
}
