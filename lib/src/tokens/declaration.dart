// import 'package:crc32/crc32.dart';

import 'arguments.dart';
import 'expression.dart';
import 'full_identifier.dart';
import 'optional_arguments.dart';
import 'term.dart';

final class TypeError implements Exception {

}

sealed class Declaration {
  const Declaration();

  // int recalculateName() => CRC32.computeString(toString());
  String? get namespace => switch (this) {
    CombinatorDeclaration(identifier: FullIdentifier(namespace: final namespace)) => namespace,
    FinalDeclaration(typeIdentifier: FullIdentifier(namespace: final namespace)) => namespace,
    PartialAppTypeDeclaration(typeIdentifier: FullIdentifier(namespace: final namespace)) => namespace,
    PartialAppCombinatorDeclaration(identifier: FullIdentifier(namespace: final namespace)) => namespace,
    BuiltinCombinatorDeclaration(identifier: FullIdentifier(namespace: final namespace)) => namespace,
  };
}

sealed class ResultType {
}

final class SimpleResultType extends ResultType {
  SimpleResultType({
    required this.typeIdentifier,
    required this.expressions,
  });

  final FullIdentifier typeIdentifier;
  final List<SubExpression> expressions;

  @override
  String toString() => '$typeIdentifier ${expressions.join(' ')}'.trim();
}

final class GenericResultType extends ResultType {
  GenericResultType({
    required this.typeIdentifier,
    required this.expressions,
  });

  final FullIdentifier typeIdentifier;
  final List<SubExpression> expressions;

  @override
  String toString() => '$typeIdentifier <${expressions.join(', ')}>';
}

final class CombinatorDeclaration extends Declaration {
  const CombinatorDeclaration({
    required this.identifier,
    required this.optionalArguments,
    required this.arguments,
    required this.resultType,
  });

  final FullIdentifier identifier;
  final List<OptionalArguments> optionalArguments;
  final List<Arguments> arguments;
  final ResultType resultType;

  @override
  String toString() => '$identifier ${optionalArguments.join(' ')} ${arguments.join(' ')} = $resultType;';
}


sealed class PartialAppDeclaration extends Declaration {
  const PartialAppDeclaration();
}

sealed class PartialAppTypeDeclaration extends PartialAppDeclaration {
  const PartialAppTypeDeclaration();

  FullIdentifier get typeIdentifier;
}

final class SimplePartialAppTypeDeclaration extends PartialAppTypeDeclaration {
  const SimplePartialAppTypeDeclaration({
    required this.typeIdentifier,
    required this.subExpressions,
  });

  @override
  final FullIdentifier typeIdentifier;
  final List<SubExpression> subExpressions;

  @override
  String toString() => '$typeIdentifier ${subExpressions.join(' ')};';
}

final class GenericPartialAppTypeDeclaration extends PartialAppTypeDeclaration {
  const GenericPartialAppTypeDeclaration({
    required this.typeIdentifier,
    required this.expressions,
  });

  @override
  final FullIdentifier typeIdentifier;
  final List<Expression> expressions;

  @override
  String toString() => '$typeIdentifier<${expressions.join(',')}>;';
}

class PartialAppCombinatorDeclaration extends PartialAppDeclaration {
  const PartialAppCombinatorDeclaration({
    required this.identifier,
    required this.subExpressions,
  });

  final FullIdentifier identifier;
  final List<SubExpression> subExpressions;

  @override
  String toString() => '$identifier ${subExpressions.join(' ')};';
}

final class FinalDeclaration extends Declaration {
  const FinalDeclaration({
    required this.keyword,
    required this.typeIdentifier,
  });

  final String keyword;
  final FullIdentifier typeIdentifier;

  @override
  String toString() => '$keyword $typeIdentifier;';
}

final class BuiltinCombinatorDeclaration extends Declaration {
  const BuiltinCombinatorDeclaration({
    required this.identifier,
    required this.typeIdentifier,
  });

  final FullIdentifier identifier;
  final FullIdentifier typeIdentifier;

  @override
  String toString() => '$identifier ? = $typeIdentifier;';
}
