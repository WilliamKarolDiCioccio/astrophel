// ignore_for_file: unintended_html_in_doc_comment

import '../token_definitions.dart';

/// Represents a type annotation.
///
/// e.g. i32, i64, f32, f64, bool, String, etc.
///
/// Includes support for generics.
///
/// e.g. List<String>, List<int>, List<T>, etc.
///
/// name: The name of the type.
/// genericArguments: The type arguments of the type.
class TypeAnnotation {
  final Token name;
  final List<Token>? genericArguments;
  final Token? pointer;

  const TypeAnnotation({
    required this.name,
    this.genericArguments,
    this.pointer,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': 'TypeAnnotation',
      'name': name.lexeme,
      if (genericArguments != null)
        'genericArguments': genericArguments!.map((a) => a.toJson()).toList(),
      if (pointer != null) 'pointer': pointer!.lexeme,
    };
  }

  List<Object?> get props => [name, genericArguments];
}
