class FullIdentifier {
  const FullIdentifier({
    required this.identifier,
    this.namespace,
    this.name,
  });

  final String? namespace;
  final String identifier;
  final int? name;


  bool isBoxed() => identifier[0].toUpperCase() == identifier.substring(0, 1);

  @override
  String toString() {
    final buffer = StringBuffer();

    if (namespace != null)
      buffer.write('$namespace.');
    buffer.write(identifier);
    if (name != null)
      buffer.write('#${name?.toRadixString(16)}');

    return buffer.toString();
  }
}
