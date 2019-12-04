import 'dart:convert';
import 'dart:html';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_app/config/config.dart';
import 'package:flutter_app/page/apk_res.dart';
import 'package:flutter_app/util/http_util.dart';
import 'package:flutter_app/widget/loading_dialog.dart';
import 'package:flutter_app/widget/toast.dart';

class AppUploadPage extends StatefulWidget {
  @override
  _AppUploadState createState() {
    // TODO: implement createState
    return _AppUploadState();
  }
}

class _AppUploadState extends State<AppUploadPage> {
  bool _loading = false;
  String _appName = '';
  File _apk;
  Uint8List _icon;
  bool _encrypted = false;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
        appBar:
            AppBar(title: Text('Upload App'), automaticallyImplyLeading: false),
        body: pageContent());
  }

  Widget pageContent() {
    if (_loading) {
      return ProgressDialog(
        loading: _loading,
        msg: '正在加载...',
        child: Center(
          child: RaisedButton(
            onPressed: () {},
            child: Text('显示加载动画'),
          ),
        ),
      );
    }
    return Center(
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
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text('App Name: '),
                  getIcon(),
                  Text('Encrypted App'),
                  RaisedButton(
                    child: Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop(context);
                    },
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  SizedBox(
                    width: 200,
                    height: 30,
                    child: TextField(
                      onChanged: (String value) => _appName = value,
                      controller: TextEditingController.fromValue(
                          TextEditingValue(text: _appName)),
                    ),
                  ),
                  RaisedButton(
                    child: getApkFileName(),
                    onPressed: () {
                      //selectIcon();
                      selectApk();
                    },
                  ),
                  Checkbox(
                    value: _encrypted,
                    onChanged: (v) {
                      setState(() {
                        _encrypted = v;
                      });
                    },
                  ),
                  RaisedButton(
                    child: Text('Confirm'),
                    onPressed: () {
                      uploadApp();
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget getApkFileName() {
    if (_apk == null) {
      return Text('Choose Apk');
    }
    return Text(_apk.name);
  }

  Widget getIcon() {
    Image icon;
    if (_icon != null) {
      icon = Image.memory(
        _icon,
        width: 60,
        height: 60,
        fit: BoxFit.scaleDown,
      );
    } else {
      icon = Image.asset(
        'images/default_pic.png',
        width: 60,
        height: 60,
        fit: BoxFit.scaleDown,
      );
    }
    return IconButton(
      icon: icon,
      iconSize: 60,
      onPressed: () {
        selectIcon();
      },
    );
  }

  selectIcon() {
    final InputElement input = document.createElement('input');
    input
      ..type = 'file'
      ..accept = 'image/*';
    input.onChange.listen((e) async {
      final List<File> files = input.files;
      final reader = new FileReader();
      reader.readAsArrayBuffer(files[0]);
      reader.onError.listen((error) => print(error.toString()));
      await reader.onLoad.first;
      //completer.complete(input.value);
      if (input.files.length > 0) {
        setState(() {
          try {
            _icon = new Uint8List.fromList(reader.result);
          } catch (ex) {
            print(ex.toString());
          }
        });
      }
    });
    input.click();
    //return completer.future;
  }

  selectApk() {
    final InputElement input = document.createElement('input');
    input
      ..type = 'file'
      ..accept = 'application/vnd.android.package-archive/*';
    input.onChange.listen((e) async {
      if (input.files.length > 0) {
        var file = input.files[0];
        if (!file.name.endsWith('.apk')) {
          Toast.toast(context, 'selected file is not an APK.');
          return;
        }
        setState(() {
          _apk = input.files[0];
        });
      }
    });
    input.click();
    //return completer.future;
  }

  uploadApp() {
    if (_appName == null || _appName.isEmpty) {
      Toast.toast(context, 'empty app name!');
      return;
    }
    if (_apk == null) {
      Toast.toast(context, 'you need to select an apk file!');
      return;
    }
    Navigator.of(context).pop();
  }

  uploadApp1() async {
    if (_appName == null || _appName.isEmpty) {
      Toast.toast(context, 'empty app name!');
      return;
    }
    if (_apk == null) {
      Toast.toast(context, 'you need to select an apk file!');
      return;
    }
    MsgResponse resp;
    String uploadResult;
    try {
      setState(() {
        _loading = true;
      });
      Map<String, String> formParams = {
        'app_name': '_appName',
        'encrypted': '1'
      };
      List<FilePart> formFiles = List.from([FilePart('apk', "test.apk", _apk)]);
      resp = await HttpUtil.httpUploadMultiPartFileData(
          Config.getInstance().endPointManageApp, null, formParams, formFiles);
      if (resp.statusCode == 200) {
        uploadResult = 'upload app success';
      } else {
        var content = json.decode(resp.data);
        var err = content['err'];
        uploadResult = err['msg'];
      }
    } catch (e) {
      uploadResult = 'uploadApp: ' + e.toString();
    } finally {
      //Navigator.of(context).pop(uploadResult);
    }
  }
}
