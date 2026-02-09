# SP Kit

A foundational library for Flutter applications, designed to streamline development by providing a robust framework for dependency injection, state management (via ViewModels), localization, and responsive UI. It includes a collection of utility extensions to reduce boilerplate and simplify common Flutter patterns.

## ✨ Features

- **Service Locator:** A simple yet powerful service locator to manage your application's dependencies as singletons or lazy singletons.
- **ViewModel Management:** A dedicated container for managing `ChangeNotifier` instances, effectively separating business logic from the UI.
- **Localization:** An intuitive system for implementing multi-language support, allowing for easy registration and switching of languages.
- **Responsive UI:** Built-in support for creating responsive user interfaces that adapt to different screen sizes using `ScreenUtil`.
- **Utility Extensions:** A rich set of extensions for `BuildContext`, `ValueNotifier`, and more, to write cleaner and more concise code.
- **Simplified Preferences:** Easy access to `SharedPreferences` for persistent key-value storage.
- **Built-in Dialogs & Toasts:** Quickly display common UI elements like alerts and toasts with minimal code.
- **`ValueNotifierWithListener`**: A `ValueNotifier` that triggers a callback when its value changes.

## Public API

This library exposes a range of modules to streamline your Flutter development. Here is a list of the public APIs exported from `sp_kit`:

- **`sp_kit.dart`**: The main entry point of the library, providing the `FlutterBase` root widget.
- **`app_localize.dart` & `locale_register.dart`**: Core components for the localization system.
- **`service_locator.dart`**: The dependency injection container.
- **`state_extension.dart`**: Extensions for state management, including `getVm` and the `isAppLoading` notifier.
- **`screen_extension.dart`**: Extensions for creating responsive UI with `ScreenUtil`.
- **`spacing_extension.dart`**: Extensions for simplified padding and spacing.
- **`number_extension.dart`**: Extensions for number formatting and checking null/zero values.
- **`future_extension.dart`**: An extension for `Future` to handle callbacks for `onStart`, `onSuccess`, `onError`, and `onEnd`.
- **`context_extension.dart`**: Extensions for `BuildContext`, providing easy access to dialogs, toasts, and more.
- **`sp_theme.dart`**: The base theme for the application.
- **`pref.dart`**: A wrapper around `SharedPreferences` for easy key-value storage.
- **`validators.dart`**: A collection of form field validators.
- **`debouncer.dart`**: A class for debouncing function calls.
- **`event_bus.dart`**: A simple event bus for communication between different parts of your app.
- **`logger.dart`**: A logging utility that only prints in debug mode.
- **`sp_text_form_field.dart`**: A `TextFormField` that integrates with `ValueNotifier`.
- **`message_dialog.dart`**: A widget for displaying message dialogs.
- **`responsive.dart`**: The `ResponsiveLayout` widget for building responsive UIs.
- **`skeleton.dart`**: A widget for showing a skeleton loading animation.
- **`value_notifier_with_listener.dart`**: A `ValueNotifier` with a built-in listener.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK: `^3.9.0` or higher
- Dart SDK: `^3.9.0` or higher

### Installation

Add `sp_kit` to your `pubspec.yaml` dependencies. It is recommended to use the Git dependency to ensure you have the latest version.

```yaml
dependencies:
  flutter:
    sdk: flutter
  sp_kit:
    git:
      url: https://github.com/Sophoun/sp_kit.git
      ref: main # Or specify a specific tag/commit
```

Then, run `flutter pub get` to install the package.

## usage

### 1. Root Widget Setup (`FlutterBase`)

Wrap your root widget with `FlutterBase` to provide the necessary containers (`ServiceLocator`, `LocaleRegister`) and screen utility initialization to the entire widget tree.

```dart
import 'package:flutter/material.dart';
import 'package:sp_kit/sp_kit.dart';
import 'package:your_app/service_locator.dart';
import 'package:your_app/lang_setup.dart';
import 'package:your_app/router.dart';

void main() async {
  // Ensure SharedPreferences is initialized if you access it before runApp()
  await Pref.init();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final _appRouter = AppRouter();

  @override
  Widget build(BuildContext context) {
    return FlutterBase(
      // (Optional) Set the design size for responsive UI
      designSize: const Size(360, 690),
      // (Optional) Set the maximum screen size of your app.
      screenSize: const Size(360, 690),

      // Register your dependencies
      serviceLocator: setupServiceLocator(),

      // Configure localization
      locale: setupLocale(),

      child: MaterialApp.router(
        routerConfig: _appRouter.config(),
        title: 'SP Kit Example',
      ),
    );
  }
}
```

### 2. Localization

#### Define Language Contracts

Create an abstract class that defines the translation keys for your app.

```dart
// lib/lang/app_lang.dart
abstract class AppLang extends AppLocalize {
  AppLang({required super.lang});

  String get appName;
  String count(int count);
  String currentLanguageIs(String lang);
}
```

#### Create Language Implementations

Provide concrete implementations for each supported language.

```dart
// lib/lang/en.dart
class En extends AppLang {
  En() : super(lang: Lang.en);

  @override
  String get appName => "My App";

  @override
  String count(int count) => "Count: $count";

  @override
  String currentLanguageIs(String lang) => "Current language is $lang";
}

// lib/lang/kh.dart
class Kh extends AppLang {
  Kh() : super(lang: Lang.km);

  @override
  String get appName => "កម្មវិធីរបស់ខ្ញុំ";

  @override
  String count(int count) => "ចំនួន៖ $count";

  @override
  String currentLanguageIs(String lang) => "ភាសាបច្ចុប្បន្នគឺ $lang";
}
```

#### Register and Use Translations

Register your languages in the `FlutterBase` widget and access them in your UI.

```dart
// Setup locale
LocaleRegister<AppLang> setupLocale() {
  return LocaleRegister<AppLang>()
    ..register(En())
    ..register(Kh())
    ..changeLang(Lang.km); // Set initial language
}

// In your widget:
final t = context.t<AppLang>();
Text(t.appName);

// To change the language:
context.local.register.changeLang(Lang.en);
```

### 3. ServiceLocator

Register services and access them from anywhere in your app.

```dart
// Setup ServiceLocator
ServiceLocator setupServiceLocator() {
  return ServiceLocator()
    ..register(MockNet()) // Singleton
    ..registerLazy((c) => MockService(mockNet: c.get<MockNet>())) // Lazy Singleton
    ..register(HomeVm()); // Register ViewModel
}

// In your class (e.g., a ViewModel or another service):
late final mockService = inject<MockService>();
```

### 4. ViewModel

Manage your UI state with `ChangeNotifier`.

#### Create a ViewModel

```dart
class HomeVm extends ChangeNotifier {
  late final _mockService = inject<MockService>();
  final counter = ValueNotifier(0);
  final title = ValueNotifier<String>("Home");

  void increment() {
    counter.value++;
    // notifyListeners() is not needed for ValueNotifier updates
  }
}
```

#### Register and Access the ViewModel

```dart
// In your widget:
final homeVm = getVm<HomeVm>();

// Use the ValueNotifier.builder extension for efficient UI updates
homeVm.counter.builder(
  build: (value) => Text(t.count(value ?? 0)),
)
```

#### GroupValueNotifierAsWidgetBuilder

Listen to multiple notifiers from the same `ViewModel` and rebuild the UI when any of them changes.

```dart
// In your widget:
final homeVm = getVm<HomeVm>();

// Listen to multiple notifiers from the same ViewModel
[homeVm.counter, homeVm.title].builder(
  build: (values) {
    final count = values[0] as int;
    final title = values[1] as String;
    return Text('$title: $count');
  },
)
```

### 5. Utility Extensions

#### Responsive UI

Design your UI for a specific screen size, and it will scale automatically.

```dart
// Initialize in FlutterBase
// designSize: const Size(360, 690),

// Use in widgets
Container(
  width: 150.w, // Scales based on screen width
  height: 200.h, // Scales based on screen height
  padding: EdgeInsets.all(16.w),
  child: Text(
    "Responsive Text",
    style: TextStyle(fontSize: 18.sp), // Scales font size
  ),
);
```

#### SharedPreferences (`p`)

Access `SharedPreferences` easily. Remember to call `Pref.init()` in `main()`.

```dart
// Save a value
await p.setString('user_name', 'Gemini');

// Read a value
final userName = p.getString('user_name');
```

#### Theme Extension

Access theme properties directly from the `BuildContext` with this convenient extension.

```dart
// Get the current theme
final theme = context.theme;

// Get the current text theme
final textTheme = context.textTheme;

// Get the current color scheme
final colorScheme = context.colorScheme;

// Get the current button theme
final buttonTheme = context.buttonTheme;
```

#### Future Extension (`execute`)

The `execute` extension on `Future` simplifies handling asynchronous operations by providing callbacks for different states.

```dart
Future<String> fetchData() async {
  await Future.delayed(const Duration(seconds: 2));
  return "Data loaded successfully";
  // Or throw Exception("Failed to load data");
}

void loadData() {
  fetchData().execute(
    onStart: () => print("Loading..."),
    onSuccess: (data) => print(data),
    onError: (e) => print(e),
    onEnd: () => print("Operation finished."),
  );
}
```

#### Either Extension (`toEither`)

The `toEither` extension on `Future` provides a functional approach to handle asynchronous operations that can either succeed with a value (`Right`) or fail with an exception (`Left`). This is particularly useful for error handling in a more explicit and type-safe manner.

```dart
import 'package:sp_kit/sp_kit.dart';

Future<String> fetchDataEither(bool shouldFail) async {
  await Future.delayed(const Duration(seconds: 1));
  if (shouldFail) {
    throw Exception("Failed to fetch data!");
  }
  return "Data fetched successfully!";
}

void handleEitherExample() async {
  // Example of a successful operation
  final successResult = await fetchDataEither(false).toEither();
  switch (successResult) {
    case Right(value: final data):
      print("Success: $data");
    case Left(value: final error):
      print("Error: ${error.toString()}");
  }
}
```

#### EitherException

The `EitherException` is a custom exception class that can be used with the `toEither` extension. It allows you to provide a `code` and a `message` for the exception.

```dart
class EitherException implements Exception {
  final String code;
  final String message;

  EitherException({this.code = "", required this.message});

  @override
  String toString() {
    return "${code.isEmpty ? '' : '$code - '}$message";
  }
}
```

You can throw an `EitherException` in your `Future` and it will be caught by the `toEither` extension and returned as a `Left` value.

```dart
import 'package:sp_kit/sp_kit.dart';

Future<String> fetchDataEither(bool shouldFail) async {
  await Future.delayed(const Duration(seconds: 1));
  if (shouldFail) {
    throw EitherException(code: "E404", message: "Failed to fetch data!");
  }
  return "Data fetched successfully!";
}

void handleEitherExample() async {
  // Example of a successful operation
  final successResult = await fetchDataEither(false).toEither();
  switch (successResult) {
    case Right(value: final data):
      print("Success: $data");
    case Left(value: final error):
      print("Error: ${error.toString()}");
  }

  // Example of a failed operation
  final failedResult = await fetchDataEither(true).toEither<String, EitherException>();
  switch (failedResult) {
    case Right(value: final data):
      print("Success: $data");
    case Left(value: final error):
      print("Error: ${error.toString()}"); // Prints "Error: E404 - Failed to fetch data!"
  }
}
```

#### FutureEitherBindExtension Extension (`bind`)

The `bind` extension on `Future<Either<R, L>>` allows you to chain multiple asynchronous operations that return an `Either`. The chain continues only if the previous operation was successful (returned a `Right`). If any operation fails (returns a `Left`), the entire chain is short-circuited, and the `Left` value is returned.

This is useful for composing a sequence of operations where each step depends on the success of the previous one, such as fetching data, processing it, and then saving it.

```dart
import 'package:sp_kit/sp_kit.dart';

// Simulate fetching a user ID
Future<Either<int, Exception>> getUserId() {
  return Future.value(Right(123));
}

// Simulate fetching user data based on an ID
Future<Either<String, Exception>> fetchUserData(int userId) {
  // Set to `true` to simulate a failure
  bool shouldFail = false;
  if (shouldFail) {
    return Future.value(Left(Exception("Failed to fetch user data")));
  }
  return Future.value(Right("User data for ID: $userId"));
}

// Simulate processing the user data
Future<Either<String, Exception>> processData(String userData) {
  return Future.value(Right("Processed: $userData"));
}

void main() async {
  final result = await getUserId()
      .bind(fetchUserData)
      .bind(processData);

  switch (result) {
    case Right(value: final data):
      print("Success: $data"); // Success: Processed: User data for ID: 123
    case Left(value: final error):
      print("Error: ${error.toString()}");
  }
}
```

#### Dialogs and Toasts

Show feedback to the user with simple function calls.

```dart
// Show a confirmation dialog
showMessage(
  type: MessageDialogType.okCancel,
  title: "Confirm Action",
  message: "Are you sure you want to proceed?",
  onOk: () => showToast("Action confirmed!"),
  onCancel: () => showToast("Action cancelled."),
);
```

### Overriding MessageDialog

You can replace the default `MessageDialog` with your own custom implementation. This is useful if you want to create a dialog that matches your app's design system.

To do this, create a class that extends `MessageDialog` and override the methods that build the different parts of the dialog, such as `buttonOk`, `buttonCancel`, `dialogTitle`, `dialogContent`, and `boxDecoration`. You can also override the `width` and `alpha` properties to customize the dialog's appearance.

**Do not override the `build` method itself.**

#### Example

First, create your custom dialog widget by overriding the desired methods:

```dart
// lib/widgets/my_custom_dialog.dart
import 'package:flutter/material.dart';
import 'package:sp_kit/sp_kit.dart';

class MyCustomDialog extends MessageDialog {
  MyCustomDialog({super.key});

  @override
  int get alpha => 200; // Customize the background dimming

  @override
  Widget buttonOk(BuildContext context) {
    return Expanded(
      child: ElevatedButton(
        onPressed: onOk,
        child: Text(messageDialogData?.okText ?? 'OK'),
      ),
    );
  }

  @override
  Widget buttonCancel(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onCancel,
        child: Text(messageDialogData?.cancelText ?? 'Cancel'),
      ),
    );
  }

  @override
  Widget dialogTitle(BuildContext context) {
    return Text(
      messageDialogData?.title ?? '',
      style: Theme.of(context).textTheme.headlineSmall,
    );
  }
}
```

Then, pass your custom dialog to the `FlutterBase` widget in your `main.dart` file:

```dart
// In your main application setup
FlutterBase(
  // ...
  messageDialogWidget: MyCustomDialog(),
  child: MaterialApp.router(
    // ...
  ),
);
```

Now, whenever you call `showMessage()`, your `MyCustomDialog` will be displayed with your custom buttons and title style.

### 6. Spacing Extensions

Simplify spacing and padding with intuitive extensions on `num`.

```dart
// Add vertical space
16.h,

// Add horizontal space
16.w,

// Apply padding on all sides
Container(
  padding: 16.paddingAll,
  child: const Text("Padded Content"),
);

// Apply horizontal padding
Container(
  padding: 16.paddingHorizontal,
  child: const Text("Padded Content"),
);

// Apply vertical padding
Container(
  padding: 16.paddingVertical,
n  child: const Text("Padded Content"),
);

// Apply padding to a single side
Container(
  padding: 16.paddingLeft,
  child: const Text("Padded Content"),
);
```

### 7. Number Extension

The `NumberExtension` provides convenient methods for formatting numbers and handling null or zero values.

| Method                                                      | Description                                                                                                                          |
| ----------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------ |
| `isNullOrZero`                                              | Checks if a number is either `null` or `0`.                                                                                          |
| `isNotNullOrZero`                                           | Checks if a number is not `null` and not `0`.                                                                                        |
| `isNullOrNegative`                                          | Checks if a number is either `null` or less than `0`.                                                                                |
| `isNotNullOrNegative`                                       | Checks if a number is not `null` and is greater than or equal to `0`.                                                                |
| `toStringAsFixedSafe(int fractionDigits)`                   | Converts a number to a string with a fixed number of decimal places. Returns '0' if the number is `null`.                            |
| `formatAmount(int fractionDigits)`                          | Formats a number with commas as thousand separators.                                                                                 |
| `formatCurrencySuffix({int fractionDigits, String symbol})` | Formats a number as a currency string with a suffix symbol (e.g., "$ 1,234.56").                                                     |
| `formatCurrencyPrefix({int fractionDigits, String symbol})` | Formats a number as a currency string with a prefix symbol (e.g., "1,234.56 $").                                                     |
| `toDateTime()`                                              | Converts a number (milliseconds since epoch) to a `DateTime` object. Returns `null` if the number is `null` or the conversion fails. |

**Usage:**

```dart
import 'package:sp_kit/sp_kit.dart';

// Example usage
final num? myNumber = 12345.678;

print(myNumber.isNullOrZero); // false
print(myNumber.formatAmount(2)); // 12,345.68
print(myNumber.formatCurrencySuffix(symbol: '€')); // € 12,345.68
print(myNumber.formatCurrencyPrefix(symbol: 'USD')); // 12,345.68 USD

final num? nullNumber = null;
print(nullNumber.isNullOrZero); // true
print(nullNumber.toStringAsFixedSafe(2)); // 0
```

### 8. Responsive Layouts (Mobile & Tablet)

The library includes a powerful `ResponsiveLayout` widget that works with the `FlutterBase` configuration to render different widgets for mobile, tablet, and desktop layouts. It can also enforce a specific aspect ratio for mobile and tablet views, ensuring your layouts look consistent.

#### Configure Aspect Ratios

In your `FlutterBase` widget, you can optionally provide `mobileAspectRatio` and `tabletAspectRatio`.

```dart
// In your main application setup
FlutterBase(
  // Default is 9 / 16
  mobileAspectRatio: 9 / 16,

  // Default is 4 / 3
  tabletAspectRatio: 4 / 3,

  child: MyApp(),
);
```

#### Use the `ResponsiveLayout` Widget

Use the `ResponsiveLayout` widget to build different UI for different screen sizes. The widget automatically applies the configured aspect ratio for mobile and tablet layouts.

```dart
import 'package:sp_kit/sp_kit.dart';

class MyPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Responsive Page")),
      body: ResponsiveLayout(
        mobile: MobileView(),
        tablet: TabletView(),
        desktop: DesktopView(), // Optional
      ),
    );
  }
}

class MobileView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This view will be constrained to the mobileAspectRatio
    return Container(color: Colors.red, child: Center(child: Text("Mobile")));
  }
}

class TabletView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // This view will be constrained to the tabletAspectRatio
    return Container(color: Colors.green, child: Center(child: Text("Tablet")));
  }
}

class DesktopView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Desktop view does not have an aspect ratio applied by default
    return Container(color: Colors.blue, child: Center(child: Text("Desktop")));
  }
}
```

### 9. String Extension

The `StringExtension` provides convenient methods for handling nullable or empty strings, checking string properties, and formatting.

| Method                    | Description                                                                          |
| ------------------------- | ------------------------------------------------------------------------------------ |
| `orNull`                  | Returns `null` if the string is null or empty, otherwise returns the string itself.  |
| `orEmpty`                 | Returns an empty string if the string is null, otherwise returns the string itself.  |
| `isNullOrEmpty`           | Checks if the string is null or empty.                                               |
| `isNotEmpty`              | Checks if the string is not null and its length is greater than 1.                   |
| `orDefault(String value)` | Returns a default string if the string is null, otherwise returns the string itself. |
| `isCapitalFirst`          | Checks if the first character of the string is capitalized.                          |
| `isCapitalEach`           | Checks if the first character of each word in the string is capitalized.             |
| `isContainSpace`          | Checks if the string contains a space.                                               |
| `toCapitalFirst`          | Capitalizes the first character of the string.                                       |
| `toCapitalEach`           | Capitalizes the first character of each word in the string.                          |

**Usage:**

```dart
import 'package:sp_kit/sp_kit.dart';

// orNull Example
String? emptyString = "";
String? nullString = null;
String? validString = "hello";

print(emptyString.orNull); // null
print(nullString.orNull);  // null
print(validString.orNull); // "hello"

// orEmpty Example
print(emptyString.orEmpty); // ""
print(nullString.orEmpty);  // ""
print(validString.orEmpty); // "hello"

// isNullOrEmpty and isNotEmpty Example
print("".isNullOrEmpty);    // true
print("hello".isNullOrEmpty); // false
print("".isNotEmpty);      // false
print("hello".isNotEmpty);  // true (Note: current implementation checks length > 1)

// orDefault Example
print(nullString.orDefault("default")); // "default"
print(validString.orDefault("default")); // "hello"

// Capitalization Examples
print("hello world".toCapitalFirst); // "Hello world"
print("hello world".toCapitalEach);  // "Hello World"
print("Hello World".isCapitalEach);  // true
print("hello world".isCapitalEach);  // false
print("Hello".isCapitalFirst);       // true
print("hello".isCapitalFirst);       // false

// isContainSpace Example
print("hello world".isContainSpace); // true
print("helloworld".isContainSpace);  // false
```

The `StringExtendToSvg` provides an extension to convert an SVG file path to an `SvgPicture.asset` widget.

| Method         | Description                                                         |
| -------------- | ------------------------------------------------------------------- |
| `toImage(...)` | Converts an SVG file path string into an `SvgPicture.asset` widget. |

**Usage:**

```dart
import 'package:sp_kit/sp_kit.dart';
import 'package:flutter/material.dart';

// Assuming you have an SVG asset at 'assets/icons/my_icon.svg'
Widget mySvgIcon = 'assets/icons/my_icon.svg'.toImage(width: 24, height: 24, color: Colors.blue);

// You can use it directly in your widget tree
// SvgPicture.asset is automatically handled.
Scaffold(
  appBar: AppBar(
    title: Text("SVG Image Example"),
  ),
  body: Center(
    child: mySvgIcon,
  ),
);
```

### 10. Date Extension

The `DateExtension` provides a convenient way to format `DateTime` objects into strings.

| Method                                                   | Description                                                                                   |
| -------------------------------------------------------- | --------------------------------------------------------------------------------------------- |
| `format(String format)`                                  | Formats a `DateTime` object into a string using a custom format.                              |
| `differsByMoreThan(DateTime other, int minuteThreshold)` | Checks if the difference between two `DateTime` objects exceeds a specified minute threshold. |

**Usage:**

```dart
import 'package:sp_kit/sp_kit.dart';

// Example usage
final now = DateTime.now();

print(now.format(DateExtension.ddMMyyyy)); // 28-09-2025
print(now.format(DateExtension.EEEEddMMyyyy)); // Sunday, 28 September 2025

final later = now.add(const Duration(minutes: 15));
print(later.differsByMoreThan(now, 10)); // true
print(later.differsByMoreThan(now, 20)); // false
```

**Available Format Constants:**

| Constant                        | Output                  |
| ------------------------------- | ----------------------- |
| `DateExtension.ddMMyyyy`        | "dd-MM-yyyy"            |
| `DateExtension.ddMMyyyyHHmmss`  | "dd-MM-yyyy HH:mm:ss"   |
| `DateExtension.yyyyMMddTHHmmss` | "yyyy-MM-dd'T'HH:mm:ss" |
| `DateExtension.hhmma`           | "hh:mm a"               |
| `DateExtension.EEEEddMMyyyy`    | "EEEE, dd MMMM yyyy"    |
| `DateExtension.MMMMyyyy`        | "MMMM yyyy"             |

### 11. Skeleton

The `Skeleton` widget provides a loading animation that can be used to indicate that data is being loaded. It supports both rectangular and circular shapes.

#### Rectangular Skeleton

The `Skeleton.rectangular` constructor creates a rectangular skeleton animation.

**Usage:**

```dart
import 'package:sp_kit/sp_kit.dart';

Skeleton.rectangular(
  width: 200,
  height: 20,
)
```

#### Circular Skeleton

The `Skeleton.circular` constructor creates a circular skeleton animation.

**Usage:**

```dart
import 'package:sp_kit/sp_kit.dart';

Skeleton.circular(
  width: 50,
  height: 50,
)
```

## 🎨 Theming

The `sp_kit` package includes a `SpTheme` class that provides a consistent theme for your application. It includes a light and dark theme with a predefined shape for widgets.

### Default Theme

The default theme uses a `RoundedRectangleBorder` with a radius of 8 for all shapes. This applies to buttons, cards, dialogs, and input fields.

### Customization

To customize the theme, you can create your own `ThemeData` objects and pass them to the `FlutterBase` in your `App` widget. You can use the `SpTheme` as a starting point by copying it and modifying it.

For example, you can create a `my_theme.dart` file in your project:

```dart
// lib/my_theme.dart
import 'package:flutter/material.dart';
import 'package:sp_kit/sp_kit.dart';

class MyTheme {
  static final light = Spheme.light.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
  );

  static final dark = SpTheme.dark.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
  );
}
```

Then, in your `MyApp` widget, you can use your custom theme:

```dart
// In your main application setup
class MyApp extends StatelessWidget {
  // ...
  @override
  Widget build(BuildContext context) {
    return FlutterBase(
      // ...
      child: MaterialApp.router(
        theme: MyTheme.light,
        darkTheme: MyTheme.dark,
        themeMode: ThemeMode.system, // Or any other theme mode
        routerConfig: _appRouter.config(),
        title: 'SP Kit Example',
      ),
    );
  }
}
```

## Form Validation

The `sp_kit` package includes a `Validators` class with a comprehensive set of static methods for form validation. These validators can be used with `TextFormField` and other form fields in Flutter.

### Usage

To use the validators, simply import the `validators.dart` file and call the desired validation method in the `validators` property of your form field.

```dart
import 'package:sp_kit/src/commons/validators.dart';

TextFormField(
  validator: (value) => Validators.required(value, message: 'Please enter a value'),
)
```

### Available Validators

| Method                                                                     | Description                                                          |
| -------------------------------------------------------------------------- | -------------------------------------------------------------------- |
| `required(String? value, {String? message})`                               | Checks if the value is not null and not empty.                       |
| `minLength(String? value, int minLength, {String? message})`               | Checks if the value has at least `minLength` characters.             |
| `maxLength(String? value, int maxLength, {String? message})`               | Checks if the value has at most `maxLength` characters.              |
| `email(String? value, {String? message})`                                  | Checks if the value is a valid email address.                        |
| `password(String? value, {String? message})`                               | Checks if the value is a valid password (at least 6 characters).     |
| `number(String? value, {String? message})`                                 | Checks if the value is a valid number.                               |
| `url(String? value, {String? message})`                                    | Checks if the value is a valid URL.                                  |
| `phone(String? value, {String? message})`                                  | Checks if the value is a valid phone number (10 digits).             |
| `date(String? value, {String? message})`                                   | Checks if the value is a valid date.                                 |
| `compare(String? value, String? otherValue, {required String message})`    | Checks if the value is the same as `otherValue`.                     |
| `notEmpty(String? value, {String? message})`                               | Checks if the value is not empty (trims whitespace).                 |
| `minValue(String? value, int minValue, {String? message})`                 | Checks if the value is a number greater than or equal to `minValue`. |
| `maxValue(String? value, int maxValue, {String? message})`                 | Checks if the value is a number less than or equal to `maxValue`.    |
| `creditCard(String? value, {String? message})`                             | Checks if the value is a valid credit card number.                   |
| `ipAddress(String? value, {String? message})`                              | Checks if the value is a valid IP address.                           |
| `slug(String? value, {String? message})`                                   | Checks if the value is a valid slug.                                 |
| `alpha(String? value, {String? message})`                                  | Checks if the value contains only alphabetic characters.             |
| `alphanumeric(String? value, {String? message})`                           | Checks if the value contains only alphanumeric characters.           |
| `isJson(String? value, {String? message})`                                 | Checks if the value is a valid JSON string.                          |
| `isJwt(String? value, {String? message})`                                  | Checks if the value is a valid JWT.                                  |
| `inList(String? value, List<String> list, {String? message})`              | Checks if the value is in the given list.                            |
| `notInList(String? value, List<String> list, {String? message})`           | Checks if the value is not in the given list.                        |
| `fileExtension(String? value, List<String> extensions, {String? message})` | Checks if the value is a valid file extension.                       |
| `creditCardExpirationDate(String? value, {String? message})`               | Checks if the value is a valid credit card expiration date.          |
| `cvv(String? value, {String? message})`                                    | Checks if the value is a valid CVV.                                  |
| `isbn(String? value, {String? message})`                                   | Checks if the value is a valid ISBN.                                 |

## SpTextFormField

The `SpTextFormField` is a wrapper around `TextFormField` that simplifies its usage with a `ValueNotifier`. It automatically handles the `TextEditingController` and keeps the `ValueNotifier` in sync with the input.

### Usage

```dart
import 'package:sp_kit/src/widgets/sp_text_form_field.dart';

final myValue = ValueNotifier<String>("");

SpTextFormField<String>(
  value: myValue,
  label: "My Value",
  hint: "Enter a value",
);
```

### With Converter

If you want to use a `ValueNotifier` with a type other than `String`, you can provide a `Converter`.

```dart
import 'package:sp_kit/src/widgets/sp_text_form_field.dart';

final myValue = ValueNotifier<int>(0);

SpTextFormField<int>(
  value: myValue,
  label: "My Value",
  hint: "Enter a number",
  converter: Converter<int>(
    fromValue: (value) => value.toString(),
    toValue: (value) => int.tryParse(value ?? '0') ?? 0,
  ),
);
```

## Debouncer

The `Debouncer` class helps to delay the execution of a function. This is useful for scenarios like search fields, where you want to wait for the user to stop typing before performing a search.

### Usage

```dart
import 'package:sp_kit/src/commons/debouncer.dart';

final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

void onSearchChanged(String query) {
  _debouncer.run(() {
    print("Searching for $query");
  });
}
```

## EventBus

The `EventBus` provides a way for different parts of your application to communicate with each other without having direct references.

### Usage

#### Registering Events

```dart
import 'package:sp_kit/src/commons/event_bus.dart';

void onEvent(int id, dynamic data) {
  print("Received event with id: $id and data: $data");
}

EventBus.register([1, 2], onEvent);
```

#### Firing Events

```dart
import 'package:sp_kit/src/commons/event_bus.dart';

EventBus.fire(1, data: "Hello from EventBus!");
```

#### Unregistering Events

```dart
import 'package:sp_kit/src/commons/event_bus.dart';

EventBus.unregister([1, 2]);
```

## Logger

The `log` function is a simple utility that prints messages to the console only when the application is in debug mode.

### Usage

```dart
import 'package:sp_kit/src/commons/logger.dart';

void myFunction() {
  log("This is a debug message");
}
```

## ValueNotifierWithListener

The `ValueNotifierWithListener` is a `ValueNotifier` that triggers a callback function whenever its value changes. This is useful for scenarios where you need to react to value changes without manually adding and removing listeners.

### Usage

```dart
import 'package:sp_kit/sp_kit.dart';

final counter = ValueNotifierWithListener<int>(0, (value) {
  print("Counter changed to: $value");
});

// To change the value and trigger the callback
counter.value = 1; // This will print "Counter changed to: 1"
```

### 12. Feature Flag

The `sp_kit` package includes a reactive feature flag system that allows you to dynamically enable or disable features in your application. When you update a feature flag, any widgets that depend on it will automatically rebuild. This is useful for A/B testing, rolling out new features gradually, or hiding unfinished features.

#### Core Concepts

- **`SpFeatureFlag`**: An abstract class that holds the feature flags for your application. You should extend this class to define your own feature flags.
- **`SpFlag`**: A class that represents a single feature flag. It contains a boolean `enabled` property. You can extend this class to add more properties to your feature flags.
- **`SpFeatureGuard`**: A widget that conditionally shows or hides its child based on a feature flag. It automatically rebuilds when the flag's value changes.

#### Static Feature Flags

Static feature flags are defined in your code.

##### Example

First, define your feature flags by extending `SpFlag`:

```dart
// lib/flags/my_feature_flags.dart
import 'package:sp_kit/sp_kit.dart';

class NewVersionFlag extends SpFlag {
  NewVersionFlag(super.enabled);
  final String version = "1.0.1-pro";
}
```

Next, create a class that extends `SpFeatureFlag` and register your flags:

```dart
// lib/flags/my_feature_flags.dart
class StaticFeatureFlag extends SpFeatureFlag {
  @override
  Map<String, SpFlag> get featureFlags => {
    'new_version': NewVersionFlag(false),
  };
}
```

Finally, register your feature flags in the `FlutterBase` widget:

```dart
// In your main application setup
final featureFlag = StaticFeatureFlag();

FlutterBase(
  // ...
  featureFlag: featureFlag,
  child: MaterialApp.router(
    // ...
  ),
);
```

#### Remote Feature Flags & Reactivity

You can update feature flags at any time, and the UI will react automatically. This is useful for remote feature flags that are fetched from a server.

##### Example

Create a class that extends `SpFeatureFlag` and fetches the flags from a remote source:

```dart
// lib/flags/my_feature_flags.dart
class RemoteFeatureFlag extends SpFeatureFlag {
  @override
  final Map<String, SpFlag> featureFlags = {};

  Future<void> fetchFlags() async {
    // Fetch flags from your remote source
    final remoteFlags = await MyApiService.fetchFlags(); // This is a mock service

    final flags = <String, SpFlag>{};
    for (var flag in remoteFlags.entries) {
      flags[flag.key] = SpFlag(flag.value);
    }

    // Update the flags
    updateFeatureFlags(flags);
  }
}
```

Then, you can fetch the flags when your app starts or at any other time:

```dart
// In your main application setup
final remoteFeatureFlag = RemoteFeatureFlag();
await remoteFeatureFlag.fetchFlags();

FlutterBase(
  // ...
  featureFlag: remoteFeatureFlag,
  child: MaterialApp.router(
    // ...
  ),
);

// You can update the flags at any time
Future.delayed(const Duration(seconds: 5), () {
  remoteFeatureFlag.updateFeatureFlags({
    'new_feature': SpFlag(true),
  });
});
```

#### Using `SpFeatureGuard`

The `SpFeatureGuard` widget allows you to show or hide a widget based on a feature flag. It automatically rebuilds when the flag's value changes.

```dart
import 'package:sp_kit/sp_kit.dart';

SpFeatureGuard(
  flagKey: 'new_version',
  on: MyNewWidget(),
  off: MyOldWidget(), // Optional
)
```

If the `new_version` flag is enabled, `MyNewWidget` will be shown. Otherwise, `MyOldWidget` will be shown. If `off` is not provided, nothing will be shown.

#### Accessing Flag Values

You can also access the flag values directly in your code:

```dart
import 'package:sp_kit/sp_kit.dart';

final newVersionFlag = SpFeatureFlag.getFeature('new_version') as NewVersionFlag;
print(newVersionFlag.version); // 1.0.1-pro
```

## 13. CLI Tools

The `sp_kit` package includes a command-line interface (CLI) tool that provides utilities to streamline development workflows, such as creating new applications and adding features.

To run `sp_kit` commands, use `dart run sp_kit:<command>`.

### Global Options

- `--help` or `-h`: Displays help information and available commands for the `sp_kit` CLI.

  #### Usage

  ```bash
  dart run sp_kit --help
  ```

### `create_app`

Creates a new Flutter application pre-configured with the `sp_kit` structure and best practices.

#### Usage

```bash
dart run sp_kit:create_app --name <app_name>
```

Replace `<app_name>` with the desired name for your new Flutter project.

### `feature_add`

Adds a new feature module to an existing `sp_kit` application. This command helps scaffold the necessary files and directories for a new feature.

#### Usage

```bash
dart run sp_kit:feature_add --name <feature_name>
```

Replace `<feature_name>` with the name of the feature you want to add.

## Example Project

The `example` directory contains a complete Flutter application demonstrating all the features of this library. To run it, navigate to the `example` folder and execute:

```bash
flutter run
```

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

_Copyright (c) 2025 SOPHOUN NHEUM_
