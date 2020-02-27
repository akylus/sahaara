import 'package:flutter/material.dart';
import 'dart:typed_data';

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

class WallpaperContainer extends StatelessWidget {

  const WallpaperContainer({
    Key key,
    @required this.wallpaper,
  }) : super(key: key);

  final wallpaper;
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: Opacity(
          child: Image.memory(
            wallpaper != null ? wallpaper : Uint8List(0),
            fit: BoxFit.fitHeight,
          ), 
        opacity: 0.7,
        ),
      );
  }
}
