import 'package:equatable/equatable.dart';

import 'definitions.dart';
export 'definitions.dart';

/// Represents a token in the source code.
///
/// Tokens are the smallest meaningful units in a programming language.
/// The lexer scans the source code and produces a sequence of tokens.
/// Each token has a type, lexeme (the actual text in the source), and a literal value.
///
/// The [line] field is used for error reporting and debugging.
class Token extends Equatable {
  final TokenType type;
  final String lexeme;
  final dynamic literal;
  final int line;
  final int column;

  Token(this.type, this.lexeme, this.literal, this.line, this.column);

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'lexeme': lexeme,
    'literal': literal,
    'line': line,
    'column': column,
  };

  @override
  List<Object?> get props => [type, lexeme, literal];

  @override
  String toString() => toJson().toString();
}
