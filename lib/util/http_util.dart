import 'dart:async';
import 'dart:html' as html;
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

class HttpUtil {
  static Map _makeHttpHeaders(
      [String contentType,
      String accept,
      String token,
      String xRequestWith,
      String xMethodOverride]) {
    Map headers = new Map<String, String>();
    int i = 0;

    if (!isEmptyStr(contentType)) {
      i++;
      headers["Content-Type"] = contentType;
    }

    if (!isEmptyStr(accept)) {
      i++;
      headers["Accept"] = accept;
    }

    if (!isEmptyStr(token)) {
      i++;
      headers["Authorization"] = "bearer " + token;
    }

    if (!isEmptyStr(xRequestWith)) {
      i++;
      headers["X-Requested-With"] = xRequestWith;
    }

    if (!isEmptyStr(xMethodOverride)) {
      i++;
      headers["X-HTTP-Method-Override"] = xMethodOverride;
    }

    if (i == 0) return null;
    // print(headers.toString());
    return headers;
  }

/** HTTP POST 上传文件 */
  static Future<MsgResponse> httpUploadFile(
    final String url,
    final html.File file, {
    String accept = "*/*",
    String token,
    String field = "apk",
    String contentType, // 默认为null，自动获取
  }) async {
    try {
      final reader = new html.FileReader();
      reader.readAsArrayBuffer(file);
      reader.onError.listen((error) => print(error.toString()));
      await reader.onLoad.first;
      //List<int> bytes = await file.readAsBytes();
      List<int> bytes = Uint8List.fromList(reader.result);
      return await httpUploadFileData(url, bytes,
          accept: accept,
          token: token,
          field: field,
          contentType: contentType,
          filename: file.name);
    } catch (e) {
      throw e;
    }
  }

  /// upload multipart data to a server
  static Future<MsgResponse> httpUploadMultiPartFileData(
      final String url,
      Map<String, String> headers,
      Map<String, String> formParams,
      final List<FilePart> formFiles) async {
    try {
      var boundary = _boundaryString();
      if (headers == null) {
        headers = new Map<String, String>();
      }
      String contentType = 'multipart/form-data; boundary=$boundary';
      headers['Content-Type'] = contentType;

      var bytes = await makeMultipartBody(boundary, formParams, formFiles);
      //print("bytes: \r\n" + UTF8.decode(bytes, allowMalformed: true));

      http.Response response =
          await http.post(url, headers: headers, body: bytes);
      if (response.statusCode == 200) {
        return new MsgResponse(response.statusCode, response.body);
      } else
        return new MsgResponse(response.statusCode, response.body);
    } catch (e) {
      throw e;
    }
  }

  /** HTTP POST 上传文件 */
  static Future<MsgResponse> httpUploadFileData(
    final String url,
    final List<int> filedata, {
    String accept = "*/*",
    String token,
    String field = "apk",
    String contentType, // 默认为null，自动获取
    String filename,
  }) async {
    try {
      List<int> bytes = filedata;
      var boundary = _boundaryString();
      String contentType = 'multipart/form-data; boundary=$boundary';
      Map headers =
          _makeHttpHeaders(contentType, accept, token); //, "XMLHttpRequest");

      // 构造文件字段数据
      String data =
          '--$boundary\r\nContent-Disposition: form-data; name="$field"; ' +
              'filename="$filename"\r\nContent-Type: ' +
              '$contentType\r\n\r\n';
      var controller = new StreamController<List<int>>(sync: true);
      controller.add(data.codeUnits);
      controller.add(bytes);
      controller.add("\r\n--$boundary--\r\n".codeUnits);

      controller.close();
      bytes = await new http.ByteStream(controller.stream).toBytes();
      //print("bytes: \r\n" + UTF8.decode(bytes, allowMalformed: true));

      http.Response response =
          await http.post(url, headers: headers, body: bytes);
      if (response.statusCode == 200) {
        return new MsgResponse(response.statusCode, response.body);
      } else
        return new MsgResponse(response.statusCode, response.body);
    } catch (e) {
      throw e;
    }
  }

  static Future<Uint8List> makeMultipartBody(String boundary,
      Map<String, String> formParams, List<FilePart> formFiles) async {
    var streamController = new StreamController<List<int>>(sync: true);
    if (formParams != null) {
      formParams.forEach((String key, String val) {
        streamController.add('--$boundary\r\n'.codeUnits);
        streamController.add(
            'Content-Disposition: form-data; name="$key"\r\n\r\n'.codeUnits);
        streamController.add('$val\r\n'.codeUnits);
      });
    }

    if (formFiles != null) {
      for (int i = 0; i < formFiles.length; i++) {
        FilePart file = formFiles[i];
        String name = file.file.name;
        if (name == null) {
          name = file.name;
        }
        streamController.add('--$boundary\r\n'.codeUnits);
        streamController.add(
            'Content-Disposition: form-data; name="${file.field}"; filename="$name"\r\n'
                .codeUnits);
        streamController
            .add('Content-Type: ${file.file.type}\r\n\r\n'.codeUnits);
        final reader = new html.FileReader();
        reader.readAsArrayBuffer(file.file);
        reader.onError.listen((error) => print(error.toString()));
        await reader.onLoad.first;
        List<int> bytes = Uint8List.fromList(reader.result);
        streamController.add(bytes);
        streamController.add('\r\n'.codeUnits);
      }
      // formFiles.forEach((FilePart file) async {
      //   streamController.add('--$boundary\r\n'.codeUnits);
      //   streamController.add(
      //       'Content-Disposition: form-data; name="${file.field}"; filename="${file.file.name}"\r\n'
      //           .codeUnits);
      //   streamController
      //       .add('Content-Type: ${file.file.type}\r\n\r\n'.codeUnits);
      //   final reader = new html.FileReader();
      //   reader.readAsArrayBuffer(file.file);
      //   reader.onError.listen((error) => print(error.toString()));
      //   await reader.onLoad.first;
      //   List<int> bytes = Uint8List.fromList(reader.result);
      //   print(reader.result);
      //   streamController.add(bytes);
      //   streamController.add('\r\n'.codeUnits);
      // });
    }
    streamController.add('--$boundary--\r\n'.codeUnits);
    streamController.close();
    return new http.ByteStream(streamController.stream).toBytes();
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

  static const int _BOUNDARY_LENGTH = 48;

  static String _boundaryString() {
    var prefix = "---DartFormBoundary";
    var boundary = randomStr(_BOUNDARY_LENGTH);
    return "$prefix$boundary";
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
