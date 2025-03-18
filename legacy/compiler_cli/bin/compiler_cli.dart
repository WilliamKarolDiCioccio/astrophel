import 'dart:io';

import 'package:args/args.dart';
import 'package:compiler/compiler.dart';
import 'package:compiler/src/shared/ast/definitions.dart';

const String version = '0.0.1';

ArgParser buildParser() {
  return ArgParser()
    ..addFlag(
      'help',
      abbr: 'h',
      negatable: false,
      help: 'Print this usage information.',
    )
    ..addFlag(
      'verbose',
      abbr: 'v',
      negatable: false,
      help: 'Show detailed token output.',
    )
    ..addFlag('version', negatable: false, help: 'Print the tool version.')
    ..addOption('file', abbr: 'f', help: 'Specify input file for lexing.');
}

void printUsage(ArgParser argParser) {
  print('Usage: dart legacy_compiler.dart --file <filename> [flags]');
  print(argParser.usage);
}

void main(List<String> arguments) {
  final ArgParser argParser = buildParser();
  try {
    final ArgResults results = argParser.parse(arguments);
    bool verbose = results.flag('verbose');

    if (results.flag('help')) {
      printUsage(argParser);
      return;
    }
    if (results.flag('version')) {
      print('legacy_compiler version: $version');
      return;
    }
    if (!results.wasParsed('file')) {
      print('Error: No input file specified.');
      printUsage(argParser);
      return;
    }

    String filePath = results['file'];
    if (!File(filePath).existsSync()) {
      print('Error: File "$filePath" not found.');
      return;
    }

    String source = File(filePath).readAsStringSync();
    Lexer lexer = Lexer(source);
    List<Token> tokens = lexer.tokenize();

    for (Token token in tokens) {
      print(verbose ? token.toString() : '${token.type}');
    }

    Parser parser = Parser(tokens);
    ModuleNode module = parser.produceAST();

    print(module);
  } on FormatException catch (e) {
    print(e.message);
    print('');
    printUsage(argParser);
  }
}
