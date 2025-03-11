import 'ast_definitions.dart';
import 'token_definitions.dart';

/// Represents a module (the top-level AST node).
class ModuleNode extends StatementNode {
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

  @override
  List<Object?> get props => [statements];
}

/// Represents an import statement.
class ImportStatementNode extends StatementNode {
  static const ASTType type = ASTType.importStatement;
  final Token importKeyword;
  final StringLiteralNode path;
  final Token? alias;

  ImportStatementNode({
    required this.importKeyword,
    required this.path,
    this.alias,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'importKeyword': importKeyword.lexeme,
      'path': path.toJson(),
      if (alias != null) 'alias': alias!.lexeme,
    };
  }

  @override
  List<Object?> get props => [importKeyword, path, alias];
}

/// Represents an export statement.
class ExportStatementNode extends StatementNode {
  static const ASTType type = ASTType.exportStatement;
  final Token exportKeyword;
  final StringLiteralNode path;

  ExportStatementNode({required this.exportKeyword, required this.path});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'exportKeyword': exportKeyword.lexeme,
      'path': path.toJson(),
    };
  }

  @override
  List<Object?> get props => [exportKeyword, path];
}

/// Represents a variable declaration.
class VariableDeclarationNode extends StatementNode {
  static const ASTType type = ASTType.variableDeclaration;
  final Token keyword; // e.g., "var", "let", or a type keyword
  final IdentifierNode name;
  final ExpressionNode? initializer;

  VariableDeclarationNode({
    required this.keyword,
    required this.name,
    this.initializer,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = {
      'type': type.toString(),
      'keyword': keyword.lexeme,
      'name': name.toJson(),
    };
    if (initializer != null) {
      json['initializer'] = initializer!.toJson();
    }
    return json;
  }

  @override
  List<Object?> get props => [keyword, name, initializer];
}

/// Represents a function declaration.
class FunctionDeclarationNode extends StatementNode {
  static const ASTType type = ASTType.functionDeclaration;
  final Token functionKeyword;
  final IdentifierNode name;
  final List<FunctionParameterNode> parameters;
  final BlockNode body;

  FunctionDeclarationNode({
    required this.functionKeyword,
    required this.name,
    required this.parameters,
    required this.body,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'functionKeyword': functionKeyword.lexeme,
      'name': name.toJson(),
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'body': body.toJson(),
    };
  }

  @override
  List<Object?> get props => [functionKeyword, name, parameters, body];
}

/// Represents a function parameter.
class FunctionParameterNode extends StatementNode {
  static const ASTType type = ASTType.functionParameter;
  final IdentifierNode name;
  final Token? typeAnnotation;

  FunctionParameterNode({required this.name, this.typeAnnotation});

  @override
  Map<String, dynamic> toJson() {
    final json = {'type': type.toString(), 'name': name.toJson()};
    if (typeAnnotation != null) {
      json['typeAnnotation'] = typeAnnotation!.toJson();
    }
    return json;
  }

  @override
  List<Object?> get props => [name, typeAnnotation];
}

/// Represents an if statement (with an optional else branch).
class IfStatementNode extends StatementNode {
  static const ASTType type = ASTType.ifStatement;
  final ExpressionNode condition;
  final StatementNode thenBranch;
  final StatementNode? elseBranch;

  IfStatementNode({
    required this.condition,
    required this.thenBranch,
    this.elseBranch,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = {
      'type': type.toString(),
      'condition': condition.toJson(),
      'thenBranch': thenBranch.toJson(),
    };
    if (elseBranch != null) {
      json['elseBranch'] = elseBranch!.toJson();
    }
    return json;
  }

  @override
  List<Object?> get props => [condition, thenBranch, elseBranch];
}

/// Represents an else statement (if you want to represent it separately).
class ElseStatementNode extends StatementNode {
  static const ASTType type = ASTType.elseStatement;
  final StatementNode branch;

  ElseStatementNode({required this.branch});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'branch': branch.toJson()};
  }

  @override
  List<Object?> get props => [branch];
}

/// Represents a switch statement.
class SwitchStatementNode extends StatementNode {
  static const ASTType type = ASTType.switchStatement;
  final ExpressionNode expression;
  final List<SwitchCaseNode> cases;

  SwitchStatementNode({required this.expression, required this.cases});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'expression': expression.toJson(),
      'cases': cases.map((c) => c.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [expression, cases];
}

/// Represents a case (or default) within a switch statement.
class SwitchCaseNode extends StatementNode {
  final ExpressionNode? caseExpression; // null indicates the default case
  final List<StatementNode> statements;

  SwitchCaseNode({this.caseExpression, required this.statements});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'statements': statements.map((s) => s.toJson()).toList(),
    };
    if (caseExpression != null) {
      json['case'] = caseExpression!.toJson();
    } else {
      json['default'] = true;
    }
    return json;
  }

  @override
  List<Object?> get props => [caseExpression, statements];
}

/// Represents a while loop.
class WhileStatementNode extends StatementNode {
  static const ASTType type = ASTType.whileStatement;
  final ExpressionNode condition;
  final StatementNode body;

  WhileStatementNode({required this.condition, required this.body});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'condition': condition.toJson(),
      'body': body.toJson(),
    };
  }

  @override
  List<Object?> get props => [condition, body];
}

/// Represents a for loop.
class ForStatementNode extends StatementNode {
  static const ASTType type = ASTType.forStatement;
  final StatementNode? initializer; // e.g., variable declaration or expression
  final ExpressionNode? condition;
  final ExpressionNode? increment;
  final StatementNode body;

  ForStatementNode({
    this.initializer,
    this.condition,
    this.increment,
    required this.body,
  });

  @override
  Map<String, dynamic> toJson() {
    final json = {'type': type.toString(), 'body': body.toJson()};
    if (initializer != null) {
      json['initializer'] = initializer!.toJson();
    }
    if (condition != null) {
      json['condition'] = condition!.toJson();
    }
    if (increment != null) {
      json['increment'] = increment!.toJson();
    }
    return json;
  }

  @override
  List<Object?> get props => [initializer, condition, increment, body];
}

/// Represents a return statement.
class ReturnStatementNode extends StatementNode {
  static const ASTType type = ASTType.returnStatement;
  final Token returnKeyword;
  final ExpressionNode? value;

  ReturnStatementNode({required this.returnKeyword, this.value});

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': type.toString(),
      'returnKeyword': returnKeyword.lexeme,
    };
    if (value != null) {
      json['value'] = value!.toJson();
    }
    return json;
  }

  @override
  List<Object?> get props => [returnKeyword, value];
}

/// Represents a block of statements.
class BlockNode extends StatementNode {
  static const ASTType type = ASTType.block;
  final List<StatementNode> statements;

  BlockNode({required this.statements});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'statements': statements.map((stmt) => stmt.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [statements];
}

/// Represents an expression used as a statement.
class ExpressionStatementNode extends StatementNode {
  static const ASTType type = ASTType.expressionStatement;
  final ExpressionNode expression;

  ExpressionStatementNode({required this.expression});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'expression': expression.toJson()};
  }

  @override
  List<Object?> get props => [expression];
}
