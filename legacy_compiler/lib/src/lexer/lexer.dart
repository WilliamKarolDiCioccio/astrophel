// ignore_for_file: unnecessary_string_escapes

import 'token_definitions.dart';
export 'token_definitions.dart';

/// The lexer scans the source code and produces a sequence of tokens.
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
  int start = 0;
  int current = 0;
  int line = 1;

  Lexer(this.source);

  /// The main entry point that runs the two-pass lexing.
  List<Token> tokenize() {
    while (!isAtEnd()) {
      start = current;
      scanToken();
    }

    addToken(TokenType.EOF);

    return tokens;
  }

  /// Scans the source code and groups characters into meaningful tokens.
  void scanToken() {
    final c = peek();

    switch (c) {
      case '(':
        addToken(TokenType.LEFT_PAREN);
        advance();
        break;
      case ')':
        addToken(TokenType.RIGHT_PAREN, ')');
        advance();
        break;
      case '[':
        addToken(TokenType.LEFT_BRACKET, '[');
        advance();
        break;
      case ']':
        addToken(TokenType.RIGHT_BRACKET, ']');
        advance();
        break;
      case '{':
        addToken(TokenType.LEFT_BRACE, '{');
        advance();
        break;
      case '}':
        addToken(TokenType.RIGHT_BRACE, '}');
        advance();
        break;
      case '.':
        print("Adding DOT token");
        addToken(TokenType.DOT, '.');
        advance();
      case ',':
        addToken(TokenType.COMMA, ',');
        advance();
        break;
      case ';':
        addToken(TokenType.SEMICOLON, ';');
        advance();
        break;
      case '+':
        addToken(TokenType.PLUS, '+');
        advance();
        break;
      case '-':
        addToken(TokenType.MINUS, '-');
        advance();
        break;
      case '*':
        addToken(TokenType.STAR, '*');
        advance();
        break;
      case '!':
        if (match('=')) {
          addToken(TokenType.BANG_EQUAL);
          advance();
          advance();
        } else {
          addToken(TokenType.BANG);
          advance();
        }
        break;
      case '=':
        if (match('=')) {
          addToken(TokenType.EQUAL_EQUAL);
          advance();
          advance();
        } else {
          addToken(TokenType.EQUAL);
          advance();
        }
        break;
      case '<':
        if (match('=')) {
          addToken(TokenType.LESS_EQUAL);
          advance();
          advance();
        } else {
          addToken(TokenType.LESS);
          advance();
        }
        break;
      case '>':
        if (match('=')) {
          addToken(TokenType.GREATER_EQUAL);
          advance();
          advance();
        } else {
          addToken(TokenType.GREATER);
          advance();
        }
        break;
      case '/':
        if (match('/')) {
          // Single-line comment: skip until end of line.
          singleLineComment();
        } else if (match('*')) {
          // C-style block comment (non-nested).
          blockComment();
        } else {
          addToken(TokenType.SLASH);
          advance();
        }
        break;
      case ' ':
      case '\r':
      case '\t':
        advance(); // Skip whitespace.
        break;
      case '\n':
        advance();
        line++;
        break;
      case '"':
        string();
        break;
      default:
        if (isDigit(c)) {
          number();
        } else if (isAlpha(c)) {
          identifier();
        } else {
          throw UnimplementedError("Unexpected character: $c");
        }
        break;
    }
  }

  void singleLineComment() {
    // Consume all remaining characters in the line
    while (peek() != '\n' && !isAtEnd()) {
      advance();
    }
  }

  void blockComment() {
    // Consume characters until we find '*/'
    while (!isAtEnd() && !(peek() == '*' && peekNext() == '/')) {
      if (peek() == '\n') line++;
      advance();
    }
    if (isAtEnd()) {
      print("Unterminated block comment at line $line");
      return;
    }
    // Consume the closing '*/'
    advance(); // consumes '*'
    advance(); // consumes '/'
  }

  void identifier() {
    while (isAlphaNumeric(peek()) && !isAtEnd()) {
      advance();
    }

    final text = source.substring(start, current);
    // Check if the identifier is a reserved keyword.
    final type = keywords[text] ?? TokenType.IDENTIFIER;

    addToken(type);
  }

  void number() {
    while (isDigit(peek()) && !isAtEnd()) {
      advance();
    }

    // Look for a fractional part.
    if (peek() == '.' && isDigit(peekNext())) {
      advance(); // consume '.'
      while (isDigit(peek())) {
        advance();
      }
    }

    final raw = source.substring(start, current);
    final value = double.parse(raw);
    addToken(TokenType.NUMBER, value);
  }

  void string() {
    if (isAtEnd()) {
      print("Unterminated string at line $line");
      return;
    } else {
      advance(); // Consume the opening '"'
    }

    // Consume until we hit an unescaped double-quote.
    while (!isAtEnd()) {
      final c = peek();
      if (c == '"' && !isEscaped()) break;
      if (c == '\n') line++;

      advance();
    }

    if (isAtEnd()) {
      print("Unterminated string at line $line");
      return;
    } else {
      advance(); // Consume the closing '"'
    }

    // Extract the raw string content (without the surrounding quotes)
    String raw = source.substring(start + 1, current - 1);
    // Process escape sequences so the stored literal is 'clean'
    String processed = processEscapeSequences(raw);
    addToken(TokenType.STRING, processed);
  }

  // Utility methods

  /// Consumes the next character in the source and returns it.
  String advance() => source[current++];

  /// Returns the current character in the source without consuming it.
  String peek() => isAtEnd() ? '\0' : source[current];

  /// Returns the next character in the source without consuming it.
  String peekNext() =>
      (current + 1 >= source.length) ? '\0' : source[current + 1];

  /// Checks if we have reached the end of the source code.
  bool isAtEnd() => current + 1 > source.length;

  /// Checks if the next character matches the expected character.
  bool match(String expected) => !isAtEnd() && source[current + 1] == expected;

  /// Checks if a character is a digit.
  bool isDigit(String c) => c.compareTo('0') >= 0 && c.compareTo('9') <= 0;

  /// Checks if a character is an alphabetic character or underscore.
  bool isAlpha(String c) =>
      (c.compareTo('a') >= 0 && c.compareTo('z') <= 0) ||
      (c.compareTo('A') >= 0 && c.compareTo('Z') <= 0) ||
      c == '_';

  /// Checks if a character is an alphanumeric character or underscore.
  bool isAlphaNumeric(String c) => isAlpha(c) || isDigit(c);

  /// Processes escape sequences in a raw string literal.
  ///
  /// This method is used to convert escape sequences in a raw string literal
  /// into their corresponding characters. For example, the sequence '\n' is
  /// converted into a newline character.
  String processEscapeSequences(String s) {
    var buffer = StringBuffer();
    for (int i = 0; i < s.length; i++) {
      var c = s[i];
      if (c == '\\' && i + 1 < s.length) {
        // Look at the next character to determine the escape sequence.
        var next = s[i + 1];
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
        buffer.write(c);
      }
    }
    return buffer.toString();
  }

  /// Checks if the current character is escaped (only used for strings).
  bool isEscaped() {
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

  void addToken(TokenType type, [Object? literal]) {
    final lexeme = source.substring(start, current);
    tokens.add(Token(type, lexeme, literal, line));
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
    'bool': TokenType.BOOL,
    'u8': TokenType.U8,
    'u16': TokenType.U16,
    'u32': TokenType.U32,
    'u64': TokenType.U64,
    'i8': TokenType.I8,
    'i16': TokenType.I16,
    'i32': TokenType.I32,
    'i64': TokenType.I64,
    'f32': TokenType.F32,
    'f64': TokenType.F64,
  };
}
