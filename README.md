# flutter_pdf_renderer

Flutter Plugin to render a PDF file. Supports both Android and iOS.

## Getting Started
In your flutter project add the dependency:
```dart
dependencies:
  ...
  flutter_pdf_renderer: any
```
For help getting started with Flutter, view the online [documentation](https://flutter.io/).

## Usage example
Import `flutter_pdf_renderer.dart`
```dart
import 'package:flutter_pdf_renderer/flutter_pdf_renderer.dart';
```

## Rendering PDF files on Android devices
Use the provided widget `PdfRenderer` in order to render a PDF file.
This plugin uses the Android native [PdfRenderer](https://developer.android.com/reference/android/graphics/pdf/PdfRenderer) to render
the pages of PDF files and provides a widget called `PdfRenderer` to display the PDF page you like.
