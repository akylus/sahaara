import 'package:flutter/material.dart';


class KeyPad extends StatelessWidget {
  final darkBlue = const Color(0xff1C2C3B);

  final VoidCallback onCallButtonClicked;
  final VoidCallback onEraseButtonClicked;
  final VoidCallback onEraseButtonLongPressed;
  final VoidCallback onBackButtonClicked;
  final VoidCallback onDownButtonClicked;
  final VoidCallback onUpButtonClicked;
  final VoidCallback onSelectButtonClicked;
  final void Function(String number) onNumberKeyClicked;

  KeyPad({
    this.onCallButtonClicked,
    this.onEraseButtonClicked,
    this.onEraseButtonLongPressed,
    this.onBackButtonClicked,
    this.onDownButtonClicked,
    this.onUpButtonClicked,
    this.onSelectButtonClicked,
    this.onNumberKeyClicked
  });

  
  @override
  Widget build(BuildContext context) {
    return _keyPad();
  }

  Widget _keyPad() {
    return Column(
      children: <Widget>[
          _actionButtons(),
          _numPad()
      ],
    );
  }

  Widget _numPad() {
    return Column(
      children: <Widget>[
        _numberRow(["1","2","3"]),
        _numberRow(["4","5","6"]),
        _numberRow(["7","8","9"]),
        _numberRow(["star","0","hash"]),
      ],
    );
  }

  Widget _actionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _callButton(),
        _navigationButtonRow(),
        _backIconsColumn(),
      ],
    );
  }

  Widget _numberRow(numArray) {
    return Row(
      children: <Widget>[
        _numberIcon(numArray[0]),
        _numberIcon(numArray[1]),
        _numberIcon(numArray[2]),
      ],
    );
  }

  Widget _numberIcon(number) {
    return Container(
        child: Expanded(
          child: RaisedButton(
          onPressed: ()=> onNumberKeyClicked(number), 
          child: 
            Image.asset('assets/images/$number.png'),
          color: darkBlue,
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
        ),
      ),
    );
  }

  Widget _callButton() {
    return Container(
          color: Colors.green,
          child: GestureDetector(
              child: IconButton(
              icon: Icon(Icons.call, color: Colors.white), 
              onPressed: onCallButtonClicked, 
              iconSize: 50.0, 
              color: Colors.white,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
    );
  }

  Widget _backIconsColumn() {
    return Column(
      children: <Widget>[
        GestureDetector(
            child: _backIcon(Icons.backspace, onEraseButtonClicked, darkBlue),
          onLongPress: onEraseButtonLongPressed,
        ),
         _backIcon(Icons.arrow_back, onBackButtonClicked, Colors.red),
      ],
    );
  }

  Widget _backIcon(icon, func, iconColor) {
    return Container(
      color: iconColor,
      child: IconButton(
        icon: Icon(icon, color: Colors.white), 
        onPressed: func, 
        iconSize: 35.0, 
      ),
      padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
    );
  }

  Widget _navigationButtonRow() {
    return Row(
      children: <Widget>[
        _navButton(Icons.arrow_drop_up, onUpButtonClicked),
        _navButton(Icons.radio_button_unchecked, onSelectButtonClicked),
        _navButton(Icons.arrow_drop_down, onDownButtonClicked),
      ],
    );
  }

  Widget _navButton(icon, func) {
    return Container(
      color: Colors.black54,
      child: GestureDetector(
          child: IconButton(
          icon: Icon(icon, color: Colors.white), 
          onPressed: func, 
          iconSize: 50.0, 
          color: Colors.white,
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
    );
  }
}
