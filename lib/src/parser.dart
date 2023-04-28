import 'package:petitparser/definition.dart';
import 'package:petitparser/parser.dart';

import 'tokens.dart';

class TypeLanguageDefinition extends GrammarDefinition<TypeLanguageProgram> {
  const TypeLanguageDefinition();
  // Characters
  /// lc-letter ::= a | b | ... | z
  Parser<String> lowercaseLetter() => pattern('a-z');
  /// uc-letter ::= A | B | ... | Z
  Parser<String> uppercaseLetter() => pattern('A-Z');
  /// digit ::= 0 | 1 | ... | 9
  Parser<String> digit() => pattern('0-9');
  /// hex-digit ::= digit | a | b | c | d | e | f
  Parser<String> hexDigit() => [digit(), pattern('a-f')].toChoiceParser();
  /// underscore ::= _
  Parser<String> underscore() => char('_');
  /// letter ::= lc-letter | uc-letter
  Parser<String> letter() => [lowercaseLetter(), uppercaseLetter()].toChoiceParser();
  /// ident-char ::= letter | digit | underscore
  Parser<String> identifierChar() => [letter(), digit(), char('_')].toChoiceParser();

  // Simple identifiers and keywords.

  /// lc-ident ::= lc-letter { ident-char }
  Parser<FullIdentifier> lowercaseIdentifier() => seq2(
    lowercaseLetter(),
    identifierChar().star(),
  ).flatten()
  .map((identifier) => FullIdentifier(identifier: identifier))
  .labeled('lc-ident');

  /// uc-ident ::= uc-letter { ident-char }
  Parser<FullIdentifier> uppercaseIdentifier() => seq2(
    uppercaseLetter(),
    identifierChar().star(),
  ).flatten()
  .map((identifier) => FullIdentifier(identifier: identifier))
  .labeled('uc-ident');

  /// namespace-ident ::= lc-ident
  Parser<String> namespaceIdentifier() => seq2(lowercaseIdentifier(), char('.'))
    .map2((identifier, _) => identifier.identifier)
    .labeled('namespace-ident');

  /// lc-ident-ns ::= [ namespace-ident `.` ] lc-ident
  Parser<FullIdentifier> lowercaseIdentifierWithNamespace() => seq2(
    namespaceIdentifier().optional(),
    lowercaseIdentifier(),
  ).map2((namespace, identifier) => FullIdentifier(
    identifier: identifier.identifier,
    namespace: namespace,
    ),
  ).labeled('lc-ident-ns');

  /// uc-ident-ns ::= [ namespace-ident `.` ] uc-ident
  Parser<FullIdentifier> uppercaseIdentifierNamespace() => seq2(
    namespaceIdentifier().optional(),
    uppercaseIdentifier(),
  ).map2((namespace, identifier) => FullIdentifier(
    identifier: identifier.identifier,
    namespace: namespace,
    ),
  ).labeled('uc-ident-ns');

  /// lc-ident-full ::= lc-ident-ns [ `#` hex-digit *8 ]
  Parser<FullIdentifier> lowercaseFullIdentifier() => seq2(
    lowercaseIdentifierWithNamespace(),
    name().optional(),
  ).map2((identifier, name) => FullIdentifier(
    identifier: identifier.identifier,
    namespace: identifier.namespace,
    name: name,
    ),
  ).labeled('lc-ident-full');

  Parser<int> name() => seq2(hash(), hexDigit().repeat(0,  8).flatten())
    .map2((_, _name) => int.parse(_name, radix: 16))
    .labeled('typeHash');

  // Other tokens

  // colon ::= :
  Parser<String> colon() => char(':');
  // semicolon ::= ;
  Parser<String> semicolon() => char(';');
  // open-par ::= (
  Parser<String> openingParenthesis() => char('(');
  // close-par ::= )
  Parser<String> closingParenthesis() => char(')');
  // open-bracket ::= [
  Parser<String> openingBracket() => char('[');
  // close-bracket ::= ]
  Parser<String> closingBracket() => char(']');
  // open-brace ::= {
  Parser<String> openingBrace() => char('{');
  // close-brace ::= }
  Parser<String> closingBrace() => char('}');
  // triple-minus ::= ---
  Parser<String> tripleMinus() => string('---');
  // nat-const ::= digit { digit }
  Parser<int> naturalConstant() => digit().plus().flatten()
    .map(int.parse);
  // equals ::= =
  Parser<String> equals() => char('=');
  // hash ::= #
  Parser<String> hash() => char('#');
  // question-mark ::= ?
  Parser<String> questionMark() => char('?');
  // percent ::= %
  Parser<String> percent() => char('%');
  // plus ::= +
  Parser<String> plus() => char('+');
  // langle ::= <
  Parser<String> lessThan() => char('<');
  // rangle ::= >
  Parser<String> greaterThan() => char('>');
  // comma ::= ,
  Parser<String> comma() => char(',');
  // dot ::= .
  Parser<String> dot() => char('.');
  // asterisk ::= *
  Parser<String> asterisk() => char('*');
  // excl-mark ::= !
  Parser<String> exclamationMark() => char('!');
  // Final-kw ::= Final
  Parser<String> finalKeyword() => string('Final');
  // New-kw ::= New
  Parser<String> newKeyword() => string('New');
  // Empty-kw ::= Empty
  Parser<String> emptyKeyword() => string('Empty');

  Parser<String> functionDeclarationsKeyword() => seq3(tripleMinus(), string('functions').trim(), tripleMinus()).trim().flatten();
  Parser<String> constructorDeclarationsKeyword() => seq3(tripleMinus(), string('types').trim(), tripleMinus()).trim().flatten();

  // Program

  @override
  Parser<TypeLanguageProgram> start() => typeLanguageProgram()
    .labeled('tl-program');

  // TL-program ::= constr-declarations { --- functions --- fun-declarations | --- types --- constr-declarations }
  Parser<TypeLanguageProgram> typeLanguageProgram() => seq2(
      constructorDeclarations(),
      [
        seq2(functionDeclarationsKeyword(), functionDeclarations()).map2((p0, p1) => p1),
        seq2(constructorDeclarationsKeyword(), constructorDeclarations()).map2((p0, p1) => p1),
      ].toChoiceParser().star(),
    ).map2(TypeLanguageProgram.new)
    .labeled('TL-program');

  // constr-declarations ::= { declaration }
  Parser<ConstructorSector> constructorDeclarations() => declaration().trim().star()
    .map(ConstructorSector.new)
    .labeled('constr-declaration');

  // fun-declarations ::= { declaration }
  Parser<FunctionSector> functionDeclarations() => declaration().trim().star()
    .map(FunctionSector.new)
    .labeled('fun-declaration');

  // declaration ::= combinator-decl | partial-app-decl | final-decl
  Parser<Declaration> declaration() => [
      combinatorDeclaration(),
      // partialApplicationDeclaration(),
      builtinCombinatorDeclaration(),
      finalDeclaration(),
    ].toChoiceParser()
    .labeled('declaration');

  // type-expr ::= expr
  Parser<TypeExpression> typeExpression() => ref0(expression)
    .map(TypeExpression.new)
    .labeled('type-expr');

  // nat-expr ::= expr
  Parser<NatExpression> naturalExpression() => ref0(expression)
    .map(NatExpression.new)
    .labeled('nat-expr');

  // expr ::= { subexpr }
  Parser<Expression> expression() => seq2(
    ref0(subExpression),
    whitespace().optional(),
  ).map2((p0, p1) => Expression([p0]))
    .labeled('expr');

  // subexpr ::= term | nat-const + subexpr | subexpr + nat-const
  Parser<SubExpression> subExpression() => [
      ref0(term),
      seq3(naturalConstant(), plus().trim(), ref0(subExpression))
        .map3((p0, p1, p2) => (p2, p0))
        .map(SubExpressionWithConstant.constantLeft),
      seq3(ref0(subExpression), plus().trim(), naturalConstant())
        .map3((p0, p1, p2) => (p0, p2))
        .map(SubExpressionWithConstant.constantRight),
    ].toChoiceParser()
    .labeled('subexpr');

  // term ::= ( expr ) | type-ident | var-ident | nat-const | % term | type-ident < expr { , expr } >
  Parser<Term> term() => [
      seq3(
        openingParenthesis(),
        ref0(expression).trim(),
        closingParenthesis(),
      ).map3((p0, p1, p2) => ExpressionTerm(p1)),
      seq4(
        typeIdentifier(),
        lessThan().trim(),
        ref0(expression).plusSeparated(comma().trim()).map((value) => value.elements),
        greaterThan().trim(),
      ).map4((p0, p1, p2, p3) => GenericTerm(p0, p2)),
      ref0(typeIdentifier).map(TypeIdentifierTerm.new),
      ref0(variableIdentifier).map(VariableIdentifierTerm.new),
      ref0(naturalConstant).map(NatConstTerm.new),
      seq2(
        percent().trim(),
        ref0(term),
      ).map2((p0, p1) => BareTerm(p1)),
    ].toChoiceParser()
    .labeled('term');

  // type-ident ::= boxed-type-ident | lc-ident-ns | #
  Parser<FullIdentifier> typeIdentifier() => [
      ref0(boxedTypeIdentifier),
      ref0(lowercaseIdentifierWithNamespace),
      ref0(hash).map((value) => const FullIdentifier(identifier: '#')),
    ].toChoiceParser()
    .labeled('ident-type');

  // boxed-type-ident ::= uc-ident-ns
  Parser<FullIdentifier> boxedTypeIdentifier() => uppercaseIdentifierNamespace()
    .labeled('boxed-type-ident');

  // var-ident ::= lc-ident | uc-ident
  Parser<FullIdentifier> variableIdentifier() => [
      ref0(lowercaseIdentifier),
      ref0(uppercaseIdentifier),
    ].toChoiceParser()
    .labeled('var-ident');

  // type-term ::= term
  Parser<TypeTerm> typeTerm() => ref0(term)
    .map(TypeTerm.new)
    .labeled('type-term');
  // nat-term ::= term
  Parser<NatTerm> naturalTerm() => ref0(term)
    .map(NatTerm.new)
    .labeled('nat-term');

  // combinator-decl ::= full-combinator-id { opt-args } { args } = result-type ;
  Parser<CombinatorDeclaration> combinatorDeclaration() => seq6(
      ref0(fullCombinatorId).trim(),
      ref0(optionalArguments).trim().star(),
      ref0(arguments).trim().star(),
      equals().trim(),
      ref0(resultType),
      semicolon().trim(),
    ).map6((p0, p1, p2, p3, p4, p5) =>
      CombinatorDeclaration(
        identifier: p0,
        optionalArguments: p1,
        arguments: p2,
        resultType: p4,
      ),
    ).labeled('combinator-decl');

  // full-combinator-id ::= lc-ident-full | _
  Parser<FullIdentifier> fullCombinatorId() => [
    lowercaseFullIdentifier(),
    underscore().map((value) => FullIdentifier(identifier: value)),
  ].toChoiceParser()
  .labeled('full-combinator-id');

  // combinator-id ::= lc-ident-ns | _
  Parser<FullIdentifier> combinatorId() => [
    lowercaseIdentifierWithNamespace(),
    underscore().map((value) => FullIdentifier(identifier: value)),
  ].toChoiceParser()
  .labeled('combinator-id');

  // opt-args ::= { var-ident { var-ident } : [excl-mark] type-expr }
  Parser<OptionalArguments> optionalArguments() => seq6(
      openingBrace().trim(),
      variableIdentifier().trim().plus(),
      colon().trim(),
      exclamationMark().trim().optional().map((value) => value != null),
      typeExpression(),
      closingBrace().trim(),
    ).map6((p0, p1, p2, p3, p4, p5) => OptionalArguments(
      identifiers: p1,
      optionalCombinatorParameter: p3,
      type: p4,
    ),).labeled('opt-args');

  Parser<Arguments> arguments() => [
    // args ::= var-ident-opt : [ conditional-arg-def ] [ ! ] type-term
    seq5(
      ref0(variableIdentifierOptional),
      colon().trim(),
      ref0(conditionalDefinition).optional(),
      ref0(exclamationMark).trim().optional().map((value) => value != null),
      ref0(typeTerm),
    ).map5((p0, p1, p2, p3, p4) => ConditionalArgument(p0, p2, p3, p4)),
    // args ::= [ var-ident-opt : ] [ multiplicity *] [ { args } ]
    seq5(
      seq2(ref0(variableIdentifierOptional), colon().trim()).map2((p0, p1) => p0).optional(),
      seq2(ref0(multiplicity), asterisk().trim()).map2((p0, p1) => p0).optional(),
      openingBracket().trim(),
      ref0(arguments).plus(),
      closingBracket().trim(),
    ).map5((p0, p1, p2, p3, p4) => MultiplicityArgument(p0, p1, p3)), // ArgumentWithMultiplicity
    // args ::= ( var-ident-opt { var-ident-opt } : [!] type-term )
    seq6(
      openingParenthesis().trim(),
      ref0(variableIdentifierOptional).trim().plus(),
      colon().trim(),
      ref0(exclamationMark).trim().optional().map((value) => value != null),
      ref0(typeTerm),
      closingParenthesis(),
    ).map6((p0, p1, p2, p3, p4, p5) => SimpleArguments(p1, p3, p4)), // ParenthesizedArgument
    // args ::= [ ! ] type-term
    seq2(
      ref0(exclamationMark).trim().optional().map((value) => value != null),
      ref0(typeTerm),
    ).map2(TermArgument.new),
  ].toChoiceParser()
  .labeled('args');

  // multiplicity ::= nat-term
  Parser<NatTerm> multiplicity() => ref0(naturalTerm)
    .labeled('multiplicity');

  // var-ident-opt ::= var-ident | _
  Parser<FullIdentifier> variableIdentifierOptional() => [
      ref0(variableIdentifier),
      ref0(underscore).map((value) => const FullIdentifier(identifier: '_')),
    ].toChoiceParser()
    .labeled('var-ident-opt');

  // conditional-def ::= var-ident [ . nat-const ] ?
  Parser<ConditionDefinition> conditionalDefinition() => seq3(
      variableIdentifier(),
      seq2(dot(), ref0(naturalConstant)).map2((p0, p1) => p1).optional(),
      questionMark().trim(),
    ).map3((p0, p1, p2) => ConditionDefinition(p0, p1))
    .labeled('conditional-def');

  Parser<ResultType> resultType() => [
    // result-type ::= boxed-type-ident < subexpr { , subexpr } >
    seq5(
      ref0(boxedTypeIdentifier),
      lessThan().trim(),
      ref0(subExpression),
      seq2(
        comma().trim(),
        ref0(subExpression),
      ).map((value) => value.second).star(),
      greaterThan().trim(),
    ).map5((p0, p1, p2, p3, p4) =>
      GenericResultType(
        typeIdentifier: p0,
        expressions: [p2, ...p3],
      ),
    ),
    // result-type ::= boxed-type-ident { subexpr }
    seq2(
      ref0(boxedTypeIdentifier),
      seq2(
        whitespace(),
        ref0(subExpression),
      ).map((value) => value.second).star(),
    ).map2((p0, p1) =>
      SimpleResultType(
        typeIdentifier: p0,
        expressions: p1,
      ),
    ),
  ].toChoiceParser()
  .labeled('result-type');

  // builtin-combinator-decl ::= full-combinator-id ? = boxed-type-ident ;
  Parser<BuiltinCombinatorDeclaration> builtinCombinatorDeclaration() => seq5(
    ref0(fullCombinatorId),
    questionMark().trim(),
    equals().trim(),
    typeIdentifier(), /* TODO: should be boxed */
    semicolon().trim(),
  ).map5((p0, p1, p2, p3, p4) =>
    BuiltinCombinatorDeclaration(
      identifier: p0,
      typeIdentifier: p3,
    ),
  ).labeled('builtin-combinator-decl');

  // partial-app-decl ::= partial-type-app-decl | partial-comb-app-decl
  Parser<PartialAppDeclaration> partialApplicationDeclaration() => [
      ref0(partialTypeApplicationDeclaration),
      ref0(partialCombinatorApplicationDeclaration)
    ].toChoiceParser()
    .labeled('partial-app-decl');

  // partial-type-app-decl ::= boxed-type-ident subexpr { subexpr } ; | boxed-type-ident < expr { , expr } > ;
  Parser<PartialAppTypeDeclaration> partialTypeApplicationDeclaration() => [
    seq3(
      ref0(boxedTypeIdentifier).trim(),
      ref0(subExpression).trim().plus(),
      semicolon().trim(),
    ).map3((p0, p1, p2) =>
      SimplePartialAppTypeDeclaration(
        typeIdentifier: p0,
        subExpressions: p1,
      ),
    ),
    seq6(
      ref0(boxedTypeIdentifier),
      lessThan().trim(),
      ref0(expression),
      seq2(comma().trim(), ref0(expression)).map2((p0, p1) => p1).star(),
      greaterThan().trim(),
      semicolon().trim(),
    ).map6((p0, p1, p2, p3, p4, p5) =>
      GenericPartialAppTypeDeclaration(
        typeIdentifier: p0,
        expressions: [p2, ...p3],
      ),
    ),
  ].toChoiceParser()
  .labeled('partial-type-app-decl');

  // partial-comb-app-decl ::= combinator-id subexpr { subexpr } ;
  Parser<PartialAppCombinatorDeclaration> partialCombinatorApplicationDeclaration() => seq3(
    combinatorId().trim(),
    subExpression().trim().plus(),
    semicolon().trim(),
  ).map3((p0, p1, p2) =>
    PartialAppCombinatorDeclaration(
      identifier: p0,
      subExpressions: p1,
    ),
  ).labeled('partial-comb-app-decl');

  // final-decl ::= New boxed-type-ident ; | Final boxed-type-ident ; | Empty boxed-type-ident ;
  Parser<FinalDeclaration> finalDeclaration() => [
    seq3(newKeyword(), boxedTypeIdentifier().trim(), semicolon().trim()),
    seq3(finalKeyword(), boxedTypeIdentifier().trim(), semicolon().trim()),
    seq3(emptyKeyword(), boxedTypeIdentifier().trim(), semicolon().trim()),
  ].toChoiceParser()
  .map3((p0, p1, p2) =>
    FinalDeclaration(
      keyword: p0,
      typeIdentifier: p1,
    ),
  ).labeled('final-decl');
}
