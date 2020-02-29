import 'package:flutter/material.dart';

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
            wallpaper,
            fit: BoxFit.cover,
          ), 
        opacity: 0.7,
        ),
      );
  }
}