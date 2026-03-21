import 'package:flutter/material.dart';
import 'package:sp_kit/sp_kit.dart';

class NoInternetDialog extends StatelessWidget {
  const NoInternetDialog({super.key});

  @override
  Widget build(BuildContext context) {
    context.hideKeyboard();

    return Container(
      color: Colors.black38,
      width: double.infinity,
      height: double.infinity,
      alignment: Alignment.center,
      child: Container(
        height: 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.white,
        ),
        padding: EdgeInsets.all(30),
        child: Material(
          child: Text('No Internet', textDirection: TextDirection.rtl),
        ),
      ),
    );
  }
}
