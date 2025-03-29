import 'expression.dart';
import 'full_identifier.dart';

sealed class SubExpression {
  const SubExpression();
}

typedef SubExpressionWithConstantArguments = (SubExpression expression, int constant);

final class SubExpressionWithConstant extends SubExpression {
  SubExpressionWithConstant.constantLeft(SubExpressionWithConstantArguments arguments)
    : expression = arguments.$1,
      constant = arguments.$2,
      _left = true;

  SubExpressionWithConstant.constantRight(SubExpressionWithConstantArguments arguments)
    : expression = arguments.$1,
      constant = arguments.$2,
      _left = false;

  final SubExpression expression;
  final int constant;
  final bool _left;

  @override
  String toString() {
    if (_left)
      return '$constant + $expression';
    return '$expression + $constant';
  }
}

sealed class Term extends SubExpression {
  const Term();
}

final class ExpressionTerm extends Term {
  ExpressionTerm(this.expression);

  final Expression expression;

  @override
  String toString() => '($expression)';
}

final class TypeIdentifierTerm extends Term {
  const TypeIdentifierTerm(this.fullIdentifier);

  final FullIdentifier? fullIdentifier;

  @override
  String toString() => fullIdentifier?.toString() ?? '#';
}

final class VariableIdentifierTerm extends Term {
  const VariableIdentifierTerm(this.fullIdentifier);

  final FullIdentifier fullIdentifier;

  @override
  String toString() => fullIdentifier.toString();
}

final class NatConstTerm extends Term {
  const NatConstTerm(this.natConstant);

  final int natConstant;

  @override
  String toString() => natConstant.toString();
}

final class BareTerm extends Term {
  const BareTerm(this.term);

  final Term term;

  @override
  String toString() => '%$term';
}

final class GenericTerm extends Term {
  const GenericTerm(this.typeIdentifier, this.expressions);

  final FullIdentifier typeIdentifier;
  final List<Expression> expressions;

  @override
  String toString() => '$typeIdentifier<${expressions.join(',')}>';
}

final class TypeTerm {
  const TypeTerm(this.term);

  final Term term;

  @override
  String toString() => term.toString();
}

final class NatTerm extends Term {
  const NatTerm(this.term);

  final Term term;

  @override
  String toString() => term.toString();
}
