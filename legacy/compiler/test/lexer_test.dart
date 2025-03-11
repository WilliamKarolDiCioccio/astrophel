import 'package:compiler/compiler.dart';
import 'package:test/test.dart';

void main() {
  group('Lexer', () {
    test('Double tokens: ++, +=, --, -=, *=', () {
      final source = '++ += -- -= *=';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      final types =
          tokens
              .where((t) => t.type != TokenType.EOF)
              .map((t) => t.type)
              .toList();

      expect(
        types,
        equals([
          TokenType.INCREMENT,
          TokenType.PLUS_EQUAL,
          TokenType.DECREMENT,
          TokenType.MINUS_EQUAL,
          TokenType.STAR_EQUAL,
        ]),
      );
    });

    test('String literal without interpolation', () {
      final source = '"Hello, world!"';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      expect(tokens[0].type, equals(TokenType.STRING_LITERAL));
      expect(tokens[0].literal, equals('Hello, world!'));
      expect(tokens.last.type, equals(TokenType.EOF));
    });

    test('String with identifier interpolation', () {
      final source = '"Hello \$name"';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      final types =
          tokens
              .where((t) => t.type != TokenType.EOF)
              .map((t) => t.type)
              .toList();
      expect(
        types,
        containsAllInOrder([
          TokenType.STRING_FRAGMENT_START,
          TokenType.IDENTIFIER_INTERPOLATION,
          TokenType.IDENTIFIER,
          TokenType.STRING_FRAGMENT_END,
        ]),
      );
    });

    test('String with expression interpolation', () {
      final source = '"Sum: \${1 + 2}"';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      final types =
          tokens
              .where((t) => t.type != TokenType.EOF)
              .map((t) => t.type)
              .toList();
      expect(
        types,
        containsAllInOrder([
          TokenType.STRING_FRAGMENT_START,
          TokenType.EXPRESSION_INTERPOLATION_START,
          TokenType.EXPRESSION_INTERPOLATION_END,
          TokenType.STRING_FRAGMENT_END,
        ]),
      );
    });

    test('Single-line comment is ignored', () {
      final source = '// This is a comment\nidentifier';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      final types =
          tokens
              .where((t) => t.type != TokenType.EOF)
              .map((t) => t.type)
              .toList();
      expect(types, equals([TokenType.IDENTIFIER]));
      expect(tokens.first.lexeme, equals('identifier'));
    });

    test('Multi-line (block) comment is ignored', () {
      final source = '/* block comment \n still comment */identifier';
      final lexer = Lexer(source);
      final tokens = lexer.tokenize();

      final types =
          tokens
              .where((t) => t.type != TokenType.EOF)
              .map((t) => t.type)
              .toList();
      expect(types, equals([TokenType.IDENTIFIER]));
      expect(tokens.first.lexeme, equals('identifier'));
    });
  });
}
