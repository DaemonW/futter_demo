import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AppUploadPage extends StatefulWidget {
  @override
  _AppUploadState createState() {
    // TODO: implement createState
    return _AppUploadState();
  }
}

class _AppUploadState extends State<AppUploadPage> {
  String _appName;
  String _apk;
  String _icon;
  bool _encrypted;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar: AppBar(
          title: Text('Upload App'),
          automaticallyImplyLeading: false
        ),
        body: Center(
          child: Container(
            alignment: Alignment.center,
            width: 600,
            height: 400,
            decoration: ShapeDecoration(
                color: Color(0xFFFFFFFF),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                  Radius.circular(8.0),
                ))),
            margin: const EdgeInsets.all(12.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('App Name: '),
                      SizedBox(
                        width: 200,
                        height: 30,
                        child: TextField(
                          controller: TextEditingController(),
                        ),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        child: Text("Choose Apk"),
                        onPressed: () {},
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Text('Encrypt Apk: '),
                      Checkbox(
                        value: false,
                        onChanged: (v) {},
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      RaisedButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      RaisedButton(
                        child: Text('Confirm'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        ));
  }
}
