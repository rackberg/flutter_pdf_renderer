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
  final double width;

  PdfRenderer({@required this.pdfFile, @required this.width});

  @override
  State<StatefulWidget> createState() => _PdfRendererState();
}

class _PdfRendererState extends State<PdfRenderer> {
  List<File> files;

  void _renderPdf() async {
    final result = await FlutterPdfRenderer.renderPdf(pdfFile: widget.pdfFile);
    setState(() {
      files = result;
    });
  }

  @override
  void initState() {
    super.initState();
    _renderPdf();
  }

  @override
  Widget build(BuildContext context) {
    if (files != null) {
      return SizedBox(
        height: widget.width,
        child: PageView(
          children: files.map((f) => Image.file(f)).toList(),
        ),
      );
    }

    return Container();
  }
}