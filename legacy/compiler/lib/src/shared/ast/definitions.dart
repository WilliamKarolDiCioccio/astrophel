import 'dart:convert';

import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

export 'expressions.dart';
export 'statements.dart';

/// NOTE: Details can be found in the corresponding statement or expression node.
enum ASTType {
  // Modules
  module,
  importStatement,
  symbolImport,
  symbolWiseImportStatement,
  exportStatement,

  // Declarations
  interfaceDeclaration,
  interfaceImplementation,
  classDeclaration,
  structDeclaration,
  enumDeclaration,
  enumVariant,
  constructorDeclaration,
  destructorDeclaration,
  functionDeclaration,
  variableDeclaration,

  // Assignment
  assignment,

  // Control flow
  ifStatement,
  elseStatement,
  elseIfStatement,
  switchStatement,
  caseStatement,
  whileStatement,
  doWhileStatement,
  forStatement,
  breakStatement,
  continueStatement,
  returnStatement,
  parameter,
  blockStatement,
  expressionStatement,

  // Expressions
  lambda,
  ternary,
  binary,
  unary,
  postfix,
  call,
  indexAccess,
  identifierAccess,
  // Primary expressions
  numericLiteral,
  stringLiteral,
  stringFragment,
  stringInterpolation,
  arrayLiteral,
  identifier,
  grouping,
}

// NOTE: I'm not using the `interface` keyword here because Dart doesn't allow for
// extending classes with `interface` outside of the same library.

/// Base class for all AST statement nodes.
///
/// This class is used to represent a statement in the AST. A statement is a
/// single instruction that performs an action. For example, a variable
/// declaration, a function declaration, or an if statement.
@immutable
abstract class StatementNode extends Equatable {
  final ASTType type;

  const StatementNode(this.type);

  Map<String, dynamic> toJson();

  @override
  String toString() => JsonEncoder.withIndent('  ').convert(toJson());
}

/// Base class for all AST expression nodes. It extends [StatementNode] as an expression can be a statement (but not vice versa).
///
/// This class is used to represent an expression in the AST. An expression is a
/// combination of values, variables, operators, and function calls that are
/// evaluated to produce a result. Expressions are a subset of statements.
@immutable
abstract class ExpressionNode extends StatementNode {
  const ExpressionNode(super.type);
}
