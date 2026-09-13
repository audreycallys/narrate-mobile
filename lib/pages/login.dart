import 'package:flutter/material.dart';
import 'package:narrate_blog/constants/app_colors.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            SizedBox(
              width: double.infinity,
              height: 275,
              child: Stack(
                children: [
                  Opacity(
                    opacity: 0.12,
                    child: ClipRect(
                      child: Transform.scale(
                        scale: 1.6,
                        child: Image.asset(
                          'assets/images/logo/white.png',
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),

                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/logo/white.png', width: 225),
                        const Text(
                          'Narrate',
                          style: TextStyle(
                            fontFamily: 'PlayfairDisplay',
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  Positioned(
                    top: 20,
                    left: 35,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: const Icon(
                          Icons.arrow_back,
                          color: AppColors.primary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 35,
                    vertical: 45,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Text(
                          'Selamat Datang Kembali',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      const Center(
                        child: Text(
                          'Temukan ide, cerita, dan sudut pandang baru setiap hari.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
