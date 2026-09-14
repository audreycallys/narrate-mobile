import 'package:flutter/material.dart';
import 'package:narrate_blog/constants/app_colors.dart';

class DetailArticlePage extends StatelessWidget {
  final Map post;
  final String categoryName;

  const DetailArticlePage({
    super.key,
    required this.post,
    required this.categoryName,
  });

  String formatDate(String createdAt) {
    final date = DateTime.parse(createdAt).toLocal();

    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];

    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  int calculateReadingTime(String content) {
    final wordCount = content.trim().split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil();

    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    final tags = post['tags'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  post['imageUrl'],
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),

                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(25, 15, 25, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          borderRadius: BorderRadius.circular(50),
                          child: Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 19,
                            ),
                          ),
                        ),

                        Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.bookmark_border,
                                size: 24,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Container(
                              width: 44,
                              height: 44,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.more_vert, size: 24),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(25, 18, 25, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF3F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          categoryName,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      Text(
                        '${calculateReadingTime(post['content'])} Menit Baca',
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    post['title'],
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      height: 1.25,
                      color: Colors.black,
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Color(0xFFE5F3F4),
                        child: Icon(Icons.person, color: AppColors.primary),
                      ),

                      const SizedBox(width: 10),

                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sakezza Labiru',
                            style: TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 2),

                          Text(
                            formatDate(post['createdAt']),
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 10,
                              fontWeight: FontWeight.w400,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  if (tags.isNotEmpty) ...[
                    const SizedBox(height: 16),

                    Wrap(
                      spacing: 7,
                      runSpacing: 7,
                      children: List.generate(tags.length, (index) {
                        final tag = tags[index];

                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFDDF3F5),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '#${tag['name']}',
                            style: const TextStyle(
                              fontFamily: 'PlusJakartaSans',
                              fontSize: 9,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary,
                            ),
                          ),
                        );
                      }),
                    ),
                  ],

                  const SizedBox(height: 22),

                  Text(
                    post['content'],
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      height: 1.65,
                      color: Color(0xFF252525),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
