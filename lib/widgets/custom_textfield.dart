import 'package:flutter/material.dart';
import 'package:hilite/utils/colors.dart';

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
  final Color? textColor;
  final Color? fillColor;
  final int? maxLines;
  final FocusNode? focusNode;
  final void Function(String)? onChanged;
  final String? Function(String?)? validator;

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
    this.textColor,
    this.fillColor,
    this.keyboardType = TextInputType.text,
    this.maxLines,
    this.focusNode,
    this.onChanged,
    this.autofillHints,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Use theme-based colors
    final Color fillColor =
        theme.inputDecorationTheme.fillColor ??
        (isDark
            ? Colors.white10
            : const Color(0xFFDBD0C8).withValues(alpha: 0.1));
    final Color borderColor = Colors.white;
    final Color focusColor = Colors.white;
    final Color enabledBorderColor = theme.colorScheme.secondary;

    return TextFormField(
      onChanged: onChanged,
      controller: controller,
      focusNode: focusNode,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      autofillHints: autofillHints,
      keyboardType: keyboardType,
      style: TextStyle(
        color: textColor ?? AppColors.textColor,
        fontFamily: 'Poppins',
      ),
      validator: validator,
      decoration: InputDecoration(
        filled: true,
        fillColor: fillColor,
        labelText: labelText,
        labelStyle:
            hintStyle ??
            TextStyle(
              color: textColor?.withValues(alpha: 0.5),
              fontFamily: 'Poppins',
            ),
        hintText: hintText,
        prefixIcon:
            prefixIcon != null
                ? Icon(prefixIcon, color: textColor?.withValues(alpha: 0.6) ?? AppColors.textColor.withOpacity(0.6))
                : null,
        suffixIcon: suffixIcon,
        hintStyle:
            hintStyle ??
            TextStyle(
              color:
                  textColor?.withValues(alpha: 0.5) ??
                  AppColors.textColor.withOpacity(0.6),
              fontFamily: 'Poppins',
            ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(color: enabledBorderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(Dimensions.radius10),
          borderSide: BorderSide(color: focusColor),
        ),
      ),
    );
  }
}
