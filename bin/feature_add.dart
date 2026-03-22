import 'dart:io';

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

  /// Read pubspec.yaml to get project name
  final projectName = File(
    'pubspec.yaml',
  ).readAsStringSync().split('name: ')[1].split('\n')[0];

  /// Extract path name and class name from feature name
  final pathName = name.toLowerCase();
  final className = name
      .split("_")
      .map((e) => e[0].toUpperCase() + e.substring(1))
      .join();

  /// Create feature folder and file
  print("adding feature $name");
  createDir("lib/features/$pathName/domain", recursive: true);
  createDir("lib/features/$pathName/repository", recursive: true);
  createDir("lib/features/$pathName/presentation/widgets", recursive: true);
  createDir("lib/features/$pathName/presentation/pages", recursive: true);
  createDir("lib/features/$pathName/presentation/view_models", recursive: true);
  touch(
    "lib/features/$pathName/presentation/pages/${pathName}_page.dart",
    create: true,
  ).write(featurePage(projectName, className));
  touch(
    "lib/features/$pathName/presentation/view_models/${pathName}_vm.dart",
    create: true,
  ).write(viewModel(projectName, className));
  touch(
    "lib/features/$pathName/repository/${pathName}_repository.dart",
    create: true,
  ).write(featureRepository(projectName, className));

  /// Rerun the dart build runner
  "dart run build_runner build --delete-conflicting-outputs".start();

  /// Show success and guide them how to register view model to main file and route to app_router.
  print("""

${green("Created feature \"$name\" successfully.")}

${green("** Please, don't forget to add your page to ${red("\"app_router.dart\"")} and register view model to ${red("\"main.dart\"")}")}
Please follow below code:

${green("* Copy code below and add it to your app_router.dart and past it inside routes list:")}
${blue("AutoRoute(page: ${className}Route.page)")}

${green("* Copy code below and register to your ${red("\"ServiceLocator()\"")} ${green("object inside")} ${red("\"injection.dart\"")}.")}
${blue("..registerLazy((di) => ${className}Repository(di.get()))")}
${blue("..registerLazy((di) => ${className}Vm(di.get()))")}

${green("Happy codeing :)")}
""");
}

/// View Model content
String viewModel(String projectName, String className) =>
    """
import 'package:flutter/widgets.dart';
import 'package:$projectName/features/${className.toLowerCase()}/repository/${className.toLowerCase()}_repository.dart';

class ${className}Vm extends ChangeNotifier {
  ${className}Vm(this._${className.toLowerCase()}Repository);

  final ${className}Repository _${className.toLowerCase()}Repository;
}

""";

/// Feature page content
String featurePage(String packageName, String className) =>
    """
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:$packageName/core/theme/theme_controller.dart';
import 'package:$packageName/core/theme/theme_extension.dart';
import 'package:$packageName/features/${className.toLowerCase()}/presentation/view_models/${className.toLowerCase()}_vm.dart';
import 'package:sp_kit/sp_kit.dart';

@RoutePage()
class ${className}Page extends StatelessWidget {
  const ${className}Page({super.key});

  ${className}Vm get vm => inject<${className}Vm>();
  ThemeController get themeController => inject<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: .min,
          spacing: 12.h,
          children: [
            Text('HomePage', style: context.appTextStyle?.h1),
            ElevatedButton(
              onPressed: () {
                themeController.updateTheme(AppThemeType.midnight);
              },
              child: Text("Go to Account", style: context.appTextStyle?.button),
            ),
          ],
        ),
      ),
    );
  }
}
""";

/// Feature repository content
String featureRepository(String projectName, String className) =>
    """
import 'package:$projectName/core/network/api_client.dart';

class ${className}Repository {
  ${className}Repository(this._apiClient);

  final ApiClient _apiClient;
}
""";
