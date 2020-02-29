import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:call_number/call_number.dart';

import 'package:phone_dialer/widgets/keypad.dart';

class DialerApp extends StatefulWidget {
  final Function(String value) updateActiveScreen;
  const DialerApp({this.updateActiveScreen});

  @override
  _DialerAppState createState() => _DialerAppState();
}

class _DialerAppState extends State<DialerApp> {
  final darkBlue = const Color(0xff1C2C3B);
  var _number = "";
  
  void _addNumber(num) {
    if(num == "star")
      num = "*";

    if(num == "hash")
      num = "#";
    
    setState(() {
      _number = _number + num;
    });
  }

  void _clearDigit() {
    if (_number.length > 0)
      setState(() {
        _number = _number.substring(0, _number.length - 1);
      });
  }

  void _clearAll() {
    setState(() {
      _number = "";
    });
  }
  
  void _initCall(number) async {
    await new CallNumber().callNumber(number);
  }

  void _goToHome() {
    widget.updateActiveScreen("Menu");
  }

  void _callNumber(_number) {
    if(_number.length>0) {
      print("Clicked");
      if(_number.contains('#')) {
        _number = _number.replaceAll('#', '%23');
      }
      _initCall(_number);
      _clearAll();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(child: _screen()),
          KeyPad(
            onCallButtonClicked: () => _callNumber(_number),
            onEraseButtonClicked: () => _clearDigit(),
            onEraseButtonLongPressed: () => _clearAll(),
            onBackButtonClicked: () => _goToHome(),
            onNumberKeyClicked: (value) => _addNumber(value),
          ),
        ],
      ),
    );
  }

  Widget _screen() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 10.0),
            Text("Enter Number",
              style: TextStyle(
                fontSize: 20.0,
                color: darkBlue,
                letterSpacing: 2.0,
              ),
            ),
            SizedBox(height: 60.0),
            Text(
              '$_number',
              style: TextStyle(
                fontSize: _number.length < 29 ? 50.0 : 30.0,
                color: darkBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

