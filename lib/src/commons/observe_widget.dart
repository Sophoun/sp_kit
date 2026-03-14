import 'package:flutter/widgets.dart' as material;

////////////////////////////////////////////////////////////////////////////////
/// Observer widget pattern
////////////////////////////////////////////////////////////////////////////////

/// Observer: it's for the type provider to Rx widget.
abstract class Observer {
  void update();
  void track(ObserverValue observable);
}

/// Observer proxy: it's hold our observer to build the Rx widget.
class ObserverProxy {
  static final List<Observer> _stack = [];
  static Observer? get proxy => _stack.lastOrNull;
  static void push(Observer observer) {
    _stack.add(observer);
  }

  static void pop() {
    _stack.removeLast();
  }
}

/// ObserverValue: It's a type that make the update happened when the value change
/// and register widget observer to listener via proxy.
class ObserverValue<T> {
  T _value;
  final Set<Observer> _listeners = {};
  final Set<Function(T value)> _updateListeners = {};

  ObserverValue(this._value);

  /// Read value from observer and get listener from proxy to register.
  T get value {
    if (ObserverProxy.proxy != null) {
      _listeners.add(ObserverProxy.proxy!);
      ObserverProxy.proxy?.track(this);
    }
    return _value;
  }

  /// Set new value and notify all listeners
  set value(T value) {
    if (_value == value) return;
    _value = value;
    for (var listener in _listeners.toSet()) {
      listener.update();
    }
    for (var listener in _updateListeners.toSet()) {
      listener(value);
    }
  }

  /// Add value change listener manually
  void addListener(void Function(T value) listener) {
    _updateListeners.add(listener);
  }

  /// Remove value change listener manually
  void removeListener(void Function(T value) listener) {
    _updateListeners.remove(listener);
  }

  /// Remove observer
  void removeObserver(Observer observer) {
    _listeners.remove(observer);
  }
}

/// Extend any value to observer value type
extension AnyValueToObserverValueExtension<T> on T {
  ObserverValue<T> get ob {
    return ObserverValue<T>(this);
  }
}

/// Observe widget: work with Observer value type. It's rebuild if the observer value change.
class Observe extends material.StatefulWidget {
  const Observe(this.builder, {super.key});

  final material.Widget Function() builder;

  @override
  material.State<Observe> createState() => _ObserveState();
}

class _ObserveState extends material.State<Observe> implements Observer {
  final Set<ObserverValue> _observableValues = {};

  @override
  material.Widget build(material.BuildContext context) {
    _clearDependencies();
    ObserverProxy.push(this);
    try {
      return widget.builder();
    } finally {
      ObserverProxy.pop();
    }
  }

  @override
  void track(ObserverValue<dynamic> observable) {
    _observableValues.add(observable);
  }

  @override
  void update() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _clearDependencies();
    super.dispose();
  }

  // Sever all ties
  void _clearDependencies() {
    for (var observable in _observableValues) {
      observable.removeObserver(this);
    }
    _observableValues.clear();
  }
}

////////////////////////////////////////////////////////////////////////////////
/// Support for ValueNotifier
////////////////////////////////////////////////////////////////////////////////

final Expando<ObserverValue> _obCache = Expando();

extension ValueNotifierToOb<T> on material.ValueNotifier<T> {
  ObserverValue<T> get toOb {
    ///Check if we already created an observable for this notifier
    var ob = _obCache[this] as ObserverValue<T>?;

    if (ob == null) {
      /// If not, create a standard ObserverValue
      ob = ObserverValue<T>(value);

      /// Forward native updates to your custom observable
      addListener(() => ob!.value = value);

      /// Save it in the cache so we don't duplicate it on the next rebuild
      _obCache[this] = ob;
    }

    return ob;
  }
}
