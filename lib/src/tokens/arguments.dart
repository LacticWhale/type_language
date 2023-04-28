import 'full_identifier.dart';
import 'term.dart';

sealed class Arguments {
  const Arguments();
}

final class TermArgument extends Arguments {
  const TermArgument(
    this.optionalCombinatorParameter,
    this.type,
  );

  final bool optionalCombinatorParameter;
  final TypeTerm type;

  @override
  String toString() => '${optionalCombinatorParameter ? '!' : ''}$type'.trim();
}

final class SimpleArguments extends Arguments {
  const SimpleArguments(
    this.identifiers,
    this.optionalCombinatorParameter,
    this.type,
  );

  /// List of field's identifier.
  final List<FullIdentifier> identifiers;
  final bool optionalCombinatorParameter;
  final TypeTerm type;

  @override
  String toString() => '{${identifiers.join(' ')}:${optionalCombinatorParameter ? '!' : ''}$type}';
}

final class ConditionDefinition {
  const ConditionDefinition(
    this.identifier,
    this.constant,
  );

  final FullIdentifier identifier;
  final int? constant;

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write(identifier.toString());

    if (constant != null)
      buffer.write('.$constant');

    return buffer.toString();
  }
}

final class ConditionalArgument extends Arguments {
  const ConditionalArgument(
    this.typeIdentifier,
    this.condition,
    this.optionalCombinatorParameter,
    this.conditionType,
  );

  final FullIdentifier typeIdentifier;
  final ConditionDefinition? condition;
  final bool optionalCombinatorParameter;
  final TypeTerm conditionType;

  @override
  String toString() {
    final buffer = StringBuffer()
      ..write('$typeIdentifier:');

    if (condition != null)
      buffer
        ..write(condition.toString())
        ..write('?');

    buffer.write(conditionType.toString());

    return buffer.toString();
  }
}

final class MultiplicityArgument extends Arguments {
  const MultiplicityArgument(
    this.identifier,
    this.multiplicity,
    this.arguments,
  );

  final FullIdentifier? identifier;
  final NatTerm? multiplicity;
  final List<Arguments> arguments;

  @override
  String toString() {
    final buffer = StringBuffer();

    if (identifier != null)
      buffer.write('$identifier:');
    if (multiplicity != null)
      buffer.write('$multiplicity*');

    buffer.write('[${arguments.join(' ')}]');

    return buffer.toString();
  }
}
