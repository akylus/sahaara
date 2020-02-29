import 'package:flutter/material.dart';
import 'package:call_log/call_log.dart';
import 'package:call_number/call_number.dart';


import 'package:phone_dialer/widgets/keypad.dart';

class CallLogApp extends StatefulWidget {
  final Function(String value) updateActiveScreen;
  const CallLogApp({this.updateActiveScreen});
  @override
  _CallLogAppState createState() => _CallLogAppState();
}

class _CallLogAppState extends State<CallLogApp> {
  final darkBlue = const Color(0xff1C2C3B);
  ScrollController _controller;
  var activeSelection = 0;

  Iterable<CallLogEntry> logEntries;

  void initState() {
    super.initState();
    _controller = ScrollController();
    _getCallLogs();
  }

  _getCallLogs() async {
    logEntries = await CallLog.get();
  }

  _moveSelectionUp() {
    if(activeSelection > 0){ 
      setState(() {
        activeSelection--;
      });
      if(activeSelection < logEntries.length-3)
        _controller.animateTo(_controller.offset - 72.0,
          curve: Curves.linear, duration: Duration(milliseconds: 50));
    }
  }

  _moveSelectionDown() {
    if(activeSelection < logEntries.length-1){ 
      setState(() {
        activeSelection++;
      });
      if(activeSelection > 2)
      _controller.animateTo(_controller.offset + 72.0,
        curve: Curves.linear, duration: Duration(milliseconds: 50));
    }
  }

  _getCallTypeAndColor(callType) {
    switch(callType) {
      case CallType.incoming:
        return ["Incoming", Colors.blue];
      case CallType.outgoing:
        return ["Outgoing", Colors.green];
      case CallType.rejected:
        return ["Rejected", Colors.redAccent];
      case CallType.missed:
        return ["Missed", Colors.red];
      default:
        return ["Null", Colors.black];

    }
  }

  void _goToHome() {
    widget.updateActiveScreen("Menu");
  }

  void _initCall(number) async {
    await new CallNumber().callNumber(number);
  }

  void _callNumber(_contactNumber) {
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
            onSelectButtonClicked: () => _callNumber(logEntries.elementAt(activeSelection).formattedNumber),
            onCallButtonClicked: () => _callNumber(logEntries.elementAt(activeSelection).formattedNumber),
            onBackButtonClicked: () => _goToHome(),
          ),
        ],
      ),
    );
  }

  Widget _screen() {
    return Container(
      color: Colors.white,
       child: logEntries != null ? _contactList() : _loader(),
    );
  }

  Widget _contactList() {
    return SizedBox(
      height: 257.0,
      child:ListView.builder(
        controller: _controller,
        itemCount: logEntries?.length ?? 0,
        itemBuilder: (context, index) {
          CallLogEntry c = logEntries?.elementAt(index);
          var name = c.name;
          var number = c.formattedNumber;
          var arr = _getCallTypeAndColor(c.callType);
          if(name == null) name = number;
          if(number != null) {
            return Container(
              color: activeSelection == index ? Colors.lightBlueAccent : null,
              child: ListTile(
                //----------Contact Icon----------
                leading: CircleAvatar(child: Text(name[0]), radius: 30.0,),
                //----------Contact Title----------
                title: Text(
                  name ?? '', 
                  style: TextStyle(
                    color: darkBlue,
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                //----------Contact Number----------
                subtitle: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Text(
                      number ?? '', 
                      style: TextStyle(
                          color: darkBlue,
                          fontSize: 15.0,
                        ),
                    ),
                    Text(
                      arr[0] ?? '', 
                      style: TextStyle(
                          color: arr[1],
                          fontSize: 15.0,
                        ),
                    ),
                  ],
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