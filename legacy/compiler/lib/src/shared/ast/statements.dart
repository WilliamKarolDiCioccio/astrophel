import 'dart:convert';

import 'package:compiler/src/shared/ast/definitions.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../tokens/definitions.dart';

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

typedef MethodDeclarationNode = FunctionDeclarationNode;
typedef FieldDeclarationNode = MultiVariableDeclarationNode;
typedef ConstructorParameterNode = ParameterNode;
typedef FunctionParameterNode = ParameterNode;

/// Represents a module (the top-level AST node).
///
/// statements: A list of statements in the module.
///
/// NOTE: This is not represented in code but is used to wrap the generated AST.
class ModuleNode extends StatementNode {
  final List<StatementNode> statements;

  const ModuleNode({required this.statements}) : super(ASTType.module);

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
///
/// Can be used to import a module or a specific symbol from a module with an optional alias.
///
/// e.g. import src.core.math as math;
/// e.g. from src.core.math import add;
///
/// importKeyword: The "import" keyword.
/// path: The path to the module being imported.
/// alias: An optional alias for the imported module.
class ImportStatementNode extends StatementNode {
  final Token importKeyword;
  final List<String> mimePath;
  final Token? alias;

  const ImportStatementNode({
    required this.importKeyword,
    required this.mimePath,
    required this.alias,
  }) : super(ASTType.importStatement);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'importKeyword': importKeyword.lexeme,
      'mimePath': mimePath,
      if (alias != null) 'alias': alias!.lexeme,
    };
  }

  @override
  List<Object?> get props => [mimePath, alias];
}

/// Represents a symbol import.
///
/// e.g. ... additions as add ... ;
class SymbolImport extends StatementNode {
  final IdentifierNode name;
  final Token? alias;

  const SymbolImport({required this.name, this.alias})
    : super(ASTType.symbolImport);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'name': name.toJson(),
      if (alias != null) 'alias': alias!.lexeme,
    };
  }

  @override
  List<Object?> get props => [name, alias];
}

/// Represents a symbol import statement.
///
/// e.g. from src.core.math import additions as add, subtraction as sub;
///
/// fromKeyword: The "from" keyword.
/// mimePath: The path to the module being imported.
/// symbols: A list of symbols being imported.
/// alias: An optional alias for the imported module.
final class SymbolWiseImportStatementNode extends StatementNode {
  final Token fromKeyword;
  final List<String> mimePath;
  final Token importKeyword;
  final List<SymbolImport> symbolImports;

  const SymbolWiseImportStatementNode({
    required this.fromKeyword,
    required this.mimePath,
    required this.importKeyword,
    required this.symbolImports,
  }) : super(ASTType.symbolWiseImportStatement);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'fromKeyword': fromKeyword.lexeme,
      'mimePath': mimePath,
      'importKeyword': importKeyword.lexeme,
      'symbolImports': symbolImports.map((s) => s.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [mimePath, symbolImports];
}

/// Represents an export statement.
///
/// Can be used to re-export a module or a specific symbol from a module.
///
/// e.g. export src.core.math;
///
/// exportKeyword: The "export" keyword.
/// mimePath: The path to the module being exported.
class ExportStatementNode extends StatementNode {
  final Token exportKeyword;
  final List<IdentifierNode> mimePath;

  const ExportStatementNode({
    required this.exportKeyword,
    required this.mimePath,
  }) : super(ASTType.exportStatement);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'exportKeyword': exportKeyword.lexeme,
      'mimePath': mimePath.map((p) => p.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [exportKeyword, mimePath];
}

/// Represents an interface declaration.
///
/// e.g. interface Shape {
///  i32 area(i32 a, i32 b);
/// }
///
/// interfaceKeyword: The "interface" keyword.
/// name: The name of the interface.
/// methods: A list of methods in the interface.
class InterfaceDeclarationNode extends StatementNode {
  final Token interfaceKeyword;
  final IdentifierNode name;
  final List<MethodDeclarationNode> methods;

  const InterfaceDeclarationNode({
    required this.interfaceKeyword,
    required this.name,
    required this.methods,
  }) : super(ASTType.interfaceDeclaration);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'interfaceKeyword': interfaceKeyword.lexeme,
      'name': name.toJson(),
      'methods': methods.map((m) => m.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [name, methods];
}

/// Represents an interface implementation for a class.
///
/// e.g. implements Shape for Square {
///  i32 area(i32 a, i32 b) {
///   return a * b;
/// }
/// }
///
/// implementsKeyword: The "implements" keyword.
/// interfaceName: The name of the interface being implemented.
/// forKeyword: The "for" keyword.
/// className: The name of the class implementing the interface.
/// methods: A list of methods in the interface implementation.
class InterfaceImplementationNode extends StatementNode {
  final Token implementsKeyword;
  final IdentifierNode interfaceName;
  final Token forKeyword;
  final IdentifierNode className;
  final List<MethodDeclarationNode> methods;

  const InterfaceImplementationNode({
    required this.implementsKeyword,
    required this.interfaceName,
    required this.forKeyword,
    required this.className,
    required this.methods,
  }) : super(ASTType.interfaceImplementation);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'implementsKeyword': implementsKeyword.lexeme,
      'interfaceName': interfaceName.toJson(),
      'forKeyword': forKeyword.lexeme,
      'className': className.toJson(),
      'methods': methods.map((m) => m.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [interfaceName, className, methods];
}

/// Represents a class declaration.
///
/// e.g.
///
/// class Square {
///   i32 x;
///   i32 y;
///
///   constructor(this.x, this.y) {}
///
///   i32 area(i32 a, i32 b) {
///     return a * b;
///   }
/// }
///
/// classKeyword: The "class" keyword.
/// name: The name of the class.
/// constructor: An optional constructor for the class.
/// fields: A list of fields in the class.
/// methods: A list of methods in the class.
class ClassDeclarationNode extends StatementNode {
  final MetaAnnotations? metaAnnotations;
  final Template? template;
  final Token? partialKeyword;
  final Token classKeyword;
  final IdentifierNode name;
  final ConstructorDeclarationNode? constructor;
  final DestructorDeclarationNode? destructor;
  final List<FieldDeclarationNode> fields;
  final List<MethodDeclarationNode> methods;
  final List<UnionDeclarationNode> unions;

  const ClassDeclarationNode({
    required this.metaAnnotations,
    required this.template,
    required this.partialKeyword,
    required this.classKeyword,
    required this.name,
    required this.constructor,
    required this.destructor,
    required this.fields,
    required this.methods,
    required this.unions,
  }) : super(ASTType.constructorDeclaration);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      if (metaAnnotations != null) 'metaAnnotations': metaAnnotations!.toJson(),
      if (template != null) 'template': template!.toJson(),
      if (partialKeyword != null) 'partialKeyword': partialKeyword!.lexeme,
      'classKeyword': classKeyword.lexeme,
      'name': name.toJson(),
      if (constructor != null) 'constructor': constructor!.toJson(),
      if (destructor != null) 'destructor': destructor!.toJson(),
      'fields': fields.map((f) => f.toJson()).toList(),
      'methods': methods.map((m) => m.toJson()).toList(),
      'unions': unions.map((u) => u.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    metaAnnotations,
    template,
    name,
    constructor,
    destructor,
    fields,
    methods,
    unions,
  ];
}

/// Represents a struct declaration.
///
/// e.g.
///
/// struct Point {
///   i32 x;
///   i32 y;
///
///   constructor(this.x, this.y) {}
/// }
///
/// structKeyword: The "struct" keyword.
/// name: The name of the struct.
/// fields: A list of fields in the struct.
/// constructor: An optional constructor for the struct.
class StructDeclarationNode extends StatementNode {
  final MetaAnnotations? metaAnnotations;
  final Template? template;
  final Token structKeyword;
  final IdentifierNode name;
  final ConstructorDeclarationNode? constructor;
  final DestructorDeclarationNode? destructor;
  final List<FieldDeclarationNode> fields;
  final List<UnionDeclarationNode> unions;

  const StructDeclarationNode({
    required this.metaAnnotations,
    required this.template,
    required this.structKeyword,
    required this.name,
    required this.constructor,
    required this.destructor,
    required this.fields,
    required this.unions,
  }) : super(ASTType.structDeclaration);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      if (metaAnnotations != null) 'metaAnnotations': metaAnnotations!.toJson(),
      if (template != null) 'template': template!.toJson(),
      'structKeyword': structKeyword.lexeme,
      'name': name.toJson(),
      if (constructor != null) 'constructor': constructor!.toJson(),
      if (destructor != null) 'destructor': destructor!.toJson(),
      'fields': fields.map((f) => f.toJson()).toList(),
      'unions': unions.map((u) => u.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    metaAnnotations,
    template,
    structKeyword,
    name,
    constructor,
    destructor,
    fields,
    unions,
  ];
}

/// Represents a union declaration.
///
/// e.g. union {
///  i32 x, r;
/// }
///
/// metaAnnotations: A list of meta annotations for the union.
/// unionKeyword: The "union" keyword.
/// fields: A list of fields in the union.
class UnionDeclarationNode extends StatementNode {
  final Token unionKeyword;
  final List<FieldDeclarationNode> fields;

  const UnionDeclarationNode({required this.unionKeyword, required this.fields})
    : super(ASTType.unionDeclaration);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'unionKeyword': unionKeyword.lexeme,
      'fields': fields.map((f) => f.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [unionKeyword, fields];
}

/// Represents a constructor declaration for a class or struct.
///
/// e.g. constructor(String label) : x = 0, y = 0 : {}
///
/// constructorKeyword: The "constructor" keyword.
/// parameters: A list of constructor parameters.
/// initializers: A list of field initializers.
/// body: The body of the constructor.
class ConstructorDeclarationNode extends StatementNode {
  final MetaAnnotations? metaAnnotations;
  final Token constructorKeyword;
  final List<ConstructorParameterNode> parameters;
  final List<AssignmentExpressionNode> initializers;
  final BlockStatementNode body;

  const ConstructorDeclarationNode({
    required this.metaAnnotations,
    required this.constructorKeyword,
    required this.initializers,
    required this.parameters,
    required this.body,
  }) : super(ASTType.constructorDeclaration);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      if (metaAnnotations != null) 'metaAnnotations': metaAnnotations!.toJson(),
      'constructorKeyword': constructorKeyword.lexeme,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'initializers': initializers.map((i) => i.toJson()).toList(),
      'body': body.toJson(),
    };
  }

  @override
  List<Object?> get props => [parameters, initializers, body];
}

/// Represents a destructor declaration for a class or struct.
///
/// e.g. destructor() {}
///
/// destructorKeyword: The "destructor" keyword.
/// body: The body of the destructor.
class DestructorDeclarationNode extends StatementNode {
  final MetaAnnotations? metaAnnotations;
  final Token destructorKeyword;
  final BlockStatementNode body;

  const DestructorDeclarationNode({
    required this.metaAnnotations,
    required this.destructorKeyword,
    required this.body,
  }) : super(ASTType.destructorDeclaration);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      if (metaAnnotations != null) 'metaAnnotations': metaAnnotations!.toJson(),
      'destructorKeyword': destructorKeyword.lexeme,
      'body': body.toJson(),
    };
  }

  @override
  List<Object?> get props => [body];
}

/// Represents a function declaration.
///
/// e.g. global async func add(i32 a, i32 b = 0) -> i32 { return a + b; }
///
/// annotations: A list of annotations for the function.
/// storageSpecifier: The storage specifier (global, local, etc.).
/// executionModelSpecifier: The execution model specifier (async, sync, etc.).
/// functionKeyword: The "func" keyword.
/// name: The name of the function.
/// parameters: A list of function parameters.
/// returnType: The return type of the function.
/// body: The body of the function.
class FunctionDeclarationNode extends StatementNode {
  final MetaAnnotations? metaAnnotations;
  final Template? template;
  final Token? storageSpecifier;
  final Token? executionModelSpecifier;
  final Token functionKeyword;
  final IdentifierNode name;
  final List<ParameterNode> parameters;
  final TypeAnnotation? returnType;
  final BlockStatementNode body;

  const FunctionDeclarationNode({
    required this.metaAnnotations,
    required this.template,
    required this.storageSpecifier,
    required this.executionModelSpecifier,
    required this.functionKeyword,
    required this.name,
    required this.parameters,
    required this.returnType,
    required this.body,
  }) : super(ASTType.functionDeclaration);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      if (metaAnnotations != null) 'metaAnnotations': metaAnnotations!.toJson(),
      if (template != null) 'template': template!.toJson(),
      if (storageSpecifier != null)
        'storageSpecifier': storageSpecifier!.lexeme,
      if (executionModelSpecifier != null)
        'executionModelSpecifier': executionModelSpecifier!.lexeme,
      'functionKeyword': functionKeyword.lexeme,
      'name': name.toJson(),
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'returnType': returnType?.toJson(),
      'body': body.toJson(),
    };
  }

  @override
  List<Object?> get props => [
    metaAnnotations,
    template,
    storageSpecifier,
    executionModelSpecifier,
    name,
    parameters,
    returnType,
    body,
  ];
}

/// Represents a variable declaration.
///
/// e.g. var x = 5;
/// e.g. let y: int;
/// e.g. const z = 3.14;
///
/// storageSpecifier: The storage specifier (var, let, const).
/// mutabilitySpecifier: The mutability specifier (constexpr, lateconst, const, latevar, var).
/// typeAnnotation: The type annotation (e.g., i32, f64).
/// nameInitializerPairs: A list of name-initializer pairs (allowing multiple declarations).
class MultiVariableDeclarationNode extends StatementNode {
  final Token? storageSpecifier;
  final Token? mutabilitySpecifier;
  final TypeAnnotation? typeAnnotation;
  final List<(IdentifierNode, ExpressionNode?)> nameInitializerPairs;

  const MultiVariableDeclarationNode({
    required this.storageSpecifier,
    required this.mutabilitySpecifier,
    required this.typeAnnotation,
    required this.nameInitializerPairs,
  }) : super(ASTType.variableDeclaration);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      if (storageSpecifier != null)
        'storageSpecifier': storageSpecifier!.lexeme,
      if (mutabilitySpecifier != null)
        'mutabilitySpecifier': mutabilitySpecifier!.lexeme,
      if (typeAnnotation != null) 'typeAnnotation': typeAnnotation!.toJson(),
      'nameInitializerPairs':
          nameInitializerPairs.map((pair) {
            return {
              'name': pair.$1.toJson(),
              if (pair.$2 != null) 'initializer': pair.$2!.toJson(),
            };
          }).toList(),
    };
  }

  @override
  List<Object?> get props => [
    storageSpecifier,
    mutabilitySpecifier,
    typeAnnotation,
    nameInitializerPairs,
  ];
}

/// Represents an enum declaration.
///
/// e.g. enum Color {
///  RED = 0,
///  GREEN = 1,
///  BLUE = 2
/// }
///
/// enumKeyword: The "enum" keyword.
/// name: The name of the enum.
/// variants: A list of enum variants.
class EnumDeclarationNode extends StatementNode {
  final Token enumKeyword;
  final IdentifierNode name;
  final List<EnumVariantNode> variants;

  const EnumDeclarationNode({
    required this.enumKeyword,
    required this.name,
    required this.variants,
  }) : super(ASTType.enumDeclaration);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'enumKeyword': enumKeyword.lexeme,
      'name': name.toJson(),
      'variants': variants.map((v) => v.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [name, variants];
}

/// Represents an enum variant.
class EnumVariantNode extends StatementNode {
  final IdentifierNode name;
  final ExpressionNode? value;

  const EnumVariantNode({required this.name, this.value})
    : super(ASTType.enumVariant);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'name': name.toJson(),
      if (value != null) 'value': value!.toJson(),
    };
  }

  @override
  List<Object?> get props => [name, value];
}

/// Represents an if statement (with an optional else branch).
class IfStatementNode extends StatementNode {
  final Token ifKeyword;
  final ExpressionNode condition;
  final StatementNode thenBranch;
  final StatementNode? elseBranch;

  const IfStatementNode({
    required this.ifKeyword,
    required this.condition,
    required this.thenBranch,
    required this.elseBranch,
  }) : super(ASTType.ifStatement);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'condition': condition.toJson(),
      'thenBranch': thenBranch.toJson(),
      if (elseBranch != null) 'elseBranch': elseBranch!.toJson(),
    };
  }

  @override
  List<Object?> get props => [condition, thenBranch, elseBranch];
}

/// Represents an else statement.
class ElseStatementNode extends StatementNode {
  final Token elseKeyword;
  final StatementNode branch;

  const ElseStatementNode({required this.elseKeyword, required this.branch})
    : super(ASTType.elseStatement);

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'branch': branch.toJson()};
  }

  @override
  List<Object?> get props => [branch];
}

/// Represents an else-if statement.
class ElseIfStatementNode extends StatementNode {
  final Token ifKeyword;
  final Token elseKeyword;
  final ExpressionNode condition;
  final StatementNode thenBranch;
  final StatementNode? elseBranch;

  const ElseIfStatementNode({
    required this.ifKeyword,
    required this.elseKeyword,
    required this.condition,
    required this.thenBranch,
    required this.elseBranch,
  }) : super(ASTType.elseIfStatement);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'condition': condition.toJson(),
      'thenBranch': thenBranch.toJson(),
      if (elseBranch != null) 'elseBranch': elseBranch!.toJson(),
    };
  }

  @override
  List<Object?> get props => [condition, thenBranch, elseBranch];
}

/// Represents a switch statement.
class SwitchStatementNode extends StatementNode {
  final Token switchKeyword;
  final ExpressionNode expression;
  final List<CaseOrDefaultStatementNode> cases;

  const SwitchStatementNode({
    required this.switchKeyword,
    required this.expression,
    required this.cases,
  }) : super(ASTType.switchStatement);

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
///
/// e.g. case 1: print('one');
/// e.g. default: print('default');
///
/// caseKeyword: The "case" or "default" keyword.
/// expression: The case expression (if any).
/// body: The body of the case statement.
class CaseOrDefaultStatementNode extends StatementNode {
  final Token caseKeyword;
  final ExpressionNode? expression;
  final BlockStatementNode? body;

  const CaseOrDefaultStatementNode({
    required this.caseKeyword,
    required this.expression,
    required this.body,
  }) : super(ASTType.caseStatement);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'caseKeyword': caseKeyword.lexeme,
      if (expression != null) 'expression': expression!.toJson(),
      if (body != null) 'body': body!.toJson(),
    };
  }

  @override
  List<Object?> get props => [expression, body];
}

/// Represents a while loop.
///
/// e.g. while (i < 10) { print(i); i++; }
///
/// condition: The loop condition.
/// body: The body of the loop.
class WhileStatementNode extends StatementNode {
  final Token whileKeyword;
  final ExpressionNode condition;
  final StatementNode body;

  const WhileStatementNode({
    required this.whileKeyword,
    required this.condition,
    required this.body,
  }) : super(ASTType.whileStatement);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'whileKeyword': whileKeyword.lexeme,
      'condition': condition.toJson(),
      'body': body.toJson(),
    };
  }

  @override
  List<Object?> get props => [condition, body];
}

/// Represents a do-while loop.
///
/// e.g. do { print(i); i++; } while (i < 10);
///
/// condition: The loop condition.
/// body: The body of the loop.
class DoWhileStatementNode extends StatementNode {
  final Token doKeyword;
  final ExpressionNode condition;
  final StatementNode body;

  const DoWhileStatementNode({
    required this.doKeyword,
    required this.condition,
    required this.body,
  }) : super(ASTType.doWhileStatement);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'doKeyword': doKeyword.lexeme,
      'body': body.toJson(),
      'condition': condition.toJson(),
    };
  }

  @override
  List<Object?> get props => [body, condition];
}

/// Represents a for loop.
///
/// e.g. for (var i = 0; i < 10; i++) { print(i); }
///
/// initializer: The initialization statement.
/// condition: The loop condition.
/// increment: The increment statement.
/// body: The body of the loop.
class ForStatementNode extends StatementNode {
  final Token forKeyword;
  final StatementNode? counterInitializer;
  final ExpressionNode? condition;
  final ExpressionNode? increment;
  final StatementNode body;

  const ForStatementNode({
    required this.forKeyword,
    required this.counterInitializer,
    required this.condition,
    required this.increment,
    required this.body,
  }) : super(ASTType.forStatement);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'forKeyword': forKeyword.lexeme,
      'body': body.toJson(),
      if (counterInitializer != null)
        'counterInitializer': counterInitializer!.toJson(),
      if (condition != null) 'condition': condition!.toJson(),
      if (increment != null) 'increment': increment!.toJson(),
    };
  }

  @override
  List<Object?> get props => [counterInitializer, condition, increment, body];
}

/// Represents a break statement.
class BreakStatementNode extends StatementNode {
  final Token breakKeyword;

  const BreakStatementNode({required this.breakKeyword})
    : super(ASTType.breakStatement);

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'breakKeyword': breakKeyword.lexeme};
  }

  @override
  List<Object?> get props => [];
}

/// Represents a continue statement.
class ContinueStatementNode extends StatementNode {
  final Token continueKeyword;

  const ContinueStatementNode({required this.continueKeyword})
    : super(ASTType.continueStatement);

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'continueKeyword': continueKeyword.lexeme};
  }

  @override
  List<Object?> get props => [];
}

/// Represents a return statement.
///
/// e.g. return 42;
/// e.g. return;
///
/// returnKeyword: The "return" keyword.
/// value: An optional return value.
class ReturnStatementNode extends StatementNode {
  final Token returnKeyword;
  final ExpressionNode? expression;

  const ReturnStatementNode({required this.returnKeyword, this.expression})
    : super(ASTType.returnStatement);

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = {
      'type': type.toString(),
      'returnKeyword': returnKeyword.lexeme,
    };
    if (expression != null) {
      json['expression'] = expression!.toJson();
    }
    return json;
  }

  @override
  List<Object?> get props => [expression];
}

/// Represents a function parameter.
class ParameterNode extends ExpressionNode {
  final TypeAnnotation typeAnnotation;
  final IdentifierNode name;
  final ExpressionNode? defaultValue;

  const ParameterNode({
    required this.typeAnnotation,
    required this.name,
    required this.defaultValue,
  }) : super(ASTType.parameter);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'name': name.toJson(),
      'typeAnnotation': typeAnnotation.toJson(),
      if (defaultValue != null) 'defaultValue': defaultValue!.toJson(),
    };
  }

  @override
  List<Object?> get props => [name, typeAnnotation, defaultValue];
}

/// Represents a block of statements.
///
/// statements: A list of statements in the block.
class BlockStatementNode extends StatementNode {
  final List<StatementNode> statements = [];

  BlockStatementNode() : super(ASTType.blockStatement);

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
  final ExpressionNode expression;

  const ExpressionStatementNode({required this.expression})
    : super(ASTType.expressionStatement);

  @override
  Map<String, dynamic> toJson() {
    return {'type': type.toString(), 'expression': expression.toJson()};
  }

  @override
  List<Object?> get props => [expression];
}
