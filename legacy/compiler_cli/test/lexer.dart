import 'package:legacy_compiler/legacy_compiler.dart';
import 'package:test/test.dart';

void main() {
  group('Lexer Tests', () {
    test('Simple identifiers and operators', () {
      final source = 'a + b';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      expect(tokens.map((t) => t.type).toList(), [
        TokenType.IDENTIFIER,
        TokenType.PLUS,
        TokenType.IDENTIFIER,
        TokenType.EOF,
      ]);

      expect(tokens[0].lexeme, 'a');
      expect(tokens[2].lexeme, 'b');
    });

    test('Numeric literal', () {
      final source = '42';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      expect(tokens.map((t) => t.type).toList(), [
        TokenType.NUMBER,
        TokenType.EOF,
      ]);

      expect(tokens[0].literal, 42.0);
    });

    test('String literal with escapes', () {
      final source = '"Hello\\nWorld"';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      expect(tokens.map((t) => t.type).toList(), [
        TokenType.STRING_LITERAL,
        TokenType.EOF,
      ]);

      expect(tokens[0].literal, 'Hello\nWorld');
    });

    test('Data type keyword recognition', () {
      final source = 'u16 x = 10;';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      expect(tokens.map((t) => t.type).toList(), [
        TokenType.TYPE_ANNOTATION,
        TokenType.IDENTIFIER,
        TokenType.EQUAL,
        TokenType.NUMBER,
        TokenType.SEMICOLON,
        TokenType.EOF,
      ]);
    });

    test('Single-line comment is ignored', () {
      final source = 'a // this is a comment\nb';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      expect(tokens.map((t) => t.type).toList(), [
        TokenType.IDENTIFIER,
        TokenType.IDENTIFIER,
        TokenType.EOF,
      ]);

      expect(tokens[0].lexeme, 'a');
      expect(tokens[1].lexeme, 'b');
    });

    test('Block comment is ignored', () {
      final source = 'a /* block comment */ b';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      expect(tokens.map((t) => t.type).toList(), [
        TokenType.IDENTIFIER,
        TokenType.IDENTIFIER,
        TokenType.EOF,
      ]);
    });

    test('Multi-character operators', () {
      final source = 'a == b != c <= d >= e';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      expect(tokens.map((t) => t.type).toList(), [
        TokenType.IDENTIFIER, // a
        TokenType.EQUAL_EQUAL, // ==
        TokenType.IDENTIFIER, // b
        TokenType.BANG_EQUAL, // !=
        TokenType.IDENTIFIER, // c
        TokenType.LESS_EQUAL, // <=
        TokenType.IDENTIFIER, // d
        TokenType.GREATER_EQUAL, // >=
        TokenType.IDENTIFIER, // e
        TokenType.EOF,
      ]);
    });
  });
}
