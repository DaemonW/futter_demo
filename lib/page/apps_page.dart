import 'package:flutter/material.dart';
import 'package:VirtualStore/event/even_bus.dart';
import 'package:VirtualStore/page/apk_res.dart';
import 'package:VirtualStore/page/app_dialog.dart';
import 'package:VirtualStore/page/app_upload_page.dart';
import 'package:VirtualStore/util/http_util.dart';
import 'package:VirtualStore/widget/alter_dialog.dart';
import 'package:VirtualStore/widget/edit_dialog.dart';
import 'package:VirtualStore/widget/loading_dialog.dart';
import 'package:VirtualStore/widget/toast.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'dart:html';
import 'dart:async';
import 'package:VirtualStore/config/config.dart';

import 'app_info_page.dart';

class AppPage extends StatefulWidget {
  @override
  _AppPageState createState() {
    return _AppPageState();
  }
}

class _AppPageState extends State<AppPage> {
  //config param
  double iconSize = 32;
  double iconSmall = 15;
  double fontBig = 14;
  double fontMid = 13;
  //var
  List _apps = [];
  bool _loading = false;
  GlobalKey _anchorKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    loadData();
  }

  @override
  Widget build(BuildContext context) {
    Widget content = Scaffold(
      appBar: AppBar(
        title: Text("全部应用"),
      ),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            color: Color(0xffefefef),
          ),
          //constraints: BoxConstraints(maxWidth: 900),
          child: getBody(),
        ),
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

  refreshUI() {
    setState(() {});
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

  goAppUploadPage() async {
    final ApkRes selectApk = await showDialog(
        context: context,
        builder: (c) {
          return AppDialog();
        });
    if (selectApk != null) {
      print('select apk: ${selectApk.apkFile.name}');
      if (selectApk.name == null || selectApk.name.isEmpty) {
        Toast.toast(context, 'empty app name!');
        return;
      }
      if (selectApk.apkFile == null) {
        Toast.toast(context, 'you need to select an apk file!');
        return;
      }
      setState(() {
        _loading = true;
      });
      await uploadApp(selectApk);
      setState(() {
        _loading = false;
      });
    }
  }

  getBody() {
    return Container(
        child: ListView.builder(
            itemCount: _apps.length,
            itemBuilder: (BuildContext context, int position) {
              return getItem(_apps[position]);
            }));
  }

  getItem(var app) {
    Widget icon;
    String iconUrl = app["Icon"];
    DateTime t = DateTime.parse(app['CreateAt']);
    String appUpdateTime = '${t.year}-${t.month}-${t.day}';
    if (iconUrl == null || iconUrl.isEmpty) {
      icon = Image.asset(
        'images/icon_default.png',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.scaleDown,
      );
    } else {
      var r = HttpUtil.randomStr(8);
      icon = Image.network(
        iconUrl + '&&r=$r',
        width: iconSize,
        height: iconSize,
        fit: BoxFit.scaleDown,
      );
    }
    double size = app['Size'] / 1024 / 1024;
    var row = Container(
      margin: EdgeInsets.all(4.0),
      child: Row(
        children: <Widget>[
          ClipRRect(
              borderRadius: BorderRadius.circular(4.0),
              child: IconButton(
                icon: icon,
                iconSize: iconSize,
                onPressed: () {
                  updateIcon(app);
                },
              )),
          Expanded(
            child: Container(
              margin: EdgeInsets.only(left: 10.0, right: 10),
              alignment: Alignment.centerLeft,
              //height: 150.0,
              //child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Text(
                        app['Name'],
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: fontBig,
                        ),
                        maxLines: 1,
                      ),
                      Expanded(
                        child: Text(
                          appUpdateTime,
                          style: TextStyle(
                            fontSize: fontMid,
                          ),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Text(
                        app['Version'],
                        style: TextStyle(fontSize: fontMid),
                      ),
                      Expanded(
                        child: Text(
                          size.toStringAsFixed(2) + "MB",
                          textAlign: TextAlign.right,
                          style: TextStyle(fontSize: fontMid),
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          getEncryptedIcon(app['Encrypted']),
          getContextMenu(app),
        ],
      ),
    );
    return Card(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        child: row,
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AppInfoPage(app);
          }));
        },
      ),
    );
  }

  Widget getEncryptedIcon(bool encrypted) {
    if (encrypted) {
      return SizedBox(
          width: iconSmall,
          height: iconSmall,
          child: Image.asset('images/encrypted.png',
              fit: BoxFit.scaleDown, width: iconSmall, height: iconSmall));
    }
    {
      return SizedBox(
        width: iconSmall,
        height: iconSmall,
      );
    }
  }

  Widget getContextMenu(var app) {
    bool encrypted = app['Encrypted'];
    return PopupMenuButton(
      onCanceled: () {},
      onSelected: (v) {
        switch (v) {
          case '1':
            showRenameDialog(app);
            break;
          case '2':
            showDeleteDialog(app);
            break;
          case '3':
            enableAppEncryped(app, !encrypted);
            break;
        }
      },
      itemBuilder: (BuildContext context) {
        List<PopupMenuEntry> list = List<PopupMenuEntry>();
        list.add(
          PopupMenuItem(
            value: '1',
            child: Text('重命名'),
          ),
        );

        list.add(
          PopupMenuItem(
            value: '2',
            child: Text('删除'),
          ),
        );
        var t = encrypted ? '取消加密' : '加密';
        list.add(
          PopupMenuItem(
            value: '3',
            child: Text(t),
          ),
        );
        return list;
      },
    );
  }

  showDeleteDialog(var app) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (c) {
          return MyAlertDialog(
            content: '确定删除应用?',
            confirmCallback: () {
              deleteApp(app);
            },
          );
        });
  }

  deleteApp(var app) async {
    try {
      Storage storage = window.localStorage;
      String token = storage['token'];
      var headers = Map<String, String>();
      headers['Authorization'] = token;
      HttpRequest resp = await HttpUtil.request(
          Config.getInstance().endPointOperateApp + '/${app['Id']}',
          method: 'DELETE',
          requestHeaders: headers);
      if (resp.status == 200) {
        loadData();
        Toast.toast(context, "删除成功");
      }
    } catch (e) {
      print('err: ' + e.toString());
    }
  }

  showRenameDialog(var app) {
    var originName = app['Name'];
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (c) {
          return MyEditDialog(
            title: '新应用名',
            initialContent: originName,
            confirmCallback: (v) {
              renameApp(app, v);
            },
          );
        });
  }

  renameApp(var app, String newName) async {
    try {
      var id = app['Id'];
      Map<String, String> params = {'name': newName};
      Storage storage = window.localStorage;
      String token = storage['token'];
      var headers = Map<String, String>();
      headers['Authorization'] = token;
      MsgResponse resp = await HttpUtil.httpUploadMultiPartFileData(
          Config.getInstance().endPointOperateApp + '/$id?scope=name',
          "PUT",
          headers,
          params,
          null);
      if (resp.statusCode == 200) {
        app['Name'] = newName;
        refreshUI();
        Toast.toast(context, "更改成功");
      }
    } catch (e) {
      print('err: ' + e.toString());
    }
  }

  enableAppEncryped(var app, bool enable) async {
    try {
      var id = app['Id'];
      var encrypted = enable ? '1' : '0';
      Map<String, String> params = {'encrypted': encrypted};
      Storage storage = window.localStorage;
      String token = storage['token'];
      var headers = Map<String, String>();
      headers['Authorization'] = token;
      MsgResponse resp = await HttpUtil.httpUploadMultiPartFileData(
          Config.getInstance().endPointOperateApp + '/$id?scope=encrypted',
          "PUT",
          headers,
          params,
          null);
      if (resp.statusCode == 200) {
        app['Encrypted'] = enable;
        refreshUI();
        Toast.toast(context, "更新成功");
      }
    } catch (e) {
      print('err: ' + e.toString());
    }
  }

  updateIcon(var app) {
    final InputElement input = document.createElement('input');
    input
      ..type = 'file'
      ..accept = 'image/*';
    input.onChange.listen((e) async {
      var i = e.target as InputElement;
      final List<File> files = i.files;
      if (files == null || files.length == 0) {
        return;
      }
      print('select icon');
      List<FilePart> formFiles =
          List.from([FilePart('icon', app['Name'], files[0])]);
      Storage storage = window.localStorage;
      String token = storage['token'];
      var headers = Map<String, String>();
      headers['Authorization'] = token;
      try {
        var id = app['Id'];
        MsgResponse resp = await HttpUtil.httpUploadMultiPartFileData(
            Config.getInstance().endPointOperateApp + '/$id?scope=icon',
            "PUT",
            headers,
            null,
            formFiles);
        if (resp.statusCode == 200) {
          loadData();
          Toast.toast(context, "更新成功");
        } else {
          var content = json.decode(resp.data);
          var err = content['err'];
          Toast.toast(context, err['msg']);
        }
      } catch (e) {
        print('err: ' + e.toString());
      }
    });
    input.click();
    //return completer.future;
  }

  uploadApp(ApkRes apk) async {
    MsgResponse resp;
    String uploadResult;
    Storage storage = window.localStorage;
    String token = storage['token'];
    var headers = Map<String, String>();
    headers['Authorization'] = token;
    try {
      Map<String, String> formParams = {
        'name': '${apk.name}',
        'encrypted': '${apk.encrypted}',
        'category':'${apk.category}'
      };
      List<FilePart> formFiles =
          List.from([FilePart('apk', apk.name, apk.apkFile)]);
      resp = await HttpUtil.httpUploadMultiPartFileData(
          Config.getInstance().endPointManageApp,
          "POST",
          headers,
          formParams,
          formFiles);
      if (resp.statusCode == 200) {
        uploadResult = '上传成功';
        loadData();
      } else {
        var content = json.decode(resp.data);
        var err = content['err'];
        uploadResult = err['msg'];
      }
    } catch (e) {
      uploadResult = 'uploadApp: ' + e.toString();
    } finally {
      Toast.toast(context, uploadResult);
    }
  }
}
