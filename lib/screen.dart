import 'package:flutter/material.dart';

import 'menu.dart';
import 'dialer.dart';
import 'contacts.dart';

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  var activeScreen = "Menu";

  updateActiveScreen(value) {
    setState(() {
      activeScreen = value;
    });
  }

  chooseScreen() {
    switch(activeScreen) {
      case "Menu":
        return Menu(updateActiveScreen: updateActiveScreen);
      case "Dialer":
        return DialerApp(updateActiveScreen: updateActiveScreen);
      case "Contacts":
        return ContactsApp(updateActiveScreen: updateActiveScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return chooseScreen();
  }
}
