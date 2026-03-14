# SP Kit

A foundational library for Flutter applications, designed to streamline development by providing a robust framework for dependency injection, state management (via ViewModels), localization, and responsive UI. It includes a collection of utility extensions to reduce boilerplate and simplify common Flutter patterns.

## ✨ Features

- **Service Locator:** A simple yet powerful service locator to manage your application's dependencies as singletons or lazy singletons.
- **ViewModel Management:** A dedicated container for managing `ChangeNotifier` instances, effectively separating business logic from the UI.
- **Localization:** An intuitive system for implementing multi-language support, allowing for easy registration and switching of languages.
- **Responsive UI:** Built-in support for creating responsive user interfaces that adapt to different screen sizes using `ScreenUtil`.
- **Utility Extensions:** A rich set of extensions for `BuildContext`, `ObserverValue` (`.ob`), and more, to write cleaner and more concise code.
- **Simplified Preferences:** Easy access to `SharedPreferences` for persistent key-value storage.
- **Built-in Dialogs & Toasts:** Quickly display common UI elements like alerts and toasts with minimal code.
- **Observer Pattern:** A reactive system using `ObserverValue` and the `Observe` widget for automatic UI updates.

## Public API

This library exposes a range of modules to streamline your Flutter development. Here is a list of the public APIs exported from `sp_kit`:

- **`sp_kit.dart`**: The main entry point of the library, providing the `SpKit` root widget.
- **`app_localize.dart` & `locale_register.dart`**: Core components for the localization system.
- **`service_locator.dart`**: The dependency injection container.
- **`state_extension.dart`**: Extensions for state management, including `inject`, `getVm`, the `isAppLoading` notifier, and the **Observer pattern** (`Observe`, `ObserverValue`).
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
- **`sp_text_form_field.dart`**: A `TextFormField` that integrates with `ObserverValue`.
- **`message_dialog.dart`**: A widget for displaying message dialogs.
- **`responsive.dart`**: The `ResponsiveLayout` widget for building responsive UIs.
- **`skeleton.dart`**: A widget for showing a skeleton loading animation.
- **`observe_widget.dart`**: Core components for the Observer pattern.

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

## Usage

### 1. Root Widget Setup (`SpKit`)

Use the `SpKit` widget as your root widget to provide the necessary containers (`ServiceLocator`, `LocaleRegister`) and screen utility initialization to the entire widget tree. `SpKit` internally manages the `MaterialApp` or `MaterialApp.router`.

#### Option A: Using `MaterialApp.router` (Recommended)

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
    return SpKit(
      // (Optional) Set the design size for responsive UI
      designSize: const Size(360, 690),
      
      // Register your dependencies
      serviceLocator: setupServiceLocator(),

      // Configure localization
      locale: setupLocale(),

      // Pass router configuration
      routerConfig: _appRouter.config(),
    );
  }
}
```

#### Option B: Using standard `MaterialApp` (with `body`)

```dart
    return SpKit(
      serviceLocator: setupServiceLocator(),
      locale: setupLocale(),
      body: const MyHomePage(),
    );
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

Register your languages in the `SpKit` widget and access them in your UI.

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

Manage your UI state with `ChangeNotifier` and `ObserverValue`.

#### Create a ViewModel

```dart
class HomeVm extends ChangeNotifier {
  late final _mockService = inject<MockService>();
  final counter = 0.ob;
  final title = "Home".ob;

  void increment() {
    counter.value++;
  }
}
```

#### Register and Access the ViewModel

```dart
// In your widget:
final homeVm = inject<HomeVm>(); // or getVm<HomeVm>()

// Use the Observe widget for reactive UI updates
Observe(() => Text(t.count(homeVm.counter.value)))
```

#### Reactive UI with Multiple Observables

The `Observe` widget automatically tracks any `ObserverValue` accessed within its builder and rebuilds when any of them changes.

```dart
// In your widget:
final homeVm = inject<HomeVm>();

Observe(() => Text('${homeVm.title.value}: ${homeVm.counter.value}'))
```

### 5. Utility Extensions

#### Responsive UI

Design your UI for a specific screen size, and it will scale automatically.

```dart
// Initialize in SpKit
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

Then, pass your custom dialog to the `SpKit` widget in your `main.dart` file:

```dart
// In your main application setup
SpKit(
  // ...
  messageDialogWidget: MyCustomDialog(),
  // ...
);
```

Now, whenever you call `showMessage()`, your `MyCustomDialog` will be displayed with your custom buttons and title style.

### 6. Spacing Extensions

Simplify spacing and padding with intuitive extensions on `num`.

```dart
// Add vertical space
16.height,

// Add horizontal space
16.width,

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
  child: const Text("Padded Content"),
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

The library includes a powerful `ResponsiveLayout` widget that supports different widgets for mobile, tablet, and desktop layouts.

#### Use the `ResponsiveLayout` Widget

Use the `ResponsiveLayout` widget to build different UI for different screen sizes.

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
    return Container(color: Colors.red, child: Center(child: Text("Mobile")));
  }
}

class TabletView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.green, child: Center(child: Text("Tablet")));
  }
}

class DesktopView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
Widget mySvgIcon = 'assets/icons/my_icon.svg'.toImage(width: 24, height: 24);

// You can use it directly in your widget tree
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

To customize the theme, you can create your own `ThemeData` objects and pass them to the `SpKit` widget.

For example, you can create a `my_theme.dart` file in your project:

```dart
// lib/my_theme.dart
import 'package:flutter/material.dart';
import 'package:sp_kit/sp_kit.dart';

class MyTheme {
  static final light = SpTheme.light.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
  );

  static final dark = SpTheme.dark.copyWith(
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.amber),
  );
}
```

Then, in your `SpKit` setup:

```dart
SpKit(
  // ...
  theme: MyTheme.light,
  darkTheme: MyTheme.dark,
  themeMode: ThemeMode.system,
  // ...
);
```

## Form Validation

The `sp_kit` package includes a `Validators` class with a comprehensive set of static methods for form validation.

### Usage

```dart
import 'package:sp_kit/sp_kit.dart';

TextFormField(
  validator: (value) => Validators.required(value, message: 'Please enter a value'),
)
```

## SpTextFormField

The `SpTextFormField` is a wrapper around `TextFormField` that simplifies its usage with an `ObserverValue`.

### Usage

```dart
import 'package:sp_kit/sp_kit.dart';

final myValue = "".ob;

SpTextFormField<String>(
  value: myValue,
  label: "My Value",
  hint: "Enter a value",
);
```

## Debouncer

The `Debouncer` class helps to delay the execution of a function.

### Usage

```dart
import 'package:sp_kit/sp_kit.dart';

final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

void onSearchChanged(String query) {
  _debouncer.run(() {
    print("Searching for $query");
  });
}
```

## EventBus

The `EventBus` provides a way for different parts of your application to communicate with each other.

### Usage

#### Registering Events

```dart
import 'package:sp_kit/sp_kit.dart';

void onEvent(int id, dynamic data) {
  print("Received event with id: $id and data: $data");
}

EventBus.register([1, 2], onEvent);
```

#### Firing Events

```dart
import 'package:sp_kit/sp_kit.dart';

EventBus.fire(1, data: "Hello from EventBus!");
```

#### Unregistering Events

```dart
import 'package:sp_kit/sp_kit.dart';

EventBus.unregister([1, 2]);
```

## Logger

The `log` function is a simple utility that prints messages to the console only when the application is in debug mode.

### Usage

```dart
import 'package:sp_kit/sp_kit.dart';

void myFunction() {
  log("This is a debug message");
}
```

## ObserverValue with Manual Listener

You can add a manual listener to an `ObserverValue`.

### Usage

```dart
import 'package:sp_kit/sp_kit.dart';

final counter = 0.ob;

counter.addListener((value) {
  print("Counter changed to: $value");
});

counter.value = 1;
```

### 12. Feature Flag

The `sp_kit` package includes a reactive feature flag system to toggle features and manage configuration dynamically.

#### Define and Register Flags

Use `SpFlag` to define your features and `SpFeatureFlag.registerFlags` to initialize them. `SpFlag` can also hold a generic value for additional configuration.

```dart
import 'package:sp_kit/sp_kit.dart';

void main() {
  SpFeatureFlag.registerFlags({
    SpFlag(
      key: 'experimental_mode',
      enabled: true,
      description: 'Enables experimental UI features',
      value: 'v2_layout', // Optional generic value
    ),
    SpFlag(
      key: 'maintenance_mode',
      enabled: false,
    ),
  });
}
```

#### Using `SpFeatureGuard`

Wrap your widgets with `SpFeatureGuard` to conditionally render content. It reactively rebuilds whenever the global feature flag state is updated.

```dart
import 'package:sp_kit/sp_kit.dart';

SpFeatureGuard(
  flagKey: 'experimental_mode',
  on: ExperimentalDashboard(),
  off: StandardDashboard(), // Optional: defaults to SizedBox.shrink()
)
```

#### Programmatic Access

Retrieve flags directly using `SpFeatureFlag.getFeature(key)`.

```dart
final flag = SpFeatureFlag.getFeature('experimental_mode');
if (flag.enabled) {
  print('Config value: ${flag.value}');
}
```

### 13. Observer Pattern

Reactive state management using `ObserverValue` and the `Observe` widget.

#### Usage Example

```dart
import 'package:sp_kit/sp_kit.dart';

final counter = 0.ob;

Observe(() => Text("Count: ${counter.value}"))
```

### 14. CLI Tools

Utilities to streamline development workflows.

```bash
dart run sp_kit:create_app --name <app_name>
dart run sp_kit:feature_add --name <feature_name>
```

## Example Project

The `example` directory contains a complete Flutter application demonstrating all the features of this library.

## 📄 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

---

_Copyright (c) 2025 SOPHOUN NHEUM_
