import 'dart:io';
import 'package:dcli/dcli.dart';
import 'package:yaml_edit/yaml_edit.dart';
import '../templates/app_templates.dart';
import '../utils/logger.dart';

class CreateAppCommand {
  void run(List<String> args) {
    if (args.isEmpty || args[0] != "--name") {
      Logger.error(
        "Missing app name. To create run: dart run sp_kit:create_app --name <your_app_name>",
      );
      return;
    }

    if (args.length < 2) {
      Logger.error("Missing app name value.");
      return;
    }

    createApp(args[1]);
  }

  void createApp(String appName) {
    Logger.info("Creating app $appName...");
    "flutter create $appName".run;

    // Delete unnecessary folders
    final testDir = "$appName/test";
    if (exists(testDir)) deleteDir(testDir);

    _setupDirectories(appName);
    _setupPubspec(appName);
    _addDependencies(appName);
    _createConfigFiles(appName);
    _createBoilerplateFiles(appName);
    _runBuildRunner(appName);

    Logger.success("""
Your project named: $appName was created successfully.
In order to open your application, type:

  \$ cd $appName
or:
  \$ code $appName

To start your development. :)
""");
  }

  void _setupDirectories(String appName) {
    final dirs = [
      "$appName/assets/images",
      "$appName/lib/core/network",
      "$appName/lib/core/db",
      "$appName/lib/core/theme/palette",
      "$appName/lib/core/theme/text",
      "$appName/lib/core/utils",
      "$appName/lib/features",
      "$appName/lib/gen",
      "$appName/lib/lang",
      "$appName/lib/router",
      "$appName/lib/widgets",
      "$appName/.vscode",
      "$appName/env",
    ];

    for (final dir in dirs) {
      if (!exists(dir)) createDir(dir, recursive: true);
    }
  }

  void _setupPubspec(String appName) {
    final file = File('$appName/pubspec.yaml');
    var yamlString = file.readAsStringSync();
    
    // Enable assets
    yamlString = yamlString.replaceFirst('# assets:', 'assets:');
    
    final yamlEditor = YamlEditor(yamlString);
    yamlEditor.update(['flutter', 'assets'], ['assets/images/']);
    yamlEditor.update(['flutter_gen'], {'output': 'lib/gen/'});
    yamlEditor.update(
      ['flutter_gen', 'integrations'],
      {'image': true, 'flutter_svg': true},
    );
    
    file.writeAsStringSync(yamlEditor.toString());
  }

  void _addDependencies(String appName) {
    // sp_kit from git
    "flutter pub add 'sp_kit:{\"git\":{\"url\":\"https://github.com/Sophoun/sp_kit.git\",\"ref\":\"main\"}}'"
        .start(workingDirectory: appName);

    final dependencies = [
      "auto_route",
      "google_fonts",
      "flutter_gen",
      "flutter_native_splash",
      "flutter_launcher_icons",
      "dio",
    ];
    for (final dep in dependencies) {
      "flutter pub add $dep".start(workingDirectory: appName);
    }

    final devDependencies = [
      "build_runner",
      "auto_route_generator",
      "flutter_gen_runner",
    ];
    for (final dep in devDependencies) {
      "flutter pub add $dep --dev".start(workingDirectory: appName);
    }

    "flutter pub get".start(workingDirectory: appName);
  }

  void _createConfigFiles(String appName) {
    // Native splash
    touch("$appName/flutter_native_splash.yaml", create: true)
        .write(flutterNativeSplashContent);
    
    // Launcher icon (generate)
    "dart run flutter_launcher_icons:generate".start(workingDirectory: appName);

    // Watch script
    touch("$appName/watch.sh", create: true).write("""
#!/bin/bash
dart run flutter_native_splash:create --path=flutter_native_splash.yaml
dart run flutter_launcher_icons
dart run build_runner watch --delete-conflicting-outputs
""");
    "chmod +x $appName/watch.sh".run;

    // Doc script
    touch("$appName/doc.sh", create: true).write("""
#!/bin/bash
dart doc .
dart pub global activate dhttpd
echo visit: 'http://localhost:8080'
dart pub global run dhttpd --path doc/api
""");
    "chmod +x $appName/doc.sh".run;

    // VS Code launch
    touch("$appName/.vscode/launch.json", create: true)
        .write(vsCodeRunner(appName));

    // Env files
    touch("$appName/env/dev.json", create: true).write('{ "ENV": "DEV" }');
    touch("$appName/env/stag.json", create: true).write('{ "ENV": "STAGING" }');
    touch("$appName/env/prod.json", create: true).write('{ "ENV": "PROD" }');
  }

  void _createBoilerplateFiles(String appName) {
    final files = {
      "lib/router/app_router.dart": appRouterContent(appName),
      "lib/lang/app_lang.dart": appLangContent,
      "lib/lang/lang_en.dart": enLangContent(appName),
      "lib/lang/lang_km.dart": kmLangContent(appName),
      "lib/injection.dart": injectionContent(appName),
      "lib/core/network/api_client.dart": apiContent,
      "lib/core/theme/palette/app_palette.dart": paletteContent,
      "lib/core/theme/palette/dark_palette.dart": darkPaletteContent(appName),
      "lib/core/theme/palette/light_palette.dart": lightPaletteContent(appName),
      "lib/core/theme/palette/navi_palette.dart": naviPaletteContent(appName),
      "lib/core/theme/text/app_text_style.dart": appTextStyleContent(appName),
      "lib/core/theme/theme_builder.dart": themeBuilderContent(appName),
      "lib/core/theme/theme_controller.dart": themeControllerContent(appName),
      "lib/core/theme/theme_extension.dart": themeExtensionContent(appName),
      "lib/main.dart": mainPageContent(appName),
      "lib/env_config.dart": envConfigContent,
    };

    files.forEach((path, content) {
      touch("$appName/$path", create: true).write(content);
    });

    // Initial feature
    "dart run ../bin/feature_add.dart --name home".start(workingDirectory: appName);
  }

  void _runBuildRunner(String appName) {
    'dart run build_runner build --delete-conflicting-outputs'.start(
      workingDirectory: appName,
    );
  }
}
