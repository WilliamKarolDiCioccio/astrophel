import 'dart:convert';

import 'package:equatable/equatable.dart';

export 'ast_expressions.dart';
export 'ast_statements.dart';

/// NOTE: Details can be found in the corresponding statement or expression node.
enum ASTType {
  // Top-level program structure.
  module,
  importStatement,
  exportStatement,
  // Declarations.
  variableDeclaration,
  functionDeclaration,
  structDeclaration,
  enumDeclaration,
  // Function
  functionParameter,
  // Expressions.
  numericLiteral,
  stringLiteral,
  stringFragment,
  stringIdentifierInterpolation,
  stringExpressionInterpolation,
  identifier,
  ternary,
  binary,
  unary,
  postfix,
  call,
  indexAccess,
  identifierAccess,
  closure,
  grouping,
  // Statements.
  block,
  expressionStatement,
  assignment,
  ifStatement,
  elseStatement,
  switchStatement,
  whileStatement,
  forStatement,
  returnStatement,
  // Type annotation.
  typeAnnotation,
}

// NOTE: I'm not using the `interface` keyword here because Dart doesn't allow for
// extending classes with `interface` outside of the same library. This would require
// redefining the toString method in each class that implements the interface.

/// Base class for all AST statement nodes.
///
/// This class is used to represent a statement in the AST. A statement is a
/// single instruction that performs an action. For example, a variable
/// declaration, a function declaration, or an if statement.
abstract class StatementNode extends Equatable {
  Map<String, dynamic> toJson();

  @override
  String toString() => JsonEncoder.withIndent('  ').convert(toJson());
}

/// Represents an expression node.
///
/// This class is used to represent an expression in the AST. An expression is a
/// combination of values, variables, operators, and function calls that are
/// evaluated to produce a result. Expressions are a subset of statements.
abstract class ExpressionNode extends StatementNode {}
