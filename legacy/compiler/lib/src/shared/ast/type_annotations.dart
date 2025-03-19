// ignore_for_file: unintended_html_in_doc_comment

import 'package:compiler/src/shared/ast/definitions.dart';

import '../token_definitions.dart';

/// Represents a type annotation.
///
/// e.g. i32, i64, f32, f64, bool, String, etc.
///
/// NOTE: Includes support for template arguments and pointers.
///
/// name: The name of the type.
/// templateArguments: The type arguments of the type.
/// pointer: If the type is a pointer.
class TypeAnnotation {
  final Token name;
  final List<TypeAnnotation>? templateArguments;
  final Token? pointer;

  const TypeAnnotation({
    required this.name,
    this.templateArguments,
    this.pointer,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'TypeAnnotation',
      'name': name.lexeme,
      if (templateArguments != null)
        'templateArguments': templateArguments!.map((a) => a.toJson()).toList(),
      if (pointer != null) 'pointer': pointer!.lexeme,
    };
  }

  List<Object?> get props => [name, templateArguments, pointer];
}

/// Represents an array type annotation.
///
/// e.g. i32[10], i64[10], f32[10], f64[10], bool[10], String[10], etc.
///
/// name: The name of the type.
/// size: The size of the array.
/// templateArguments: The type arguments of the type.
/// pointer: If the type is a pointer.
class ArrayTypeAnnotation extends TypeAnnotation {
  final NumericLiteralNode size;

  const ArrayTypeAnnotation({
    required super.name,
    required this.size,
    super.templateArguments,
    super.pointer,
  });

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'ArrayTypeAnnotation',
      'name': name.lexeme,
      'size': size.toJson(),
      if (templateArguments != null)
        'templateArguments': templateArguments!.map((a) => a.toJson()).toList(),
      if (pointer != null) 'pointer': pointer!.lexeme,
    };
  }

  @override
  List<Object?> get props => [name, size, templateArguments, pointer];
}
