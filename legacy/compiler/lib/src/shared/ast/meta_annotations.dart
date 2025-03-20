import '../tokens/definitions.dart';

import 'definitions.dart';

/// Represent a meta annotation.
///
/// e.g. @abstract
/// e.g. @implements
///
/// annotationKeyword: The annotation keyword.
class MetaAnnotations {
  final ASTType type = ASTType.metaAnnotations;
  final Token leftBracket;
  final List<Token> annotations;

  const MetaAnnotations({required this.leftBracket, required this.annotations});

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'leftBracket': leftBracket.lexeme,
      'annotations': annotations.map((a) => a.lexeme).toList(),
    };
  }

  List<Object?> get props => [annotations];
}
