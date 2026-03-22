/// VS Code runner
String vsCodeRunner(String appName) => """
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

/// env_config.dart content
const envConfigContent = """
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

/// api_client.dart
const apiContent = """
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

/// app_lang.dart file content
const appLangContent = """
import 'package:sp_kit/sp_kit.dart';

abstract class AppLang extends AppLocalize {
  AppLang({required super.lang});

  String get appName;
}
""";

/// en.dart file content
String enLangContent(String appName) => """
import 'package:sp_kit/sp_kit.dart';
import 'package:$appName/lang/app_lang.dart';

class LangEn extends AppLang {
  LangEn() : super(lang: Lang.en);

  @override
  String get appName => "$appName";
}
""";

/// km.dart file content
String kmLangContent(String appName) => """
import 'package:sp_kit/sp_kit.dart';
import 'package:$appName/lang/app_lang.dart';

class LangKm extends AppLang {
  LangKm() : super(lang: Lang.km);
  
  @override
  String get appName => "$appName";
}
""";

/// injection.dart content
String injectionContent(String appName) => """
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

/// main.dart content
String mainPageContent(String appName) => """
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

/// app_router.dart content
String appRouterContent(String appName) => """
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

/// Flutter native splash content
const flutterNativeSplashContent = """
flutter_native_splash:
  color: "#42a5f5"
  image: assets/splash.png
  fullscreen: true
  android_12:
    color: "#42a5f5"
    image: assets/images/logo/blank.png    
    icon_background_color: "#111111"
""";

/// Palette content
const paletteContent = """
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

/// Dark palette content
String darkPaletteContent(String appName) => """
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
""";

/// Light palette content
String lightPaletteContent(String appName) => """
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
""";

/// Navi palette content
String naviPaletteContent(String appName) => """
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:$appName/core/theme/palette/app_palette.dart';

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
""";

/// App text style content
String appTextStyleContent(String appName) => """
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
""";

/// Theme builder content
String themeBuilderContent(String appName) => """
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
""";

/// Theme controller content
String themeControllerContent(String appName) => """
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
""";

/// Theme extension content
String themeExtensionContent(String appName) => """
import 'package:flutter/material.dart';
import 'package:$appName/core/theme/palette/app_palette.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:$appName/core/theme/text/app_text_style.dart';

extension ThemeExtension on BuildContext {
  AppPalette? get palette => Theme.of(this).extension<AppPalette>();
  AppTextStyle? get appTextStyle => AppTextStyle.create(palette);
}
""";
