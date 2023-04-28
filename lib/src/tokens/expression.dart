import 'term.dart';

final class Expression {
  const Expression(this.subExpressions);

  final List<SubExpression> subExpressions;

  @override
  String toString() => subExpressions.join(' ');
}

final class TypeExpression extends Expression {
  TypeExpression(Expression expression)
    : super(expression.subExpressions);
}

final class NatExpression extends Expression {
  NatExpression(Expression expression)
    : super(expression.subExpressions);
}
