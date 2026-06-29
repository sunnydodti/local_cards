import 'package:flutter/material.dart';

class CardDisplayText extends StatelessWidget {
  final String? primaryText;
  final String? secondaryText;
  final bool scaleSecondaryText;
  final CrossAxisAlignment alignment;
  const CardDisplayText({
    super.key,
    required this.primaryText,
    required this.secondaryText,
    this.scaleSecondaryText = true,
    this.alignment = CrossAxisAlignment.start,
  });

  @override
  Widget build(BuildContext context) {
    bool hasPrimary = primaryText != null && primaryText!.isNotEmpty;
    bool hasSecondary = secondaryText != null && secondaryText!.isNotEmpty;
    double secondaryTextScale = hasPrimary && scaleSecondaryText ? 0.6 : 1.0;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: alignment,
      children: [
        if (hasPrimary) Text(primaryText!),
        if (hasSecondary)
          Text(
            secondaryText!,
            textScaler: TextScaler.linear(secondaryTextScale),
          ),
      ],
    );
  }
}
