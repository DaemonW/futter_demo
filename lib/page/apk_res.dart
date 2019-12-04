import 'dart:html';

class ApkRes {
  File icon;
  File apk;
  bool encrypted;
  String name;

  ApkRes(File apk, {File icon, String name, bool encrypted}) {
    this.apk = apk;
    this.name = name;
    this.icon = icon;
    this.encrypted = encrypted;
  }
}
