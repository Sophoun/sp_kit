#! /usr/bin/env dcli

import 'dart:io';

import 'package:dcli/dcli.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main(List<String> args) {
  try {
    switch (args.firstOrNull) {
      case "--name":
        if (args.length < 2) {
          print(
            red(
              "Missing app name. To create run: dart run sp_kit:create_app --name <your_app_name>",
            ),
          );
          return;
        }
        createApp(args[1]);
        break;
    }
  } catch (e) {
    print(red(e.toString()));
  }
}

/// Create app
void createApp(String? appName) {
  print("creating app $appName");
  "flutter create $appName".run;

  ///
  /// Delete unecessery folders
  ///
  deleteDir("$appName/test");

  ///
  /// Add directories structure
  ///

  /// Assets
  final assetsPath = "$appName/assets";
  if (!exists(assetsPath)) createDir(assetsPath);

  /// Images
  final imagesPath = "$appName/assets/images";
  if (!exists(imagesPath)) createDir(imagesPath, recursive: true);

  /// Add path to yaml assets path
  final file = File('$appName/pubspec.yaml');
  final yamlString = file.readAsStringSync().replaceFirst(
    '# assets:',
    'assets:',
  );
  final yamlEditor = YamlEditor(yamlString);
  yamlEditor.update(['flutter', 'assets'], ['assets/images/']);
  yamlEditor.update(['flutter_gen'], {'output': 'lib/gen/'});
  yamlEditor.update(
    ['flutter_gen', 'integrations'],
    {'image': true, 'flutter_svg': true},
  );
  file.writeAsStringSync(yamlEditor.toString());

  /// Add folders structure
  final folders = [
    /// Core
    "lib/core/network",
    "lib/core/db",
    "lib/core/theme",
    "lib/core/theme/palette",
    "lib/core/theme/text",
    "lib/core/utils",

    /// Features
    "lib/features",

    /// Generate
    "lib/gen",

    /// Lang/Router
    "lib/lang",
    "lib/router",
    "lib/widgets",
  ];

  for (final folder in folders) {
    final path = "$appName/$folder";
    if (!exists(path)) createDir(path, recursive: true);
  }

  ///
  /// Add dependencies
  ///
  /// sp_kit
  "flutter pub add 'sp_kit:{\"git\":{\"url\":\"https://github.com/Sophoun/sp_kit.git\",\"ref\":\"main\"}}'"
      .start(workingDirectory: appName);

  /// dependencies
  final dependencies = [
    "auto_route",
    "google_fonts",
    "flutter_gen",
    "flutter_native_splash",
    "flutter_launcher_icons",
    "dio",
  ];
  for (final dependency in dependencies) {
    "flutter pub add $dependency".start(workingDirectory: appName);
  }

  /// dev dependencies
  final devDependencies = [
    "build_runner",
    "auto_route_generator",
    "flutter_gen_runner",
  ];
  for (final dependency in devDependencies) {
    "flutter pub add $dependency --dev".start(workingDirectory: appName);
  }

  /// Run pub get
  "flutter pub get".start(workingDirectory: appName);

  ///
  /// Create flutter_native_splash.yaml and flutter_launcher_icons.yaml files
  ///

  /// Native splash screen
  touch(
    "$appName/flutter_native_splash.yaml",
    create: true,
  ).write(flutterNativeSplashContent);

  /// Launcher icon
  "dart run flutter_launcher_icons:generate".start(workingDirectory: appName);

  ///
  /// Create watch.sh command
  ///
  touch("$appName/watch.sh", create: true).write("""
#!/bin/bash

# Generate splash screen
dart run flutter_native_splash:create --path=flutter_native_splash.yaml

# Generate launcher icon
dart run flutter_launcher_icons

# Build and watch the changes
dart run build_runner watch --delete-conflicting-outputs
""");

  ///
  /// Create doc.sh command
  ///
  touch("$appName/doc.sh", create: true).write("""
#!/bin/bash
dart doc .
dart pub global activate dhttpd
echo visit: 'http://localhost:8080'
dart pub global run dhttpd --path doc/api
""");

  /// Router
  touch(
    "$appName/lib/router/app_router.dart",
    create: true,
  ).write(appRouterContent(appName!));

  /// Languages
  touch("$appName/lib/lang/app_lang.dart", create: true).write(appLangContent);
  touch(
    "$appName/lib/lang/lang_en.dart",
    create: true,
  ).write(enLangContent(appName));
  touch(
    "$appName/lib/lang/lang_km.dart",
    create: true,
  ).write(kmLangContent(appName));

  /// Injecttion
  touch(
    "$appName/lib/injection.dart",
    create: true,
  ).write(injectionContent(appName));

  /// API
  touch(
    "$appName/lib/core/network/api_client.dart",
    create: true,
  ).write(apiContent);

  /// Theme
  touch("$appName/lib/core/theme/palette/app_palette.dart", create: true).write(
    """
import 'package:flutter/material.dart';

abstract class AppPalette extends ThemeExtension<AppPalette> {
  Color get primary;
  Color get secondary;
  Color get background;
  Color get surface;
  Color get error;
  // Custom roles
  Color get success;
  Color get warning;

  // Semantic Text Tokens
  Color get textPrimary; // Main headings
  Color get textSecondary; // Subtitles/Descriptions
  Color get textDisabled; // Greyed out inputs
  Color get textLink; // Clickable text
  Color get textOnPrimary; // Text inside a primary-colored button
  Color get textOnSecondary; // Text inside a secondary-colored button

  /// Asset resource based on theme
  String get homeBackground;
}
  """,
  );

  touch(
    "$appName/lib/core/theme/palette/dark_palette.dart",
    create: true,
  ).write("""
import 'package:flutter/material.dart';
import 'package:$appName/core/theme/palette/app_palette.dart';

class DarkPalette implements AppPalette {
  @override
  Color get primary => const Color(0xFF7C4DFF); // Electric Violet
  @override
  Color get secondary => const Color(0xFF03DAC6); // Cyber Teal
  @override
  Color get background => const Color(0xFF0A0A0B); // Deep Obsidian
  @override
  Color get surface => const Color(0xFF161618); // Elevated Surface
  @override
  Color get error => const Color(0xFFFF5252); // Vibrant Red
  @override
  Color get success => const Color(0xFF00E676); // Neon Green
  @override
  Color get warning => const Color(0xFFFFAB00); // Bright Amber

  // Semantic Text Tokens
  @override
  Color get textPrimary => const Color(0xFFF5F5F7); // Off-White
  @override
  Color get textSecondary => const Color(0xFF8E8E93); // iOS-style Silver
  @override
  Color get textDisabled => const Color(0xFF424242); // Dim Charcoal
  @override
  Color get textLink => const Color(0xFFB388FF); // Soft Violet
  @override
  Color get textOnPrimary => const Color(0xFFFFFFFF); // White on Violet
  @override
  Color get textOnSecondary => const Color(0xFF000000);

  @override
  String get homeBackground => "";

  @override
  ThemeExtension<AppPalette> copyWith() {
    return this;
  }

  @override
  ThemeExtension<AppPalette> lerp(
    covariant ThemeExtension<AppPalette>? other,
    double t,
  ) {
    return this;
  }

  @override
  Object get type => this;
}
""");
  touch(
    "$appName/lib/core/theme/palette/light_palette.dart",
    create: true,
  ).write("""
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:$appName/core/theme/palette/app_palette.dart'; // Using material for standard Color constants if needed

class LightPalette implements AppPalette {
  @override
  Color get primary => const Color(0xFF004CFF); // Deep Trust Blue
  @override
  Color get secondary => const Color(0xFF00CFE8); // Modern Cyan
  @override
  Color get background => const Color(0xFFF8F9FA); // Very Light Grey (Soft on eyes)
  @override
  Color get surface => const Color(0xFFFFFFFF); // Pure White
  @override
  Color get error => const Color(0xFFE53935); // Standard Red
  @override
  Color get success => const Color(0xFF4CAF50); // Success Green
  @override
  Color get warning => const Color(0xFFFFB300); // Amber Warning

  // Semantic Text Tokens
  @override
  Color get textPrimary => const Color(0xFF1A1A1A); // Near Black (High contrast)
  @override
  Color get textSecondary => const Color(0xFF757575); // Muted Grey
  @override
  Color get textDisabled => const Color(0xFFBDBDBD); // Light Grey
  @override
  Color get textLink => const Color(0xFF004CFF); // Matches Primary
  @override
  Color get textOnPrimary => const Color(0xFFFFFFFF); // White for Blue buttons
  @override
  Color get textOnSecondary => const Color(0xFFFFFFFF);

  @override
  String get homeBackground => "";

  @override
  ThemeExtension<AppPalette> copyWith() {
    return this;
  }

  @override
  ThemeExtension<AppPalette> lerp(
    covariant ThemeExtension<AppPalette>? other,
    double t,
  ) {
    return this;
  }

  @override
  Object get type => this;
}
""");

  touch(
    "$appName/lib/core/theme/palette/navi_palette.dart",
    create: true,
  ).write("""
import 'dart:ui';
import 'package:flutter/material.dart';
import 'app_palette.dart';

class NaviPalette implements AppPalette {
  // Brand Colors
  @override
  Color get primary => const Color(0xFF002366); // Royal Navy
  @override
  Color get secondary => const Color(0xFFC5A059); // Champagne Gold
  @override
  Color get background => const Color(0xFFF0F2F5); // Cool Grey-Blue
  @override
  Color get surface => const Color(0xFFFFFFFF); // Pure White
  @override
  Color get error => const Color(0xFFD32F2F); // Deep Red
  @override
  Color get success => const Color(0xFF1B5E20); // Forest Green
  @override
  Color get warning => const Color(0xFFE65100); // Burnt Orange

  // Semantic Text Tokens
  @override
  Color get textPrimary => const Color(0xFF001B3D); // Midnight Blue (Very dark)
  @override
  Color get textSecondary => const Color(0xFF506680); // Slate Blue-Grey
  @override
  Color get textDisabled => const Color(0xFFA0ACB9); // Muted Steel
  @override
  Color get textLink => const Color(0xFF0056B3); // Classic Link Blue
  @override
  Color get textOnPrimary => const Color(0xFFFFFFFF); // White on Navy
  @override
  Color get textOnSecondary => const Color(0xFF002366);

  @override
  String get homeBackground => "";

  @override
  ThemeExtension<AppPalette> copyWith() {
    return this;
  }

  @override
  ThemeExtension<AppPalette> lerp(
    covariant ThemeExtension<AppPalette>? other,
    double t,
  ) {
    return this;
  }

  @override
  Object get type => this;
}
""");
  touch("$appName/lib/core/theme/text/app_text_style.dart", create: true).write("""
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:$appName/core/theme/palette/app_palette.dart';

class AppTextStyle {
  final AppPalette? palette;
  static AppTextStyle? _instance;

  factory AppTextStyle.create(AppPalette? palette) {
    _instance ??= AppTextStyle._(palette);
    return _instance!;
  }

  AppTextStyle._(this.palette);

  TextStyle get h1 => GoogleFonts.plusJakartaSans(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: palette?.textPrimary,
  );

  TextStyle get h2 => GoogleFonts.plusJakartaSans(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: palette?.textPrimary,
  );

  TextStyle get h3 => GoogleFonts.plusJakartaSans(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: palette?.textPrimary,
  );

  TextStyle get bodyLarge => GoogleFonts.plusJakartaSans(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: palette?.textPrimary,
  );

  TextStyle get bodyMedium => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: palette?.textPrimary,
  );

  TextStyle get label => GoogleFonts.plusJakartaSans(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: palette?.textPrimary,
  );

  TextStyle get button => GoogleFonts.plusJakartaSans(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: palette?.textPrimary,
  );
}
""");
  touch("$appName/lib/core/theme/theme_builder.dart", create: true).write("""
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:$appName/core/theme/palette/app_palette.dart';

class ThemeBuilder {
  static ThemeData build(AppPalette palette, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,

      colorScheme: ColorScheme.fromSeed(
        seedColor: palette.primary,
        primary: palette.primary,
        onPrimary: palette.textOnPrimary,
        secondary: palette.secondary,
        onSecondary: palette.textOnSecondary,
        surface: palette.surface,
        onSurface: palette.textPrimary,
        error: palette.error,
        onError: Colors.white,
        brightness: brightness,
      ),

      scaffoldBackgroundColor: palette.background,

      textTheme:
          GoogleFonts.plusJakartaSansTextTheme(
            ThemeData(brightness: brightness).textTheme,
          ).apply(
            bodyColor: palette.textPrimary,
            displayColor: palette.textPrimary,
          ),

      appBarTheme: AppBarTheme(
        backgroundColor: palette.surface,
        foregroundColor: palette.textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: palette.textPrimary,
        ),
      ),

      cardTheme: CardThemeData(
        color: palette.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: palette.textDisabled.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: palette.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? palette.surface : palette.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: palette.textDisabled.withValues(alpha: 0.2),
          ),
        ),
        hintStyle: TextStyle(color: palette.textDisabled),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: palette.primary,
          foregroundColor: palette.textOnPrimary,
        ),
      ),

      /// Inject Custom Extensions
      extensions: [palette],
    );
  }
}
""");
  touch("$appName/lib/core/theme/theme_controller.dart", create: true).write("""
import 'package:flutter/material.dart';
import 'package:$appName/core/theme/palette/app_palette.dart';
import 'package:$appName/core/theme/palette/dark_palette.dart';
import 'package:$appName/core/theme/palette/light_palette.dart';
import 'package:$appName/core/theme/palette/navi_palette.dart';
import 'package:$appName/core/theme/theme_builder.dart';
import 'package:sp_kit/sp_kit.dart';

/// App Theme Type
enum AppThemeType { classic, midnight, navi }

/// Theme Controller
class ThemeController {
  final themeData = ObserverValue(
    ThemeBuilder.build(LightPalette(), Brightness.light),
  );
  AppPalette _palette = LightPalette();

  /// Update theme
  void updateTheme(AppThemeType type) {
    Brightness brightness = Brightness.light;

    switch (type) {
      case AppThemeType.midnight:
        _palette = DarkPalette();
        brightness = Brightness.dark;
        break;
      case AppThemeType.navi:
        _palette = NaviPalette();
        brightness = Brightness.light;
        break;
      case AppThemeType.classic:
        _palette = LightPalette();
        brightness = Brightness.light;
        break;
    }
    log("Current theme: \${type.name}");

    themeData.value = ThemeBuilder.build(_palette, brightness);
  }
}
""");

  touch("$appName/lib/core/theme/theme_extension.dart", create: true).write("""
import 'package:flutter/material.dart';
import 'package:$appName/core/theme/palette/app_palette.dart';
import 'package:$appName/core/theme/text/app_text_style.dart';

extension ThemeExtension on BuildContext {
  AppPalette? get palette => Theme.of(this).extension<AppPalette>();
  AppTextStyle? get appTextStyle => AppTextStyle.create(palette);
}
""");

  /// Main file
  touch("$appName/lib/main.dart", create: true).write(mainPageConent(appName));

  /// Environment variable
  final envPath = "$appName/env";
  if (!exists(envPath)) createDir(envPath);
  touch("$appName/env/dev.json", create: true).write('{ "ENV": "DEV"  }');
  touch("$appName/env/stag.json", create: true).write('{ "ENV": "STAGING"  }');
  touch("$appName/env/prod.json", create: true).write('{ "ENV": "PROD"  }');
  touch("$appName/lib/env_config.dart", create: true).write(envConfigContent);

  /// Create new feature
  "dart run ../bin/feature_add.dart --name home".start(
    workingDirectory: appName,
  );
  // "dart run sp_kit:feature_add --name home".start(workingDirectory: appName);

  /// VS Code runner
  final vsCodePath = "$appName/.vscode";
  if (!exists(vsCodePath)) createDir(vsCodePath, recursive: true);
  touch(
    "$appName/.vscode/launch.json",
    create: true,
  ).write(vsCodeRunner(appName));

  ///
  /// Run build script
  ///
  'dart run build_runner build --delete-conflicting-outputs'.start(
    workingDirectory: appName,
  );

  ///
  /// Show success
  ///
  print(
    green("""
Your project named: $appName was created successfully.
In order to open your application, type:

  \$ cd $appName
or:
  \$ code $appName

To start your development. :)
"""),
  );
}

////////////////////////////////////////////////////////////////////////////////

/// Write palette
String palette() {
  return """
import 'package:flutter/material.dart';

abstract class AppPalette extends ThemeExtension<AppPalette> {
  Color get primary;
  Color get secondary;
  Color get background;
  Color get surface;
  Color get error;
  // Custom roles
  Color get success;
  Color get warning;

  // Semantic Text Tokens
  Color get textPrimary; // Main headings
  Color get textSecondary; // Subtitles/Descriptions
  Color get textDisabled; // Greyed out inputs
  Color get textLink; // Clickable text
  Color get textOnPrimary; // Text inside a primary-colored button
  Color get textOnSecondary; // Text inside a secondary-colored button

  /// Asset resource based on theme
  String get homeBackground;
}

""";
}

///
/// VS Code runner
///
String vsCodeRunner(String appName) =>
    """
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "$appName-dev",
      "request": "launch",
      "type": "dart",
      "args": [
        "-t",
        "./lib/main.dart",
        "--dart-define-from-file",
        "env/dev.json"
      ]
    },
    {
      "name": "$appName-stag",
      "request": "launch",
      "type": "dart",
      "args": [
        "-t",
        "./lib/main.dart",
        "--dart-define-from-file",
        "env/stag.json"
      ]
    },
    {
      "name": "$appName-prod",
      "request": "launch",
      "type": "dart",
      "args": [
        "-t",
        "./lib/main.dart",
        "--dart-define-from-file",
        "env/prod.json"
      ]
    },
    {
      "name": "flutter_base_preview",
      "type": "node-terminal",
      "request": "launch",
      // https://docs.flutter.dev/tools/widget-previewer
      "command": "flutter widget-preview start"
    }
  ]
}
""";

///
/// env_config.dart content
///
final envConfigContent = """
import 'dart:developer';

class EnvConfig {
  static const String _notFound = "NOT_FOUND";

  static const String env = String.fromEnvironment(
    'ENV',
    defaultValue: _notFound,
  );

  static void validate() {
    final missingKeys = <String>[];
    if (env == _notFound) missingKeys.add('ENV');
    if (missingKeys.isNotEmpty) {
      final error = '❌ MISSING ENVIRONMENT VARIABLES: \${missingKeys.join(", ")} Make sure to run with: --dart-define-from-file=env/<env_name>.json';

      assert(() {
        throw Exception(error);
      }());

      log(error);
    }
  }
}

""";

///
/// api_client.dart
///
final apiContent = """
import 'package:dio/dio.dart';
import 'package:sp_kit/sp_kit.dart';

class ApiClient {
  final Dio _dio;

  ApiClient()
      : _dio = Dio(
          BaseOptions(
            baseUrl: String.fromEnvironment('BASE_URL'),
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            headers: {'Content-Type': 'application/json'},
          ),
        );

  /// GET Request
  Future<Either<Response, EitherException>> get(
    String path, {
    Map<String, dynamic>? query,
  }) async {
    return await _dio.get(path, queryParameters: query).toEither();
  }

  /// POST Request
  Future<Either<Response, EitherException>> post(
    String path, {
    dynamic data,
  }) async {
    return await _dio.post(path, data: data).toEither();
  }

  /// UPDATE (PUT) Request
  Future<Either<Response, EitherException>> put(
    String path, {
    dynamic data,
  }) async {
    return await _dio.put(path, data: data).toEither();
  }

  /// DELETE Request
  Future<Either<Response, EitherException>> delete(
    String path, {
    dynamic data,
  }) async {
    return await _dio.delete(path, data: data).toEither();
  }
}
""";

///
/// app_lang.dart file content
///
final appLangContent = """
import 'package:sp_kit/sp_kit.dart';

abstract class AppLang extends AppLocalize {
  AppLang({required super.lang});

  String get appName;
}
""";

///
/// en.dart file content
///
String enLangContent(String appName) =>
    """
import 'package:sp_kit/sp_kit.dart';
import 'package:$appName/lang/app_lang.dart';

class LangEn extends AppLang {
  LangEn() : super(lang: Lang.en);

  @override
  String get appName => "$appName";
}
""";

///
/// en.dart file content
///
String kmLangContent(String appName) =>
    """
import 'package:sp_kit/sp_kit.dart';
import 'package:$appName/lang/app_lang.dart';

class LangKm extends AppLang {
  LangKm() : super(lang: Lang.km);
  
  @override
  String get appName => "$appName";
}
""";

///
/// injection.dart content
///
String injectionContent(String appName) =>
    """
import 'package:$appName/core/theme/theme_controller.dart';
import 'package:$appName/features/home/presentation/view_models/home_vm.dart';
import 'package:$appName/features/home/repository/home_repository.dart';
import 'package:sp_kit/sp_kit.dart';
import 'package:$appName/core/network/api_client.dart';

final serviceLocators = ServiceLocator()
  ..register(ThemeController())
  ..register(ApiClient())
  ..registerLazy((di) => HomeRepository(di.get()))
  ..registerLazy((di) => HomeVm(di.get()));
""";

///
/// main.dart content
///
String mainPageConent(String appName) =>
    """
import 'package:flutter/material.dart';
import 'package:$appName/core/theme/theme_controller.dart';
import 'package:$appName/env_config.dart';
import 'package:$appName/lang/app_lang.dart';
import 'package:$appName/lang/lang_en.dart';
import 'package:$appName/lang/lang_km.dart';
import 'package:$appName/router/app_router.dart';
import 'package:$appName/injection.dart';
import 'package:sp_kit/sp_kit.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

void main(List<String> args) {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  EnvConfig.validate();
  // whenever your initialization is completed, remove the splash screen:
  FlutterNativeSplash.remove();

  /// Run app
  runApp(App());
}

class App extends StatelessWidget {
  App({super.key});

  final router = AppRouter();
  ThemeController get themeController => inject<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Observe(
      () => SpKit(
        routerConfig: router.config(),
        serviceLocator: serviceLocators,
        theme: themeController.themeData.value,
        themeMode: .light,
        locale: LocaleRegister<AppLang>()
          ..register(LangEn())
          ..register(LangKm())
          ..changeLang(Lang.en),
      ),
    );
  }
}

""";

///
/// app_router.dart content
///
String appRouterContent(String appName) =>
    """
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:$appName/router/app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(page: HomeRoute.page, initial: true),
  ];

  /// A custom modal sheet route builder that creates a modal bottom sheet
  Route<T> modalSheetBuilder<T>(
    BuildContext context,
    Widget child,
    Page<T> page,
  ) {
    return ModalBottomSheetRoute(
      settings: page,
      builder: (context) => SafeArea(
        child: ClipRRect(
          borderRadius: BorderRadiusGeometry.only(
            topLeft: Radius.circular(12),
            topRight: Radius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: 600, minHeight: 100),
            child: child,
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }

  Route<T> modalDialogBuilder<T>(
    BuildContext context,
    Widget child,
    Page<T> page,
  ) {
    return DialogRoute(
      settings: page,
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(child: child),
    );
  }
}

""";

///
/// Flutter native splash content
///
final flutterNativeSplashContent = """
flutter_native_splash:
  # This package generates native code to customize Flutter's default white native splash screen
  # with background color and splash image.
  # Steps to make this work:
  # 1. Customize the parameters below.
  # 2. run the following command in the terminal:
  # dart run flutter_native_splash:create
  # or if you place this not in pubspec.yaml and not in flutter_native_splash.yaml:
  # dart run flutter_native_splash:create -p ../your-filepath.yaml
  # 3. voila, done!

  # NOTES:
  # - in case you got some trouble, cleaning up flutter project might help:
  # flutter clean ; flutter pub get
  # - To restore Flutter's default white splash screen, run the following command in the terminal:
  # dart run flutter_native_splash:remove
  # or if you place this not in pubspec.yaml and not in flutter_native_splash.yaml:
  # dart run flutter_native_splash:remove -p ../your-filepath.yaml

  # IMPORTANT NOTE: These parameter do not affect the configuration of Android 12 and later, which
  # handle splash screens differently that prior versions of Android.  Android 12 and later must be
  # configured specifically in the android_12 section below, at the very end.

  #======================================================================
  
  # uncomment this if you want to disable this package for specific platform:
  # android: false
  # ios: false
  # web: false
  
  #======================================================================

  #! FOR ALL PLATFORM, except Android 12+:

  # general color for all platform (except android 12+):
  # see there only 2 lines in all parameters that marked as [required], so others
  # remain optional. NOTE that if you specify the [required] color, then you cant 
  # use the [required] background_image in the next section. the reverse is true.
  # select one, they cant work together.
  color: "#42a5f5"  ##====================================[REQUIRED]==========
  #color_dark: "#042a49"
  # platform-specific color. will override general color if active:
  #color_android: "#42a5f5"
  #color_dark_android: "#042a49"
  #color_ios: "#42a5f5"
  #color_dark_ios: "#042a49"
  #color_web: "#42a5f5"
  #color_dark_web: "#042a49"

  # general background_image for all platform (except android 12+)
  # if you specify this [required] background_image, then you should comment the 
  # [required] color in previous section. select one, they cant work together.
  #background_image:      "assets/background.png" #========[REQUIRED]============
  #background_image_dark: "assets/dark-background.png"
  # platform-specific background_image. will override general background_image if active:
  #background_image_android:      "assets/background-android.png"
  #background_image_dark_android: "assets/dark-background-android.png"
  #background_image_ios:          "assets/background-ios.png"
  #background_image_dark_ios:     "assets/dark-background-ios.png"
  #background_image_web:          "assets/background-web.png"
  #background_image_dark_web:     "assets/dark-background-web.png"

  # general image for all platform (except android 12+):
  # allows you to specify an image used in the splash screen. It must be a
  # png file and should be sized for 4x pixel density.
  image:                assets/splash.png
  #image_dark:          assets/splash-invert.png
  # platform-specific image. will override general image if active:
  #image_android:       assets/splash-android.png
  #image_dark_android:  assets/splash-invert-android.png
  #image_ios:           assets/splash-ios.png
  #image_dark_ios:      assets/splash-invert-ios.png
  #image_web:           assets/splash-web.gif
  #image_dark_web:      assets/splash-invert-web.gif  

  # image alignment (default center if not specified, or speccified something else):
  #android_gravity: center       # bottom, center, center_horizontal, center_vertical, 
  # clip_horizontal, clip_vertical, end, fill, fill_horizontal, fill_vertical, left, right, start, top. could also be a combination like `android_gravity: fill|clip_vertical`
  # This will fill the width while maintaining the image's vertical aspect ratio.
  # visit https://developer.android.com/reference/android/view/Gravity
  #ios_content_mode: center      # scaleToFill, scaleAspectFit, scaleAspectFill, 
  # center, top, bottom, left, right, topLeft, topRight, bottomLeft, or bottomRight.
  # visit https://developer.apple.com/documentation/uikit/uiview/contentmode
  #web_image_mode: center        # center, contain, stretch, cover

  # general branding for all platform (except android 12+):
  # allows you to specify an image used as branding in the splash screen. should be png.
  #branding:      assets/dart.png
  #branding_dark: assets/dart_dark.png
  # platform-specific branding. will override general branding if active:
  #branding_android:      assets/brand-android.png
  #branding_dark_android: assets/dart_dark-android.png
  #branding_ios:          assets/brand-ios.png
  #branding_dark_ios:     assets/dart_dark-ios.png
  #branding_web:          assets/brand-web.gif
  #branding_dark_web:     assets/dart_dark-web.gif

  # branding position:
  # you can use bottom, bottomRight, and bottomLeft. The default values is 
  # bottom if not specified or specified something else.
  #branding_mode: bottom                # default bottom
  #branding_bottom_padding: 24          # default 0
  #branding_bottom_padding_android: 24  # default 0
  #branding_bottom_padding_ios: 24      # default 0
  # branding bottom padding web is not available yet.

  # The screen orientation can be set in Android with the android_screen_orientation parameter.
  # Valid parameters can be found here:
  # https://developer.android.com/guide/topics/manifest/activity-element#screen
  #android_screen_orientation: sensorLandscape

  # hide notif bar on android. ios already hides it by default. 
  # Has no effect in web since web has no notification bar.
  fullscreen: true                # default false
  # if you dont want to hide notif bar, for android just set this to false,
  # but for ios, add this to your flutter main():
  # WidgetsFlutterBinding.ensureInitialized(); 
  # SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [SystemUiOverlay.bottom, SystemUiOverlay.top], );
    
  #! extra note for IOS:
  # If you have changed the name(s) of your info.plist file(s), you can specify the filename(s)
  # with the info_plist_files parameter.  Remove only the # characters in the three lines below,
  # do not remove any spaces:
  #info_plist_files:
  #  - 'ios/Runner/Info-Debug.plist'
  #  - 'ios/Runner/Info-Release.plist'

  #========================================================================

  # what we did above won't affect Android 12 and newer at all. they have different
  # handling concept. visit https://developer.android.com/guide/topics/ui/splash-screen
  
  #! ANDROID 12+ configuration:
  android_12:
    # background color
    color: "#42a5f5"
    # color_dark: "#042a49"

    # center-logo
    # If this parameter is not specified, the app's launcher icon will be used instead. 
    # Please note that the splash screen will be clipped to a circle on the center of the screen. 
    # with background: 960×960 px (fit within circle 640px in diameter)    
    # without background: 1152×1152 px (fit within circle 768px in diameter)
    # ensure that the most important design elements of your image are placed within a circular area 
    image: assets/images/logo/blank.png    
    # image_dark: assets/images/logo/logo-splash2.png  

    # center-logo background color
    icon_background_color: "#111111"
    # icon_background_color_dark: "#eeeeee"

    # branding:
    # The branding image dimensions must be 800x320 px.
    #branding:      assets/dart.png      
    #branding_dark: assets/dart_dark.png
""";
