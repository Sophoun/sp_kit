import 'dart:async';
export 'screen_extension.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:sp_kit/sp_kit.dart';
import 'package:sp_kit/src/localization/localize_inherited.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Convert any value to vale notifier
extension ToValueNotifier<T> on T {
  ValueNotifier<T> get notifier {
    return ValueNotifier(this);
  }
}

/// Vallue notifier builder function
extension ValueNotifierAsWidgetBuilder<T> on ValueNotifier<T> {
  /// Converts the ValueNotifier to a Widget that rebuilds when the value changes.
  Widget builder({required Widget Function(T value) build, Key? key}) {
    return ValueListenableBuilder<T>(
      valueListenable: this,
      builder: (context, value, child) {
        return build(value);
      },
      key: key,
    );
  }
}

/// Group Value notifier builder function
extension GroupValueNotifierAsWidgetBuilder on List<ValueNotifier<dynamic>> {
  /// Converts the ValueNotifier to a Widget that rebuilds when the value changes.
  Widget builder({
    required Widget Function(List<dynamic> values) build,
    Key? key,
  }) {
    return ValueListenableBuilder<List<dynamic>>(
      valueListenable: _GroupValueListenable(listenables: this),
      builder: (context, value, child) {
        return build(value);
      },
      key: key,
    );
  }
}

/// Combine value notifier turple 2
Widget combineValueNotifierT2<T1, T2>(
  ValueNotifier<T1> n1,
  ValueNotifier<T2> n2,
  Function(T1, T2) builder,
) {
  return [n1, n2].builder(
    build: (values) {
      return builder(values[0] as T1, values[1] as T2);
    },
  );
}

/// Combine value notifier turple 3
Widget combineValueNotifierT3<T1, T2, T3>(
  ValueNotifier<T1> n1,
  ValueNotifier<T2> n2,
  ValueNotifier<T3> n3,
  Function(T1, T2, T3) builder,
) {
  return [n1, n2, n3].builder(
    build: (values) {
      return builder(values[0] as T1, values[1] as T2, values[2] as T3);
    },
  );
}

/// Combine value notifier turple 4
Widget combineValueNotifierT4<T1, T2, T3, T4>(
  ValueNotifier<T1> n1,
  ValueNotifier<T2> n2,
  ValueNotifier<T3> n3,
  ValueNotifier<T4> n4,
  Function(T1, T2, T3, T4) builder,
) {
  return [n1, n2, n3, n4].builder(
    build: (values) {
      return builder(
        values[0] as T1,
        values[1] as T2,
        values[2] as T3,
        values[3] as T4,
      );
    },
  );
}

/// Combine value notifier turple 5
Widget combineValueNotifierT5<T1, T2, T3, T4, T5>(
  ValueNotifier<T1> n1,
  ValueNotifier<T2> n2,
  ValueNotifier<T3> n3,
  ValueNotifier<T4> n4,
  ValueNotifier<T5> n5,
  Function(T1, T2, T3, T4, T5) builder,
) {
  return [n1, n2, n3, n4, n5].builder(
    build: (values) {
      return builder(
        values[0] as T1,
        values[1] as T2,
        values[2] as T3,
        values[3] as T4,
        values[4] as T5,
      );
    },
  );
}

/// Group value listenable helper class
class _GroupValueListenable extends ValueListenable<List<dynamic>> {
  List<ValueNotifier<dynamic>> listenables = List.from([]);

  _GroupValueListenable({required this.listenables});

  @override
  void addListener(VoidCallback listener) {
    for (var e in listenables) {
      e.addListener(listener);
    }
  }

  @override
  void removeListener(VoidCallback listener) {
    for (var e in listenables) {
      e.removeListener(listener);
    }
  }

  @override
  get value => listenables.map((e) => e.value).toList();
}

/// Is loading
final isAppLoading = ValueNotifier(false);

/// Post loading value
extension PostLoadingExtension on ChangeNotifier {
  /// Post loading value
  void postLoading(bool loading) {
    isAppLoading.value = loading;
  }
}

///
/// Get di/vm extensions
///
extension StatelessExtension on StatelessWidget {
  T inject<T>() => ServiceLocator().get<T>();
}

extension StatefulExtension on StatefulWidget {
  T inject<T>() => ServiceLocator().get<T>();
}

extension StateExtension on State {
  T inject<T>() => ServiceLocator().get<T>();
}

extension ChangeNotifierExtension on ChangeNotifier {
  T inject<T>() => ServiceLocator().get<T>();
}

/// Language extension
extension LanguageExtension on BuildContext {
  LocalizeInherited get local => LocalizeInherited.of(this);
  T t<T>() => local.register.l as T;
}

/// Message dialog
final messageDialog =
    StreamController<MapEntry<bool, MessageDialogData>>.broadcast();

/// Message dialog data that hold all data needed by dialog
class MessageDialogData {
  final String? title;
  final String? message;
  final MessageDialogType type;
  final String okText;
  final String cancelText;
  final Function()? onOk;
  final Function()? onCancel;

  const MessageDialogData({
    this.title,
    this.message,
    this.type = MessageDialogType.okCanncel,
    this.onOk,
    this.onCancel,
    this.okText = "Ok",
    this.cancelText = "Cancel",
  });
}

/// Message dialog type, to distingue between dialog style
enum MessageDialogType { ok, okCanncel, toast }

/// Show message dialog
void showMessage({
  String? title,
  required String message,
  Function()? onOk,
  Function()? onCancel,
  MessageDialogType type = MessageDialogType.ok,
  String okText = "Ok",
  String cancelText = "Cancel",
}) {
  messageDialog.sink.add(
    MapEntry(
      true,
      MessageDialogData(
        title: title,
        message: message,
        onOk: onOk,
        onCancel: onCancel,
        type: type,
        okText: okText,
        cancelText: cancelText,
      ),
    ),
  );
}

/// Show message toast
void showToast(String message) {
  showMessage(message: message, type: MessageDialogType.toast);
}

/// Hide message dialog
void hideMessage() {
  messageDialog.sink.add(MapEntry(false, MessageDialogData()));
}

/// Provide the preferencessor
SharedPreferences get p => Pref.instance().p;

/// Global messenger key
final GlobalKey<material.ScaffoldMessengerState> globalScaffoldMessengerKey =
    GlobalKey<material.ScaffoldMessengerState>();

/// Show snackbar anywhere you want
void showSnackBar(String message) {
  globalScaffoldMessengerKey.currentState?.showSnackBar(
    material.SnackBar(content: Text(message)),
  );
}

/// Observer: it's for the type provider to Rx widget.
abstract class Observer {
  void update();
}

/// Observer proxy: it's hold our observer to build the Rx widget.
class ObserverProxy {
  static Observer? proxy;
}

/// Reactive: It's a type that make the update happened when the value change
/// and register widget observer to listener via proxy.
class Reactive<T> {
  T _value;
  final Set<Observer> _listeners = {};

  Reactive(this._value);

  T get value {
    if (ObserverProxy.proxy != null) {
      _listeners.add(ObserverProxy.proxy!);
    }
    return _value;
  }

  set value(T value) {
    if (_value == value) return;
    _value = value;
    for (var listener in _listeners) {
      listener.update();
    }
  }
}

/// Extend any value to reactive type
extension ReactiveExtension<T> on T {
  Reactive<T> get rx {
    return Reactive<T>(this);
  }
}

/// Rx widget: work with reactive type. It's rebuild if the reactive value change.
class Rx extends material.StatefulWidget {
  const Rx(this.builder, {super.key});

  final Widget Function() builder;

  @override
  State<Rx> createState() => _RxState();
}

class _RxState extends material.State<Rx> implements Observer {
  @override
  material.Widget build(material.BuildContext context) {
    ObserverProxy.proxy = this;
    final notifierWidget = widget.builder();
    ObserverProxy.proxy = null;
    return notifierWidget;
  }

  @override
  void update() {
    if (mounted) {
      setState(() {});
    }
  }
}
