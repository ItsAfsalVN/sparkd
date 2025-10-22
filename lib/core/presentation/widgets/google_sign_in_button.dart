import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:sparkd/core/utils/app_colors.dart';
import 'package:sparkd/core/utils/app_text_theme_extension.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLight = Theme.brightnessOf(context) == Brightness.light;
    return ElevatedButton(
      onPressed: () {},
      style: ElevatedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isLight ? AppColors.white200 : AppColors.black600,
          ),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: SvgPicture.asset(
                'assets/icons/google.svg',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
            ),
            Center(
              child: Text(
                'Sign in with google',
                style: Theme.of(context).textStyles.subtext.copyWith(
                  color: isLight ? AppColors.white300 : AppColors.black400,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
