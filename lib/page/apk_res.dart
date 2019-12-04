import 'dart:html';

class ApkRes {
  File iconFile;
  File apkFile;
  bool encrypted;
  String name;

  ApkRes(File apk, File icon, String name, bool encrypted) {
    this.apkFile = apk;
    this.name = name;
    this.iconFile = icon;
    this.encrypted = encrypted;
  }
}
