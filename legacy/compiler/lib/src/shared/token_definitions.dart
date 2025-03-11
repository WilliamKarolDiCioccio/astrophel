// ignore_for_file: constant_identifier_names

// We ignore a few naming convention warnings because some lowercase names would conflict with dart's itself keywords.
enum TokenType {
  // Single-character tokens.
  LEFT_PAREN,
  RIGHT_PAREN,
  LEFT_BRACKET,
  RIGHT_BRACKET,
  LEFT_BRACE,
  RIGHT_BRACE,
  DOT,
  COMMA,
  COLON,
  SEMICOLON,
  DOLLAR,
  AT,
  QUESTION,
  // One or two character tokens.
  PLUS,
  PLUS_EQUAL,
  INCREMENT,
  MINUS,
  MINUS_EQUAL,
  DECREMENT,
  STAR,
  STAR_EQUAL,
  SLASH,
  SLASH_EQUAL,
  MODULUS,
  MODULUS_EQUAL,
  BANG,
  BANG_EQUAL,
  EQUAL,
  EQUAL_EQUAL,
  LESS,
  LESS_EQUAL,
  GREATER,
  GREATER_EQUAL,
  AMPERSAND,
  AMPERSAND_AMPERSAND,
  HAT,
  HAT_HAT,
  PIPE,
  PIPE_PIPE,
  // Literals.
  IDENTIFIER,
  STRING_LITERAL,
  STRING_FRAGMENT_START,
  STRING_FRAGMENT_END,
  STRING_FRAGMENT,
  IDENTIFIER_INTERPOLATION,
  EXPRESSION_INTERPOLATION_START,
  EXPRESSION_INTERPOLATION_END,
  NUMBER,
  // Keywords.
  IMPORT,
  EXPORT,
  IF,
  ELSE,
  SWITCH,
  WHILE,
  FOR,
  RETURN,
  // Data types (example types with size qualifiers)
  TYPE_ANNOTATION,
  // End-of-file.
  EOF,
}

/// Represents a token in the source code.
///
/// Tokens are the smallest meaningful units in a programming language.
/// The lexer scans the source code and produces a sequence of tokens.
/// Each token has a type, lexeme (the actual text in the source), and a literal value.
///
/// The [line] field is used for error reporting and debugging.
class Token {
  final TokenType type;
  final String lexeme;
  final dynamic literal;
  final int line;

  Token(this.type, this.lexeme, this.literal, this.line);

  Map<String, dynamic> toJson() => {
    'type': type.toString(),
    'lexeme': lexeme,
    'literal': literal,
    'line': line,
  };

  @override
  String toString() => toJson().toString();
}
