import 'package:flutter/material.dart';

import '../utils/dimensions.dart';


class DropdownTextField<T> extends StatelessWidget {
  final String label;
  final List<T> items;
  final T? selectedItem;
  final void Function(T?) onChanged;
  final String Function(T) itemToString;
  final String? hintText;
  final Color? backgroundColor;

  const DropdownTextField({
    super.key,
    required this.label,
    required this.items,
    required this.selectedItem,
    required this.onChanged,
    required this.itemToString,
    this.hintText,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final Color effectiveFillColor = backgroundColor ??
        (isDark
            ? Colors.white.withOpacity(0.05)
            : theme.inputDecorationTheme.fillColor ??
            const Color(0xFFF2F2F2));
    final Color textColor = theme.textTheme.bodyLarge?.color ?? Colors.black;
    final Color borderColor = isDark
        ? Colors.grey.shade700
        : Colors.grey.shade300;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6.0),
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: textColor,
              ),
            ),
          ),
        DropdownButtonFormField<T>(
          value: selectedItem,
          dropdownColor: isDark ? Colors.grey.shade900 : Colors.white,
          decoration: InputDecoration(
            filled: true,
            fillColor: effectiveFillColor,
            hintText: hintText ?? "Select an option",
            hintStyle: TextStyle(color: textColor.withOpacity(0.5)),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.6),
              ),
            ),
            contentPadding: EdgeInsets.symmetric(
              horizontal: Dimensions.width10,
              vertical: Dimensions.height10,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(
                itemToString(item),
                style: TextStyle(color: textColor),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}