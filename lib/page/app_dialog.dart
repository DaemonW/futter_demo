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
          width: 400,
          height: 300,
          decoration: ShapeDecoration(
              color: Color(0xFFFFFFFF),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                Radius.circular(8.0),
              ))),
          //margin: const EdgeInsets.all(12.0),
          child: AppUploadPage()
        ),
      ),
    );
  }
}