// ignore_for_file: unintended_html_in_doc_comment

import '../token_definitions.dart';

/// Represents a template.
///
/// e.g. template<T> { ... }
///
/// parameters: The parameters of the template.
class Template {
  final Token templateKeyword;
  final List<Token> parameters;

  const Template({required this.templateKeyword, required this.parameters});

  Map<String, dynamic> toJson() {
    return {
      'type': 'Template',
      'templateKeyword': templateKeyword.lexeme,
      'parameters': parameters.map((p) => p.lexeme).toList(),
    };
  }

  List<Object?> get props => [templateKeyword, parameters];
}
