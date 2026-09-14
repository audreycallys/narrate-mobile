import 'package:flutter/material.dart';
import 'package:narrate_blog/constants/app_colors.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo, Sakezza Labiru!',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Ada cerita apa hari ini?',
                        style: TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  CircleAvatar(radius: 24, backgroundColor: AppColors.primary),
                ],
              ),

              const SizedBox(height: 20),

              TextField(
                decoration: InputDecoration(
                  hintText: 'Cari artikel, kategori, atau topik...',
                  hintStyle: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    color: Color.fromARGB(255, 82, 82, 82),
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFFECECEC),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 15,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
