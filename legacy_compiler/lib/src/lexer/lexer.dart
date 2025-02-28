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
///
/// Despite currently implementing a single-pass lexer, the design allows for a two-pass approach
/// that will be useful for more complex language features in the future.
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

    tokens.add(Token(TokenType.EOF, '', null, line));

    _secondPass();

    return tokens;
  }

  /// Second pass can modify or reclassify tokens if context demands.
  ///
  /// The basic idea is to combine tokens into more complex structures.
  void _secondPass() {
    return;
  }

  /// Scans the source code and groups characters into meaningful tokens.
  void scanToken() {
    var c = advance();
    switch (c) {
      case '(':
        addToken(TokenType.LEFT_PAREN);
        break;
      case ')':
        addToken(TokenType.RIGHT_PAREN);
        break;
      case '{':
        addToken(TokenType.LEFT_BRACE);
        break;
      case '}':
        addToken(TokenType.RIGHT_BRACE);
        break;
      case ',':
        addToken(TokenType.COMMA);
        break;
      case ';':
        addToken(TokenType.SEMICOLON);
        break;
      case '+':
        addToken(TokenType.PLUS);
        break;
      case '-':
        addToken(TokenType.MINUS);
        break;
      case '*':
        addToken(TokenType.STAR);
        break;
      case '!':
        addToken(match('=') ? TokenType.BANG_EQUAL : TokenType.BANG);
        break;
      case '=':
        addToken(match('=') ? TokenType.EQUAL_EQUAL : TokenType.EQUAL);
        break;
      case '<':
        addToken(match('=') ? TokenType.LESS_EQUAL : TokenType.LESS);
        break;
      case '>':
        addToken(match('=') ? TokenType.GREATER_EQUAL : TokenType.GREATER);
        break;
      case '/':
        if (match('/')) {
          // Single-line comment: skip until end of line.
          while (peek() != '\n' && !isAtEnd()) {
            advance();
          }
        } else if (match('*')) {
          // C-style block comment (non-nested).
          blockComment();
        } else {
          addToken(TokenType.SLASH);
        }
        break;
      case ' ':
      case '\r':
      case '\t':
        // Ignore whitespace.
        break;
      case '\n':
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
    while (isAlphaNumeric(peek())) {
      advance();
    }
    var text = source.substring(start, current);
    // Check if the identifier is a reserved keyword.
    var type = keywords[text] ?? TokenType.IDENTIFIER;
    addToken(type);
  }

  void number() {
    while (isDigit(peek())) {
      advance();
    }

    // Look for a fractional part.
    if (peek() == '.' && isDigit(peekNext())) {
      advance(); // consume '.'
      while (isDigit(peek())) {
        advance();
      }
    }

    var value = double.parse(source.substring(start, current));
    addToken(TokenType.NUMBER, value);
  }

  void string() {
    // Consume until we hit an unescaped double-quote.
    while (!isAtEnd()) {
      if (peek() == '"' && !isEscaped()) {
        break;
      }
      if (peek() == '\n') line++;
      advance();
    }

    if (isAtEnd()) {
      print("Unterminated string at line $line");
      return;
    }

    advance(); // Consume the closing '"'

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

  /// Checks if the current character matches the expected character.
  bool match(String expected) {
    if (isAtEnd() || source[current] != expected) return false;
    current++;
    return true;
  }

  /// Checks if we have reached the end of the source code.
  bool isAtEnd() => current >= source.length;

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
    int count = 0;
    int index = current - 1;
    while (index >= start && source[index] == '\\') {
      count++;
      index--;
    }
    return count % 2 == 1;
  }

  void addToken(TokenType type, [dynamic literal]) {
    var text = source.substring(start, current);
    tokens.add(Token(type, text, literal, line));
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
