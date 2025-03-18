import '../token_definitions.dart';

/// Represent a meta annotation.
///
/// e.g. @abstract
/// e.g. @implements
///
/// annotationKeyword: The annotation keyword.
class MetaAnnotations {
  final Token leftBracket;
  final List<Token> annotations;

  const MetaAnnotations({required this.leftBracket, required this.annotations});

  Map<String, dynamic> toJson() {
    return {
      'type': 'MetaAnnotations',
      'leftBracket': leftBracket.lexeme,
      'annotations': annotations.map((a) => a.lexeme).toList(),
    };
  }

  List<Object?> get props => [leftBracket, annotations];
}
