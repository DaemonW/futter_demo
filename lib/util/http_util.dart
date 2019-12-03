import 'dart:async';
import 'dart:html';
import 'dart:math';
import 'dart:typed_data';
import 'package:http/http.dart' as http;

import 'package:http_parser/http_parser.dart';

class HttpUtil {
  static Map _makeHttpHeaders(
      [String contentType,
      String accept,
      String token,
      String XRequestWith,
      String XMethodOverride]) {
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

    if (!isEmptyStr(XRequestWith)) {
      i++;
      headers["X-Requested-With"] = XRequestWith;
    }

    if (!isEmptyStr(XMethodOverride)) {
      i++;
      headers["X-HTTP-Method-Override"] = XMethodOverride;
    }

    if (i == 0) return null;
    // print(headers.toString());
    return headers;
  }

/** HTTP POST 上传文件 */
  static Future<MsgResponse> httpUploadFile(
    final String url,
    final File file, {
    String accept = "*/*",
    String token,
    String field = "apk",
    String file_contentType, // 默认为null，自动获取
  }) async {
    try {
      final reader = new FileReader();
      reader.readAsArrayBuffer(file);
      reader.onError.listen((error) => print(error.toString()));
      await reader.onLoad.first;
      //List<int> bytes = await file.readAsBytes();
      List<int> bytes = Uint8List.fromList(reader.result);
      return await httpUploadFileData(url, bytes,
          accept: accept,
          token: token,
          field: field,
          file_contentType: file_contentType,
          filename: file.name);
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
    String file_contentType, // 默认为null，自动获取
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
              '$file_contentType\r\n\r\n';
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

  /** 生成随机字符串 */
  static String randomStr(
      [int len = 8, List<int> chars = _BOUNDARY_CHARACTERS]) {
    var list = new List<int>.generate(
        len, (index) => chars[_random.nextInt(chars.length)],
        growable: false);
    return new String.fromCharCodes(list);
  }

  static const List<int> _BOUNDARY_CHARACTERS = const <int>[
    0x30,
    0x31,
    0x32,
    0x33,
    0x34,
    0x35,
    0x36,
    0x37,
    0x38,
    0x39,
    0x61,
    0x62,
    0x63,
    0x64,
    0x65,
    0x66,
    0x67,
    0x68,
    0x69,
    0x6A,
    0x6B,
    0x6C,
    0x6D,
    0x6E,
    0x6F,
    0x70,
    0x71,
    0x72,
    0x73,
    0x74,
    0x75,
    0x76,
    0x77,
    0x78,
    0x79,
    0x7A,
    0x41,
    0x42,
    0x43,
    0x44,
    0x45,
    0x46,
    0x47,
    0x48,
    0x49,
    0x4A,
    0x4B,
    0x4C,
    0x4D,
    0x4E,
    0x4F,
    0x50,
    0x51,
    0x52,
    0x53,
    0x54,
    0x55,
    0x56,
    0x57,
    0x58,
    0x59,
    0x5A
  ];
  static const int _BOUNDARY_LENGTH = 48;
  static final Random _random = new Random();
  static String _boundaryString() {
    var prefix = "---DartFormBoundary";
    var list = new List<int>.generate(
        _BOUNDARY_LENGTH - prefix.length,
        (index) =>
            _BOUNDARY_CHARACTERS[_random.nextInt(_BOUNDARY_CHARACTERS.length)],
        growable: false);
    return "$prefix${new String.fromCharCodes(list)}";
  }

  static MediaType getMediaType(final String fileExt) {
    switch (fileExt) {
      case ".jpg":
      case ".jpeg":
      case ".jpe":
        return new MediaType("image", "jpeg");
      case ".png":
        return new MediaType("image", "png");
      case ".bmp":
        return new MediaType("image", "bmp");
      case ".gif":
        return new MediaType("image", "gif");
      case ".json":
        return new MediaType("application", "json");
      case ".svg":
      case ".svgz":
        return new MediaType("image", "svg+xml");
      case ".mp3":
        return new MediaType("audio", "mpeg");
      case ".mp4":
        return new MediaType("video", "mp4");
      case ".htm":
      case ".html":
        return new MediaType("text", "html");
      case ".css":
        return new MediaType("text", "css");
      case ".csv":
        return new MediaType("text", "csv");
      case ".txt":
      case ".text":
      case ".conf":
      case ".def":
      case ".log":
      case ".in":
        return new MediaType("text", "plain");
    }
    return null;
  }

  static bool isEmptyStr(String str) {
    return str == null || str.isEmpty;
  }
}

/**
 * 请求响应数据
 */
class MsgResponse {
  int statusCode = 0;
  Object data; // 数据内容，一般为字符串
  String errMsg; // 错误消息
  MsgResponse([this.statusCode = 0, this.data = null, this.errMsg = null]);
}