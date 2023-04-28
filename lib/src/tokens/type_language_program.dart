import 'declaration.dart';

class TypeLanguageProgram {
  TypeLanguageProgram(
    ConstructorSector declarations,
    this.declarationSectors,
  ) : declarations = declarations.declarations;

  const TypeLanguageProgram.fromDeclarationsList(
    this.declarations,
    this.declarationSectors,
  );

  final List<Declaration> declarations;
  final List<DeclarationSector> declarationSectors;

  List<Declaration> get allConstructors => [
    ...declarations,
    ...declarationSectors
      .whereType<ConstructorSector>()
      .map((sector) => sector.declarations).expand((element) => element)
    ];

  List<Declaration> get allFunctions => [
    ...declarationSectors
      .whereType<FunctionSector>()
      .map((sector) => sector.declarations).expand((element) => element),
    ];

  // Map<String, TypeLanguageProgram>
  Map<String?, TypeLanguageProgram> get splitByNamespace => Map.fromEntries(
    [
      ...allConstructors,
      ...allFunctions,
    ].map((e) => e.namespace,)
    .toSet()
    .map((namespace) =>
      MapEntry(
        namespace,
        TypeLanguageProgram.fromDeclarationsList(
          declarations.where((declaration) => declaration.namespace == namespace).toList(),
          declarationSectors.map((e) => e.ofNamespace(namespace)).toList(),
        ),
      ),
    ),
  );


  @override
  String toString() => '${declarations.join('\n')}\n${declarationSectors.join()}';
}

sealed class DeclarationSector {
  const DeclarationSector(this.declarations);

  final List<Declaration> declarations;

  DeclarationSector ofNamespace(String? namespace) => switch (this) {
    ConstructorSector() => ConstructorSector(
      declarations.where((element) => element.namespace == namespace).toList(),
    ),
    FunctionSector() => FunctionSector(
      declarations.where((element) => element.namespace == namespace).toList(),
    ),
  };
}

final class ConstructorSector extends DeclarationSector {
  const ConstructorSector(super.declarations);

  @override
  String toString() => (
    StringBuffer()
    ..writeln('---types---')
    ..writeAll(declarations.map((e) => '$e'), '\n')
  ).toString();
}

final class FunctionSector extends DeclarationSector {
  const FunctionSector(super.declarations);

  @override
  String toString() => (
    StringBuffer()
    ..writeln('---functions---')
    ..writeAll(declarations.map((e) => '$e'), '\n')
  ).toString();
}
