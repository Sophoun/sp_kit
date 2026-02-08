import 'package:auto_route/auto_route.dart';
import 'package:example/flags/static_feature_flag.dart';
import 'package:example/lang/app_lang.dart';
import 'package:example/vm/home_vm.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sp_kit/sp_kit.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  HomePage({super.key}) {
    EventBus.register([1, 2], (id, data) {
      switch (id) {
        case 1:
          log("Case 1 $data");
          break;
        case 2:
          log("Case 2 $data");
          break;
      }
    });
  }

  HomeVm get homeVm => inject<HomeVm>();
  final _inputDebounce = Debouncer();

  @override
  Widget build(BuildContext context) {
    final t = context.t<AppLang>();

    return Scaffold(
      appBar: AppBar(title: Text(t.appName())),
      body: ResponsiveLayout(
        mobile: _buildContent(context, t),
        tablet: _buildContent(context, t),
        desktop: _buildContent(context, t),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLang t) {
    return Container(
      padding: const EdgeInsets.all(12),
      child: ListView(
        children: [
          Text(DateTime.now().format(DateExtension.EddMMyyyy)),
          Text(DateTime.now().format(DateExtension.ddMMyyyyHHmm)),
          Text(DateTime.now().format(DateExtension.ddMMyy)),
          Text(DateTime.now().format(DateExtension.ddMMyyyy_hhmma)),
          Text(DateTime.now().format(DateExtension.ddMMyyyy_hhmms_a)),
          ElevatedButton(
            onPressed: () {
              homeVm.tryShowLoading();
            },
            child: Text("Loading", style: TextStyle(fontSize: 20.w)),
          ),
          ElevatedButton(
            onPressed: () {
              homeVm.loadingForever();
            },
            child: Text("Loading forever"),
          ),
          Text(t.currentLanguageIs(t.lang.name)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => context.local.register.changeLang(Lang.en),
                child: const Text("English"),
              ),
              OutlinedButton(
                onPressed: () => context.local.register.changeLang(Lang.km),
                child: const Text("Khmer"),
              ),
            ],
          ),
          homeVm.counter.builder(build: (value) => Text(t.count(value ?? 0))),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            spacing: 8,
            children: [
              OutlinedButton(
                onPressed: () => homeVm.incrementCounter(),
                child: const Text("increment"),
              ),
              OutlinedButton(
                onPressed: () => homeVm.decrementCounter(),
                child: const Text("decrement"),
              ),
            ],
          ),
          SizedBox(
            width: 200,
            child: SpTextFormField(
              value: homeVm.counter,
              converter: Converter(
                fromValue: (value) => value.toString(),
                toValue: (value) => int.tryParse(value ?? "0") ?? 0,
              ),
              label: "Counter mirror",
              hint: "Input any number you wish.",
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              helperText: "Only number allowed.",
              autofocus: true,
              onChanged: (value) => _inputDebounce.run(() => log(value)),
              onTap: () => log("Tapped"),
              onTapOutside: (_) => context.hideKeyboard(),
            ),
          ),
          SizedBox(
            width: 200,
            child: SpTextFormField(
              value: homeVm.counter,
              converter: Converter(
                fromValue: (value) => value.toString(),
                toValue: (value) => int.tryParse(value ?? "0") ?? 0,
              ),
              label: "Counter",
              hint: "Input any number you wish.",
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              helperText: "Only number allowed.",
              autofocus: true,
              onChanged: (value) => _inputDebounce.run(() => log(value)),
              onTap: () => log("Tapped"),
              onTapOutside: (_) => context.hideKeyboard(),
              selectAllOnFocus: true,
            ),
          ),
          homeVm.mockValue.builder(build: (value) => Text(value ?? "")),
          ElevatedButton(
            onPressed: () => homeVm.getMockData(),
            child: const Text("Get Mock Data"),
          ),
          ElevatedButton(
            onPressed: () => showMessage(
              type: MessageDialogType.okCanncel,
              title: "Welcome, to my longest title dialog",
              message:
                  "This is my longest Hello world, Hello world, Hello world, Hello world Hello world!",
              onOk: () {
                showToast("You clicked OK");
              },
              onCancel: () {
                showToast("You clicked Cancel");
              },
            ),
            child: const Text("Show message"),
          ),
          ElevatedButton(
            onPressed: () => showSnackBar("Hello from snakebar :snake:"),
            child: const Text("Show snackbar"),
          ),
          [homeVm.counter, homeVm.mockValue].builder(
            build: (value) => Text(t.count(value.first ?? 0) + value[1]),
          ),
          combineValueNotifierT2(
            homeVm.counter,
            homeVm.mockValue,
            (t1, t2) => Text("Count: $t1, mock value is: $t2"),
          ),
          Skeleton.circular(width: 100, height: 100),
          Skeleton.rectangular(width: 100, height: 12),
          SpFeatureGuard(
            flagKey: 'new_version',
            on: Center(
              child: Text(
                "New version available ${SpFeatureFlag.getFeatureByType<NewVersionFlag>().version}",
                style: context.textTheme?.bodyMedium?.copyWith(
                  color: Colors.green,
                ),
              ),
            ),
            off: Center(
              child: Text(
                "New version not available",
                style: context.textTheme?.bodyMedium?.copyWith(
                  color: Colors.red,
                ),
              ),
            ),
          ),
        ].map((e) => Padding(padding: EdgeInsets.all(5.w), child: e)).toList(),
      ),
    );
  }
}
