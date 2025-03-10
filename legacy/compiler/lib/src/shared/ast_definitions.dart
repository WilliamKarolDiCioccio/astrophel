import 'dart:convert';

export 'ast_expressions.dart';
export 'ast_statements.dart';

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
  stringFragment, // e.g., "Hello, ...", any non opened/closed string literal part of a string interpolation.
  stringIdentifierInterpolation,
  stringExpressionInterpolation,
  identifier, // Variable names, function names.
  binary, // Binary operations, e.g., a + b.
  unary, // Unary operations, e.g., -a.
  postfix, // Postfix operations, e.g., a++.
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

/// Base class for all AST statement nodes.
///
/// NOTE: I'm not using the `interface` keyword here because Dart doesn't allow for
/// extending classes with `interface` outside of the same library. This would require
/// redefining the toString method in each class that implements the interface.
abstract class StatementNode {
  Map<String, dynamic> toJson();

  @override
  String toString() => JsonEncoder.withIndent('  ').convert(toJson());
}

/// Represents an expression node.
abstract class ExpressionNode extends StatementNode {}
