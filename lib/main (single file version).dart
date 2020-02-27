import 'package:flutter/material.dart';
//import 'package:url_launcher/url_launcher.dart' as UrlLauncher;
import 'package:launcher_assist/launcher_assist.dart';
import 'package:call_number/call_number.dart';
import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
  

void main() => runApp(PhoneDialer());

class PhoneDialer extends StatelessWidget {
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sahaara',
      home: Dialer(title: 'SAHAARA'),
    );
  }
}

class Dialer extends StatefulWidget {
  Dialer({Key key, this.title}) : super(key: key);
  final String title;
  _DialerState createState() => _DialerState();
}

class _DialerState extends State<Dialer> {
  var wallpaper;
  bool accessStorage;
  var _number = "";
  var _activeScreen = "_menuScreen";
  var _selectButtonPressed = false;
  int _activeSelection = 0;
  var contactIndex = -1;
  var darkBlue = const Color(0xff1C2C3B);
  Iterable<Contact> _contacts;
  List<Contact> _trueContacts;
  var _activeContactSelection = 0;
  ScrollController _controller;

  void initState() {
    _controller = ScrollController();
    accessStorage = false;
    super.initState();
    getPermissions();
  }

//-------------------------------------Handling contact and storage permissions--------------------------------
  getPermissions() async {
    await getContacts();
    await handleStoragePermissions();
  }

  getContacts() async {
    PermissionStatus permissionStatus = await _getPermission(PermissionGroup.contacts);
    if (permissionStatus == PermissionStatus.granted) {
      var contacts = await ContactsService.getContacts();
      if(this.mounted) {
        setState(() {
          _contacts = contacts;
        });
      }
    } else {
      throw PlatformException(
        code: 'PERMISSION_DENIED',
        message: 'Access to location data denied',
        details: null,
      );
    }
    var trueContacts = await getTrueContacts();      //Skip contacts without phone number
    if(this.mounted) {
        setState(() {
          _trueContacts = trueContacts;
        });
      }
  }

  Future<PermissionStatus> _getPermission(permissionType) async {
    PermissionStatus permission = await PermissionHandler()
      .checkPermissionStatus(permissionType);
    if (permission != PermissionStatus.granted &&
      permission != PermissionStatus.disabled) {
        Map<PermissionGroup, PermissionStatus> permisionStatus =
          await PermissionHandler()
            .requestPermissions([permissionType]);
        return permisionStatus[permissionType] ??
          PermissionStatus.unknown;
    } 
    else
      return permission;
  }

  handleStoragePermissions() async {
      PermissionStatus permissionStatus = await _getPermission(PermissionGroup.storage);
      if (permissionStatus == PermissionStatus.granted) {
        await LauncherAssist.getWallpaper().then((imageData) {
          setState(() {
            wallpaper = imageData;
            accessStorage = !accessStorage;
          });
        });
      } else {
        throw PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'Access to location data denied',
          details: null,
        );
      }
      
  }

  getTrueContacts() {
    List<Contact> _trueContacts = [];
    for(var i=0; i< _contacts.length; i++) {
      var c = _contacts.elementAt(i);
      var phoneNumberList = c.phones.toList();
      for(var j=0; j<phoneNumberList.length; j++) {
        if(phoneNumberList[j].value.length > 0 && phoneNumberList[j].value.contains("+91")) {
          _trueContacts.add(c);
          break;
        }
      }
    }
    return _trueContacts;
  }

//-------------------------------------Phone App Functions--------------------------------


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

//-------------------------------------Button Functions--------------------------------

//---------------Up Arrow---------------
  _upArrowPressed() {
    var minValue = 0;
    if(_activeScreen == "_menuScreen") {
      if(_activeSelection > minValue) {
        if(this.mounted) {
          setState(() {
            _activeSelection--;
          });
        }
      }
    }
    else if(_activeScreen == "_contactsApp") {
      if(_activeContactSelection > minValue) {
        if(this.mounted) {
          setState(() {
            _activeContactSelection--;
          });
        }
        _controller.animateTo(_controller.offset - 72.0,
          curve: Curves.linear, duration: Duration(milliseconds: 50));
      }
    }
    
  }

//---------------Down Arrow---------------

  _downArrowPressed() {
    var maxValue;
    if(_activeScreen == "_menuScreen") {
      maxValue = 1;
      if(_activeSelection < maxValue) {
        if(this.mounted) {
          setState(() {
            _activeSelection++;
          });
        }
      }
    }
    else if(_activeScreen == "_contactsApp") {                  
      if(_activeContactSelection < _trueContacts.length) {
        if(this.mounted) {
          setState(() {
            _activeContactSelection++;
          });
        }
        _controller.animateTo(_controller.offset + 72.0,
          curve: Curves.linear, duration: Duration(milliseconds: 50));
      }
    }
  }

//---------------Select Button---------------

  _selectPressed() {
    if(_activeScreen == "_menuScreen") {
      if(this.mounted) {
        setState(() {
          _selectButtonPressed = true;
        });
      }
    }
    else if(_activeScreen == "_contactsApp") {
      Contact contact = _trueContacts?.elementAt(_activeContactSelection);
      var _contactNumber = getPhoneNumber(contact.phones.toList());
      _initCall(_contactNumber);
    }
  }

//---------------Back Button---------------

  _goToHomeScreen() {
    _setActiveScreen("_menuScreen");
    setState(() {
      _selectButtonPressed = false;
      _number = "";
    });
  }

//-------------------------------------Uncategorised--------------------------------

  _setActiveScreen(screenName) {
    _activeScreen = screenName;
  }


  void _callNumber() {
    print(_activeScreen);
    if(_number.length>0) {
      print("Clicked");
      if(_number.contains('#')) {
        _number = _number.replaceAll('#', '%23');
      }
      _initCall(_number);
      _clearAll();
    }
    else if(_activeScreen == "_contactsApp") {
      Contact contact = _trueContacts?.elementAt(_activeContactSelection);
      var _contactNumber = getPhoneNumber(contact.phones.toList());
      _initCall(_contactNumber);
    }
  }
  

  getPhoneNumber(phoneNumberList) {
    var i;
    var phoneNumber;
    for(i=0; i<phoneNumberList.length; i++) {
      if(phoneNumberList[i].value.length > 0 && phoneNumberList[i].value.contains("+91")) {
        phoneNumber = phoneNumberList[i].value;
        return phoneNumber;
      }
    }
    return null;
  }

//=================================================BUILD SARTS HERE=================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text(widget.title, style: TextStyle(letterSpacing: 3.0, fontSize: 22.0),),),
        backgroundColor: darkBlue,
      ),
      backgroundColor: darkBlue,
      body: WillPopScope(
          onWillPop: ()=>Future(()=>false),
            child: Column(
          children: <Widget>[
            _screen(),
            _actionButtons(),
            _numPad(),
          ],
        ),
      ),
    );
  }

  Widget _screen() {
    return Expanded(
      child: Container(
        child: _selectButtonPressed ? _chooseScreen() : _miniScreen(_menuScreen),
        decoration: BoxDecoration(
          border: Border.all(
          color: darkBlue,
          width:5.0,
          ),
          color: Colors.white,
        ),
      )
    );
  }

  Widget _chooseScreen () {
    switch(_activeSelection) {
      case 0:
        return _miniScreen(_phoneApp);
      case 1:
        return _contactsApp();
    } 
    return _miniScreen(_menuScreen);
  }

  Widget _miniScreen(func) {
    return Column(
      children: <Widget>[
        Stack(
          children: <Widget>[
            Container(
              child: func(),
            ),
          ],
        ),
      ],
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
          color: _activeSelection == selection ? Colors.lightBlueAccent : null,
        ),
        Text(label),
      ],
    );
  }

//-------------------------------------Phone App Widget--------------------------------


  Widget _phoneApp() {
    _setActiveScreen("_phoneApp");
    return Center(
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
    );
  }

//-------------------------------------Contacts App Widgets--------------------------------


  Widget _contactsApp() {
    _setActiveScreen("_contactsApp");
    return Container(
      child: _accessContacts(),
    );
  }

  Widget _accessContacts() {
    return Container(
       child: _contacts != null ? _contactList() : _loader()
    );
  }

  Widget _contactList() {
    return SizedBox(
      height: 257.0,
      child:ListView.builder(
        controller: _controller,
        itemCount: _trueContacts?.length ?? 0,
        itemBuilder: (context, index) {
          Contact c = _trueContacts?.elementAt(index);
          var a = "";
          a = getPhoneNumber(c.phones.toList());
          if(a != null) {
            return Container(
              color: _activeContactSelection == index ? Colors.lightBlueAccent : null,
              child: ListTile(
                //----------Contact Icon----------
                leading: (c.avatar != null && c.avatar.length > 0)
                  ? CircleAvatar(
                      backgroundImage: MemoryImage(c.avatar, scale: 0.5),
                      radius: 30.0,
                    )
                  : CircleAvatar(child: Text(c.initials()), radius: 30.0,),
                //----------Contact Title----------
                title: Text(
                  c.displayName ?? '', 
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                //----------Contact Number----------
                subtitle: Text(
                  a ?? '', 
                  style: TextStyle(
                      color: darkBlue,
                      fontSize: 20.0,
                    ),
                ),
                onTap: (){setState(() {
                  _activeContactSelection = index;
                });},
              ),
            );
          }
          else {
            return Container();
          }
        },
      ),
    );
  }

  Widget _loader() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Center(
          child: Column(
            children: <Widget>[
              SizedBox(
                child: CircularProgressIndicator(
                  backgroundColor: darkBlue,
                ),
                height: 38.0,
              ),
              SizedBox(height:10.0),
              Text("Please wait..", style: TextStyle(fontSize:20.0),)
            ],
          ),
        ),
      ],
    );
  }

//-------------------------------------Buttons-related Widgets--------------------------------

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
        _backIcons(),
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

  Widget _numberIcon(num) {
    return Container(
        child: Expanded(
          child: RaisedButton(
          onPressed: ()=> _addNumber(num), 
          child: 
            Image.asset('assets/images/$num.png'),
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
              icon: Icon(Icons.call), 
              onPressed: _callNumber, 
              iconSize: 50.0, 
              color: Colors.white,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
    );
  }

  Widget _backIcons() {
    return Column(
      children: <Widget>[
        GestureDetector(
            child: Container(
            color: darkBlue,
            child: IconButton(
              icon: Icon(Icons.backspace), 
              onPressed: _clearDigit, 
              iconSize: 35.0, 
              color: Colors.white,
            ),
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
          ),
          onLongPress: _clearAll,
        ),
        Container(
          color: Colors.red,
          child: IconButton(
            icon: Icon(Icons.arrow_back), 
            onPressed: _goToHomeScreen, 
            iconSize: 35.0, 
            color: Colors.white,
          ),
          padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 0.0),
        ),
      ],
    );
  }

  Widget _navigationButtonRow() {
    return Row(
      children: <Widget>[
        _navButton(Icons.arrow_drop_up, _upArrowPressed),
        _navButton(Icons.radio_button_unchecked, _selectPressed),
        _navButton(Icons.arrow_drop_down, _downArrowPressed),
      ],
    );
  }

  Widget _navButton(icon, func) {
    return Container(
          color: Colors.black54,
          child: GestureDetector(
              child: IconButton(
              icon: Icon(icon), 
              onPressed: func, 
              iconSize: 50.0, 
              color: Colors.white,
            ),
          ),
          padding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 20.0),
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
