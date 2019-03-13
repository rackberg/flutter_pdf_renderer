import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdf_renderer/flutter_pdf_renderer.dart';
import 'package:path_provider/path_provider.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<String> downloadedFilePath;
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('PdfRenderer example app'),
        ),
        body: Column(children: <Widget>[
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: 'Enter URL here...',
            ),
          ),
          RaisedButton(
            onPressed: download,
            child: Text('Render PDF'),
          ),
          FutureBuilder<String>(
            future: downloadedFilePath,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              Text text = Text('');
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  text = Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  text = Text('Data: ${snapshot.data}');
                  return PdfRenderer(pdfFile: snapshot.data, width: 500.0);
                } else {
                  text = Text('Unavailable');
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                text = Text('Downloading PDF File...');
              } else {
                text = Text('Please load a PDF file.');
              }
              return Container(
                child: text,
              );
            },
          ),
        ]),
      ),
    );
  }

  void download() {
    setState(() {
      downloadedFilePath = downloadPdfFile(controller.text);
    });
  }

  Future<String> downloadPdfFile(String url) async {
    final filename = url.substring(url.lastIndexOf("/") + 1);
    String dir = (await getTemporaryDirectory()).path;
    File file = new File('$dir/$filename');
    bool exist = false;
    try {
      await file.length().then((len) {
        exist = true;
      });
    } catch (e) {
      print(e);
    }
    if (!exist) {
      var request = await HttpClient().getUrl(Uri.parse(url));
      var response = await request.close();
      var bytes = await consolidateHttpClientResponseBytes(response);
      await file.writeAsBytes(bytes);
    }
    return file.path;
  }
}
