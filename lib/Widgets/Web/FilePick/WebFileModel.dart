import 'dart:typed_data';

import 'html_nonweb.dart' if (dart.library.js) 'dart:html' as html;

class WebFileModel {
  final String path;
  final String type;
  final DateTime createdAt;
  final html.File? htmlFile;
  final Uint8List? uIntFile;

  WebFileModel({
    required this.path,
    required this.type,
    required this.createdAt,
    this.htmlFile,
    this.uIntFile,
  });

  WebFileModel copyWith({
    String? path,
    String? type,
    DateTime? createdAt,
    html.File? htmlFile,
    Uint8List? uIntFile,
  }) {
    return WebFileModel(
      path: path ?? this.path,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      htmlFile: htmlFile ?? this.htmlFile,
      uIntFile: uIntFile ?? this.uIntFile,
    );
  }
}
