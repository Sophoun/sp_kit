/// View Model content
String viewModelTemplate(String projectName, String className) => """
import 'package:flutter/widgets.dart';
import 'package:$projectName/features/${className.toLowerCase()}/repository/${className.toLowerCase()}_repository.dart';

class ${className}Vm extends ChangeNotifier {
  ${className}Vm(this._${className.toLowerCase()}Repository);

  final ${className}Repository _${className.toLowerCase()}Repository;
}
""";

/// Feature page content
String featurePageTemplate(String packageName, String className) => """
import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:$packageName/core/theme/theme_controller.dart';
import 'package:$packageName/core/theme/theme_extension.dart';
import 'package:$packageName/features/${className.toLowerCase()}/presentation/view_models/${className.toLowerCase()}_vm.dart';
import 'package:sp_kit/sp_kit.dart';

@RoutePage()
class ${className}Page extends StatelessWidget {
  const ${className}Page({super.key});

  ${className}Vm get vm => inject<${className}Vm>();
  ThemeController get themeController => inject<ThemeController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 12.h,
          children: [
            Text('${className}Page', style: context.appTextStyle?.h1),
            ElevatedButton(
              onPressed: () {
                themeController.updateTheme(AppThemeType.midnight);
              },
              child: Text("Change theme", style: context.appTextStyle?.button),
            ),
          ],
        ),
      ),
    );
  }
}
""";

/// Feature repository content
String featureRepositoryTemplate(String projectName, String className) => """
import 'package:$projectName/core/network/api_client.dart';

class ${className}Repository {
  ${className}Repository(this._apiClient);

  final ApiClient _apiClient;
}
""";
