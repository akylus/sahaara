import 'package:flutter/material.dart';

import 'screen.dart';

void main() => runApp(Sahaara());

class Sahaara extends StatelessWidget {
  final darkBlue = const Color(0xff1C2C3B);
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahaara',
      home: Scaffold(
      appBar: AppBar(
        backgroundColor: darkBlue,
      ),
      backgroundColor: darkBlue,
      body: WillPopScope(
          onWillPop: ()=>Future(()=>false),
          child: Screen(),
        ),
      ),
    );
  }
}


