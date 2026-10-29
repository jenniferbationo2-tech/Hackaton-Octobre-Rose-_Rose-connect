import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Avatar à l'initiale du prénom, ou icône neutre sans compte.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, this.initial, this.size = 40});

  final String? initial;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: initial == null ? AppColors.surface : AppColors.roseTint,
        border: Border.all(
          color: initial == null ? AppColors.border : AppColors.roseBorder,
        ),
      ),
      child: initial == null
          ? Icon(Icons.person_outline,
              color: AppColors.textMuted, size: size * 0.55)
          : Text(
              initial!,
              style: TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontWeight: FontWeight.w700,
                fontSize: size * 0.42,
                color: AppColors.deepBerry,
                height: 1,
              ),
            ),
    );
  }
}
