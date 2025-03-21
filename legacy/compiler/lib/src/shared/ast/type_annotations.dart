// ignore_for_file: unintended_html_in_doc_comment

import 'package:compiler/src/shared/ast/definitions.dart';

import '../tokens/definitions.dart';

/// Base class for type annotations.
class TypeAnnotation {
  final ASTType type;

  const TypeAnnotation(this.type);

  Map<String, dynamic> toJson() {
    return {'type': type.toString()};
  }

  List<Object?> get props => [];
}

/// Represents an atomic type annotation.
///
/// e.g. i32, i64, f32, f64, bool, String, etc.
///
/// name: The name of the type.
/// templateArguments: The type arguments of the type.
/// pointer: If the type is a pointer.
///
/// NOTE: Includes support for template arguments and pointers.
class AtomicTypeAnnotation extends TypeAnnotation {
  final Token? name;
  final List<TypeAnnotation>? templateArguments;
  final Token? pointer;

  const AtomicTypeAnnotation({this.name, this.templateArguments, this.pointer})
    : super(ASTType.atomicTypeAnnotation);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      if (name != null) 'name': name!.lexeme,
      if (templateArguments != null)
        'templateArguments': templateArguments!.map((a) => a.toJson()).toList(),
      if (pointer != null) 'pointer': pointer!.lexeme,
    };
  }

  @override
  List<Object?> get props => [name, templateArguments, pointer];
}

/// Represents an array type annotation.
///
/// e.g. i32[10], i64[10], f32[10], f64[10], bool[10], String[10], etc.
///
/// size: The size of the array.
class ArrayTypeAnnotation extends TypeAnnotation {
  final Token leftBracket;
  final AtomicTypeAnnotation? name;
  final NumericLiteralNode size;

  const ArrayTypeAnnotation({
    required this.leftBracket,
    required this.name,
    required this.size,
  }) : super(ASTType.arrayTypeAnnotation);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'name': name!.toJson(),
      'leftBracket': leftBracket.lexeme,
      'size': size.toJson(),
    };
  }

  @override
  List<Object?> get props => [name, size];
}

/// Tuple type annotation.
///
/// e.g. {i32, i64}, {f32, f64}, {bool, String}, etc.
///
/// elements: The elements of the tuple.
class TupleTypeAnnotation extends TypeAnnotation {
  final Token leftParen;
  final List<TypeAnnotation> elements;
  final Token? pointer;

  const TupleTypeAnnotation({
    required this.leftParen,
    required this.elements,
    this.pointer,
  }) : super(ASTType.tupleTypeAnnotation);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'leftParen': leftParen.lexeme,
      'elements': elements.map((e) => e.toJson()).toList(),
      if (pointer != null) 'pointer': pointer!.lexeme,
    };
  }

  @override
  List<Object?> get props => [elements, pointer];
}

/// Represents a function type annotation.
///
/// e.g. (i32, i32) -> i32, (i64, i64) -> i64, etc.
///
/// leftParen: The left parenthesis (used for error reporting).
/// parameters: The parameters of the function.
/// returnType: The return type of the function.
class FunctionTypeAnnotation extends TypeAnnotation {
  final Token leftParen;
  final List<TypeAnnotation> parameters;
  final TypeAnnotation returnType;

  const FunctionTypeAnnotation({
    required this.leftParen,
    required this.parameters,
    required this.returnType,
  }) : super(ASTType.functionTypeAnnotation);

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'leftParen': leftParen.lexeme,
      'parameters': parameters.map((p) => p.toJson()).toList(),
      'returnType': returnType.toJson(),
    };
  }

  @override
  List<Object?> get props => [parameters, returnType];
}
