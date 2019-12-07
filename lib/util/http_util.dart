import 'dart:async';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class HttpUtil {
  static Future<html.HttpRequest> request(String url,
      {String method,
      bool withCredentials,
      String responseType,
      String mimeType,
      Map<String, String> requestHeaders,
      sendData,
      void onProgress(html.ProgressEvent e)}) {
    var completer = new Completer<html.HttpRequest>();

    var xhr = new html.HttpRequest();
    if (method == null) {
      method = 'GET';
    }
    xhr.open(method, url, async: true);

    if (withCredentials != null) {
      xhr.withCredentials = withCredentials;
    }

    if (responseType != null) {
      xhr.responseType = responseType;
    }

    if (mimeType != null) {
      xhr.overrideMimeType(mimeType);
    }

    if (requestHeaders != null) {
      requestHeaders.forEach((header, value) {
        xhr.setRequestHeader(header, value);
      });
    }

    if (onProgress != null) {
      xhr.onProgress.listen(onProgress);
    }

    xhr.onLoad.listen((e) {
      completer.complete(xhr);
    });

    xhr.onError.listen(completer.completeError);

    if (sendData != null) {
      xhr.send(sendData);
    } else {
      xhr.send();
    }

    return completer.future;
  }

  /// upload multipart data to a server
  static Future<MsgResponse> httpUploadMultiPartFileData(
      final String url,
      final String method,
      Map<String, String> headers,
      Map<String, String> formParams,
      final List<FilePart> formFiles) async {
    html.FormData body = new html.FormData();
    if (formParams != null) {
      formParams.forEach((String key, String val) {
        body.append(key, val);
      });
    }
    if (formFiles != null) {
      for (int i = 0; i < formFiles.length; i++) {
        FilePart file = formFiles[i];
        body.appendBlob(file.field, file.file);
      }
    }
    html.HttpRequest resp;
    try {
      resp = await request(url,
          method: method, requestHeaders: headers, sendData: body);
      return new MsgResponse(resp.status, resp.responseText);
    } catch (e) {
      throw e;
    }
  }

  static String randomStr(int len) {
    String alphabet =
        'qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM0123456789';
    List<int> bytes = new List<int>(len);
    for (var i = 0; i < len; i++) {
      bytes[i] = alphabet.codeUnitAt(Random().nextInt(alphabet.length));
    }
    return new String.fromCharCodes(bytes);
  }

  static bool isEmptyStr(String str) {
    return str == null || str.isEmpty;
  }
}

class MsgResponse {
  int statusCode = 0;
  Object data; // 数据内容，一般为字符串
  String errMsg; // 错误消息
  MsgResponse([this.statusCode = 0, this.data, this.errMsg]);

  bool isOk() {
    return statusCode < 300;
  }
}

class FilePart {
  String field;
  String name;
  html.File file;

  FilePart(String field, String name, html.File f) {
    this.field = field;
    this.name = name;
    this.file = f;
  }
}
