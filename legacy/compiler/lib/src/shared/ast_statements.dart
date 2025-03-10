import 'ast_definitions.dart';
import 'token_definitions.dart';

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
}

/// Represents an import statement.
interface class ImportStatementNode extends StatementNode {
  static const ASTType type = ASTType.importStatement;
  final Token importKeyword;
  final StringLiteralNode path;
  final Token? alias; // Optional alias (e.g., import "foo" as bar)

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
}

/// Represents an export statement.
interface class ExportStatementNode extends StatementNode {
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
}

/// Represents a variable declaration.
interface class VariableDeclarationNode extends StatementNode {
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
}

/// Represents a function declaration.
interface class FunctionDeclarationNode extends StatementNode {
  static const ASTType type = ASTType.functionDeclaration;
  final Token functionKeyword;
  final IdentifierNode name;
  final List<ParameterNode> parameters;
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
}

/// Represents a function parameter.
interface class ParameterNode extends StatementNode {
  static const ASTType type = ASTType.parameter;
  final IdentifierNode name;
  final Token? typeAnnotation;

  ParameterNode({required this.name, this.typeAnnotation});

  @override
  Map<String, dynamic> toJson() {
    final json = {'type': type.toString(), 'name': name.toJson()};
    if (typeAnnotation != null) {
      json['typeAnnotation'] = typeAnnotation!.toJson();
    }
    return json;
  }
}

/// Represents an if statement (with an optional else branch).
interface class IfStatementNode extends StatementNode {
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
}

/// Represents an else statement (if you want to represent it separately).
interface class ElseStatementNode extends StatementNode {
  static const ASTType type = ASTType.elseStatement;
  final StatementNode branch;

  ElseStatementNode({required this.branch});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'branch': branch.toJson()};
  }
}

/// Represents a switch statement.
interface class SwitchStatementNode extends StatementNode {
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
}

/// Represents a case (or default) within a switch statement.
interface class SwitchCaseNode extends StatementNode {
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
}

/// Represents a while loop.
interface class WhileStatementNode extends StatementNode {
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
}

/// Represents a for loop.
interface class ForStatementNode extends StatementNode {
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
}

/// Represents a return statement.
interface class ReturnStatementNode extends StatementNode {
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
}

/// Represents a block of statements.
interface class BlockNode extends StatementNode {
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
}

/// Represents an expression used as a statement.
interface class ExpressionStatementNode extends StatementNode {
  static const ASTType type = ASTType.expressionStatement;
  final ExpressionNode expression;

  ExpressionStatementNode({required this.expression});

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'expression': expression.toJson()};
  }
}
