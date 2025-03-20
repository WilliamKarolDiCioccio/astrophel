export 'expressions.dart';
export 'statements.dart';
export 'type_annotations.dart';
export 'meta_annotations.dart';
export 'templates.dart';

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
  unionDeclaration,
  enumDeclaration,
  enumVariant,
  constructorDeclaration,
  destructorDeclaration,
  functionDeclaration,
  variableDeclaration,

  // Type annotations
  atomicTypeAnnotation,
  arrayTypeAnnotation,
  tupleTypeAnnotation,

  // Meta-annotations
  metaAnnotations,

  // Assignment
  assignment,

  // Memory management
  allocation,
  deallocation,

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
  memberAccess,
  indexAccess,
  tupleAccess,

  // Primary expressions
  numericLiteral,
  stringLiteral,
  stringFragment,
  stringInterpolation,
  arrayLiteral,
  tupleLiteral,
  grouping,
  identifier,
}
