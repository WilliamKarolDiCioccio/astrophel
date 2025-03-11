// ignore_for_file: unnecessary_string_escapes

import 'package:meta/meta.dart';

import '../../shared/token_definitions.dart';
export '../../shared/token_definitions.dart';

/// The lexer scans the source code and produces a sequence of tokens. It runs on a per-file basis.
///
/// The lexer is responsible for converting the raw source code into a stream of tokens.
/// It scans the source text character by character and groups them into meaningful tokens.
///
/// The lexer is basically a state machine. Despite not having explicit states, you can see the
/// submethods (e.g. [blockComment]) used in the [scanToken] method as the different states of the lexer. This design
/// allow simple and easy-to-understand code that can be easily extended in the future.
class Lexer {
  final String source;
  final List<Token> tokens = [];
  int current = 0;
  int line = 1;
  int column = 1;

  Lexer(this.source);

  /// The main entry point that runs the two-pass lexing.
  List<Token> tokenize() {
    while (!_isAtEnd()) {
      scanToken();
    }

    // Always add an EOF token at the end with null terminator as lexeme
    _addToken(TokenType.EOF, lexeme: '\0');

    return tokens;
  }

  /// Scans the source code and groups characters into meaningful tokens.
  @visibleForTesting
  void scanToken() {
    final char = _peek();

    switch (char) {
      case '(':
        _addToken(TokenType.LEFT_PAREN, lexeme: source[current]);
        _advance();
        break;
      case ')':
        _addToken(TokenType.RIGHT_PAREN, lexeme: source[current]);
        _advance();
        break;
      case '[':
        _addToken(TokenType.LEFT_BRACKET, lexeme: source[current]);
        _advance();
        break;
      case ']':
        _addToken(TokenType.RIGHT_BRACKET, lexeme: source[current]);
        _advance();
        break;
      case '{':
        _addToken(TokenType.LEFT_BRACE, lexeme: source[current]);
        _advance();
        break;
      case '}':
        _addToken(TokenType.RIGHT_BRACE, lexeme: source[current]);
        _advance();
        break;
      case '.':
        _addToken(TokenType.DOT, lexeme: source[current]);
        _advance();
        break;
      case ',':
        _addToken(TokenType.COMMA, lexeme: source[current]);
        _advance();
        break;
      case ';':
        _addToken(TokenType.SEMICOLON, lexeme: source[current]);
        _advance();
        break;
      case ':':
        _addToken(TokenType.COLON, lexeme: source[current]);
        _advance();
        break;
      case '?':
        _addToken(TokenType.QUESTION, lexeme: source[current]);
        _advance();
        break;
      case '@':
        _addToken(TokenType.AT, lexeme: source[current]);
        _advance();
        break;
      case '+':
        scanDoubleToken({
          '+': TokenType.INCREMENT,
          '=': TokenType.PLUS_EQUAL,
        }, TokenType.PLUS);
        break;
      case '-':
        scanDoubleToken({
          '-': TokenType.DECREMENT,
          '=': TokenType.MINUS_EQUAL,
        }, TokenType.MINUS);
        break;
      case '*':
        scanDoubleToken({'=': TokenType.STAR_EQUAL}, TokenType.STAR);
        break;
      case '%':
        _addToken(TokenType.MODULUS, lexeme: source[current]);
        _advance();
        break;
      case '!':
        scanDoubleToken({'=': TokenType.BANG_EQUAL}, TokenType.BANG);
        break;
      case '=':
        scanDoubleToken({'=': TokenType.EQUAL_EQUAL}, TokenType.EQUAL);
        break;
      case '<':
        scanDoubleToken({'=': TokenType.LESS_EQUAL}, TokenType.LESS);
        break;
      case '>':
        scanDoubleToken({'=': TokenType.GREATER_EQUAL}, TokenType.GREATER);
        break;
      case '&':
        scanDoubleToken({
          '&': TokenType.AMPERSAND_AMPERSAND,
        }, TokenType.AMPERSAND);
        break;
      case '|':
        scanDoubleToken({'|': TokenType.PIPE_PIPE}, TokenType.PIPE);
        break;
      case '^':
        scanDoubleToken({'^': TokenType.HAT_HAT}, TokenType.HAT);
        break;
      case '/':
        if (_matchNext('/')) {
          // Single-line comment: skip until end of line
          singleLineComment();
        } else if (_matchNext('*')) {
          // C-style block comment (non-nested)
          blockComment();
        } else {
          _addToken(TokenType.SLASH, lexeme: source[current]);
          _advance();
        }
        break;
      case ' ':
      case '\r':
      case '\t':
        _advance(); // Skip whitespace
        break;
      case '\n':
        _advance();
        line++;
        column = 1;
        break;
      case '"':
        string();
        break;
      default:
        if (_isDigit(char)) {
          number();
        } else if (_isAlpha(char)) {
          identifier();
        } else {
          throw UnimplementedError("Unexpected character: $char");
        }
        break;
    }
  }

  @visibleForTesting
  void scanDoubleToken(Map<String, TokenType> options, TokenType defaultType) {
    for (final entry in options.entries) {
      if (_matchNext(entry.key)) {
        _advance();
        _advance();
        _addToken(entry.value, lexeme: source.substring(current - 2, current));
        return;
      }
    }

    _addToken(defaultType, lexeme: source[current]);
    _advance();
  }

  @visibleForTesting
  void singleLineComment() {
    // Consume all remaining characters in the line
    while (_peek() != '\n' && !_isAtEnd()) {
      _advance();
    }
  }

  @visibleForTesting
  void blockComment() {
    // Consume characters until we find '*/'
    while (!_isAtEnd() && !(_peek() == '*' && _peekNext() == '/')) {
      if (_peek() == '\n') {
        line++;
        column = 1;
      }
      _advance();
    }
    if (_isAtEnd()) {
      print("Unterminated block comment at line $line");
      return;
    }
    // Consume the closing '*/'
    _advance(); // consumes '*'
    _advance(); // consumes '/'
  }

  @visibleForTesting
  void identifier() {
    final start = current;

    while (_isAlphaNumeric(_peek()) && !_isAtEnd()) {
      _advance();
    }

    final text = source.substring(start, current);
    // Check if the identifier is a reserved keyword
    final type = keywords[text] ?? TokenType.IDENTIFIER;

    _addToken(type, lexeme: text);
  }

  @visibleForTesting
  void number() {
    final start = current;

    while (_isDigit(_peek()) && !_isAtEnd()) {
      _advance();
    }

    // Look for a fractional part
    if (_peek() == '.' && _isDigit(_peekNext())) {
      _advance(); // consume '.'
      while (_isDigit(_peek())) {
        _advance();
      }
    }

    // Extract the raw number string
    final raw = source.substring(start, current);
    // Parse the number as a double (type is not a lexer concern)
    final value = double.parse(raw);

    _addToken(TokenType.NUMBER, lexeme: raw, literal: value);
  }

  @visibleForTesting
  void string() {
    // Reset for each string fragment
    var start = current;
    // If at any point in a string there is an interpolation, the string is a fragment
    var isFragment = false;

    if (_isAtEnd()) {
      print("Unterminated string at line $line");
      return;
    } else {
      _advance(); // Consume the opening '"'
    }

    // Consume until we hit an unescaped double-quote
    while (!_isAtEnd()) {
      final c = _peek();

      // Check for string closing
      if (c == '"' && !_isEscaped()) break;

      // Track line numbers
      if (c == '\n') {
        line++;
        column = 1;
      }

      // String interpolation
      if (c == '\$' && !_isEscaped()) {
        // Extract the raw string content (without the surrounding quotes)
        String raw = source.substring(
          isFragment ? start : start + 1,
          current - 1,
        );

        _addToken(
          isFragment
              ? TokenType.STRING_FRAGMENT
              : TokenType.STRING_FRAGMENT_START,
          lexeme: source.substring(start, current - 1),
          literal: _processEscapeSequences(raw),
        );

        if (_matchNext('{')) {
          expressionInterpolation(); // Parse the expression interpolation
        } else {
          identifierInterpolation(); // Parse the identifier interpolation
        }

        start = current;
        isFragment = true;

        continue;
      }

      _advance();
    }

    if (_isAtEnd()) {
      print("Unterminated string at line $line");
      return;
    } else {
      _advance(); // Consume the closing '"'
    }

    // Extract the raw string content (without the surrounding quotes)
    String raw = source.substring(isFragment ? start : start + 1, current - 1);

    _addToken(
      isFragment ? TokenType.STRING_FRAGMENT_END : TokenType.STRING_LITERAL,
      lexeme: source.substring(start, current),
      literal: _processEscapeSequences(raw),
    );
  }

  @visibleForTesting
  void identifierInterpolation() {
    _advance(); // Consume the '$'
    _addToken(TokenType.IDENTIFIER_INTERPOLATION, lexeme: '\$');
    identifier(); // Parse the identifier
  }

  @visibleForTesting
  void expressionInterpolation() {
    var nestingCounter = 1;

    _advance(); // Consume the '$'
    _advance(); // Consume the '{'
    _addToken(
      TokenType.EXPRESSION_INTERPOLATION_START,
      lexeme: source.substring(current - 2, current),
    );

    while (!_isAtEnd() && nestingCounter > 0) {
      if (_peek() == '{' && !_isEscaped()) {
        nestingCounter++;
        _advance();
      } else if (_peek() == '}' && !_isEscaped()) {
        nestingCounter--;

        if (nestingCounter == 0) {
          _addToken(
            TokenType.EXPRESSION_INTERPOLATION_END,
            lexeme: source[current],
          );
        }

        _advance();
      }

      if (nestingCounter > 0) {
        scanToken();
      }
    }
  }

  // Utility methods

  /// Consumes the next character in the source and returns it.
  String _advance() {
    column++;
    return source[current++];
  }

  /// Returns the current character in the source without consuming it.
  String _peek() => _isAtEnd() ? '\0' : source[current];

  /// Returns the next character in the source without consuming it.
  String _peekNext() =>
      (current + 1 >= source.length) ? '\0' : source[current + 1];

  /// Checks if we have reached the end of the source code.
  bool _isAtEnd() => current + 1 > source.length;

  /// Checks if the next character matches the expected character.
  bool _matchNext(String expected) =>
      !_isAtEnd() && source[current + 1] == expected;

  /// Checks if a character is a digit.
  bool _isDigit(String c) => c.compareTo('0') >= 0 && c.compareTo('9') <= 0;

  /// Checks if a character is an alphabetic character or underscore.
  bool _isAlpha(String c) =>
      (c.compareTo('a') >= 0 && c.compareTo('z') <= 0) ||
      (c.compareTo('A') >= 0 && c.compareTo('Z') <= 0) ||
      c == '_';

  /// Checks if a character is an alphanumeric character or underscore.
  bool _isAlphaNumeric(String c) => _isAlpha(c) || _isDigit(c);

  /// Processes escape sequences in a raw string literal.
  ///
  /// This method is used to convert escape sequences in a raw string literal
  /// into their corresponding characters. For example, the sequence '\n' is
  /// converted into a newline character.
  String _processEscapeSequences(String str) {
    var buffer = StringBuffer();

    for (int i = 0; i < str.length; i++) {
      var char = str[i];

      if (char == '\\' && i + 1 < str.length) {
        // Look at the next character to determine the escape sequence.
        var next = str[i + 1];
        i++; // Skip the backslash.
        switch (next) {
          case 'n':
            buffer.write('\n');
            break;
          case 't':
            buffer.write('\t');
            break;
          case 'r':
            buffer.write('\r');
            break;
          case '"':
            buffer.write('"');
            break;
          case '\\':
            buffer.write('\\');
            break;
          // Add more escape sequences as needed.\n
          default:
            // If it's not a recognized escape, keep the character as is.
            buffer.write(next);
            break;
        }
      } else {
        buffer.write(char);
      }
    }

    return buffer.toString();
  }

  /// Checks if the current character is escaped (only used for strings).
  bool _isEscaped() {
    int backslashes = 0;

    for (int i = current - 1; i >= 0; i--) {
      if (source[i] == '\\') {
        backslashes++;
      } else {
        break;
      }
    }

    return backslashes % 2 == 1;
  }

  void _addToken(TokenType type, {required String lexeme, dynamic literal}) {
    tokens.add(Token(type, lexeme, literal, line, current));
  }

  // Match the token type with the reserved keywords.
  static final Map<String, TokenType> keywords = {
    'import': TokenType.IMPORT,
    'export': TokenType.EXPORT,
    'if': TokenType.IF,
    'else': TokenType.ELSE,
    'switch': TokenType.SWITCH,
    'while': TokenType.WHILE,
    'for': TokenType.FOR,
    'return': TokenType.RETURN,
    'void': TokenType.TYPE_ANNOTATION,
    'bool': TokenType.TYPE_ANNOTATION,
    'char': TokenType.TYPE_ANNOTATION,
    'u8': TokenType.TYPE_ANNOTATION,
    'u16': TokenType.TYPE_ANNOTATION,
    'u32': TokenType.TYPE_ANNOTATION,
    'u64': TokenType.TYPE_ANNOTATION,
    'i8': TokenType.TYPE_ANNOTATION,
    'i16': TokenType.TYPE_ANNOTATION,
    'i32': TokenType.TYPE_ANNOTATION,
    'i64': TokenType.TYPE_ANNOTATION,
    'f32': TokenType.TYPE_ANNOTATION,
    'f64': TokenType.TYPE_ANNOTATION,
    'string': TokenType.TYPE_ANNOTATION,
  };
}
