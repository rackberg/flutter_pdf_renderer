import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlutterPdfRenderer {
  static const MethodChannel _channel =
  MethodChannel('rackberg.flutter_pdf_renderer');

  /// Sends the [pdfFile] to the platform which then renders it.
  static Future<List<File>> renderPdf({@required String pdfFile}) async {
    final result =
    await _channel.invokeMethod('renderPdf', <String, dynamic>{
      'path': pdfFile,
    });

    List<File> files = [];
    if (result.length > 0) {
      result.forEach((r) {
        files.add(File(r));
      });
    }

    return files;
  }
}

/// Displays the pages of a [pdfFile] stored on the device.
class PdfRenderer extends StatefulWidget {
  final String pdfFile;

  PdfRenderer({@required this.pdfFile});

  @override
  State<StatefulWidget> createState() => _PdfRendererState();
}

class _PdfRendererState extends State<PdfRenderer> {
  Future<List<File>> _pdfImages;

  @override
  void initState() {
    super.initState();
    _pdfImages = FlutterPdfRenderer.renderPdf(
        pdfFile: widget.pdfFile);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<File>>(
        future: _pdfImages,
        builder: (BuildContext context, AsyncSnapshot<List<File>> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return PageView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (context, index) {
                  return Image.file(snapshot.data[index]);
                }
            );
          } else if (snapshot.error != null) {
            return Text('Error rendering pdf file!');
          } else {
            return Text('No pdf data received.');
          }
        });
  }
}

