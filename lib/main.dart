import 'package:flutter/material.dart';
import 'package:yaaamaca_flutter_client/node_view.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'yaaamaca',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.purple,
        backgroundColor: Colors.grey.shade900,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.purple.shade400,
        textTheme: TextTheme(
          bodyText1: TextStyle(color: Colors.white),
          bodyText2: TextStyle(color: Colors.white),
          headline1: TextStyle(color: Colors.white),
          headline2: TextStyle(color: Colors.white),
          headline3: TextStyle(color: Colors.white),
          headline4: TextStyle(color: Colors.purpleAccent),
          subtitle1: TextStyle(color: Colors.grey.shade100),
          subtitle2: TextStyle(color: Colors.grey.shade200),
        ),
        dividerColor: Colors.purple.shade200,
        primaryIconTheme: IconThemeData(color: Colors.white),
        iconTheme: IconThemeData(color: Colors.white),
        cardTheme: CardTheme(color: Colors.grey.shade900),
      ),
      home: AppPage(title: 'yaaamaca'),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AppPage extends StatefulWidget {
  AppPage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _AppPageState createState() => _AppPageState();
}

class _AppPageState extends State<AppPage> {
  @override
  Widget build(BuildContext context) {
    return NodeView(
      nodeId: "0",
    );
  }
}
