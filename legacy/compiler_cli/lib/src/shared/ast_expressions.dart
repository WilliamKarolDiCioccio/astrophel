import 'ast_definitions.dart';
import 'token_definitions.dart';

// The declarations appear in order of parsing precedence.

/// Represents a function call.
interface class CallExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.call;
  final ExpressionNode callee;
  final Token paren; // Token representing the closing parenthesis, for example
  final List<ExpressionNode> arguments;

  CallExpressionNode({
    required this.callee,
    required this.paren,
    required this.arguments,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'callee': callee.toJson(),
      'paren': paren.lexeme,
      'arguments': arguments.map((arg) => arg.toJson()).toList(),
    };
  }
}

/// Represents an assignment expression.
interface class AssignmentExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.assignment;
  final IdentifierNode target;
  final ExpressionNode value;
  final Token operator; // e.g., "="

  AssignmentExpressionNode({
    required this.target,
    required this.value,
    required this.operator,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'target': target.toJson(),
      'operator': operator.lexeme,
      'value': value.toJson(),
    };
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

/// Represents a postfix expression.
interface class PostfixExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.postfix;
  final ExpressionNode operand;
  final Token operator;

  PostfixExpressionNode({required this.operand, required this.operator});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'operand': operand.toJson(),
      'operator': operator.lexeme,
    };
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

/// Represents a string literal.
interface class StringLiteralNode extends ExpressionNode {
  static const ASTType type = ASTType.stringLiteral;
  final Token value;

  StringLiteralNode({required this.value});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'value': value.lexeme};
  }
}

/// Represents a string interpolation expression.
interface class StringFragmentNode extends ExpressionNode {
  static const ASTType type = ASTType.stringFragment;
  final Token value;

  StringFragmentNode({required this.value});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'value': value.lexeme};
  }
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

/// Represents a string interpolation expression.
interface class StringInterpolationNode extends ExpressionNode {
  static const ASTType type = ASTType.stringExpressionInterpolation;
  final List<ExpressionNode> fragments;

  StringInterpolationNode({required this.fragments});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'fragments': fragments.map((fragment) => fragment.toJson()).toList(),
    };
  }
}
