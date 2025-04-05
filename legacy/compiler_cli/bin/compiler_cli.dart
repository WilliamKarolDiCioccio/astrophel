import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

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
    ..addOption(
      'file',
      abbr: 'f',
      help: 'Comma-separated list of input file paths for lexing.',
    );
}

void printUsage(ArgParser argParser) {
  print(
    'Usage: dart legacy_compiler.dart --file <filename> [--file <filename> ...] [flags]',
  );
  print(argParser.usage);
}

class FileJob {
  final String filePath;
  final bool verbose;
  final SendPort sendPort;
  FileJob(this.filePath, this.verbose, this.sendPort);
}

void processFile(FileJob job) {
  final filePath = job.filePath;
  final verbose = job.verbose;
  final sendPort = job.sendPort;

  try {
    final file = File(filePath);

    if (!file.existsSync()) {
      sendPort.send('Error: File "$filePath" not found.');
      return;
    }

    final source = file.readAsStringSync();

    final lexer = Lexer(source);
    final List<Token> tokens = lexer.tokenize();

    if (verbose) {
      for (var token in tokens) {
        print('[$filePath] ${token.toString()}');
      }
    } else {
      for (var token in tokens) {
        print('[$filePath] ${token.type}');
      }
    }

    final parser = Parser(tokens);
    final ModuleNode module = parser.produceAST();
    final jsonAst = jsonEncode(module.toJson());

    final baseName = file.uri.pathSegments.last;
    final nameWithoutExt = baseName.replaceFirst(RegExp(r'\.\w+$'), '');
    final outputFileName = '${nameWithoutExt}_ast.json';

    File(outputFileName).writeAsStringSync(jsonAst);
    sendPort.send('Processed "$filePath" -> "$outputFileName"');
  } catch (e) {
    sendPort.send('Error processing "$filePath": $e');
  }
}

Future<void> main(List<String> arguments) async {
  final ArgParser argParser = buildParser();

  ArgResults results;
  try {
    results = argParser.parse(arguments);
  } on FormatException catch (e) {
    print(e.message);
    printUsage(argParser);
    return;
  }

  if (results['help'] as bool) {
    printUsage(argParser);
    return;
  }
  if (results['version'] as bool) {
    print('legacy_compiler version: $version');
    return;
  }

  final String fileList = results['file'];

  if (fileList.trim().isEmpty) {
    print('Error: No input file specified.');
    printUsage(argParser);
    return;
  }

  final List<String> filePaths =
      fileList.split(',').map((s) => s.trim()).toList();

  for (var filePath in filePaths) {
    if (!File(filePath).existsSync()) {
      print('Error: File "$filePath" does not exist.');
      return;
    }
  }

  final verbose = results['verbose'] as bool;
  final receivePort = ReceivePort();

  final futures = <Future>[];
  for (var filePath in filePaths) {
    final completer = Completer();

    late StreamSubscription sub;

    sub = receivePort.listen((message) {
      print(message);
      completer.complete();
      sub.cancel();
    });

    Isolate.spawn(
      processFile,
      FileJob(filePath, verbose, receivePort.sendPort),
    );

    futures.add(completer.future);
  }

  await Future.wait(futures);
  receivePort.close();

  print('All files processed.');
}
