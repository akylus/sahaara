import 'package:flutter/material.dart';

import 'keypad.dart';

class Menu extends StatefulWidget {
  final Function(String value) updateActiveScreen;
  const Menu({this.updateActiveScreen});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  final darkBlue = const Color(0xff1C2C3B);
  var activeSelection = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Expanded(child: _screen()),
        KeyPad(
          onUpButtonClicked: () {
            if(activeSelection > 0){ 
              setState(() {
                activeSelection--;
              });
            }
          },
          onDownButtonClicked: () {
            if(activeSelection < 1){ 
              setState(() {
                activeSelection++;
              });
            }
          },
          onSelectButtonClicked: () {
            if(activeSelection == 0) {
              widget.updateActiveScreen("Dialer");
            }
            else if(activeSelection == 1) {
              widget.updateActiveScreen("Contacts");
            }
          },
        ),
      ],
    );
  }

  Widget _screen() {
    return Container(
      child: _menuScreen(),
      decoration: BoxDecoration(
        border: Border.all(
        color: darkBlue,
        width:5.0,
        ),
        color: Colors.white,
      ),
    );
  }


  Widget _menuScreen() {
    return Stack(
      children: <Widget>[
        //WallpaperContainer(wallpaper: wallpaper),
        Column(
          children: <Widget>[
            SizedBox(height:100.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                _menuIcons(Icons.call, 0, "Phone"),
                _menuIcons(Icons.contacts, 1, "Contacts"),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _menuIcons(icon, selection, label) {
    return Column(
      children: <Widget>[
        Container(
          child: IconButton(
            icon: Icon(icon), 
            onPressed: (){}, 
            iconSize: 50.0, 
          ),
          color: activeSelection == selection ? Colors.lightBlueAccent : null,
        ),
        Text(label),
      ],
    );
  }
}
