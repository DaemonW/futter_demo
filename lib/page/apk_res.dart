import 'dart:html';

class ApkRes {
  File iconFile;
  File apkFile;
  bool encrypted;
  String name;
  String category;

  ApkRes(File apk, File icon, String name, bool encrypted, String category) {
    this.apkFile = apk;
    this.name = name;
    this.iconFile = icon;
    this.encrypted = encrypted;
    this.category = category;
  }
}
