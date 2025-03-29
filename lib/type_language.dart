import 'package:petitparser/core.dart';

import 'src/parser.dart';
import 'src/tokens.dart';

export 'src/parser.dart' show TypeLanguageDefinition;
export 'src/tokens.dart';

Parser<TypeLanguageProgram> parseTypeLanguageDefinition() {
  final parser = const TypeLanguageDefinition().build<TypeLanguageProgram>();
  
  return parser;
}
