// ignore_for_file: unintended_html_in_doc_comment

import 'package:compiler/src/shared/ast/definitions.dart';

import '../token_definitions.dart';

/// Base class for type annotations.
class TypeAnnotation {
  const TypeAnnotation();

  Map<String, dynamic> toJson() {
    return {'type': 'TypeAnnotation'};
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

  const AtomicTypeAnnotation({this.name, this.templateArguments, this.pointer});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'AtomicTypeAnnotation',
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
  final AtomicTypeAnnotation? name;
  final NumericLiteralNode size;

  const ArrayTypeAnnotation({required this.name, required this.size});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'ArrayTypeAnnotation',
      'name': name!.toJson(),
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
  final List<TypeAnnotation> elements;
  final Token? pointer;

  const TupleTypeAnnotation({required this.elements, this.pointer});

  @override
  Map<String, dynamic> toJson() {
    return {
      'type': 'TupleTypeAnnotation',
      'elements': elements.map((e) => e.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [elements];
}
