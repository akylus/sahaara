import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:launcher_assist/launcher_assist.dart';
import 'package:flutter/services.dart';
import 'package:contacts_service/contacts_service.dart';



import 'package:phone_dialer/screens/menu.dart';
import 'package:phone_dialer/screens/dialer.dart';
import 'package:phone_dialer/screens/contacts.dart';
import 'package:phone_dialer/screens/callLog.dart';
import 'package:phone_dialer/widgets/wallpaper.dart';

class Screen extends StatefulWidget {
  @override
  _ScreenState createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {

  var activeScreen = "Menu";
  var wallpaper;
  bool accessStorage;
  Iterable<Contact> _contacts;
  List<Contact> _trueContacts;

  @override
  void initState() {
    accessStorage = false;
    super.initState();
    getPermissions();
  }

  getPermissions() async {
    await getContacts();
    await handleStoragePermissions();

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
        return ContactsApp(updateActiveScreen: updateActiveScreen, trueContacts: _trueContacts,);
      case "CallLog":
        return CallLogApp(updateActiveScreen: updateActiveScreen);
    }
  }

  @override
  Widget build(BuildContext context) {
    return chooseScreen();      
  }
}
