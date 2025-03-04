import 'dart:convert';

import 'token_definitions.dart';

/// The difference between a statement and an expression is that a statement
/// performs an action, while an expression evaluates to a value.

enum ASTType {
  // Top-level program structure.
  module,
  importStatement,
  exportStatement,
  // Declarations.
  variableDeclaration,
  functionDeclaration,
  parameter,
  // Expressions.
  numericLiteral, // e.g., 42, 3.14
  stringLiteral, // e.g., "Hello, world!"
  identifier, // Variable names, function names.
  binary, // Binary operations, e.g., a + b.
  unary, // Unary operations, e.g., -a.
  call, // Function calls, e.g., foo(a, b).
  grouping, // Grouping expressions, e.g., (a + b)
  // Statements.
  block, // { ... } block of statements.
  expressionStatement, // Expression used as a statement.
  assignment, // Assignment expression.
  ifStatement,
  elseStatement,
  switchStatement,
  whileStatement,
  forStatement,
  returnStatement,
  // Type annotation.
  typeAnnotation, // e.g., u16, f32
}

/// Base interface for all AST statement nodes.
abstract interface class StatementNode {
  Map<String, dynamic> toJson();

  @override
  String toString() => JsonEncoder.withIndent('  ').convert(toJson());
}

/// Represents a module (the top-level AST node).
interface class ModuleNode extends StatementNode {
  static const ASTType type = ASTType.module;
  final List<StatementNode> statements = <StatementNode>[];

  ModuleNode();

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'statements': statements.map((stmt) => stmt.toJson()).toList(),
    };
  }

  // Remove the override of toString so that StatementNode's implementation is used.
}

/// Represents an expression node.
abstract interface class ExpressionNode extends StatementNode {
  @override
  Map<String, dynamic> toJson();
}

/// Represents an identifier.
interface class IdentifierNode extends ExpressionNode {
  static const ASTType type = ASTType.identifier;
  final Token name;

  IdentifierNode({required this.name});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'name': name.lexeme};
  }
}

/// Represents a numeric literal.
interface class NumericLiteralNode extends ExpressionNode {
  static const ASTType type = ASTType.numericLiteral;
  final Token value;

  NumericLiteralNode({required this.value});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'value': value.lexeme};
  }
}

/// Represents a unary expression.
interface class UnaryExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.unary;
  final ExpressionNode expression;
  final Token operator;

  UnaryExpressionNode({required this.expression, required this.operator});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'expression': expression.toJson(),
      'operator': operator.lexeme,
    };
  }
}

/// Represents a grouping expression.
interface class GroupingExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.grouping;
  final ExpressionNode expression;

  GroupingExpressionNode({required this.expression});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'expression': expression.toJson()};
  }
}

/// Represents a binary expression.
interface class BinaryExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.binary;
  final ExpressionNode left;
  final ExpressionNode right;
  final Token operator;

  BinaryExpressionNode({
    required this.left,
    required this.right,
    required this.operator,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'left': left.toJson(),
      'right': right.toJson(),
      'operator': operator.lexeme,
    };
  }
}
