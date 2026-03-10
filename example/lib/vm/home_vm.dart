import 'package:example/service/mock_service.dart';
import 'package:flutter/widgets.dart';
import 'package:sp_kit/sp_kit.dart';

class HomeVm extends ChangeNotifier {
  late final mockService = inject<MockService>();

  /// Counter variable
  final counter = 10.notifier;

  /// Mock value
  final mockValue = ValueNotifier("unknow");

  /// Try show loading
  Future<void> tryShowLoading() async {
    postLoading(true);
    await Future.delayed(Duration(milliseconds: 500));
    postLoading(false);
  }

  Future<void> loadingForever() async {
    postLoading(true);
  }

  /// increment counter
  void incrementCounter() {
    counter.value++;
    EventBus.fire(1, data: "Hi in");
  }

  /// decrement counter
  void decrementCounter() {
    if (counter.value > 0) {
      counter.value--;
    }
    EventBus.fire(2, data: "Hi de");
  }

  /// get mock data
  void getMockData() {
    mockService.getHelloWorld().execute(
      onStart: () => postLoading(true),
      onEnd: () => postLoading(false),
      onSuccess: (data) {
        mockValue.value = data;
      },
      onError: (e) {
        log(e.toString());
      },
    );
  }
}
