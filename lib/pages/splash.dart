import 'package:flutter/material.dart';
import 'package:narrate_blog/constants/app_colors.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 70),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/logo/white.png', width: 96),

                const SizedBox(width: 5),

                const Text(
                  "Narrate",
                  style: TextStyle(
                    fontFamily: 'PlayfairDisplay',
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 70),
            
            Image.asset('assets/images/splash.png')
          ],
        ),
      ),
    );
  }
}
