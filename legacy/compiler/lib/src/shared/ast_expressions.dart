import 'ast_definitions.dart';
import 'token_definitions.dart';

// The declarations appear in ascending order of parsing precedence.

/// Represents a lambda expression (anonymous function or closure).
///
/// captures: The variables captured by the lambda expression.
/// parameters: The parameters of the lambda expression.
/// body: The body of the lambda expression.
class ClosureExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.closure;
  final List<IdentifierNode> captures;
  final List<IdentifierNode> parameters;
  final StatementNode body;

  ClosureExpressionNode({
    required this.captures,
    required this.parameters,
    required this.body,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'captures': captures.map((capture) => capture.toJson()).toList(),
      'parameters': parameters.map((param) => param.toJson()).toList(),
      'body': body.toJson(),
    };
  }
}

/// Represents a ternary expression (commonly known as the inline conditional operator).
///
/// condition: The condition to evaluate. Can be any expression that evaluates to a boolean or can be coerced to a boolean.
/// thenBranch: The expression to evaluate if the condition is true.
/// elseBranch: The expression to evaluate if the condition is false.

class TernaryExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.ternary;
  final ExpressionNode condition;
  final ExpressionNode thenBranch;
  final ExpressionNode elseBranch;

  TernaryExpressionNode({
    required this.condition,
    required this.thenBranch,
    required this.elseBranch,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'condition': condition.toJson(),
      'thenBranch': thenBranch.toJson(),
      'elseBranch': elseBranch.toJson(),
    };
  }
}

/// Represents an assignment expression.
///
/// target: The target of the assignment. Can be either an identifier or an index expression.
/// value: The value to assign to the target.
/// operator: The assignment operator, e.g., "=".

class AssignmentExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.assignment;
  final ExpressionNode target;
  final ExpressionNode value;
  final Token operator;

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
///
/// left: The left-hand side of the binary expression.
/// right: The right-hand side of the binary expression.
/// operator: The binary operator, can be logical, arithmetic, or comparison, e.g., "+", "&&", "<".

class BinaryExpressionNode extends ExpressionNode {
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

/// Represents a unary expression (postfix or prefix).
///
/// expression: The expression to apply the unary operator to.
/// operator: The unary operator, e.g., "!", "-", "++".
///
/// NOTE: It's common to refer prefix operators as unary operators. They are essentially the same thing.

class UnaryExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.unary;
  final ExpressionNode operand;
  final Token operator;

  UnaryExpressionNode({required this.operand, required this.operator});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'expression': operand.toJson(),
      'operator': operator.lexeme,
    };
  }
}

/// Represents an identifier access expression.
///
/// dot: Token representing the dot operator (used for error reporting).
/// name: The name of the identifier to access.

class IdentifierAccessExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.identifierAccess;
  final ExpressionNode object;
  final Token dot;
  final Token name;

  IdentifierAccessExpressionNode({
    required this.object,
    required this.dot,
    required this.name,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'object': object.toJson(),
      'dot': dot.lexeme,
      'name': name.lexeme,
    };
  }
}

/// Represents an index access expression.
///
/// bracket: Token representing the bracket operator (used for error reporting).
/// index: The index to access. Can be any expression that evaluates to an integer or can be coerced to an integer.

class IndexAccessExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.indexAccess;
  final ExpressionNode object;
  final Token bracket;
  final ExpressionNode index;

  IndexAccessExpressionNode({
    required this.object,
    required this.bracket,
    required this.index,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'object': object.toJson(),
      'bracket': bracket.lexeme,
      'index': index.toJson(),
    };
  }
}

/// Represents a function call.
///
/// callee: The identifier or expression representing the function to call.
/// paren: Token representing the closing parenthesis (used for error reporting).
/// arguments: The arguments to pass to the function.
///
/// NOTE: The identifier can be a constructor, a function, a method, a closure, or a variable that holds a function.

class CallExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.call;
  final ExpressionNode callee;
  final Token paren;
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

/// Represents a numeric literal.
///
/// value: The token representing the numeric literal.

class NumericLiteralNode extends ExpressionNode {
  static const ASTType type = ASTType.numericLiteral;
  final Token value;

  NumericLiteralNode({required this.value});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'value': value.lexeme};
  }
}

/// Represents a string literal.
///
/// value: The token representing the string literal.

class StringLiteralNode extends ExpressionNode {
  static const ASTType type = ASTType.stringLiteral;
  final Token value;

  StringLiteralNode({required this.value});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'value': value.lexeme};
  }
}

/// Represents a string interpolation expression.
///
/// value: The token representing the string literal.
///
/// NOTE: This is a special case of a string literal where the string contains interpolated expressions.

class StringFragmentNode extends ExpressionNode {
  static const ASTType type = ASTType.stringFragment;
  final Token value;

  StringFragmentNode({required this.value});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'value': value.lexeme};
  }
}

/// Represents an identifier.
///
/// name: The token representing the identifier.

class IdentifierNode extends ExpressionNode {
  static const ASTType type = ASTType.identifier;
  final Token name;

  IdentifierNode({required this.name});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'name': name.lexeme};
  }
}

/// Represents a grouping expression to manipulate precedence.
///
/// expression: The expression inside the grouping.

class GroupingExpressionNode extends ExpressionNode {
  static const ASTType type = ASTType.grouping;
  final ExpressionNode expression;

  GroupingExpressionNode({required this.expression});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'expression': expression.toJson()};
  }
}

/// Represents a string interpolation expression.
///
/// fragments: The fragments that make up the string interpolation.
///
/// NOTE: A string interpolation is a string that contains expressions that are evaluated and concatenated to the string.

class StringInterpolationNode extends ExpressionNode {
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
