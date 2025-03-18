import 'package:compiler/compiler.dart';
import 'package:compiler/src/shared/ast/definitions.dart';
import 'package:test/test.dart';

void main() {
  group('Parser', () {
    group('parseTernaryExpression', () {
      test('parseTernaryExpression with valid ternary expression', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.QUESTION, '?', null, 0, 0),
          Token(TokenType.NUMBER, '1', 1, 0, 0),
          Token(TokenType.COLON, ':', null, 0, 0),
          Token(TokenType.NUMBER, '2', 2, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseTernaryExpression();

        expect(result, isA<TernaryExpressionNode>());
        final ternaryNode = result as TernaryExpressionNode;
        expect(ternaryNode.condition, isA<IdentifierNode>());
        expect(ternaryNode.thenBranch, isA<NumericLiteralNode>());
        expect(ternaryNode.elseBranch, isA<NumericLiteralNode>());
      });

      test('parseTernaryExpression with missing colon', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.QUESTION, '?', null, 0, 0),
          Token(TokenType.NUMBER, '1', 1, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);

        expect(() => parser.parseTernaryExpression(), throwsUnimplementedError);
      });

      test('parseTernaryExpression without ternary operator', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseTernaryExpression();

        expect(result, isA<IdentifierNode>());
      });
    });

    group('parseAssignmentExpression', () {
      test('parseAssignmentExpression with valid assignment', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.EQUAL, '=', null, 0, 0),
          Token(TokenType.NUMBER, '1', 1, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseAssignmentExpression();

        expect(result, isA<AssignmentExpressionNode>());
        final assignmentNode = result as AssignmentExpressionNode;
        expect(assignmentNode.target, isA<IdentifierNode>());
        expect(assignmentNode.value, isA<NumericLiteralNode>());
        expect(assignmentNode.operator.type, TokenType.EQUAL);
      });

      test('parseAssignmentExpression with invalid assignment target', () {
        final tokens = [
          Token(TokenType.NUMBER, '1', 1, 0, 0),
          Token(TokenType.EQUAL, '=', null, 0, 0),
          Token(TokenType.NUMBER, '2', 2, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);

        expect(
          () => parser.parseAssignmentExpression(),
          throwsUnimplementedError,
        );
      });

      test('parseAssignmentExpression without assignment operator', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseAssignmentExpression();

        expect(result, isA<IdentifierNode>());
      });
    });

    group('parseLogicalExpression', () {
      test('parseLogicalExpression with valid logical AND expression', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.AMPERSAND_AMPERSAND, '&&', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'b', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseLogicalOrExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<IdentifierNode>());
        expect(binaryNode.right, isA<IdentifierNode>());
        expect(binaryNode.operator.type, TokenType.AMPERSAND_AMPERSAND);
      });

      test('parseLogicalExpression with valid logical OR expression', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.PIPE_PIPE, '||', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'b', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseLogicalOrExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<IdentifierNode>());
        expect(binaryNode.right, isA<IdentifierNode>());
        expect(binaryNode.operator.type, TokenType.PIPE_PIPE);
      });

      test('parseLogicalExpression without logical operator', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseLogicalOrExpression();

        expect(result, isA<IdentifierNode>());
      });

      test('parseLogicalExpression with multiple logical operators', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.AMPERSAND_AMPERSAND, '&&', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'b', null, 0, 0),
          Token(TokenType.PIPE_PIPE, '||', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'c', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseLogicalOrExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<BinaryExpressionNode>());
        expect(binaryNode.right, isA<IdentifierNode>());
        expect(binaryNode.operator.type, TokenType.PIPE_PIPE);

        final leftNode = binaryNode.left as BinaryExpressionNode;
        expect(leftNode.left, isA<IdentifierNode>());
        expect(leftNode.right, isA<IdentifierNode>());
        expect(leftNode.operator.type, TokenType.AMPERSAND_AMPERSAND);
      });
    });

    group('parseEqualityExpression', () {
      test('parseEqualityExpression with valid equality expression', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.EQUAL_EQUAL, '==', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'b', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseEqualityExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<IdentifierNode>());
        expect(binaryNode.right, isA<IdentifierNode>());
        expect(binaryNode.operator.type, TokenType.EQUAL_EQUAL);
      });

      test('parseEqualityExpression with valid inequality expression', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.BANG_EQUAL, '!=', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'b', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseEqualityExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<IdentifierNode>());
        expect(binaryNode.right, isA<IdentifierNode>());
        expect(binaryNode.operator.type, TokenType.BANG_EQUAL);
      });

      test('parseEqualityExpression without equality operator', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseEqualityExpression();

        expect(result, isA<IdentifierNode>());
      });
    });

    group('parseRelationalExpression', () {
      test('parseRelationalExpression with valid greater than expression', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.GREATER, '>', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'b', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseRelationalExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<IdentifierNode>());
        expect(binaryNode.right, isA<IdentifierNode>());
        expect(binaryNode.operator.type, TokenType.GREATER);
      });

      test('parseRelationalExpression with valid less than expression', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.LESS, '<', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'b', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseRelationalExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<IdentifierNode>());
        expect(binaryNode.right, isA<IdentifierNode>());
        expect(binaryNode.operator.type, TokenType.LESS);
      });

      test('parseRelationalExpression without relational operator', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseRelationalExpression();

        expect(result, isA<IdentifierNode>());
      });
    });

    group('parseAdditiveExpression', () {
      test('parseAdditiveExpression with valid addition expression', () {
        final tokens = [
          Token(TokenType.NUMBER, '1', null, 0, 0),
          Token(TokenType.PLUS, '+', null, 0, 0),
          Token(TokenType.NUMBER, '2', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseAdditiveExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<NumericLiteralNode>());
        expect(binaryNode.right, isA<NumericLiteralNode>());
        expect(binaryNode.operator.type, TokenType.PLUS);
      });

      test('parseAdditiveExpression with valid subtraction expression', () {
        final tokens = [
          Token(TokenType.NUMBER, '1', null, 0, 0),
          Token(TokenType.MINUS, '-', null, 0, 0),
          Token(TokenType.NUMBER, '2', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseAdditiveExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<NumericLiteralNode>());
        expect(binaryNode.right, isA<NumericLiteralNode>());
        expect(binaryNode.operator.type, TokenType.MINUS);
      });

      test('parseAdditiveExpression without additive operator', () {
        final tokens = [
          Token(TokenType.NUMBER, '1', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseAdditiveExpression();

        expect(result, isA<NumericLiteralNode>());
      });
    });

    group('parseMultiplicativeExpression', () {
      test(
        'parseMultiplicativeExpression with valid multiplication expression',
        () {
          final tokens = [
            Token(TokenType.NUMBER, '1', null, 0, 0),
            Token(TokenType.STAR, '*', null, 0, 0),
            Token(TokenType.NUMBER, '2', null, 0, 0),
            Token(TokenType.EOF, '0', null, 0, 0),
          ];

          final parser = Parser(tokens);
          final result = parser.parseMultiplicativeExpression();

          expect(result, isA<BinaryExpressionNode>());
          final binaryNode = result as BinaryExpressionNode;
          expect(binaryNode.left, isA<NumericLiteralNode>());
          expect(binaryNode.right, isA<NumericLiteralNode>());
          expect(binaryNode.operator.type, TokenType.STAR);
        },
      );

      test('parseMultiplicativeExpression with valid division expression', () {
        final tokens = [
          Token(TokenType.NUMBER, '1', null, 0, 0),
          Token(TokenType.SLASH, '/', null, 0, 0),
          Token(TokenType.NUMBER, '2', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseMultiplicativeExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<NumericLiteralNode>());
        expect(binaryNode.right, isA<NumericLiteralNode>());
        expect(binaryNode.operator.type, TokenType.SLASH);
      });

      test('parseMultiplicativeExpression with valid modulus expression', () {
        final tokens = [
          Token(TokenType.NUMBER, '1', null, 0, 0),
          Token(TokenType.MODULUS, '%', null, 0, 0),
          Token(TokenType.NUMBER, '2', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseMultiplicativeExpression();

        expect(result, isA<BinaryExpressionNode>());
        final binaryNode = result as BinaryExpressionNode;
        expect(binaryNode.left, isA<NumericLiteralNode>());
        expect(binaryNode.right, isA<NumericLiteralNode>());
        expect(binaryNode.operator.type, TokenType.MODULUS);
      });

      test('parseMultiplicativeExpression without multiplicative operator', () {
        final tokens = [
          Token(TokenType.NUMBER, '1', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseMultiplicativeExpression();

        expect(result, isA<NumericLiteralNode>());
      });
    });

    group('parsePrefixExpression', () {
      test('parsePrefixExpression with valid prefix minus', () {
        final tokens = [
          Token(TokenType.MINUS, '-', null, 0, 0),
          Token(TokenType.NUMBER, '1', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parsePrefixExpression();

        expect(result, isA<UnaryExpressionNode>());
        final unaryNode = result as UnaryExpressionNode;
        expect(unaryNode.operator.type, TokenType.MINUS);
        expect(unaryNode.operand, isA<NumericLiteralNode>());
      });

      test('parsePrefixExpression with valid prefix bang', () {
        final tokens = [
          Token(TokenType.BANG, '!', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parsePrefixExpression();

        expect(result, isA<UnaryExpressionNode>());
        final unaryNode = result as UnaryExpressionNode;
        expect(unaryNode.operator.type, TokenType.BANG);
        expect(unaryNode.operand, isA<IdentifierNode>());
      });

      test('parsePrefixExpression without prefix operator', () {
        final tokens = [
          Token(TokenType.NUMBER, '1', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parsePrefixExpression();

        expect(result, isA<NumericLiteralNode>());
      });
    });

    group('parsePostfixExpression', () {
      test('parsePostfixExpression with valid postfix increment', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.INCREMENT, '++', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parsePostfixExpression();

        expect(result, isA<UnaryExpressionNode>());
        final unaryNode = result as UnaryExpressionNode;
        expect(unaryNode.operator.type, TokenType.INCREMENT);
        expect(unaryNode.operand, isA<IdentifierNode>());
      });

      test('parsePostfixExpression with valid postfix decrement', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.DECREMENT, '--', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parsePostfixExpression();

        expect(result, isA<UnaryExpressionNode>());
        final unaryNode = result as UnaryExpressionNode;
        expect(unaryNode.operator.type, TokenType.DECREMENT);
        expect(unaryNode.operand, isA<IdentifierNode>());
      });

      test('parsePostfixExpression without postfix operator', () {
        final tokens = [
          Token(TokenType.IDENTIFIER, 'a', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parsePostfixExpression();

        expect(result, isA<IdentifierNode>());
      });
    });

    group('parseStringOrInterpolation', () {
      test('parseStringOrInterpolation with identifier interpolation', () {
        final tokens = [
          Token(TokenType.STRING_FRAGMENT_START, '"Hello, ', null, 0, 0),
          Token(TokenType.IDENTIFIER_INTERPOLATION, '\$', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'name', null, 0, 0),
          Token(TokenType.STRING_FRAGMENT_END, '"', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseStringOrInterpolation();

        expect(result, isA<StringInterpolationNode>());
        final stringNode = result as StringInterpolationNode;
        expect(stringNode.fragments.length, 3);
        expect(stringNode.fragments.first, isA<StringFragmentNode>());
        expect(stringNode.fragments[1], isA<IdentifierNode>());
        expect(stringNode.fragments.last, isA<StringFragmentNode>());
      });

      test('parseStringOrInterpolation with expression interpolation', () {
        final tokens = [
          Token(TokenType.STRING_FRAGMENT_START, '"Result: ', null, 0, 0),
          Token(TokenType.EXPRESSION_INTERPOLATION_START, '\${', null, 0, 0),
          Token(TokenType.NUMBER, '1', null, 0, 0),
          Token(TokenType.PLUS, '+', null, 0, 0),
          Token(TokenType.NUMBER, '2', null, 0, 0),
          Token(TokenType.EXPRESSION_INTERPOLATION_END, '}', null, 0, 0),
          Token(TokenType.STRING_FRAGMENT_END, '"', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);
        final result = parser.parseStringOrInterpolation();

        expect(result, isA<StringInterpolationNode>());
        final stringNode = result as StringInterpolationNode;
        expect(stringNode.fragments.length, 3);
        expect(stringNode.fragments.first, isA<StringFragmentNode>());
        expect(stringNode.fragments[1], isA<BinaryExpressionNode>());
        expect(stringNode.fragments.last, isA<StringFragmentNode>());
      });

      test('parseStringOrInterpolation with missing end token', () {
        final tokens = [
          Token(TokenType.STRING_FRAGMENT_START, '"Hello, ', null, 0, 0),
          Token(TokenType.IDENTIFIER_INTERPOLATION, '\$', null, 0, 0),
          Token(TokenType.IDENTIFIER, 'name', null, 0, 0),
          Token(TokenType.EOF, '0', null, 0, 0),
        ];

        final parser = Parser(tokens);

        expect(
          () => parser.parseStringOrInterpolation(),
          throwsUnimplementedError,
        );
      });
    });

    group('Parser Integration Tests', () {
      test('Arithmetic precedence: 1 + 2 * 3', () {
        final Lexer lexer = Lexer("1 + 2 * 3;");
        final tokens = lexer.tokenize();
        final parser = Parser(tokens);
        final ast = parser.produceAST();

        final expectedAST = ModuleNode(
          statements: [
            ExpressionStatementNode(
              expression: BinaryExpressionNode(
                left: NumericLiteralNode(value: tokens[0]),
                right: BinaryExpressionNode(
                  left: NumericLiteralNode(value: tokens[2]),
                  right: NumericLiteralNode(value: tokens[4]),
                  operator: tokens[3],
                ),
                operator: tokens[1],
              ),
            ),
          ],
        );

        expect(ast, equals(expectedAST));
      });

      test('Postfix precedence: a.b(c)++', () {
        final Lexer lexer = Lexer("a.b(c)++;");
        final tokens = lexer.tokenize();
        final parser = Parser(tokens);
        final ast = parser.produceAST();

        final expectedAST = ModuleNode(
          statements: [
            ExpressionStatementNode(
              expression: UnaryExpressionNode(
                operand: CallExpressionNode(
                  callee: IdentifierAccessExpressionNode(
                    object: IdentifierNode(name: tokens[0]),
                    dot: tokens[1],
                    name: tokens[2],
                  ),
                  leftParen: tokens[3],
                  arguments: [IdentifierNode(name: tokens[4])],
                ),
                operator: tokens[6],
              ),
            ),
          ],
        );

        expect(ast, equals(expectedAST));
      });
    });
  });
}
