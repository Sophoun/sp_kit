import 'package:dcli/dcli.dart';

class Logger {
  static void info(String message) => print(message);
  static void success(String message) => print(green(message));
  static void error(String message) => print(red(message));
  static void warn(String message) => print(orange(message));
}
