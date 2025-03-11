import 'package:meta/meta.dart';

import '../../shared/ast_definitions.dart';
import '../../shared/token_definitions.dart';

/// The parser class is responsible for converting a list of tokens into an AST. It runs on a per-file basis.
class Parser {
  final List<Token> tokens;
  int current = 0;

  Parser(this.tokens);

  /// The main entry point that produces the AST from the token stream.
  ModuleNode produceAST() {
    final ModuleNode module = ModuleNode();

    // Consumes tokens until the end of file token.
    while (!_isAtEnd()) {
      module.statements.add(parseStatement());
    }

    return module;
  }

  /// Parses a statement from the token stream.
  @visibleForTesting
  StatementNode parseStatement() {
    return parseExpression();
  }

  /// Parses an expression from the token stream.
  @visibleForTesting
  ExpressionNode parseExpression() {
    return parseLamdaExpression();
  }

  /// Parses a closure expression from the token stream.
  @visibleForTesting
  ExpressionNode parseLamdaExpression() {
    /// TODO: To implement this we're awaiting parameter declarations support.

    return parseTernaryExpression();
  }

  /// Parses a ternary expression from the token stream (inlined if-else).
  @visibleForTesting
  ExpressionNode parseTernaryExpression() {
    ExpressionNode condition = parseAssignmentExpression();

    if (_match(TokenType.QUESTION)) {
      _advance(); // Consume the QUESTION token

      ExpressionNode thenBranch = parseTernaryExpression();

      if (!_match(TokenType.COLON)) {
        throw UnimplementedError("Expected colon token for ternary expression");
      }

      _advance(); // Consume the COLON token

      ExpressionNode elseBranch = parseTernaryExpression();

      return TernaryExpressionNode(
        condition: condition,
        thenBranch: thenBranch,
        elseBranch: elseBranch,
      );
    }

    return condition;
  }

  /// Parses an assignment expression from the token stream.
  @visibleForTesting
  ExpressionNode parseAssignmentExpression() {
    ExpressionNode expression = parseLogicalExpression();

    if (_match(TokenType.EQUAL) ||
        _match(TokenType.PLUS_EQUAL) ||
        _match(TokenType.MINUS_EQUAL) ||
        _match(TokenType.STAR_EQUAL) ||
        _match(TokenType.SLASH_EQUAL) ||
        _match(TokenType.MODULUS_EQUAL)) {
      final operator = _advance();

      final ExpressionNode value = parseAssignmentExpression();

      if (expression is IdentifierNode ||
          expression is IdentifierAccessExpressionNode ||
          expression is IndexAccessExpressionNode) {
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
  @visibleForTesting
  ExpressionNode parseLogicalExpression() {
    var left = parseEqualityExpression();

    while (_peek().type == TokenType.AMPERSAND_AMPERSAND ||
        _peek().type == TokenType.PIPE_PIPE) {
      final operator = _advance();
      final right = parseEqualityExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// Parses an equality expression from the token stream.
  @visibleForTesting
  ExpressionNode parseEqualityExpression() {
    var left = parseRelationalExpression();

    while (_peek().type == TokenType.BANG_EQUAL ||
        _peek().type == TokenType.EQUAL_EQUAL) {
      final operator = _advance();
      final right = parseRelationalExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// Pareses a relational expression from the token stream.
  @visibleForTesting
  ExpressionNode parseRelationalExpression() {
    var left = parseAdditiveExpression();

    while (_peek().type == TokenType.GREATER ||
        _peek().type == TokenType.GREATER_EQUAL ||
        _peek().type == TokenType.LESS ||
        _peek().type == TokenType.LESS_EQUAL) {
      final operator = _advance();
      final right = parseAdditiveExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  // Secondary expressions - Arithmetic

  /// Parses an arithmetic expression from the token stream.
  @visibleForTesting
  ExpressionNode parseAdditiveExpression() {
    var left = parseMultiplicativeExpression();

    while (_peek().type == TokenType.PLUS || _peek().type == TokenType.MINUS) {
      final operator = _advance();
      final right = parseMultiplicativeExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// Parses a multiplicative expression from the token stream.
  @visibleForTesting
  ExpressionNode parseMultiplicativeExpression() {
    var left = parsePrefixExpression();

    while (_peek().type == TokenType.STAR ||
        _peek().type == TokenType.SLASH ||
        _peek().type == TokenType.MODULUS) {
      final operator = _advance();
      final right = parsePrefixExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  // Primary expressions

  /// Parses a unary expression from the token stream.
  @visibleForTesting
  ExpressionNode parsePrefixExpression() {
    if (_peek().type == TokenType.MINUS ||
        _peek().type == TokenType.BANG ||
        _peek().type == TokenType.INCREMENT ||
        _peek().type == TokenType.DECREMENT) {
      final operator = _advance();
      final right = parsePostfixExpression();
      return UnaryExpressionNode(operand: right, operator: operator);
    }

    return parsePostfixExpression();
  }

  /// Parses a postfix expression from the token stream.
  @visibleForTesting
  ExpressionNode parsePostfixExpression() {
    ExpressionNode expression = parsePrimaryExpression();

    while (true) {
      if (_match(TokenType.DOT)) {
        _advance(); // Consume the dot token

        if (!_match(TokenType.IDENTIFIER)) {
          throw UnimplementedError("Expected identifier after dot token");
        }

        expression = IdentifierAccessExpressionNode(
          object: expression,
          dot: tokens[current - 1],
          name: _advance(),
        );
      } else if (_match(TokenType.INCREMENT) || _match(TokenType.DECREMENT)) {
        final operator = _advance();
        expression = UnaryExpressionNode(
          operand: expression,
          operator: operator,
        );
      } else if (_match(TokenType.LEFT_PAREN)) {
        final arguments = parseArguments();
        expression = CallExpressionNode(
          callee: expression,
          paren: tokens[current - 1],
          arguments: arguments,
        );
      } else if (_match(TokenType.LEFT_BRACKET)) {
        _advance(); // Consume the opening bracket

        final index = parseExpression();

        if (!_match(TokenType.RIGHT_BRACKET)) {
          throw UnimplementedError(
            "Expected closing bracket for index expression",
          );
        }

        _advance(); // Consume the closing bracket

        expression = IndexAccessExpressionNode(
          object: expression,
          bracket: tokens[current - 1],
          index: index,
        );
      } else {
        break;
      }
    }

    return expression;
  }

  /// Parses an index expression from the token stream.

  /// Parses a grouping expression from the token stream.
  @visibleForTesting
  ExpressionNode parseGroupingExpression() {
    _advance(); // Consume the left parenthesis

    final expression = parseExpression();

    if (!_match(TokenType.RIGHT_PAREN)) {
      throw UnimplementedError("Expected closing parenthesis");
    }

    _advance(); // Consume the closing parenthesis

    return GroupingExpressionNode(expression: expression);
  }

  /// Parses a string or string interpolation from the token stream.
  @visibleForTesting
  ExpressionNode parseStringOrInterpolation() {
    List<ExpressionNode> fragments = [];

    if (!_match(TokenType.STRING_FRAGMENT_START)) {
      throw UnimplementedError(
        "Expected string fragment start token: ${_peek()}",
      );
    }

    fragments.add(StringFragmentNode(value: _peek()));

    _advance(); // Consume the STRING_FRAGMENT_START token

    while (_peek().type == TokenType.STRING_FRAGMENT ||
        _peek().type == TokenType.STRING_FRAGMENT_END ||
        _peek().type == TokenType.IDENTIFIER_INTERPOLATION ||
        _peek().type == TokenType.EXPRESSION_INTERPOLATION_START) {
      final token = _peek();

      if (token.type == TokenType.STRING_FRAGMENT ||
          token.type == TokenType.STRING_FRAGMENT_END) {
        fragments.add(StringFragmentNode(value: _advance()));
      } else if (token.type == TokenType.IDENTIFIER_INTERPOLATION) {
        _advance(); // Consume the IDENTIFIER_INTERPOLATION token

        if (!_match(TokenType.IDENTIFIER)) {
          throw UnimplementedError("Expected identifier interpolation token");
        }

        fragments.add(IdentifierNode(name: _peek()));

        _advance(); // Consume the IDENTIFIER token
      } else if (token.type == TokenType.EXPRESSION_INTERPOLATION_START) {
        _advance(); // Consume the EXPRESSION_INTERPOLATION_START token

        ExpressionNode interpolatedExpr = parseExpression();

        if (!_match(TokenType.EXPRESSION_INTERPOLATION_END)) {
          throw UnimplementedError(
            "Expected end token for expression interpolation",
          );
        }

        _advance(); // Consume the EXPRESSION_INTERPOLATION_END token

        fragments.add(interpolatedExpr);
      } else {
        throw UnimplementedError("Unexpected token: $token");
      }
    }

    if (fragments.length == 1 && fragments.first is StringFragmentNode) {
      throw UnimplementedError("Unexpected token: $fragments.first");
    }

    if (fragments.last is! StringFragmentNode ||
        (fragments.last as StringFragmentNode).value.type !=
            TokenType.STRING_FRAGMENT_END) {
      throw UnimplementedError("Expected end token for string interpolation");
    }

    return StringInterpolationNode(fragments: fragments);
  }

  /// Parses a primary expression from the token stream.
  @visibleForTesting
  ExpressionNode parsePrimaryExpression() {
    var tk = _peek();

    late ExpressionNode expression;

    switch (tk.type) {
      case TokenType.NUMBER:
        expression = NumericLiteralNode(value: tk);
        _advance();
        break;
      case TokenType.STRING_LITERAL:
        expression = StringLiteralNode(value: tk);
        _advance();
        break;
      case TokenType.STRING_FRAGMENT_START:
        expression = parseStringOrInterpolation();
        break;
      case TokenType.IDENTIFIER:
        expression = IdentifierNode(name: tk);
        _advance();
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

  /// Parses a list of arguments from the token stream.
  @visibleForTesting
  List<ExpressionNode> parseArguments() {
    _advance(); // Consume the left parenthesis

    List<ExpressionNode> arguments = [];

    while (!_match(TokenType.RIGHT_PAREN)) {
      arguments.add(parseExpression());

      if (_match(TokenType.COMMA)) {
        _advance(); // Consume the comma
      } else {
        break;
      }
    }

    if (!_match(TokenType.RIGHT_PAREN)) {
      throw UnimplementedError("Expected closing parenthesis: ${_peek()}");
    }

    _advance(); // Consume the right parenthesis

    return arguments;
  }

  /// Consumes the next token in the stream and returns it.
  Token _advance() => tokens[current++];

  /// Returns the current token in the stream without consuming it.
  Token _peek() => tokens[current];

  /// Checks if the current token matches the expected token type.
  bool _match(TokenType expected) => tokens[current].type == expected;

  /// Checks if we have reached the end of the token stream.
  bool _isAtEnd() => current + 1 >= tokens.length;
}
