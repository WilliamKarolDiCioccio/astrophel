import '../lexer/token_definitions.dart';
import './ast_definitions.dart';
export 'ast_definitions.dart';

class Parser {
  final List<Token> tokens;
  int current = 0;

  Parser(this.tokens);

  /// The main entry point that produces the AST from the token stream.
  ModuleNode produceAST() {
    final ModuleNode module = ModuleNode();

    // Consumes tokens until the end of file token.
    while (!isAtEnd()) {
      module.statements.add(parseStatement());
    }

    return module;
  }

  /// Parses a statement from the token stream.
  StatementNode parseStatement() {
    return parseExpression();
  }

  /// Parses an expression from the token stream.
  ExpressionNode parseExpression() {
    return parseAdditiveExpression();
  }

  /// Parses an arithmetic expression from the token stream.
  ExpressionNode parseAdditiveExpression() {
    var left = parseMultiplicativeExpression();

    while (peek().type == TokenType.PLUS || peek().type == TokenType.MINUS) {
      final operator = advance();
      final right = parseMultiplicativeExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// Parses a multiplicative expression from the token stream.
  ExpressionNode parseMultiplicativeExpression() {
    var left = parsePrimaryExpression();

    while (peek().type == TokenType.STAR ||
        peek().type == TokenType.SLASH ||
        peek().type == TokenType.MODULUS) {
      final operator = advance();
      final right = parsePrimaryExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// Parses a primary expression from the token stream.
  ExpressionNode parsePrimaryExpression() {
    var tk = advance();

    switch (tk.type) {
      case TokenType.NUMBER:
        return NumericLiteralNode(value: tk);
      case TokenType.IDENTIFIER:
        return IdentifierNode(name: tk);
      case TokenType.LEFT_PAREN:
        final value = parseExpression();
        if (!match(TokenType.RIGHT_PAREN)) {
          throw UnimplementedError("Expected closing parenthesis");
        } else {
          advance(); // Consume the closing parenthesis
          return value;
        }
      default:
        throw UnimplementedError("Unexpected token: $tk");
    }
  }

  // Utility methods

  /// Consumes the next token in the stream and returns it.
  Token advance() => tokens[current++];

  /// Returns the current token in the stream without consuming it.
  Token peek() => tokens[current];

  /// Returns the next token in the stream without consuming it.
  Token? peekNext() => isAtEnd() ? tokens[current + 1] : null;

  /// Checks if the current token matches the expected token type.
  bool match(TokenType expected) => tokens[current].type == expected;

  /// Checks if the next token matches the expected token type.
  bool matchNext(TokenType expected) =>
      !isAtEnd() && tokens[current + 1].type == expected;

  /// Checks if we have reached the end of the token stream.
  bool isAtEnd() => current + 1 >= tokens.length;
}
