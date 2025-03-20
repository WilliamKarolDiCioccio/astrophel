// ignore_for_file: constant_identifier_names

export 'token.dart';

// We ignore a few naming convention warnings because some lowercase names would conflict with dart's itself keywords.
enum TokenType {
  // Single-character tokens
  LEFT_PAREN,
  RIGHT_PAREN,
  LEFT_BRACKET,
  RIGHT_BRACKET,
  LEFT_BRACE,
  RIGHT_BRACE,
  DOT,
  COMMA,
  SEMICOLON,
  DOLLAR,
  QUESTION,
  // Two-character tokens
  COLON,
  COLON_EQUAL,
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
  LESS_LESS,
  LESS_EQUAL,
  GREATER,
  GREATER_GREATER,
  GREATER_EQUAL,
  AMPERSAND,
  AMPERSAND_AMPERSAND,
  AMPERSAND_EQUAL,
  CARET,
  CARET_EQUAL,
  CARET_CARET,
  PIPE,
  PIPE_PIPE,
  PIPE_EQUAL,
  TILDE,
  TILDE_EQUAL,
  // Multi-character tokens
  IDENTIFIER,
  STRING_LITERAL,
  STRING_FRAGMENT_START,
  STRING_FRAGMENT_END,
  STRING_FRAGMENT,
  IDENTIFIER_INTERPOLATION,
  EXPRESSION_INTERPOLATION_START,
  EXPRESSION_INTERPOLATION_END,
  NUMBER,

  // Module system
  IMPORT,
  EXPORT,
  AS,
  FROM,

  // Variable declarations & storage specifiers
  MUTABILITY_SPECIFIER,
  STORAGE_SPECIFIER,

  // Function execution models
  FUNCTION,
  ARROW,
  LAMBDA,
  FAT_ARROW,
  EXECUTION_MODEL_SPECIFIER,
  AWAIT,

  // Class & struct system
  INTERFACE,
  IMPLEMENT,
  PARTIAL,
  CLASS,
  STRUCT,
  UNION,
  ENUM,
  CONSTRUCTOR,
  DESTRUCTOR,

  // Templates
  TEMPLATE,

  // RTTI
  TYPEINFO,

  // Memory management
  ALLOCATE,
  DEALLOCATE,

  // Control flow
  IF,
  ELSE,
  SWITCH,
  CASE,
  DEFAULT,
  DO,
  WHILE,
  FOR,
  BREAK,
  CONTINUE,
  RETURN,
  YIELD,

  // Annotations
  ANNOTATION,

  // Utility
  EOF,
}
