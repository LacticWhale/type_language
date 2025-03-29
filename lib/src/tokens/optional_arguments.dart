import 'expression.dart';
import 'full_identifier.dart';

final class OptionalArguments {
  const OptionalArguments({
    required this.identifiers,
    required this.optionalCombinatorParameter,
    required this.type,
  });

  /// List of field's identifier.
  final List<FullIdentifier> identifiers;
  final bool optionalCombinatorParameter;
  final TypeExpression type;

  @override
  String toString() => '{${identifiers.join(' ')}:$type}';
}
