import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../utils/dimensions.dart';



class CustomButton extends StatelessWidget {
  final String? text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isDisabled;
  final EdgeInsets? padding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? borderColor;
  final TextStyle? textStyle;
  final Widget? icon;

  const CustomButton({
    super.key,
    this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isDisabled = false,
    this.borderRadius,
    this.backgroundColor = AppColors.primary,
    this.borderColor,
    this.textStyle,
    this.icon,
    this.padding
  });

  @override
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color effectiveBgColor = isDisabled
        ? Colors.grey.shade500.withOpacity(0.4)
        : backgroundColor ?? (isDark ? AppColors.primary : Color(0xFF85CE5C));

    final Color effectiveTextColor = textStyle?.color ??
        (effectiveBgColor.computeLuminance() < 0.5 ? Colors.white : Colors.black);

    return InkWell(
      onTap: (isDisabled || isLoading) ? null : onPressed,
      borderRadius: borderRadius ?? BorderRadius.circular(Dimensions.radius10),
      child: Container(
        alignment: Alignment.center,
        padding: padding ?? EdgeInsets.symmetric(
          vertical: Dimensions.height15,
          horizontal:Dimensions.width20,
        ),
        decoration: BoxDecoration(
          color: effectiveBgColor,
          borderRadius: borderRadius ?? BorderRadius.circular(Dimensions.radius30),
          border: Border.all(color: borderColor ?? effectiveBgColor)
        ),
        child: isLoading
            ? const SizedBox(
          height: 22,
          width: 22,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 8),
            ],
            Flexible(
              child: Text(
                text ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: textStyle ??
                    TextStyle(
                      color: effectiveTextColor,
                      fontSize: Dimensions.font16,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Poppins'
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }}

