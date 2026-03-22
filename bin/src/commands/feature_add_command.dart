import 'dart:io';
import 'package:dcli/dcli.dart';
import '../templates/feature_templates.dart';
import '../utils/logger.dart';

class FeatureAddCommand {
  void run(List<String> args) {
    if (args.isEmpty || (args[0] != "--name" && args[0] != "-n")) {
      Logger.error(
        "Missing feature name. To add new feature run: dart run sp_kit:feature_add --name <feature_name>",
      );
      return;
    }

    if (args.length < 2) {
      Logger.error("Missing feature name value.");
      return;
    }

    addFeature(args[1]);
  }

  void addFeature(String name) {
    if (name.contains(' ')) {
      Logger.error(
        "Feature name must be leading by capital letter and no space but you can use underscore instead.",
      );
      return;
    }

    // Read pubspec.yaml to get project name
    final pubspecFile = File('pubspec.yaml');
    if (!pubspecFile.existsSync()) {
      Logger.error("pubspec.yaml not found. Are you in the project root?");
      return;
    }
    
    final projectName = pubspecFile
        .readAsStringSync()
        .split('name: ')[1]
        .split('\n')[0]
        .trim();

    final pathName = name.toLowerCase();
    final className = name
        .split("_")
        .map((e) => e[0].toUpperCase() + e.substring(1))
        .join();

    Logger.info("Adding feature $name...");
    
    final baseDir = "lib/features/$pathName";
    createDir("$baseDir/domain", recursive: true);
    createDir("$baseDir/repository", recursive: true);
    createDir("$baseDir/presentation/widgets", recursive: true);
    createDir("$baseDir/presentation/pages", recursive: true);
    createDir("$baseDir/presentation/view_models", recursive: true);

    touch("$baseDir/presentation/pages/${pathName}_page.dart", create: true)
        .write(featurePageTemplate(projectName, className));
    touch("$baseDir/presentation/view_models/${pathName}_vm.dart", create: true)
        .write(viewModelTemplate(projectName, className));
    touch("$baseDir/repository/${pathName}_repository.dart", create: true)
        .write(featureRepositoryTemplate(projectName, className));

    "dart run build_runner build --delete-conflicting-outputs".start();

    _printSuccessGuide(className);
  }

  void _printSuccessGuide(String className) {
    Logger.success("""
Created feature successfully.

** Please, don't forget to add your page to "app_router.dart" and register view model to "injection.dart"
Please follow below code:

* Copy code below and add it to your app_router.dart inside routes list:
AutoRoute(page: ${className}Route.page)

* Copy code below and register to your ServiceLocator() object inside "injection.dart":
..registerLazy((di) => ${className}Repository(di.get()))
..registerLazy((di) => ${className}Vm(di.get()))

Happy coding :)
""");
  }
}
