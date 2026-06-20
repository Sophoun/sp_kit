---
name: flutter-sp-kit
description: Best practices for sp_kit — a Flutter foundation library providing dependency injection, reactive state management (ObserverValue/Observe), localization, responsive UI, feature flags, Either-based error handling, and utility extensions.
metadata:
  origin: custom
---

# Flutter sp_kit Best Practices

A comprehensive guide for using `sp_kit` — a foundational Flutter library that streamlines dependency injection, state management, localization, responsive UI, and common patterns.

## When to Activate

- Building Flutter apps with `sp_kit` as the foundation
- Setting up dependency injection with `ServiceLocator`
- Managing state with `ObserverValue` and `Observe` widgets
- Implementing localization with `LocaleRegister`
- Handling async operations with `Either` monad
- Building responsive UIs with screen scaling
- Using feature flags for conditional rendering
- Implementing form validation and reactive form fields

## App Bootstrap

### Root Widget Setup

Always use `SpKit` as your root widget. It bootstraps DI, localization, theming, connectivity monitoring, and screen scaling.

```dart
void main() async {
  await Pref.init();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SpKit(
      designSize: const Size(360, 690),
      serviceLocator: setupServiceLocator(),
      locale: setupLocale(),
      routerConfig: _appRouter.config(),
      theme: MyTheme.light,
      darkTheme: MyTheme.dark,
      themeMode: ThemeMode.system,
    );
  }
}
```

**Best Practices**:
- Call `Pref.init()` before `runApp()` if accessing preferences in `main()`
- Use `routerConfig` for auto_route integration (recommended over `body`)
- Set `designSize` to match your Figma/design tool dimensions
- Customize themes via `SpTheme.light.copyWith(...)` rather than creating from scratch

## Dependency Injection

### ServiceLocator Pattern

Use `ServiceLocator` for all dependency registration. Register in a single setup function.

```dart
ServiceLocator setupServiceLocator() {
  return ServiceLocator()
    ..register(ApiClient())
    ..registerLazy((c) => UserRepository(c.get()))
    ..registerLazy((c) => HomeVm(c.get()));
}
```

**Best Practices**:
- Use `register()` for singletons that should be created immediately
- Use `registerLazy()` for expensive objects or those with dependencies
- Always pass dependencies via the factory callback parameter `c`
- Register ViewModels in the ServiceLocator for global access
- Create a dedicated `injection.dart` or `service_locator.dart` file

### Accessing Dependencies

Use `inject<T>()` extension available on widgets, states, and ChangeNotifiers:

```dart
class HomeVm extends ChangeNotifier {
  late final _repository = inject<UserRepository>();
  
  void loadData() {
    _repository.fetchUsers();
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final vm = inject<HomeVm>();
    return Observe(() => Text(vm.title.value));
  }
}
```

**Best Practices**:
- Use `late final` for injected dependencies in ViewModels
- Prefer `inject<T>()` over `getVm<T>()` for consistency
- Never create new instances of registered services manually

## State Management

### ObserverValue for Reactive State

Use `ObserverValue<T>` (via `.ob` extension) for reactive state that automatically updates UI:

```dart
class HomeVm extends ChangeNotifier {
  final counter = 0.ob;
  final title = "Home".ob;
  final items = <String>[].ob;
  
  void increment() {
    counter.value++;
  }
  
  void updateTitle(String newTitle) {
    title.value = newTitle;
  }
}
```

### Observe Widget

Wrap UI that depends on `ObserverValue` with `Observe`:

```dart
Observe(() => Column(
  children: [
    Text(vm.title.value),
    Text('Count: ${vm.counter.value}'),
    if (vm.items.value.isNotEmpty)
      ListView.builder(
        itemCount: vm.items.value.length,
        itemBuilder: (_, i) => Text(vm.items.value[i]),
      ),
  ],
));
```

**Best Practices**:
- Access `.value` inside `Observe` to auto-track dependencies
- Keep `Observe` widgets small and focused — avoid wrapping entire screens
- Multiple `ObserverValue` accesses in one `Observe` are all tracked
- Use `Observe` for fine-grained reactivity, not `ValueListenableBuilder`

### Global Loading State

Use `postLoading()` extension on `ChangeNotifier` for app-wide loading overlays:

```dart
class HomeVm extends ChangeNotifier {
  Future<void> loadData() async {
    postLoading(true);
    try {
      final data = await _repository.fetch();
      items.value = data;
    } finally {
      postLoading(false);
    }
  }
}
```

**Best Practices**:
- Always use `try/finally` to ensure `postLoading(false)` is called
- The loading overlay is managed by `SpKit` — don't create your own
- Use for long operations (>1 second) that block user interaction

## Error Handling with Either

### Functional Error Handling

Use `toEither()` for type-safe error handling without try/catch:

```dart
Future<Either<User, EitherException>> getUser(String id) async {
  return api.get('/users/$id').toEither();
}

void loadUser() async {
  final result = await getUser("123");
  switch (result) {
    case Right(value: final user):
      currentUser.value = user;
    case Left(value: final error):
      showToast("Error: ${error.message}");
  }
}
```

### Chaining Operations with bind

Use `bind()` to chain multiple Either-returning operations:

```dart
Future<Either<Profile, EitherException>> getFullProfile() async {
  return await api.login(credentials).toEither()
    .bind((token) => api.getUser(token).toEither())
    .bind((user) => api.getProfile(user.id).toEither());
}
```

**Best Practices**:
- Use `EitherException` with `code` and `message` for structured errors
- Chain with `bind()` when each step depends on the previous success
- Handle errors at the presentation layer with pattern matching
- Use `execute()` for simpler cases where you just need callbacks:

```dart
fetchData().execute(
  onStart: () => postLoading(true),
  onSuccess: (data) => items.value = data,
  onError: (e) => showToast(e.toString()),
  onEnd: () => postLoading(false),
);
```

## Localization

### Type-Safe Translations

Define an abstract language contract, implement per locale, register in `SpKit`:

```dart
abstract class AppLang extends AppLocalize {
  AppLang({required super.lang});
  String get appName;
  String itemCount(int count);
}

class En extends AppLang {
  En() : super(lang: Lang.en);
  @override
  String get appName => "My App";
  @override
  String itemCount(int count) => "$count items";
}

LocaleRegister<AppLang> setupLocale() {
  return LocaleRegister<AppLang>()
    ..register(En())
    ..register(Kh())
    ..changeLang(Lang.en);
}
```

### Accessing Translations

Use `context.t<T>()` for type-safe translation access:

```dart
Widget build(BuildContext context) {
  final t = context.t<AppLang>();
  return Text(t.appName);
}
```

### Changing Language

```dart
context.local.register.changeLang(Lang.km);
```

**Best Practices**:
- Define all translation keys in the abstract class
- Use methods for dynamic values: `String itemCount(int count)`
- Access translations via `context.t<AppLang>()` — never hardcode strings
- Language changes automatically rebuild the widget tree

## Responsive UI

### Screen Scaling

Use `.w`, `.h`, `.sp` extensions for responsive dimensions:

```dart
Container(
  width: 150.w,
  height: 200.h,
  padding: EdgeInsets.all(16.w),
  child: Text(
    "Hello",
    style: TextStyle(fontSize: 18.sp),
  ),
)
```

### ResponsiveLayout Widget

Use for completely different layouts per screen size:

```dart
ResponsiveLayout(
  mobile: MobileHomePage(),
  tablet: TabletHomePage(),
  desktop: DesktopHomePage(),
)
```

**Best Practices**:
- Use `.w` for widths and horizontal padding
- Use `.h` for heights and vertical spacing
- Use `.sp` for font sizes
- Use `ResponsiveLayout` only when layouts differ significantly
- For minor adjustments, use `MediaQuery` or conditional logic

## Feature Flags

### Registering Flags

```dart
SpFeatureFlag.registerFlags({
  SpFlag(
    key: 'new_dashboard',
    enabled: true,
    description: 'Enables the new dashboard UI',
    value: 'v2',
  ),
  SpFlag(
    key: 'beta_features',
    enabled: false,
  ),
});
```

### Conditional Rendering

```dart
SpFeatureGuard(
  flagKey: 'new_dashboard',
  on: NewDashboard(),
  off: OldDashboard(),
)
```

### Programmatic Access

```dart
final flag = SpFeatureFlag.getFeature('new_dashboard');
if (flag.enabled) {
  print('Version: ${flag.value}');
}
```

**Best Practices**:
- Register all flags at app startup in `main()`
- Use `SpFeatureGuard` for widget-level conditionals
- Use `SpFeatureFlag.getFeature()` for logic-level checks
- Flags are reactive — updates trigger rebuilds

## Utility Extensions

### Spacing

```dart
16.height              // SizedBox(height: 16)
16.width               // SizedBox(width: 16)
16.paddingAll          // EdgeInsets.all(16)
16.paddingHorizontal   // EdgeInsets.symmetric(horizontal: 16)
16.paddingVertical     // EdgeInsets.symmetric(vertical: 16)
```

### Numbers

```dart
final amount = 1234.56;
amount.formatAmount(2)                    // "1,234.56"
amount.formatCurrencySuffix(symbol: '$')  // "$ 1,234.56"
amount.formatCurrencyPrefix(symbol: 'USD') // "1,234.56 USD"

final num? nullable = null;
nullable.isNullOrZero      // true
nullable.toStringAsFixedSafe(2)  // "0"
```

### Strings

```dart
final String? name = null;
name.orEmpty              // ""
name.orDefault("Guest")   // "Guest"
"".isNullOrEmpty          // true

"hello world".toCapitalFirst  // "Hello world"
"hello world".toCapitalEach   // "Hello World"
```

### Dates

```dart
final now = DateTime.now();
now.format(DateExtension.ddMMyyyy)           // "28-09-2025"
now.format(DateExtension.EEEEddMMyyyy)       // "Sunday, 28 September 2025"
now.format(DateExtension.ddMMyyyyHHmmss)     // "28-09-2025 14:30:45"
```

### Context Extensions

```dart
context.theme           // Theme.of(context)
context.textTheme       // Theme.of(context).textTheme
context.colorScheme     // Theme.of(context).colorScheme
context.hideKeyboard()  // Unfocus
context.safePop()       // Pop if canPop()
```

## Dialogs and Toasts

### Message Dialogs

```dart
showMessage(
  type: MessageDialogType.okCancel,
  title: "Confirm Delete",
  message: "Are you sure?",
  onOk: () => deleteItem(),
  onCancel: () => log("Cancelled"),
);
```

### Toasts and SnackBars

```dart
showToast("Item saved");
showSnackBar("Undo available");
```

**Best Practices**:
- Use `showToast()` for brief, non-critical feedback
- Use `showMessage()` for confirmations requiring user action
- Use `showSnackBar()` for actionable messages with undo

## Form Fields

### Reactive Form Fields

Use `SpTextFormField` with `ObserverValue` for two-way binding:

```dart
final email = "".ob;
final age = 0.ob;

SpTextFormField<String>(
  value: email,
  label: "Email",
  hint: "Enter email",
  validator: (v) => Validators.email(v),
)

SpTextFormField<int>(
  value: age,
  converter: Converter(
    fromValue: (v) => v.toString(),
    toValue: (v) => int.tryParse(v ?? "0") ?? 0,
  ),
  keyboardType: TextInputType.number,
)
```

### Validation

Use the `Validators` class for common validations:

```dart
TextFormField(
  validator: (v) => Validators.required(v, message: 'Required'),
)
```

## EventBus

### Publishing and Subscribing

```dart
EventBus.register([1, 2], (id, data) {
  log("Event $id: $data");
});

EventBus.fire(1, data: "Hello");

EventBus.unregister([1, 2]);
```

**Best Practices**:
- Define event IDs as constants in a dedicated file
- Unregister in `dispose()` to prevent memory leaks
- Use for cross-feature communication only — prefer direct calls otherwise

## Debouncer

```dart
final _debouncer = Debouncer(delay: Duration(milliseconds: 500));

void onSearchChanged(String query) {
  _debouncer.run(() => search(query));
}
```

## Skeleton Loading

```dart
Skeleton.rectangular(width: 200, height: 20)
Skeleton.circular(width: 50, height: 50)
```

Use while data is loading to improve perceived performance.

## Project Structure (from CLI)

Use the CLI tools to scaffold projects and features:

```bash
dart run sp_kit:create_app --name my_app
dart run sp_kit:feature_add --name profile
```

**Recommended Structure**:
```
lib/
  core/
    network/api_client.dart
    theme/palette/, text/
    utils/
  features/<name>/
    domain/
    repository/
    presentation/pages/, view_models/, widgets/
  lang/
  router/
  injection.dart
  main.dart
```

## Anti-Patterns to Avoid

- **Don't** create manual `ValueNotifier` when `ObserverValue` is available — use `.ob`
- **Don't** wrap entire screens in `Observe` — keep it granular
- **Don't** call `postLoading()` outside of `ChangeNotifier` subclasses
- **Don't** hardcode strings — always use the localization system
- **Don't** use `MediaQuery.of(context).size` — use `.w` and `.h` extensions
- **Don't** register services multiple times — check for existing registrations
- **Don't** forget to call `Pref.init()` before accessing preferences
- **Don't** use `EventBus` for parent-child communication — use callbacks or ViewModels
- **Don't** catch exceptions manually when using `toEither()` — let it handle errors
- **Don't** forget to unregister `EventBus` listeners in `dispose()`

## Testing

When testing code that uses sp_kit:

```dart
test('counter increments', () {
  final vm = HomeVm();
  vm.increment();
  expect(vm.counter.value, 1);
});

testWidgets('Observe rebuilds on value change', (tester) async {
  final counter = 0.ob;
  await tester.pumpWidget(
    MaterialApp(
      home: Observe(() => Text('${counter.value}')),
    ),
  );
  expect(find.text('0'), findsOneWidget);
  
  counter.value = 5;
  await tester.pump();
  expect(find.text('5'), findsOneWidget);
});
```

## Migration Checklist

When adopting sp_kit in an existing project:

1. Replace `Provider`/`Riverpod` with `ServiceLocator` + `ObserverValue`
2. Replace `GetX` observables with `.ob` and `Obx` with `Observe`
3. Replace `flutter_screenutil` with sp_kit's `.w`/`.h`/`.sp` extensions
4. Replace manual `SharedPreferences` access with `Pref` and `p` getter
5. Replace try/catch blocks with `toEither()` for API calls
6. Replace hardcoded strings with `context.t<AppLang>()` calls
7. Replace `MediaQuery` size checks with `ResponsiveLayout` or extensions

## References

- Package: `sp_kit` v1.0.0
- Repository: https://github.com/sophoun/sp_flkit
- Flutter SDK: `^3.9.0`, Dart SDK: `^3.9.0`
- Key dependencies: `http`, `shared_preferences`, `flutter_svg`, `auto_route`