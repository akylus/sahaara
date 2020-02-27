import 'package:contacts_service/contacts_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'keypad.dart';
import 'package:call_number/call_number.dart';



class ContactsApp extends StatefulWidget {
  final Function(String value) updateActiveScreen;
  const ContactsApp({this.updateActiveScreen});
  @override
  _ContactsAppState createState() => _ContactsAppState();
}

class _ContactsAppState extends State<ContactsApp> {
  final darkBlue = const Color(0xff1C2C3B);
  Iterable<Contact> _contacts;
  List<Contact> _trueContacts;
  ScrollController _controller;
  var activeSelection = 0;

  void initState() {
    _controller = ScrollController();
    super.initState();
    getPermissions();
  }

  getPermissions() {
    getContacts();
  }

  void getContacts() async {
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

  void _goToHome() {
    widget.updateActiveScreen("Menu");
  }

  void _initCall(number) async {
    await new CallNumber().callNumber(number);
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

  _moveSelectionUp() {
    if(activeSelection > 0){ 
      setState(() {
        activeSelection--;
      });
      if(activeSelection < _trueContacts.length-3)
        _controller.animateTo(_controller.offset - 72.0,
          curve: Curves.linear, duration: Duration(milliseconds: 50));
    }
  }

  _moveSelectionDown() {
    if(activeSelection < _trueContacts.length-1){ 
      setState(() {
        activeSelection++;
      });
      if(activeSelection > 2)
      _controller.animateTo(_controller.offset + 72.0,
        curve: Curves.linear, duration: Duration(milliseconds: 50));
    }
  }

  void _callNumber() {
    Contact contact = _trueContacts?.elementAt(activeSelection);
    var _contactNumber = getPhoneNumber(contact.phones.toList());
    _initCall(_contactNumber);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Expanded(child: _screen()),
          KeyPad(
            onUpButtonClicked: () => _moveSelectionUp(),
            onDownButtonClicked: () => _moveSelectionDown(),
            onSelectButtonClicked: () => _callNumber(),
            onCallButtonClicked: () => _callNumber(),
            onBackButtonClicked: () => _goToHome(),
          ),
        ],
      ),
    );
  }

  Widget _screen() {
    return Container(
      color: Colors.white,
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
              color: activeSelection == index ? Colors.lightBlueAccent : null,
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
                onTap: (){
                  setState(() {
                    activeSelection = index;
                  });
                },
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
}
