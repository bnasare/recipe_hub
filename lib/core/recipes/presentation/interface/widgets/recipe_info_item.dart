import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../../../../../shared/presentation/theme/extra_colors.dart';

class RecipeInfoItem extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color? iconColor;
  final Color? textColor;
  final double? textSize;
  final double? iconSize;
  final double? width;
  final double? wordSpacing;

  const RecipeInfoItem({
    this.icon,
    required this.text,
    super.key,
    this.iconColor,
    this.textSize = 16,
    this.iconSize = 16,
    this.width = 1,
    this.wordSpacing = -1,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: iconColor ?? ExtraColors.white,
            size: iconSize,
          ),
          SizedBox(width: width),
          Flexible(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                wordSpacing: wordSpacing,
                color: textColor ?? ExtraColors.white,
                fontSize: textSize,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
