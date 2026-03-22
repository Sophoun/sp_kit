// ignore_for_file: avoid_print
import 'src/commands/create_app_command.dart';
import 'src/commands/feature_add_command.dart';
import 'src/utils/logger.dart';

void main(List<String> args) {
  if (args.isEmpty) {
    printOptions();
    return;
  }

  final command = args[0];
  final commandArgs = args.sublist(1);

  switch (command) {
    case "create_app":
      CreateAppCommand().run(commandArgs);
      break;
    case "feature_add":
      FeatureAddCommand().run(commandArgs);
      break;
    case "-h":
    case "--help":
    case "help":
      printOptions();
      break;
    default:
      Logger.error("Unknown command: $command");
      printOptions();
      break;
  }
}

void printOptions() {
  print("""
Usage: dart run sp_kit <command> [arguments]

Available commands:
  create_app --name <app_name>      : Create a new project with sp_kit structure.
  feature_add --name <feature_name> : Add a new feature to your current project.
  help, -h, --help                 : Show this help information.

Examples:
  dart run sp_kit create_app --name my_cool_app
  dart run sp_kit feature_add --name login
""");
}
