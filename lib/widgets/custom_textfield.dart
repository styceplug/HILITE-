import 'package:flutter/material.dart';

import '../utils/dimensions.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController? controller;
  final String? labelText;
  final String? hintText;
  final TextStyle? hintStyle;
  final IconData? prefixIcon;
  final bool obscureText;
  final List<String>? autofillHints;
  final bool enabled;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final int? maxLines;
  final void Function(String)? onChanged;

  const CustomTextField({
    super.key,
    this.controller,
    this.labelText,
    this.hintText,
    this.hintStyle,
    this.prefixIcon,
    this.obscureText = false,
    this.enabled = true,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.maxLines,
    this.onChanged,
    this.autofillHints,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use theme-based colors
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final Color fillColor = theme.inputDecorationTheme.fillColor ??
        (isDark ? Colors.white10 : const Color(0xFFDBD0C8).withOpacity(0.1));
    final Color borderColor = theme.dividerColor;
    final Color focusColor = theme.colorScheme.primary.withOpacity(0.6);
    final Color enabledBorderColor = theme.colorScheme.secondary;

    return TextField(
      onChanged: onChanged,
      controller: controller,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      autofillHints: autofillHints,
      keyboardType: keyboardType,
      style: TextStyle(color: textColor,fontFamily: 'Poppins'),
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        labelText: labelText,
        labelStyle: hintStyle ?? TextStyle(color: textColor.withOpacity(0.5),fontFamily: 'Poppins'),
        hintText: hintText,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: textColor.withOpacity(0.6))
            : null,
        suffixIcon: suffixIcon,
        hintStyle: hintStyle ?? TextStyle(color: textColor.withOpacity(0.5),fontFamily: 'Poppins'),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          borderSide: BorderSide(color: enabledBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius20),
          borderSide: BorderSide(color: focusColor),
        ),
      ),
    );
  }
}