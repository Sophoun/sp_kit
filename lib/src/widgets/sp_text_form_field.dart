import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sp_kit/sp_kit.dart';

/// Provide the base form field to easy handle with value notifier
// ignore: must_be_immutable
class SpTextFormField<T> extends StatefulWidget {
  SpTextFormField({
    super.key,
    required this.value,
    this.converter,
    this.keyboardType = TextInputType.text,
    this.decoration,
    this.label = "",
    this.hint = "",
    this.errorText,
    this.valildator,
    this.inputFormatters,
    this.helperText,
    this.readOnly = false,
    this.enabled,
    this.prefixIcon,
    this.suffixIcon,
    this.textAlign = TextAlign.start,
    this.style,
    this.autofocus = false,
    this.onChanged,
    this.onTap,
    this.onTapOutside,
    this.focusNode,
    this.showCursor,
    this.selectAllOnFocus,
    this.minLines,
    this.maxLines,
  }) {
    /// Decoration
    decoration ??= InputDecoration(
      labelText: label,
      hintText: hint,
      errorText: errorText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  final Reactive<T> value;
  final TextInputType keyboardType;
  InputDecoration? decoration;
  final Converter<T>? converter;
  final String label;
  final String hint;
  final String? errorText;
  final FormFieldValidator<String?>? valildator;
  final List<TextInputFormatter>? inputFormatters;
  final String? helperText;
  final bool readOnly;
  bool? enabled;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextAlign textAlign;
  final TextStyle? style;
  final bool autofocus;
  final void Function(String value)? onChanged;
  final void Function()? onTap;
  final void Function(PointerDownEvent)? onTapOutside;
  FocusNode? focusNode;
  final bool? showCursor;
  final bool? selectAllOnFocus;
  final int? minLines;
  final int? maxLines;

  @override
  State<SpTextFormField<T>> createState() => _SpTextFormFieldState<T>();
}

class _SpTextFormFieldState<T> extends State<SpTextFormField<T>> {
  TextEditingController? controller;

  /// Listen text change from the outside
  void outsideTextChangesListener(T value) {
    log("changes: ${widget.label}, ${widget.value.value}");
    // Update value
    controller?.value = TextEditingValue(
      text: widget.converter == null
          ? widget.value.value.toString()
          : widget.converter?.fromValue?.call(widget.value.value) ?? "",
      selection: TextSelection.collapsed(
        offset: widget.value.value.toString().length,
      ),
    );
  }

  @override
  void initState() {
    super.initState();

    /// Controller
    controller = TextEditingController(
      text: widget.converter == null
          ? widget.value.value.toString()
          : widget.converter?.fromValue?.call(widget.value.value),
    );

    /// Listen value change from outside
    widget.value.addListener(outsideTextChangesListener);
  }

  @override
  void dispose() {
    widget.value.removeListener(outsideTextChangesListener);
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: widget.keyboardType,
      selectAllOnFocus: widget.selectAllOnFocus,
      autofocus: widget.autofocus,
      decoration: widget.decoration,
      showCursor: widget.showCursor,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      onChanged: (newValue) {
        // Remove outside lister first
        widget.value.removeListener(outsideTextChangesListener);
        // Update value
        try {
          widget.value.value =
              (widget.converter == null
                      ? newValue
                      : widget.converter?.toValue?.call(newValue))
                  as T;
        } catch (e) {
          throw Exception(
            "Please, provide `converter` property to convert value from string to ${T.toString()}",
          );
        }
        // Add listener back when value updated
        widget.value.addListener(outsideTextChangesListener);

        /// Invoke onChnaged to listener
        widget.onChanged?.call(newValue);
      },
      validator: widget.valildator,
      inputFormatters: widget.inputFormatters,
      readOnly: widget.readOnly,
      enabled: widget.enabled,
      textAlign: widget.textAlign,
      style: widget.style,
      onTap: () {
        widget.onTap?.call();

        /// Select all text when first tab
        if (widget.selectAllOnFocus == true &&
            widget.focusNode?.hasFocus == false) {
          widget.focusNode?.requestFocus();
          controller?.selection = TextSelection(
            baseOffset: 0,
            extentOffset: controller?.text.length ?? 0,
          );
        }
      },
      onTapOutside: widget.onTapOutside,
      focusNode: widget.focusNode,
    );
  }
}

/// Value converter for BaseTextFormField
class Converter<T> {
  Converter({this.fromValue, this.toValue});
  final String Function(T? value)? fromValue;
  T Function(String? value)? toValue;
}

class BaseTextFormFileldInputFilters {
  BaseTextFormFileldInputFilters._();

  /// Allow only 2 decimal formater or any value you need
  static List<TextInputFormatter> decimalOnly({int decimalPlaces = 2}) {
    final regexString = decimalPlaces <= 0
        ? r'^\d*'
        : r'^\d+\.?\d{0,' + decimalPlaces.toString() + r'}';
    return [
      FilteringTextInputFormatter.allow(RegExp(regexString)),
      TextInputFormatter.withFunction((oldValue, newValue) {
        final text = newValue.text;
        return text.isEmpty
            ? newValue
            : double.tryParse(text) == null
            ? oldValue
            : newValue;
      }),
    ];
  }

  /// Allow only positive number
  static List<TextInputFormatter> get positiveNumber {
    return [
      FilteringTextInputFormatter.singleLineFormatter,
      FilteringTextInputFormatter.digitsOnly,
    ];
  }
}
