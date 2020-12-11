import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DownloadFile {
  static MethodChannel _channel =
      const MethodChannel('com.r34.browser/platform')
        ..setMethodCallHandler(_callbackHandler);

  static Future<String> downloadFile(String url) async {
    final String path = await _channel.invokeMethod('saveFile', {'url': url});
    return path;
  }

  static Future<dynamic> _callbackHandler(MethodCall methodCall) {
    if (methodCall.method == 'saveFinish') {
      Fluttertoast.showToast(msg: 'Download Success!');
    }

    return Future.value(true);
  }
}
