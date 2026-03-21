import 'package:dcli/dcli.dart';

void main(List<String> args) {
  try {
    switch (args.firstOrNull) {
      case '--name':
      case '-n':
        if (args.length < 2) {
          print(
            red(
              "Missing feature name. To add new feature to your app, run: dart run sp_kit:feature_add --name <your_app_name>",
            ),
          );
          return;
        }
        addFeature(args[1]);
        break;
    }
  } catch (e) {
    print(red(e.toString()));
  }
}

void addFeature(String name) {
  if (name.contains(' ')) {
    print(
      red(
        "Feature name must be leading by capital letter and no space but you can use underscore instead.",
      ),
    );
    return;
  }

  /// Extract path name and class name from feature name
  final pathName = name.toLowerCase();
  final className = name
      .split("_")
      .map((e) => e[0].toUpperCase() + e.substring(1))
      .join();

  /// Create feature folder and file
  print("adding feature $name");
  createDir("lib/features/$pathName", recursive: true);
  touch(
    "lib/features/$pathName/${pathName}_page.dart",
    create: true,
  ).write(featurePage(className));
  touch(
    "lib/features/$pathName/${pathName}_vm.dart",
    create: true,
  ).write(viewModel(className));

  /// Rerun the dart build runner
  "dart run build_runner build --delete-conflicting-outputs".start();

  /// Show success and guide them how to register view model to main file and route to app_router.
  print("""
Created feature $name successfully.
${green("Please, don't forget to add your page to app_router.dart and register view model to main.dart")}
Please follow below code:
Copy code below and add it to your app_router.dart and past it inside routes list:

${green("AutoRoute(page: ${className}Route.page)")}

Copy code below and register to your ServiceLocator() object inside main.dart.

${green("..register(${className}Vm())")}

${green("Happy codeing :)")}
""");
}

/// View Model content
String viewModel(String className) =>
    """
import 'package:flutter/widgets.dart';

class ${className}Vm extends ChangeNotifier {
  
}
""";

/// Feature page content
String featurePage(String className) =>
    """
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class ${className}Page extends StatelessWidget {
  const ${className}Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('${className}Page'),
      ),
    );
  }
}
""";
