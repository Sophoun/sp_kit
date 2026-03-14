import 'package:flutter/material.dart';
import 'package:sp_kit/sp_kit.dart';

// ignore: must_be_immutable
class MessageDialog extends StatelessWidget {
  MessageDialog({super.key});

  MessageDialogData? messageDialogData;

  void setData(MessageDialogData? data) {
    messageDialogData = data;
  }

  void onOk() {
    hideMessage();
    messageDialogData?.onOk?.call();
  }

  void onCancel() {
    hideMessage();
    messageDialogData?.onCancel?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (messageDialogData?.type == MessageDialogType.toast) {
      Future.delayed(Duration(seconds: 1), () {
        hideMessage();
        messageDialogData?.onCancel?.call();
      });
    }

    return PopScope(
      canPop: false,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black.withAlpha(alpha),
        child: Center(
          child: Container(
            width: width,
            decoration: boxDecoration(context),
            padding: EdgeInsets.all(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              spacing: 6,
              children: [
                if (messageDialogData?.title != null)
                  Flexible(child: dialogTitle(context)),
                Flexible(child: dialogContent(context)),
                // Show as OK
                if (messageDialogData?.type == MessageDialogType.ok)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 8,
                    children: [buttonOk(context)],
                  )
                // Show as OK and Cancel
                else if (messageDialogData?.type == MessageDialogType.okCancel)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    spacing: 8,
                    children: [buttonCancel(context), buttonOk(context)],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  double width = 230;
  int alpha = 100;

  Widget dialogTitle(BuildContext context) {
    return Text(
      messageDialogData?.title ?? "",
      style: Theme.of(context).textTheme.titleMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget dialogContent(BuildContext context) {
    return Text(
      messageDialogData?.message ?? "",
      style: Theme.of(context).textTheme.bodySmall,
      textAlign: TextAlign.center,
    );
  }

  Widget buttonCancel(BuildContext context) {
    return TextButton(
      onPressed: onCancel,
      child: Text(
        messageDialogData?.cancelText ?? "",
        style:
            Theme.of(context).textButtonTheme.style?.textStyle
                ?.resolve({})
                ?.copyWith(color: Colors.redAccent) ??
            TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget buttonOk(BuildContext context) {
    return TextButton(
      onPressed: onOk,
      child: Text(
        messageDialogData?.okText ?? "",
        style: Theme.of(context).textButtonTheme.style?.textStyle?.resolve({}),
      ),
    );
  }

  Decoration boxDecoration(BuildContext context) {
    return BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainer,
      borderRadius: BorderRadius.circular(12),
      // boxShadow: [
      //   BoxShadow(
      //     color: Theme.of(
      //       context,
      //     ).colorScheme.surfaceDim.withValues(alpha: 0.5),
      //     spreadRadius: 5,
      //     blurRadius: 10,
      //     offset: Offset(0, 5), // changes position of shadow
      //   ),
      // ],
    );
  }
}
