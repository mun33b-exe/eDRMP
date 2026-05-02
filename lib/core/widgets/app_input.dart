import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_padding.dart';
import '../constants/app_spacing.dart';

/// Themed labelled text field with an optional prefix/suffix and helper text.
class AppInput extends StatelessWidget {
  const AppInput({
    required this.label,
    this.controller,
    this.hintText,
    this.helperText,
    this.errorText,
    this.prefixIcon,
    this.suffix,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.obscureText = false,
    this.enabled = true,
    this.autofillHints,
    this.maxLength,
    this.maxLines = 1,
    this.minLines,
    this.focusNode,
    this.autofocus = false,
    super.key,
  });

  final String label;
  final TextEditingController? controller;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final FormFieldValidator<String>? validator;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onFieldSubmitted;
  final bool obscureText;
  final bool enabled;
  final Iterable<String>? autofillHints;
  final int? maxLength;
  final int maxLines;
  final int? minLines;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppPadding.xs,
            bottom: AppPadding.xs,
          ),
          child: Text(label, style: textTheme.bodyLarge),
        ),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          autofocus: autofocus,
          enabled: enabled,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          validator: validator,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          autofillHints: autofillHints,
          maxLength: maxLength,
          maxLines: obscureText ? 1 : maxLines,
          minLines: minLines,
          style: textTheme.bodyLarge,
          decoration: InputDecoration(
            hintText: hintText,
            helperText: helperText,
            errorText: errorText,
            prefixIcon: prefixIcon == null ? null : Icon(prefixIcon, size: 20),
            suffixIcon: suffix,
            counterText: maxLength == null ? null : '',
          ),
        ),
        if (helperText != null && errorText == null) AppSpacing.vXs,
      ],
    );
  }
}
