import '../../shared/ast_definitions.dart';
import '../../shared/token_definitions.dart';

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
    return parseAssignmentExpression();
  }

  /// Parses an assignment expression from the token stream.
  ExpressionNode parseAssignmentExpression() {
    ExpressionNode expression = parseLogicalExpression();

    if (match(TokenType.EQUAL)) {
      final operator = advance();

      final ExpressionNode value = parseAssignmentExpression();

      if (expression is IdentifierNode) {
        return AssignmentExpressionNode(
          target: expression,
          value: value,
          operator: operator,
        );
      } else {
        throw UnimplementedError("Invalid assignment target: $expression");
      }
    }

    return expression;
  }

  /// Parses a logical expression from the token stream.
  ExpressionNode parseLogicalExpression() {
    var left = parseEqualityExpression();

    while (peek().type == TokenType.AMPERSAND_AMPERSAND ||
        peek().type == TokenType.PIPE_PIPE) {
      final operator = advance();
      final right = parseEqualityExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// Parses an equality expression from the token stream.
  ExpressionNode parseEqualityExpression() {
    var left = parseRelationalExpression();

    while (peek().type == TokenType.BANG_EQUAL ||
        peek().type == TokenType.EQUAL_EQUAL) {
      final operator = advance();
      final right = parseRelationalExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// Pareses a relational expression from the token stream.
  ExpressionNode parseRelationalExpression() {
    var left = parseAdditiveExpression();

    while (peek().type == TokenType.GREATER ||
        peek().type == TokenType.GREATER_EQUAL ||
        peek().type == TokenType.LESS ||
        peek().type == TokenType.LESS_EQUAL) {
      final operator = advance();
      final right = parseAdditiveExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  // Secondary expressions - Arithmetic

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
    var left = parseUnaryExpression();

    while (peek().type == TokenType.STAR ||
        peek().type == TokenType.SLASH ||
        peek().type == TokenType.MODULUS) {
      final operator = advance();
      final right = parseUnaryExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  // Primary expressions

  /// Parses a unary expression from the token stream.
  ExpressionNode parseUnaryExpression() {
    if (peek().type == TokenType.MINUS ||
        peek().type == TokenType.BANG ||
        peek().type == TokenType.INCREMENT ||
        peek().type == TokenType.DECREMENT) {
      final operator = advance();
      final right = parseUnaryExpression();
      return UnaryExpressionNode(expression: right, operator: operator);
    }

    return parsePostfixExpression();
  }

  /// Parses a postfix expression from the token stream.
  ExpressionNode parsePostfixExpression() {
    ExpressionNode expression = parsePrimaryExpression();

    while (true) {
      if (match(TokenType.INCREMENT) || match(TokenType.DECREMENT)) {
        final operator = advance();
        expression = PostfixExpressionNode(
          operand: expression,
          operator: operator,
        );
      } else {
        break;
      }
    }

    return expression;
  }

  /// Parses a grouping expression from the token stream.
  ExpressionNode parseGroupingExpression() {
    advance(); // Consume the left parenthesis

    final expression = parseExpression();

    if (!match(TokenType.RIGHT_PAREN)) {
      throw UnimplementedError("Expected closing parenthesis");
    }

    advance(); // Consume the closing parenthesis

    return GroupingExpressionNode(expression: expression);
  }

  /// Parses a string or string interpolation from the token stream.
  ExpressionNode parseStringOrInterpolation() {
    List<ExpressionNode> fragments = [];

    if (!match(TokenType.STRING_FRAGMENT_START)) {
      throw FormatException("Expected string fragment start token");
    }

    fragments.add(StringFragmentNode(value: peek()));

    advance(); // Consume the STRING_FRAGMENT_START token

    while (peek().type == TokenType.STRING_FRAGMENT ||
        peek().type == TokenType.STRING_FRAGMENT_END ||
        peek().type == TokenType.IDENTIFIER_INTERPOLATION ||
        peek().type == TokenType.EXPRESSION_INTERPOLATION_START) {
      final token = peek();

      if (token.type == TokenType.STRING_FRAGMENT ||
          token.type == TokenType.STRING_FRAGMENT_END) {
        fragments.add(StringFragmentNode(value: advance()));
      } else if (token.type == TokenType.IDENTIFIER_INTERPOLATION) {
        advance(); // Consume the IDENTIFIER_INTERPOLATION token

        if (!match(TokenType.IDENTIFIER)) {
          throw FormatException("Expected identifier interpolation token");
        }

        fragments.add(IdentifierNode(name: peek()));

        advance(); // Consume the IDENTIFIER token
      } else if (token.type == TokenType.EXPRESSION_INTERPOLATION_START) {
        advance(); // Consume the EXPRESSION_INTERPOLATION_START token

        ExpressionNode interpolatedExpr = parseExpression();

        if (!match(TokenType.EXPRESSION_INTERPOLATION_END)) {
          throw FormatException(
            "Expected end token for expression interpolation",
          );
        }

        advance(); // Consume the EXPRESSION_INTERPOLATION_END token

        fragments.add(interpolatedExpr);
      } else {
        throw UnimplementedError("Unexpected token: $token");
      }
    }

    if (fragments.isEmpty ||
        fragments.length == 1 && fragments.first is StringFragmentNode) {
      throw UnimplementedError("Unexpected token: $fragments.first");
    }

    return StringInterpolationNode(fragments: fragments);
  }

  /// Parses a primary expression from the token stream.
  ExpressionNode parsePrimaryExpression() {
    var tk = peek();

    late ExpressionNode expression;

    switch (tk.type) {
      case TokenType.NUMBER:
        expression = NumericLiteralNode(value: tk);
        advance();
        break;
      case TokenType.STRING_LITERAL:
        expression = StringLiteralNode(value: tk);
        advance();
        break;
      case TokenType.STRING_FRAGMENT_START:
        expression = parseStringOrInterpolation();
        break;
      case TokenType.IDENTIFIER:
        expression = IdentifierNode(name: tk);
        advance();
        break;
      case TokenType.LEFT_PAREN:
        expression = parseGroupingExpression();
        break;
      default:
        throw UnimplementedError("Unexpected token: $tk");
    }

    return expression;
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
