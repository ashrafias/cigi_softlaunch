const document = Document();

class Document {
  const Document();

  Element createElement(String el) => InputElement();
}

class File {
  final int? lastModified = null;

  final String? type = null;
}

class Element {
  const Element();
}

class InputElement extends Element {
  const InputElement();

  final List<File>? files = null;

  Stream<Object> get onChange => Stream.empty();

  set type(String type) {}

  set multiple(bool multiple) {}

  set accept(String s) {}

  void readAsDataUrl(File file) {}

  void click() {}
}

class FileReader {
  Stream<void Function(Object error, [StackTrace? stackTrace])> get onError =>
      Stream.empty();

  void readAsDataUrl(File file) {}

  Stream<Object> get onLoad => Stream.empty();

  final Object? result = null;
}
