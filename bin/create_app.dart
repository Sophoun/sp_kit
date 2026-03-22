#! /usr/bin/env dcli
import 'src/commands/create_app_command.dart';

void main(List<String> args) {
  CreateAppCommand().run(args);
}
