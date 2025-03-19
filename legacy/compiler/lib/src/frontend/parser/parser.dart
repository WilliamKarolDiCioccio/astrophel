import 'package:meta/meta.dart';

import '../../shared/ast/definitions.dart';
import '../../shared/ast/meta_annotations.dart';
import '../../shared/ast/type_annotations.dart';
import '../../shared/token_definitions.dart';

/// The parser class is responsible for converting a list of tokens into an AST. It runs on a per-file basis.
class Parser {
  final List<Token> tokens;
  int current = 0;

  Parser(this.tokens);

  /// AST generation entry point.
  ModuleNode produceAST() {
    final List<StatementNode> statements = [];

    // Consumes tokens until the end of file token.
    while (!_isAtEnd()) {
      if (_match(TokenType.SEMICOLON)) {
        throw UnimplementedError("Unexpected semicolon token: ${_peek()}");
      }

      statements.add(parseStatement());
    }

    return ModuleNode(statements: statements);
  }

  /// See [StatementNode] for more information.
  @visibleForTesting
  StatementNode parseStatement() {
    var tk = _peek();

    MetaAnnotations? metaAnnotations;

    if (tk.type == TokenType.LEFT_BRACKET &&
        _matchIn(1, TokenType.ANNOTATION)) {
      metaAnnotations = parseMetaAnnotations();
    }

    tk = _peek(); // Re-evaluate the token after parsing meta annotations.

    late StatementNode statement;

    // NOTE: Support for wrapping statements in blocks for scoping.
    if (tk.type == TokenType.LEFT_BRACE) {
      statement = parseBlock();
    } else if (tk.type == TokenType.IMPORT) {
      statement = parseImportStatement();
    } else if (tk.type == TokenType.EXPORT) {
      statement = parseExportStatement();
    } else if (tk.type == TokenType.FROM) {
      statement = parseSymbolWiseImportStatement();
    } else if (tk.type == TokenType.INTERFACE) {
      statement = parseInterfaceDeclaration(metaAnnotations);
    } else if (tk.type == TokenType.IMPLEMENT) {
      statement = parseInterfaceImplementationDeclaration(metaAnnotations);
    } else if (tk.type == TokenType.PARTIAL || tk.type == TokenType.CLASS) {
      statement = parseClassDeclaration(metaAnnotations);
    } else if (tk.type == TokenType.STRUCT) {
      statement = parseStructDeclaration(metaAnnotations);
    } else if (tk.type == TokenType.UNION) {
      statement = parseUnionDeclaration(metaAnnotations);
    } else if (tk.type == TokenType.ENUM) {
      statement = parseEnumDeclaration(metaAnnotations);
    } else if (tk.type == TokenType.CONSTRUCTOR) {
      statement = parseConstructorDeclaration(metaAnnotations);
    }
    // NOTE: Function and variable declarations require arbitrary lookahead for disambiguation.
    else if (tk.type == TokenType.STORAGE_SPECIFIER) {
      if (_matchIn(2, TokenType.FUNCTION)) {
        statement = parseFunctionDeclaration(metaAnnotations);
      } else if (_matchIn(1, TokenType.MUTABILITY_SPECIFIER)) {
        statement = parseVariableDeclaration(metaAnnotations);
      } else {
        throw UnimplementedError("Unexpected token: $tk");
      }
    } else if (tk.type == TokenType.EXECUTION_MODEL_SPECIFIER ||
        tk.type == TokenType.FUNCTION) {
      statement = parseFunctionDeclaration(metaAnnotations);
    } else if (tk.type == TokenType.MUTABILITY_SPECIFIER) {
      statement = parseVariableDeclaration(metaAnnotations);
    } else if (tk.type == TokenType.IF) {
      statement = parseIfStatement();
    } else if (tk.type == TokenType.SWITCH) {
      statement = parseSwitchStatement();
    } else if (tk.type == TokenType.WHILE) {
      statement = parseWhileStatement();
    } else if (tk.type == TokenType.DO) {
      statement = parseDoWhileStatement();
    } else if (tk.type == TokenType.FOR) {
      statement = parseForStatement();
    } else if (tk.type == TokenType.BREAK) {
      statement = parseBreakStatement();
    } else if (tk.type == TokenType.CONTINUE) {
      statement = parseContinueStatement();
    } else if (tk.type == TokenType.RETURN) {
      statement = parseReturnStatement();
    } else {
      statement = parseExpressionStatement();
    }

    return statement;
  }

  /// See [ImportStatementNode] for more information.
  @visibleForTesting
  ImportStatementNode parseImportStatement() {
    Token importKeyword = _advance(null); // Consume the 'import' keyword

    final List<String> mimePath = [];

    do {
      if (_match(TokenType.IDENTIFIER)) {
        mimePath.add(_peek().lexeme);

        _advance(null); // Consume the identifier token

        if (_match(TokenType.DOT)) {
          _advance(null); // Consume the dot token
        }
      } else {
        break;
      }
    } while (!_isAtEnd());

    Token? alias;

    if (_match(TokenType.AS)) {
      _advance(null); // Consume the 'as' keyword

      alias = _advance(
        TokenType.IDENTIFIER,
        message: "Expected identifier for import alias, instead got ${_peek()}",
      );
    }

    _advance(
      TokenType.SEMICOLON,
      message:
          "Expected ';' at the end of import statement, instead got ${_peek()}",
    );

    return ImportStatementNode(
      importKeyword: importKeyword,
      mimePath: mimePath,
      alias: alias,
    );
  }

  /// See [SymbolWiseImportStatementNode] for more information.
  @visibleForTesting
  SymbolWiseImportStatementNode parseSymbolWiseImportStatement() {
    final fromKeyword = _advance(null); // Consume the 'from' keyword

    final List<String> mimePath = [];

    do {
      if (_match(TokenType.IDENTIFIER)) {
        mimePath.add(_peek().lexeme);

        _advance(null); // Consume the identifier token

        if (_match(TokenType.DOT)) {
          _advance(null); // Consume the dot token
        }
      } else {
        break;
      }
    } while (!_isAtEnd());

    _advance(
      TokenType.IMPORT,
      message: "Expected 'import' keyword, instead got ${_peek()}",
    );

    final List<SymbolImport> symbolImports = [];

    do {
      if (_match(TokenType.IDENTIFIER)) {
        final name = IdentifierNode(
          name: _advance(null),
        ); // Consume the identifier token

        Token? asKeyword;

        if (_match(TokenType.AS)) {
          asKeyword = _advance(null); // Consume the 'as' keyword

          _advance(
            TokenType.IDENTIFIER,
            message:
                "Expected identifier for import alias, instead got ${_peek()}",
          );
        }

        symbolImports.add(SymbolImport(name: name, alias: asKeyword));

        if (_match(TokenType.COMMA)) {
          _advance(null); // Consume the dot token
        }
      } else {
        break;
      }
    } while (!_isAtEnd());

    _advance(
      TokenType.SEMICOLON,
      message:
          "Expected ';' at the end of symbol wise import statement, instead got ${_peek()}",
    );

    return SymbolWiseImportStatementNode(
      fromKeyword: fromKeyword,
      importKeyword: _peek(),
      symbolImports: symbolImports,
      mimePath: mimePath,
    );
  }

  /// See [ExportStatementNode] for more information.
  @visibleForTesting
  ExportStatementNode parseExportStatement() {
    Token exportKeyword = _advance(null); // Consume the 'export' keyword

    final List<IdentifierNode> mimePath = [];

    do {
      if (_match(TokenType.IDENTIFIER)) {
        mimePath.add(IdentifierNode(name: _peek()));

        _advance(null); // Consume the identifier token

        if (_match(TokenType.DOT)) {
          _advance(null); // Consume the dot token
        }
      } else {
        break;
      }
    } while (!_isAtEnd());

    _advance(
      TokenType.SEMICOLON,
      message:
          "Expected ';' at the end of export statement, instead got ${_peek()}",
    );

    return ExportStatementNode(
      exportKeyword: exportKeyword,
      mimePath: mimePath,
    );
  }

  /// See [InterfaceDeclarationNode] for more information.
  @visibleForTesting
  InterfaceDeclarationNode parseInterfaceDeclaration(
    MetaAnnotations? metaAnnotations,
  ) {
    Token interfaceKeyword = _advance(
      TokenType.INTERFACE,
      message: "Expected 'interface' keyword, instead got ${_peek()}",
    );

    Token name = _advance(
      TokenType.IDENTIFIER,
      message: "Expected identifier for interface name, instead got ${_peek()}",
    );

    _advance(
      TokenType.LEFT_BRACE,
      message: "Expected '{' for interface declaration, instead got ${_peek()}",
    );

    List<FunctionDeclarationNode> methods = [];

    while (!_match(TokenType.RIGHT_BRACE)) {
      final tk = _peek();

      if (tk.type == TokenType.EXECUTION_MODEL_SPECIFIER ||
          tk.type == TokenType.FUNCTION) {
        methods.add(parseFunctionDeclaration(metaAnnotations));
      } else {
        throw UnimplementedError("Unexpected token: $tk");
      }
    }

    _advance(
      TokenType.RIGHT_BRACE,
      message: "Expected '}' for interface declaration, instead got ${_peek()}",
    );

    return InterfaceDeclarationNode(
      interfaceKeyword: interfaceKeyword,
      name: IdentifierNode(name: name),
      methods: methods,
    );
  }

  /// See [InterfaceImplementationNode] for more information.
  @visibleForTesting
  InterfaceImplementationNode parseInterfaceImplementationDeclaration(
    MetaAnnotations? metaAnnotations,
  ) {
    Token implementsKeyword = _advance(
      TokenType.IMPLEMENT,
      message: "Expected 'implement' keyword, instead got ${_peek()}",
    );

    Token interfaceName = _advance(
      TokenType.IDENTIFIER,
      message: "Expected identifier for interface name, instead got ${_peek()}",
    );

    Token forKeyword = _advance(
      TokenType.FOR,
      message: "Expected 'for' keyword, instead got ${_peek()}",
    );

    Token className = _advance(
      TokenType.IDENTIFIER,
      message: "Expected identifier for class name, instead got ${_peek()}",
    );

    _advance(
      TokenType.LEFT_BRACE,
      message:
          "Expected '{' for interface implementation, instead got ${_peek()}",
    );

    List<FunctionDeclarationNode> methods = [];

    while (!_match(TokenType.RIGHT_BRACE)) {
      final tk = _peek();

      if (tk.type == TokenType.STORAGE_SPECIFIER ||
          tk.type == TokenType.EXECUTION_MODEL_SPECIFIER ||
          tk.type == TokenType.FUNCTION) {
        methods.add(parseFunctionDeclaration(metaAnnotations));
      } else {
        throw UnimplementedError("Unexpected token: $tk");
      }
    }

    _advance(
      TokenType.RIGHT_BRACE,
      message:
          "Expected '}' for interface implementation declaration, instead got ${_peek()}",
    );

    return InterfaceImplementationNode(
      implementsKeyword: implementsKeyword,
      interfaceName: IdentifierNode(name: interfaceName),
      forKeyword: forKeyword,
      className: IdentifierNode(name: className),
      methods: methods,
    );
  }

  /// See [ClassDeclarationNode] for more information.
  @visibleForTesting
  ClassDeclarationNode parseClassDeclaration(MetaAnnotations? metaAnnotations) {
    Token? partialKeyword;

    if (_match(TokenType.PARTIAL)) {
      partialKeyword = _advance(null);
    }

    Token classKeyword = _advance(
      TokenType.CLASS,
      message: "Expected 'class' keyword, instead got ${_peek()}",
    );

    Token name = _advance(
      TokenType.IDENTIFIER,
      message: "Expected identifier for class name, instead got ${_peek()}",
    );

    _advance(
      TokenType.LEFT_BRACE,
      message: "Expected '{' for class declaration, instead got ${_peek()}",
    );

    final List<FieldDeclarationNode> fields = [];
    final List<MethodDeclarationNode> methods = [];
    final List<UnionDeclarationNode> unions = [];
    ConstructorDeclarationNode? constructor;
    DestructorDeclarationNode? destructor;

    while (!_match(TokenType.RIGHT_BRACE)) {
      var tk = _peek();

      MetaAnnotations? metaAnnotations;

      if (tk.type == TokenType.LEFT_BRACKET &&
          _matchIn(1, TokenType.ANNOTATION)) {
        metaAnnotations = parseMetaAnnotations();
      }

      tk = _peek(); // Re-evaluate the token after parsing meta annotations.

      if (tk.type == TokenType.CONSTRUCTOR) {
        if (constructor != null) {
          throw UnimplementedError("Multiple constructors are not allowed");
        } else {
          constructor = parseConstructorDeclaration(metaAnnotations);
        }
      } else if (tk.type == TokenType.DESTRUCTOR) {
        if (destructor != null) {
          throw UnimplementedError("Multiple destructors are not allowed");
        } else {
          destructor = parseDestructorDeclaration(metaAnnotations);
        }
      } // NOTE: Function and variable declarations require arbitrary lookahead for disambiguation.
      else if (tk.type == TokenType.STORAGE_SPECIFIER) {
        if (_matchIn(2, TokenType.FUNCTION)) {
          methods.add(parseFunctionDeclaration(metaAnnotations));
        } else if (_matchIn(1, TokenType.MUTABILITY_SPECIFIER)) {
          fields.add(parseVariableDeclaration(metaAnnotations));
        }
      } else if (tk.type == TokenType.UNION) {
        unions.add(parseUnionDeclaration(metaAnnotations));
      } else if (tk.type == TokenType.EXECUTION_MODEL_SPECIFIER ||
          tk.type == TokenType.FUNCTION) {
        methods.add(parseFunctionDeclaration(metaAnnotations));
      } else if (tk.type == TokenType.MUTABILITY_SPECIFIER) {
        fields.add(parseVariableDeclaration(metaAnnotations));
      } else {
        throw UnimplementedError("Unexpected token: $tk");
      }
    }

    _advance(
      TokenType.RIGHT_BRACE,
      message: "Expected '}' for class declaration, instead got ${_peek()}",
    );

    return ClassDeclarationNode(
      metaAnnotations: metaAnnotations,
      partialKeyword: partialKeyword,
      classKeyword: classKeyword,
      name: IdentifierNode(name: name),
      constructor: constructor,
      destructor: destructor,
      fields: fields,
      methods: methods,
      unions: unions,
    );
  }

  /// See [StructDeclarationNode] for more information.
  @visibleForTesting
  StructDeclarationNode parseStructDeclaration(
    MetaAnnotations? metaAnnotations,
  ) {
    Token structKeyword = _advance(
      TokenType.STRUCT,
      message: "Expected 'class' keyword, instead got ${_peek()}",
    );

    Token name = _advance(
      TokenType.IDENTIFIER,
      message: "Expected identifier for class name, instead got ${_peek()}",
    );

    _advance(
      TokenType.LEFT_BRACE,
      message: "Expected '{' for class declaration, instead got ${_peek()}",
    );

    final List<FieldDeclarationNode> fields = [];
    final List<UnionDeclarationNode> unions = [];
    ConstructorDeclarationNode? constructor;
    DestructorDeclarationNode? destructor;

    while (!_match(TokenType.RIGHT_BRACE)) {
      var tk = _peek();

      MetaAnnotations? metaAnnotations;

      if (tk.type == TokenType.LEFT_BRACKET &&
          _matchIn(1, TokenType.ANNOTATION)) {
        metaAnnotations = parseMetaAnnotations();
      }

      tk = _peek(); // Re-evaluate the token after parsing meta annotations.

      if (tk.type == TokenType.CONSTRUCTOR) {
        if (constructor != null) {
          throw UnimplementedError("Multiple constructors are not allowed");
        }

        constructor = parseConstructorDeclaration(metaAnnotations);
      } else if (tk.type == TokenType.DESTRUCTOR) {
        if (destructor != null) {
          throw UnimplementedError("Multiple destructors are not allowed");
        }

        destructor = parseDestructorDeclaration(metaAnnotations);
      } else if (tk.type == TokenType.UNION) {
        unions.add(parseUnionDeclaration(metaAnnotations));
      } else if (tk.type == TokenType.STORAGE_SPECIFIER ||
          tk.type == TokenType.MUTABILITY_SPECIFIER) {
        fields.add(parseVariableDeclaration(metaAnnotations));
      } else {
        throw UnimplementedError("Unexpected token: $tk");
      }
    }

    _advance(
      TokenType.RIGHT_BRACE,
      message: "Expected '}' for class declaration, instead got ${_peek()}",
    );

    return StructDeclarationNode(
      metaAnnotations: metaAnnotations,
      structKeyword: structKeyword,
      name: IdentifierNode(name: name),
      constructor: constructor,
      destructor: destructor,
      fields: fields,
      unions: unions,
    );
  }

  /// See [UnionDeclarationNode] for more information.
  @visibleForTesting
  UnionDeclarationNode parseUnionDeclaration(MetaAnnotations? metaAnnotations) {
    Token unionKeyword = _advance(
      TokenType.UNION,
      message: "Expected 'union' keyword, instead got ${_peek()}",
    );

    _advance(
      TokenType.LEFT_BRACE,
      message: "Expected '{' for union declaration, instead got ${_peek()}",
    );

    List<FieldDeclarationNode> fields = [];

    while (!_match(TokenType.RIGHT_BRACE)) {
      final tk = _peek();

      if (tk.type == TokenType.STORAGE_SPECIFIER ||
          tk.type == TokenType.MUTABILITY_SPECIFIER) {
        fields.add(parseVariableDeclaration(metaAnnotations));
      } else {
        throw UnimplementedError("Unexpected token: $tk");
      }
    }

    _advance(
      TokenType.RIGHT_BRACE,
      message: "Expected '}' for union declaration, instead got ${_peek()}",
    );

    return UnionDeclarationNode(
      metaAnnotations: metaAnnotations,
      unionKeyword: unionKeyword,
      fields: fields,
    );
  }

  /// See [EnumDeclarationNode] for more information.
  @visibleForTesting
  EnumDeclarationNode parseEnumDeclaration(MetaAnnotations? metaAnnotations) {
    Token enumKeyword = _advance(
      TokenType.ENUM,
      message: "Expected 'enum' keyword, instead got ${_peek()}",
    );

    Token name = _advance(
      TokenType.IDENTIFIER,
      message: "Expected identifier for enum name, instead got ${_peek()}",
    );

    final variants = parseList(
      {TokenType.LEFT_BRACE},
      {TokenType.RIGHT_BRACE},
      TokenType.COMMA,
      () {
        final name = _advance(
          TokenType.IDENTIFIER,
          message:
              "Expected identifier for variant name, instead got ${_peek()}",
        );

        ExpressionNode? value;

        if (_match(TokenType.EQUAL)) {
          _advance(null); // Consume the equal token
          value = parseExpression();
        }

        return EnumVariantNode(name: IdentifierNode(name: name), value: value);
      },
    );

    return EnumDeclarationNode(
      enumKeyword: enumKeyword,
      name: IdentifierNode(name: name),
      variants: variants,
    );
  }

  /// See [ConstructorDeclarationNode] for more information.
  @visibleForTesting
  ConstructorDeclarationNode parseConstructorDeclaration(
    MetaAnnotations? metaAnnotations,
  ) {
    Token constructorKeyword = _advance(
      TokenType.CONSTRUCTOR,
      message: "Expected 'constructor' keyword, instead got ${_peek()}",
    );

    final parameters = parseParameters();

    final List<AssignmentExpressionNode> initializers = [];

    if (_match(TokenType.COLON)) {
      initializers.addAll(parseInitializers());
    }

    final body = parseBlock();

    return ConstructorDeclarationNode(
      constructorKeyword: constructorKeyword,
      parameters: parameters,
      initializers: initializers,
      body: body,
    );
  }

  /// See [DestructorDeclarationNode] for more information.
  @visibleForTesting
  DestructorDeclarationNode parseDestructorDeclaration(
    MetaAnnotations? metaAnnotations,
  ) {
    Token destructorKeyword = _advance(
      TokenType.DESTRUCTOR,
      message: "Expected 'destructor' keyword, instead got ${_peek()}",
    );

    _advance(
      TokenType.LEFT_PAREN,
      message:
          "Expected '(' for destructor declaration, instead got ${_peek()}",
    );

    _advance(
      TokenType.RIGHT_PAREN,
      message:
          "Expected ')' for destructor declaration, instead got ${_peek()}",
    );

    final body = parseBlock();

    return DestructorDeclarationNode(
      destructorKeyword: destructorKeyword,
      body: body,
    );
  }

  /// See [FunctionDeclarationNode] for more information.
  @visibleForTesting
  FunctionDeclarationNode parseFunctionDeclaration(
    MetaAnnotations? metaAnnotations,
  ) {
    Token? storageSpecifier;

    if (_match(TokenType.STORAGE_SPECIFIER)) {
      storageSpecifier = _advance(null); // Consume the storage specifier
    }

    Token? executionModelSpecifier;

    if (_match(TokenType.EXECUTION_MODEL_SPECIFIER)) {
      executionModelSpecifier = _advance(
        null,
      ); // Consume the execution specifier
    }

    final Token functionKeyword = _advance(
      TokenType.FUNCTION,
      message: "Expected 'function' keyword, instead got ${_peek()}",
    );

    final Token name = _advance(
      TokenType.IDENTIFIER,
      message: "Expected identifier for function name, instead got ${_peek()}",
    );

    final parameters = parseParameters();

    TypeAnnotation? returnType;

    if (_match(TokenType.ARROW)) {
      _advance(null); // Consume the arrow token

      returnType = parseTypeAnnotation();
    }

    final body = parseBlock();

    return FunctionDeclarationNode(
      metaAnnotations: metaAnnotations,
      storageSpecifier: storageSpecifier,
      executionModelSpecifier: executionModelSpecifier,
      functionKeyword: functionKeyword,
      returnType: returnType,
      name: IdentifierNode(name: name),
      parameters: parameters,
      body: body,
    );
  }

  /// See [ParameterNode] for more information.
  @visibleForTesting
  VariableDeclarationNode parseVariableDeclaration(
    MetaAnnotations? metaAnnotations,
  ) {
    Token? storageSpecifier;

    if (_match(TokenType.STORAGE_SPECIFIER)) {
      storageSpecifier = _advance(null); // Consume the storage specifier
    }

    Token? mutabilitySpecifier;

    if (_match(TokenType.MUTABILITY_SPECIFIER)) {
      mutabilitySpecifier = _advance(null); // Consume the mutability specifier
    }

    TypeAnnotation? typeAnnotation;

    if (!_matchAt(current + 1, TokenType.EQUAL) &&
        !_matchAt(current + 1, TokenType.SEMICOLON)) {
      typeAnnotation = parseTypeAnnotation();
    }

    final List<(IdentifierNode, ExpressionNode?)> nameInitializerPairs =
        parseList({}, {TokenType.SEMICOLON}, TokenType.COMMA, () {
          final Token name = _advance(
            TokenType.IDENTIFIER,
            message:
                "Expected identifier for variable name, instead got ${_peek()}",
          );

          ExpressionNode? initializer;

          if (_match(TokenType.EQUAL)) {
            _advance(null); // Consume the equal token
            initializer = parseExpression();
          }

          return (IdentifierNode(name: name), initializer);
        });

    return VariableDeclarationNode(
      metaAnnotations: metaAnnotations,
      storageSpecifier: storageSpecifier,
      mutabilitySpecifier: mutabilitySpecifier,
      typeAnnotation: typeAnnotation,
      nameInitializerPairs: nameInitializerPairs,
    );
  }

  /// See [IfStatementNode] for more information.
  @visibleForTesting
  IfStatementNode parseIfStatement() {
    final Token ifKeyword = _advance(
      TokenType.IF,
      message: "Expected 'if' keyword, instead got ${_peek()}",
    );

    final condition = parseExpression();
    final thenBranch = parseBlock();
    StatementNode? elseBranch;

    if (_match(TokenType.ELSE)) {
      if (_matchAt(current + 1, TokenType.IF)) {
        elseBranch = parseElseIfStatement();
      } else {
        elseBranch = parseElseStatement();
      }
    }

    return IfStatementNode(
      ifKeyword: ifKeyword,
      condition: condition,
      thenBranch: thenBranch,
      elseBranch: elseBranch,
    );
  }

  /// See [ElseStatementNode] for more information.
  @visibleForTesting
  ElseStatementNode parseElseStatement() {
    final Token elseKeyword = _advance(
      TokenType.ELSE,
      message: "Expected 'else' keyword, instead got ${_peek()}",
    );

    final branch = parseBlock();

    return ElseStatementNode(elseKeyword: elseKeyword, branch: branch);
  }

  /// See [ElseIfStatementNode] for more information.
  @visibleForTesting
  ElseIfStatementNode parseElseIfStatement() {
    final Token elseKeyword = _advance(
      TokenType.ELSE,
      message: "Expected 'else' keyword, instead got ${_peek()}",
    );

    final ifKeyword = _advance(
      TokenType.IF,
      message: "Expected 'if' keyword, instead got ${_peek()}",
    );

    final condition = parseExpression();
    final thenBranch = parseBlock();
    StatementNode? elseBranch;

    if (_match(TokenType.ELSE)) {
      if (_matchAt(current + 1, TokenType.IF)) {
        elseBranch = parseElseIfStatement();
      } else {
        elseBranch = parseElseStatement();
      }
    }

    return ElseIfStatementNode(
      elseKeyword: elseKeyword,
      ifKeyword: ifKeyword,
      condition: condition,
      thenBranch: thenBranch,
      elseBranch: elseBranch,
    );
  }

  /// See [SwitchStatementNode] for more information.
  @visibleForTesting
  SwitchStatementNode parseSwitchStatement() {
    final Token switchKeyword = _advance(
      TokenType.SWITCH,
      message: "Expected 'switch' keyword, instead got ${_peek()}",
    );

    final expression = parseExpression();

    final cases = parseList(
      {TokenType.LEFT_BRACE},
      {TokenType.RIGHT_BRACE},
      null,
      parseCaseStatement,
    );

    return SwitchStatementNode(
      switchKeyword: switchKeyword,
      expression: expression,
      cases: cases,
    );
  }

  /// See [CaseOrDefaultStatementNode] for more information.
  @visibleForTesting
  CaseOrDefaultStatementNode parseCaseStatement() {
    late Token caseKeyword;
    ExpressionNode? expression;

    if (_match(TokenType.CASE) || _match(TokenType.DEFAULT)) {
      caseKeyword = _advance(null); // Consume the case or default token
    } else {
      throw UnimplementedError(
        "Expected 'case' or 'default' keyword, instead got ${_peek()}",
      );
    }

    if (caseKeyword.type == TokenType.CASE) {
      expression = parseExpression();
    }

    _advance(
      TokenType.COLON,
      message:
          "Expected colon token for case statement, instead got ${_peek()}",
    );

    final body = parseBlock();

    return CaseOrDefaultStatementNode(
      caseKeyword: caseKeyword,
      expression: expression,
      body: body,
    );
  }

  /// See [WhileStatementNode] for more information.
  @visibleForTesting
  WhileStatementNode parseWhileStatement() {
    final Token whileKeyword = _advance(
      TokenType.WHILE,
      message: "Expected 'while' keyword, instead got ${_peek()}",
    );

    final condition = parseExpression();
    final body = parseBlock();

    return WhileStatementNode(
      whileKeyword: whileKeyword,
      condition: condition,
      body: body,
    );
  }

  /// See [DoWhileStatementNode] for more information.
  @visibleForTesting
  DoWhileStatementNode parseDoWhileStatement() {
    final Token doKeyword = _advance(
      TokenType.DO,
      message: "Expected 'do' keyword, instead got ${_peek()}",
    );

    final body = parseBlock();

    _advance(
      TokenType.WHILE,
      message: "Expected 'while' keyword, instead got ${_peek()}",
    );

    final condition = parseExpression();

    _advance(
      TokenType.SEMICOLON,
      message:
          "Expected ';' at the end of do-while statement, instead got ${_peek()}",
    );

    return DoWhileStatementNode(
      doKeyword: doKeyword,
      body: body,
      condition: condition,
    );
  }

  /// See [ForStatementNode] for more information.
  @visibleForTesting
  ForStatementNode parseForStatement() {
    final Token forKeyword = _advance(
      TokenType.FOR,
      message: "Expected 'for' keyword, instead got ${_peek()}",
    );

    _advance(
      TokenType.LEFT_PAREN,
      message: "Expected '(' for for statement, instead got ${_peek()}",
    );

    VariableDeclarationNode? counterInitializer;

    if (!_match(TokenType.SEMICOLON)) {
      if (_match(TokenType.STORAGE_SPECIFIER)) {
        throw UnimplementedError(
          "Storage specifiers are not allowed in for loop counter initializer",
        );
      }

      if (_match(TokenType.MUTABILITY_SPECIFIER)) {
        throw UnimplementedError(
          "Mutability specifiers are not allowed in for loop counter initializer",
        );
      }

      TypeAnnotation? typeAnnotation;

      if (!_matchAt(current + 1, TokenType.EQUAL)) {
        typeAnnotation = parseTypeAnnotation();
      }

      final Token name = _advance(
        TokenType.IDENTIFIER,
        message:
            "Expected identifier for variable name, instead got ${_peek()}",
      );

      _advance(
        TokenType.EQUAL,
        message:
            "Expected '=' for counter initializer in for statement, instead got ${_peek()}",
      );

      final initializer = parseExpression();

      counterInitializer = VariableDeclarationNode(
        metaAnnotations: null,
        storageSpecifier: null,
        mutabilitySpecifier: null,
        typeAnnotation: typeAnnotation,
        nameInitializerPairs: [(IdentifierNode(name: name), initializer)],
      );
    }

    _advance(
      TokenType.SEMICOLON,
      message:
          "Expected ';' at the end of counter initializer for for statement, instead got ${_peek()}",
    );

    ExpressionNode? condition;

    if (!_match(TokenType.SEMICOLON)) {
      condition = parseExpression();
    }

    _advance(
      TokenType.SEMICOLON,
      message:
          "Expected ';' at the end of condition for for statement, instead got ${_peek()}",
    );

    ExpressionNode? increment;

    if (!_match(TokenType.RIGHT_PAREN)) {
      increment = parseExpression();
    }

    _advance(
      TokenType.RIGHT_PAREN,
      message:
          "Expected ')' at the end of for statement, instead got ${_peek()}",
    );

    final body = parseBlock();

    return ForStatementNode(
      forKeyword: forKeyword,
      counterInitializer: counterInitializer,
      condition: condition,
      increment: increment,
      body: body,
    );
  }

  /// See [BreakStatementNode] for more information.
  @visibleForTesting
  BreakStatementNode parseBreakStatement() {
    final Token breakKeyword = _advance(
      TokenType.BREAK,
      message: "Expected 'break' keyword, instead got ${_peek()}",
    );

    _advance(
      TokenType.SEMICOLON,
      message:
          "Expected ';' at the end of break statement, instead got ${_peek()}",
    );

    return BreakStatementNode(breakKeyword: breakKeyword);
  }

  /// See [ContinueStatementNode] for more information.
  @visibleForTesting
  ContinueStatementNode parseContinueStatement() {
    final Token continueKeyword = _advance(
      TokenType.CONTINUE,
      message: "Expected 'continue' keyword, instead got ${_peek()}",
    );

    _advance(
      TokenType.SEMICOLON,
      message:
          "Expected ';' at the end of continue statement, instead got ${_peek()}",
    );

    return ContinueStatementNode(continueKeyword: continueKeyword);
  }

  /// See [ReturnStatementNode] for more information.
  @visibleForTesting
  ReturnStatementNode parseReturnStatement() {
    final Token returnKeyword = _advance(
      TokenType.RETURN,
      message: "Expected 'return' keyword, instead got ${_peek()}",
    );

    final expression = parseExpression();

    _advance(
      TokenType.SEMICOLON,
      message:
          "Expected ';' at the end of return statement, instead got ${_peek()}",
    );

    return ReturnStatementNode(
      returnKeyword: returnKeyword,
      expression: expression,
    );
  }

  /// See [ExpressionStatementNode] for more information.
  @visibleForTesting
  ExpressionStatementNode parseExpressionStatement() {
    final expression = parseExpression();

    _advance(
      TokenType.SEMICOLON,
      message:
          "Expected ';' at the end of expression statement, instead got ${_peek()}",
    );

    return ExpressionStatementNode(expression: expression);
  }

  /// Expressions parsing entry point.
  @visibleForTesting
  ExpressionNode parseExpression() {
    return parseLambdaExpression();
  }

  /// See [LambdaExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseLambdaExpression() {
    final tk = _peek();

    if (tk.type == TokenType.EXECUTION_MODEL_SPECIFIER ||
        tk.type == TokenType.LAMBDA) {
      Token? executionModelSpecifier;

      if (_match(TokenType.EXECUTION_MODEL_SPECIFIER)) {
        executionModelSpecifier = _advance(
          null,
        ); // Consume the execution specifier
      }

      final Token lambdaKeyword = _advance(
        TokenType.LAMBDA,
        message: "Expected 'lambda' keyword, instead got ${_peek()}",
      );

      final parameters = parseParameters();

      TypeAnnotation? returnType;

      if (_match(TokenType.ARROW)) {
        _advance(null); // Consume the arrow token

        if (_match(TokenType.LEFT_BRACE)) {
          throw UnimplementedError(
            "Return type expected if the '->' token is presen. Remove the '->' token if you want the compiler to infer the return type.",
          );
        }

        returnType = parseTypeAnnotation();
      }

      final body = parseBlock();

      return LambdaExpressionNode(
        executionModelSpecifier: executionModelSpecifier,
        lambdaKeyword: lambdaKeyword,
        returnType: returnType,
        parameters: parameters,
        body: body,
      );
    }

    return parseTernaryExpression();
  }

  /// See [TernaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseTernaryExpression() {
    ExpressionNode condition = parseAssignmentExpression();

    if (_match(TokenType.QUESTION)) {
      _advance(null); // Consume the question token

      ExpressionNode thenBranch = parseAssignmentExpression();

      _advance(
        TokenType.COLON,
        message:
            "Expected colon token for ternary expression, instead got ${_peek()}",
      );

      ExpressionNode elseBranch = parseAssignmentExpression();

      return TernaryExpressionNode(
        condition: condition,
        thenBranch: thenBranch,
        elseBranch: elseBranch,
      );
    }

    return condition;
  }

  /// See [AssignmentExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseAssignmentExpression() {
    ExpressionNode expression = parseLogicalOrExpression();

    if (_match(TokenType.EQUAL) ||
        _match(TokenType.PLUS_EQUAL) ||
        _match(TokenType.MINUS_EQUAL) ||
        _match(TokenType.STAR_EQUAL) ||
        _match(TokenType.SLASH_EQUAL) ||
        _match(TokenType.MODULUS_EQUAL)) {
      final operator = _advance(null); // Consume the operator token

      final ExpressionNode value = parseExpression();

      if (expression is IdentifierNode ||
          expression is IdentifierAccessExpressionNode ||
          expression is IndexAccessExpressionNode) {
        return AssignmentExpressionNode(
          target: expression,
          value: value,
          operator: operator,
        );
      } else {
        throw UnimplementedError("Invalid assignment target: $expression");
      }
    }

    return expression;
  }

  // See [Disjunctive Normal Form](https://en.wikipedia.org/wiki/Disjunctive_normal_form)
  // to understand the precedence of logical OR expressions.

  /// See [BinaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseLogicalOrExpression() {
    var left = parseLogicalAndExpression();

    while (_match(TokenType.PIPE_PIPE)) {
      final operator = _advance(null); // Consume the operator token
      final right = parseLogicalAndExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// See [BinaryExpressionNode] for more information.
  ExpressionNode parseLogicalAndExpression() {
    var left = parseBitwiseOrExpression();

    while (_match(TokenType.AMPERSAND_AMPERSAND)) {
      final operator = _advance(null); // Consume the operator token
      final right = parseBitwiseOrExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// See [BinaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseBitwiseOrExpression() {
    var left = parseBitwiseXorExpression();

    while (_match(TokenType.PIPE)) {
      final operator = _advance(null); // Consume the operator token
      final right = parseBitwiseXorExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// See [BinaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseBitwiseXorExpression() {
    var left = parseBitwiseAndExpression();

    while (_match(TokenType.CARET)) {
      final operator = _advance(null); // Consume the operator token
      final right = parseBitwiseAndExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// See [BinaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseBitwiseAndExpression() {
    var left = parseEqualityExpression();

    while (_match(TokenType.AMPERSAND)) {
      final operator = _advance(null); // Consume the operator token
      final right = parseEqualityExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// See [BinaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseEqualityExpression() {
    var left = parseRelationalExpression();

    while (_match(TokenType.BANG_EQUAL) || _match(TokenType.EQUAL_EQUAL)) {
      final operator = _advance(null); // Consume the operator token
      final right = parseRelationalExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// See [BinaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseRelationalExpression() {
    var left = parseShiftExpression();

    while (_match(TokenType.GREATER) ||
        _match(TokenType.GREATER_EQUAL) ||
        _match(TokenType.LESS) ||
        _match(TokenType.LESS_EQUAL)) {
      final operator = _advance(null); // Consume the operator token
      final right = parseShiftExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// See [BinaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseShiftExpression() {
    var left = parseAdditiveExpression();

    while (_match(TokenType.LESS_LESS) || _match(TokenType.GREATER_GREATER)) {
      final operator = _advance(null); // Consume the operator token
      final right = parseAdditiveExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// See [BinaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseAdditiveExpression() {
    var left = parseMultiplicativeExpression();

    while (_match(TokenType.PLUS) || _match(TokenType.MINUS)) {
      final operator = _advance(null); // Consume the operator token
      final right = parseMultiplicativeExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// See [BinaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseMultiplicativeExpression() {
    var left = parsePrefixExpression();

    while (_match(TokenType.STAR) ||
        _match(TokenType.SLASH) ||
        _match(TokenType.MODULUS)) {
      final operator = _advance(null); // Consume the operator token
      final right = parsePrefixExpression();
      left = BinaryExpressionNode(left: left, right: right, operator: operator);
    }

    return left;
  }

  /// See [UnaryExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parsePrefixExpression() {
    if (_match(TokenType.AMPERSAND) ||
        _match(TokenType.STAR) ||
        _match(TokenType.MINUS) ||
        _match(TokenType.BANG) ||
        _match(TokenType.INCREMENT) ||
        _match(TokenType.DECREMENT)) {
      final operator = _advance(null); // Consume the operator token
      final right = parsePostfixExpression();
      return UnaryExpressionNode(operand: right, operator: operator);
    }

    return parsePostfixExpression();
  }

  /// See [IdentifierAccessExpressionNode], [IndexAccessExpressionNode],
  /// [UnaryExpressionNode] or [CallExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parsePostfixExpression() {
    ExpressionNode expression = parsePrimaryExpression();

    while (true) {
      if (_match(TokenType.DOT)) {
        final dot = _advance(null); // Consume the dot token

        final name = _advance(
          TokenType.IDENTIFIER,
          message:
              "Expected identifier after dot token, instead got ${_peek()}",
        );

        expression = IdentifierAccessExpressionNode(
          object: expression,
          dot: dot,
          name: name,
        );
      } else if (_match(TokenType.INCREMENT) || _match(TokenType.DECREMENT)) {
        expression = UnaryExpressionNode(
          operand: expression,
          operator: _advance(null), // Consume the increment or decrement token
        );
      } else if (_match(TokenType.LEFT_PAREN)) {
        final leftParen = _peek(); // Already consumed by parseArguments
        final arguments = parseArguments();

        expression = CallExpressionNode(
          callee: expression,
          leftParen: leftParen,
          arguments: arguments,
        );
      } else if (_match(TokenType.LEFT_BRACKET)) {
        _advance(null); // Consume the opening bracket

        final index = parseExpression();

        if (!_match(TokenType.RIGHT_BRACKET)) {
          throw UnimplementedError(
            "Expected closing bracket for index expression",
          );
        }

        _advance(
          TokenType.RIGHT_BRACKET,
          message:
              "Expected closing bracket for index expression, instead got ${_peek()}",
        );

        expression = IndexAccessExpressionNode(
          object: expression,
          bracket: tokens[current - 1],
          index: index,
        );
      } else {
        break;
      }
    }

    return expression;
  }

  /// See [GroupingExpressionNode] for more information.
  @visibleForTesting
  ExpressionNode parseGroupingExpression() {
    final leftParen = _advance(null); // Consume the left parenthesis

    final expression = parseExpression();

    _advance(
      TokenType.RIGHT_PAREN,
      message: "Expected closing parenthesis, instead got ${_peek()}",
    );

    return GroupingExpressionNode(expression: expression, leftParen: leftParen);
  }

  /// See [StringLiteralNode], [StringFragmentNode]
  /// or [StringInterpolationNode] for more information.
  @visibleForTesting
  ExpressionNode parseStringOrInterpolation() {
    List<ExpressionNode> fragments = [];

    final value = _advance(
      TokenType.STRING_FRAGMENT_START,
      message: "Expected string fragment start token, instead got ${_peek()}",
    );

    fragments.add(StringFragmentNode(value: value));

    while (_match(TokenType.STRING_FRAGMENT) ||
        _match(TokenType.STRING_FRAGMENT_END) ||
        _match(TokenType.IDENTIFIER_INTERPOLATION) ||
        _match(TokenType.EXPRESSION_INTERPOLATION_START)) {
      final token = _peek();

      if (token.type == TokenType.STRING_FRAGMENT ||
          token.type == TokenType.STRING_FRAGMENT_END) {
        fragments.add(
          StringFragmentNode(value: _advance(null)),
        ); // Consume the fragment token
      } else if (token.type == TokenType.IDENTIFIER_INTERPOLATION) {
        _advance(null);

        final name = _advance(
          TokenType.IDENTIFIER,
          message: "Expected identifier token, instead got ${_peek()}",
        );

        fragments.add(IdentifierNode(name: name));
      } else if (token.type == TokenType.EXPRESSION_INTERPOLATION_START) {
        _advance(null); // Consume the start token

        ExpressionNode interpolatedExpr = parseExpression();

        if (!_match(TokenType.EXPRESSION_INTERPOLATION_END)) {
          throw UnimplementedError(
            "Expected end token for expression interpolation",
          );
        }

        _advance(
          TokenType.EXPRESSION_INTERPOLATION_END,
          message:
              "Expected end token for expression interpolation, instead got ${_peek()}",
        );

        fragments.add(interpolatedExpr);
      } else {
        throw UnimplementedError("Unexpected token: $token");
      }
    }

    if (fragments.length == 1 && fragments.first is StringFragmentNode) {
      throw UnimplementedError("Unexpected token: $fragments.first");
    }

    if (fragments.last is! StringFragmentNode ||
        (fragments.last as StringFragmentNode).value.type !=
            TokenType.STRING_FRAGMENT_END) {
      throw UnimplementedError("Expected end token for string interpolation");
    }

    return StringInterpolationNode(fragments: fragments);
  }

  /// See [ArrayLiteralNode] for more information.
  @visibleForTesting
  ExpressionNode parseArrayExpression() {
    final leftBracket = _peek(); // Already consumed by parseList

    final elements = parseList(
      {TokenType.LEFT_BRACKET},
      {TokenType.RIGHT_BRACKET},
      TokenType.COMMA,
      parseExpression,
    );

    return ArrayLiteralNode(leftBracket: leftBracket, elements: elements);
  }

  /// Primary expressions parsing entry point.
  @visibleForTesting
  ExpressionNode parsePrimaryExpression() {
    var tk = _peek();

    ExpressionNode expression;

    switch (tk.type) {
      case TokenType.IDENTIFIER:
        expression = IdentifierNode(name: tk);
        _advance(null);
        break;
      case TokenType.NUMBER:
        expression = NumericLiteralNode(value: tk);
        _advance(null);
        break;
      case TokenType.STRING_LITERAL:
        expression = StringLiteralNode(value: tk);
        _advance(null);
        break;
      case TokenType.STRING_FRAGMENT_START:
        expression = parseStringOrInterpolation();
        break;
      case TokenType.LEFT_BRACKET:
        expression = parseArrayExpression();
        break;
      case TokenType.LEFT_PAREN:
        expression = parseGroupingExpression();
        break;
      default:
        throw UnimplementedError("Unexpected token: $tk");
    }

    return expression;
  }

  @visibleForTesting
  List<T> parseList<T>(
    Set<TokenType> openers,
    Set<TokenType> closers,
    TokenType? separator,
    T Function() parser,
  ) {
    if (closers.isEmpty) {
      throw UnimplementedError("Missing list delimiter");
    }

    if (openers.isNotEmpty) {
      if (!openers.any(_match)) {
        throw UnimplementedError(
          "Expected one of $openers, instead got ${_peek()}",
        );
      }

      _advance(null); // Consume the opener token
    }

    final List<T> list = [];

    while (!closers.any(_match)) {
      list.add(parser());

      if (separator != null) {
        if (_match(separator)) {
          _advance(null);
        } else {
          break;
        }
      }
    }

    _advance(null); // Consume the closer token

    return list;
  }

  @visibleForTesting
  List<ParameterNode> parseParameters() {
    return parseList(
      {TokenType.LEFT_PAREN},
      {TokenType.RIGHT_PAREN},
      TokenType.COMMA,
      () {
        final typeAnnotation = parseTypeAnnotation();

        final name = _advance(
          TokenType.IDENTIFIER,
          message:
              "Expected identifier for parameter name, instead got ${_peek()}",
        );

        ExpressionNode? defaultValue;

        if (_match(TokenType.EQUAL)) {
          _advance(null); // Consume the equal token
          defaultValue = parseExpression();
        }

        return ParameterNode(
          typeAnnotation: typeAnnotation,
          name: IdentifierNode(name: name),
          defaultValue: defaultValue,
        );
      },
    );
  }

  @visibleForTesting
  List<AssignmentExpressionNode> parseInitializers() {
    return parseList(
      {TokenType.COLON},
      {TokenType.COLON},
      TokenType.COMMA,
      () => parseAssignmentExpression() as AssignmentExpressionNode,
    );
  }

  @visibleForTesting
  List<ExpressionNode> parseArguments() {
    return parseList(
      {TokenType.LEFT_PAREN},
      {TokenType.RIGHT_PAREN},
      TokenType.COMMA,
      parseExpression,
    );
  }

  @visibleForTesting
  BlockStatementNode parseBlock() {
    return BlockStatementNode()
      ..statements.addAll(
        parseList(
          {TokenType.LEFT_BRACE},
          {TokenType.RIGHT_BRACE},
          null,
          parseStatement,
        ),
      );
  }

  @visibleForTesting
  MetaAnnotations parseMetaAnnotations() {
    final leftBracket = _peek(); // Already consumed by parseList

    final annotations = parseList(
      {TokenType.LEFT_BRACKET},
      {TokenType.RIGHT_BRACKET},
      TokenType.COMMA,
      () => _advance(
        TokenType.ANNOTATION,
        message: "Expected annotation, instead got ${_peek()}",
      ),
    );

    return MetaAnnotations(leftBracket: leftBracket, annotations: annotations);
  }

  @visibleForTesting
  TypeAnnotation parseTypeAnnotation() {
    final name = _advance(
      TokenType.IDENTIFIER,
      message:
          "Expected identifier for type annotation, instead got ${_peek()}",
    );

    List<TypeAnnotation>? templateArguments;

    if (_match(TokenType.LESS)) {
      templateArguments = parseList(
        {TokenType.LESS},
        {TokenType.GREATER},
        TokenType.COMMA,
        () => parseTypeAnnotation(),
      );
    }

    NumericLiteralNode? size;

    if (_match(TokenType.LEFT_BRACKET)) {
      _advance(null); // Consume the left bracket token

      size = NumericLiteralNode(
        value: _advance(
          TokenType.NUMBER,
          message: "Expected number for array size, instead got ${_peek()}",
        ),
      );

      _advance(
        TokenType.RIGHT_BRACKET,
        message:
            "Expected right bracket for array size, instead got ${_peek()}",
      );
    }

    Token? pointer;

    if (_match(TokenType.STAR)) {
      pointer = _advance(null); // Consume the star token
    }

    if (size != null) {
      return ArrayTypeAnnotation(
        name: name,
        templateArguments: templateArguments,
        size: size,
        pointer: pointer,
      );
    } else {
      return TypeAnnotation(
        name: name,
        templateArguments: templateArguments,
        pointer: pointer,
      );
    }
  }

  /// Consumes the next token in the stream and returns it.
  Token _advance(TokenType? expected, {String? message}) {
    if (expected != null && !_match(expected)) {
      throw UnimplementedError(message ?? "Expected token of type $expected");
    }

    return tokens[current++];
  }

  /// Peeks at the current token in the stream.
  Token _peek() => tokens[current];

  /// Checks if the current token matches the expected token type.
  bool _match(TokenType expected) => _matchAt(current, expected);

  /// Check if the token matches the expected token type at any given position.
  bool _matchAt(int position, TokenType expected) =>
      !_isAtEnd() && tokens[position].type == expected;

  /// Check if you can match the expected token type in the next n tokens.
  ///
  /// NOTE: This allows what's called "arbitrary lookahead".
  bool _matchIn(int n, TokenType expected) {
    for (var i = 0; i <= n; i++) {
      if (_matchAt(current + i, expected)) {
        return true;
      }
    }

    return false;
  }

  /// Checks if we have reached the end of the token stream.
  bool _isAtEnd() => current + 1 >= tokens.length;
}
