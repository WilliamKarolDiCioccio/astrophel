import 'package:meta/meta.dart';

import '../../shared/ast/definitions.dart';
import '../tokens/definitions.dart';

/// evaluated to produce a result. Expressions are a subset of statements.
@immutable
abstract class ExpressionNode extends StatementNode {
  const ExpressionNode(super.type);
}

/// captures: The variables captured by the lambda expression.
/// parameters: The parameters of the lambda expression.
/// body: The body of the lambda expression.
class LambdaExpressionNode extends ExpressionNode {
  final Token? executionModelSpecifier;
  final Token lambdaKeyword;
  final List<ExpressionNode> parameters;
  final TypeAnnotation? returnType;
  final StatementNode body;

  const LambdaExpressionNode({
    required this.executionModelSpecifier,
    required this.lambdaKeyword,
    required this.parameters,
    required this.returnType,
    required this.body,
  }) : super(ASTType.lambda);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      if (executionModelSpecifier != null)
        'executionModelSpecifier': executionModelSpecifier!.lexeme,
      'lambdaKeyword': lambdaKeyword.lexeme,
      'parameters': parameters.map((param) => param.toJson()).toList(),
      if (returnType != null) 'returnType': returnType!.toJson(),
      'body': body.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    executionModelSpecifier,
    lambdaKeyword,
    parameters,
    returnType,
    body,
  ];
}

/// Represents a ternary expression (commonly known as the inline conditional operator).
///
/// condition: The condition to evaluate. Can be any expression that evaluates to a boolean or can be coerced to a boolean.
/// thenBranch: The expression to evaluate if the condition is true.
/// elseBranch: The expression to evaluate if the condition is false.
class TernaryExpressionNode extends ExpressionNode {
  final ExpressionNode condition;
  final ExpressionNode thenBranch;
  final ExpressionNode elseBranch;

  const TernaryExpressionNode({
    required this.condition,
    required this.thenBranch,
    required this.elseBranch,
  }) : super(ASTType.ternary);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'condition': condition.toJson(),
      'thenBranch': thenBranch.toJson(),
      'elseBranch': elseBranch.toJson(),
    };
  }

  @override
  List<Object?> get props => [condition, thenBranch, elseBranch];
}

/// Represents an assignment expression.
///
/// target: The target of the assignment. Can be either an identifier or an index expression.
/// value: The value to assign to the target.
/// operator: The assignment operator, e.g., "=".
class AssignmentExpressionNode extends ExpressionNode {
  final ExpressionNode target;
  final ExpressionNode value;
  final Token operator;

  const AssignmentExpressionNode({
    required this.target,
    required this.value,
    required this.operator,
  }) : super(ASTType.assignment);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'target': target.toJson(),
      'operator': operator.lexeme,
      'value': value.toJson(),
    };
  }

  @override
  List<Object?> get props => [target, value, operator];
}

/// Represents a binary expression.
///
/// left: The left-hand side of the binary expression.
/// right: The right-hand side of the binary expression.
/// operator: The binary operator, can be logical, arithmetic, or comparison, e.g., "+", "&&", "<".
class BinaryExpressionNode extends ExpressionNode {
  final ExpressionNode left;
  final ExpressionNode right;
  final Token operator;

  const BinaryExpressionNode({
    required this.left,
    required this.right,
    required this.operator,
  }) : super(ASTType.binary);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'left': left.toJson(),
      'right': right.toJson(),
      'operator': operator.lexeme,
    };
  }

  @override
  List<Object?> get props => [left, right, operator];
}

/// Represents a unary expression (postfix or prefix).
///
/// expression: The expression to apply the unary operator to.
/// operator: The unary operator, e.g., "!", "-", "++".
///
/// NOTE: It's common to refer prefix operators as unary operators. They are essentially the same thing.
class UnaryExpressionNode extends ExpressionNode {
  final ExpressionNode operand;
  final Token operator;

  const UnaryExpressionNode({required this.operand, required this.operator})
    : super(ASTType.unary);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'expression': operand.toJson(),
      'operator': operator.lexeme,
    };
  }

  @override
  List<Object?> get props => [operand, operator];
}

/// Represents an identifier access expression.
///
/// dot: Token representing the dot operator (used for error reporting).
/// name: The name of the identifier to access.
class MemberAccessExpressionNode extends ExpressionNode {
  final ExpressionNode object;
  final Token dot;
  final Token name;

  const MemberAccessExpressionNode({
    required this.object,
    required this.dot,
    required this.name,
  }) : super(ASTType.memberAccess);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'object': object.toJson(),
      'dot': dot.lexeme,
      'name': name.lexeme,
    };
  }

  @override
  List<Object?> get props => [object, dot, name];
}

/// Represents an index access expression.
///
/// bracket: Token representing the bracket operator (used for error reporting).
/// index: The index to access. Can be any expression that evaluates to an integer or can be coerced to an integer.
///
/// NOTE: The access index is zero-based.
class IndexAccessExpressionNode extends ExpressionNode {
  final ExpressionNode object;
  final Token bracket;
  final ExpressionNode index;

  const IndexAccessExpressionNode({
    required this.object,
    required this.bracket,
    required this.index,
  }) : super(ASTType.indexAccess);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'object': object.toJson(),
      'bracket': bracket.lexeme,
      'index': index.toJson(),
    };
  }

  @override
  List<Object?> get props => [object, bracket, index];
}

/// Represents a tuple access expression.
///
/// e.g. tuple.0, tuple.1, tuple.2, etc.
///
/// dot: Token representing the dot operator (used for error reporting).
/// index: The index to access. Can be any expression that evaluates to an integer or can be coerced to an integer.
///
/// NOTE: The access index is zero-based and generated up to a max length of 9.
class TupleAccessExpressionNode extends ExpressionNode {
  final ExpressionNode object;
  final Token dot;
  final Token index;

  const TupleAccessExpressionNode({
    required this.object,
    required this.dot,
    required this.index,
  }) : super(ASTType.tupleAccess);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'object': object.toJson(),
      'dot': dot.lexeme,
      'index': index.lexeme,
    };
  }

  @override
  List<Object?> get props => [object, dot, index];
}

/// Represents a call expression (function, method, constructor, or lambda call).
///
/// callee: The identifier or expression representing the function to call.
/// paren: Token representing the closing parenthesis (used for error reporting).
/// arguments: The arguments to pass to the function.
///
/// NOTE: The identifier can be a constructor, a function, a method, a closure, or a variable that holds a function.
class CallExpressionNode extends ExpressionNode {
  final ExpressionNode callee;
  final Token leftParen;
  final List<ExpressionNode> arguments;

  const CallExpressionNode({
    required this.callee,
    required this.leftParen,
    required this.arguments,
  }) : super(ASTType.call);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'callee': callee.toJson(),
      'leftParen': leftParen.lexeme,
      'arguments': arguments.map((arg) => arg.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [callee, arguments];
}

/// Represents an allocation expression.
///
/// allocateKeyword: The token representing the allocation keyword.
/// leftParen: Token representing the opening parenthesis (used for error reporting).
/// objectType: The type of the allocation.
class AllocationExpressionNode extends ExpressionNode {
  final Token allocateKeyword;
  final Token leftParen;
  final ExpressionNode constructor;

  const AllocationExpressionNode({
    required this.allocateKeyword,
    required this.leftParen,
    required this.constructor,
  }) : super(ASTType.allocation);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'allocateKeyword': allocateKeyword.lexeme,
      'leftParen': leftParen.lexeme,
      'constructor': constructor.toJson(),
    };
  }

  @override
  List<Object?> get props => [constructor];
}

/// Represents a deallocation expression.
///
/// e.g. deallocate(object)
///
/// deallocateKeyword: The token representing the deallocation keyword.
/// leftParen: Token representing the opening parenthesis (used for error reporting).
/// object: The object to deallocate.
class DeAllocationExpressionNode extends ExpressionNode {
  final Token deallocateKeyword;
  final Token leftParen;
  final ExpressionNode object;

  const DeAllocationExpressionNode({
    required this.deallocateKeyword,
    required this.leftParen,
    required this.object,
  }) : super(ASTType.deallocation);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'deallocateKeyword': deallocateKeyword.lexeme,
      'leftParen': leftParen.lexeme,
      'object': object.toJson(),
    };
  }

  @override
  List<Object?> get props => [object];
}

/// Represents a numeric literal.
///
/// value: The token representing the numeric literal.
class NumericLiteralNode extends ExpressionNode {
  final Token value;

  const NumericLiteralNode({required this.value})
    : super(ASTType.numericLiteral);

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'value': value.literal};
  }

  @override
  List<Object?> get props => [value];
}

/// Represents a string literal.
///
/// value: The token representing the string literal.
class StringLiteralNode extends ExpressionNode {
  final Token value;

  const StringLiteralNode({required this.value}) : super(ASTType.stringLiteral);

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'value': value.literal};
  }

  @override
  List<Object?> get props => [value];
}

/// Represents a string interpolation expression.
///
/// value: The token representing the string literal.
///
/// NOTE: This is a special case of a string literal where the string contains interpolated expressions.
class StringFragmentNode extends ExpressionNode {
  final Token value;

  const StringFragmentNode({required this.value})
    : super(ASTType.stringFragment);

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'value': value.literal};
  }

  @override
  List<Object?> get props => [value];
}

/// Represents a string interpolation expression.
///
/// fragments: The fragments that make up the string interpolation.
///
/// NOTE: A string interpolation is a string that contains expressions that are evaluated and concatenated to the string.
class StringInterpolationNode extends ExpressionNode {
  final List<ExpressionNode> fragments;

  const StringInterpolationNode({required this.fragments})
    : super(ASTType.stringInterpolation);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'fragments': fragments.map((fragment) => fragment.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [fragments];
}

/// Represents an array literal.
///
/// e.g. [1, 2, 3, 4, 5]
///
/// elements: The elements that make up the array.
/// leftBracket: Token representing the opening bracket (used for error reporting).
class ArrayLiteralNode extends ExpressionNode {
  final Token leftBracket;
  final List<ExpressionNode> elements;

  const ArrayLiteralNode({required this.leftBracket, required this.elements})
    : super(ASTType.arrayLiteral);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'leftBracket': leftBracket.lexeme,
      'elements': elements.map((element) => element.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [elements];
}

/// Represents a tuple literal.
///
/// e.g. {1, 2, 3, 4, 5}
///
/// elements: The elements that make up the tuple.
class TupleLiteralNode extends ExpressionNode {
  final Token leftParen;
  final List<ExpressionNode> elements;

  const TupleLiteralNode({required this.leftParen, required this.elements})
    : super(ASTType.tupleLiteral);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'elements': elements.map((element) => element.toJson()).toList(),
      'leftParen': leftParen.lexeme,
    };
  }

  @override
  List<Object?> get props => [elements];
}

/// Represents a grouping expression to manipulate precedence.
///
/// expression: The expression inside the grouping.
class GroupingExpressionNode extends ExpressionNode {
  final ExpressionNode expression;
  final Token leftParen;

  const GroupingExpressionNode({
    required this.expression,
    required this.leftParen,
  }) : super(ASTType.grouping);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'expression': expression.toJson(),
      'leftParen': leftParen.lexeme,
    };
  }

  @override
  List<Object?> get props => [expression];
}

/// Represents an identifier.
///
/// name: The token representing the identifier.
class IdentifierNode extends ExpressionNode {
  final Token name;

  const IdentifierNode({required this.name}) : super(ASTType.identifier);

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'name': name.lexeme};
  }

  @override
  List<Object?> get props => [name];
}
