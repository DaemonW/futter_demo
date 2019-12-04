import 'package:flutter/material.dart';
import 'package:flutter_app/event/even_bus.dart';
import 'package:flutter_app/page/apk_res.dart';
import 'package:flutter_app/page/app_dialog.dart';
import 'package:flutter_app/page/app_upload_page.dart';
import 'package:flutter_app/util/http_util.dart';
import 'package:flutter_app/widget/loading_dialog.dart';
import 'package:flutter_app/widget/toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'dart:html';
import 'dart:async';
import 'package:flutter_app/config/config.dart';

class AppPage extends StatefulWidget {
  @override
  _AppPageState createState() {
    return _AppPageState();
  }
}

class _AppPageState extends State<AppPage> {
  List _apps = [];
  bool _loading = false;

  @override
  void initState() {
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      appBar: AppBar(
        title: Text("全部应用"),
      ),
      body: Center(
        child: getBody(),
      ),
      floatingActionButton: new Builder(builder: (BuildContext context) {
        return new FloatingActionButton(
          child: const Icon(Icons.add),
          tooltip: "Upload App",
          foregroundColor: Colors.white,
          backgroundColor: Colors.black,
          heroTag: null,
          elevation: 7.0,
          highlightElevation: 14.0,
          onPressed: () {
            try {
              goAppUploadPage();
            } catch (ex) {
              print('select file error: ' + ex.toString());
            }
          },
          mini: false,
          shape: new CircleBorder(),
          isExtended: false,
        );
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
    return ProgressDialog(
      loading: _loading,
      msg: "uploading...",
      child: content,
    );
  }

  loadData() async {
    try {
      String loadRUL = Config.getInstance().endPointQueryApps + '?uuid=123';
      http.Response response = await http.get(loadRUL);
      var resp = json.decode(response.body);
      if (response.statusCode == 200) {
        var result = resp['result'];
        setState(() {
          _apps = result['apps'];
        });
      } else {
        var err = resp['err'];
        Toast.toast(context, err['msg']);
      }
    } catch (ex) {
      print("error: " + ex.toString());
    }
  }

  Future<String> getFile() {
    final completer = new Completer<String>();
    final InputElement input = document.createElement('input');
    input
      ..type = 'file'
      ..accept = '*/*';
    input.onChange.listen((e) async {
      //final List<File> files = input.files;
      // final reader = new FileReader();
      // reader.readAsDataUrl(files[0]);
      // reader.onError.listen((error) => completer.completeError(error));
      // await reader.onLoad.first;
      completer.complete(input.value);
    });
    input.click();
    return completer.future;
  }

  showUploadDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AppDialog();
        });
  }

  goAppUploadPage() async {
    final ApkRes selectApk = await Navigator.of(context).push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return AppUploadPage();
        }));
        print("select apk");
    if (selectApk != null) {
      uploadApp(selectApk);
    }
  }

  getBody() {
    if (_apps.length != 0) {
      return ListView.builder(
          itemCount: _apps.length,
          itemBuilder: (BuildContext context, int position) {
            return getItem(_apps[position]);
          });
    } else {
      // 加载菊花
      return CupertinoActivityIndicator();
    }
  }

  getItem(var app) {
    String icon = app["Icon"];
    if (icon == null || icon.isEmpty) {
      icon = Config.getInstance().endPointDownloads + '/icon_default.png';
    }
    double size = app['Size'] / 1024 / 1024;
    var row = Container(
      margin: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(4.0),
            child: Image.network(
              icon,
              width: 60.0,
              height: 60.0,
              fit: BoxFit.scaleDown,
            ),
          ),
          Container(
            margin: EdgeInsets.only(left: 20.0),
            //height: 150.0,
            child: Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  app['Name'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                  maxLines: 1,
                ),
                Text(
                  app['Version'] + '    ' + size.toStringAsFixed(2) + "MB",
                  style: TextStyle(fontSize: 16.0),
                ),
              ],
            )),
          )
        ],
      ),
    );
    return Card(
      child: row,
    );
  }

  uploadApp(ApkRes apk) async {
    if (apk.name == null || apk.name.isEmpty) {
      Toast.toast(context, 'empty app name!');
      return;
    }
    if (apk.apkFile == null) {
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
      List<FilePart> formFiles =
          List.from([FilePart('apk', apk.name, apk.apkFile)]);
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
      setState(() {
        _loading = false;
      });
      Toast.toast(context, uploadResult);
    }
  }
}
