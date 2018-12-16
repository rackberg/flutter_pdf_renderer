import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterPdfRenderer {
  static const MethodChannel _channel =
      MethodChannel('rackberg.flutter_pdf_renderer');

  /// Sends the [pdfFile] to the platform which then renders it.
  ///
  /// If you omit the [page] parameter, the first page will be rendered by default.
  static Future<File> renderPdf({
    @required String pdfFile,
    int page: 0,
  }) async {
    final String path =
        await _channel.invokeMethod('renderPdf', <String, dynamic>{
      'path': pdfFile,
      'page': page,
    });
    return path == null ? null : File(path);
  }
}
