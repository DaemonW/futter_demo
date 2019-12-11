import 'package:flutter/material.dart';
import 'package:VirtualStore/page/app_upload_page.dart';

class AppDialog extends Dialog {
  @override
  Widget build(BuildContext context) {
    return new Material(
      //创建透明层
      type: MaterialType.transparency, //透明类型
      child: Center(
          child: Container(
        alignment: Alignment.center,
        constraints: BoxConstraints(maxHeight: 400, maxWidth: 500),
        decoration: BoxDecoration(
            color: Color(0xFFFFFFFF),
            borderRadius: BorderRadius.circular(5.0)),
        //margin: const EdgeInsets.all(12.0),
        //child: AppUploadPage()),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: AppUploadPage(),
        ),
      )),
    );
  }
}
