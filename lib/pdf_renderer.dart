import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_pdf_renderer/flutter_pdf_renderer.dart';

/// Displays the requested [page] of a [pdfFile] stored on the device.
class PdfRenderer extends StatefulWidget {
  final String pdfFile;
  final int page;

  PdfRenderer({
    @required this.pdfFile,
    this.page: 0,
  });

  @override
  State<StatefulWidget> createState() => _PdfRendererState();
}

class _PdfRendererState extends State<PdfRenderer> {
  Future<File> _pdfImage;

  @override
  void initState() {
    super.initState();
    _pdfImage = FlutterPdfRenderer.renderPdf(
        pdfFile: widget.pdfFile, page: widget.page);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<File>(
        future: _pdfImage,
        builder: (BuildContext context, AsyncSnapshot<File> snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.data != null) {
            return Image.file(snapshot.data);
          } else if (snapshot.error != null) {
            return Text('Error rendering pdf file!');
          } else {
            return Text('No pdf data received yet.');
          }
        });
  }
}
