import 'package:flutter/material.dart';

class ArticleCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String createdAt;
  final String content;

  final bool isSaved;
  final VoidCallback? onBookmarkTap;
  final VoidCallback? onTap;

  const ArticleCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.createdAt,
    required this.content,
    this.isSaved = false,
    this.onBookmarkTap,
    this.onTap,
  });

  String formatDate() {
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

  int calculateReadingTime() {
    final wordCount = content.trim().split(RegExp(r'\s+')).length;
    final minutes = (wordCount / 200).ceil();

    return minutes < 1 ? 1 : minutes;
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl,
                    width: 110,
                    height: 90,
                    fit: BoxFit.cover,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),

                      const SizedBox(height: 3),

                      Text(
                        '${formatDate()} • ${calculateReadingTime()} Menit Baca',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                          color: Color.fromARGB(255, 82, 82, 82),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 9,
                          fontWeight: FontWeight.w400,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                Padding(
                  padding: const EdgeInsets.only(top: 18),
                  child: InkWell(
                    onTap: onBookmarkTap,
                    child: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      size: 22,
                      color: isSaved ? const Color(0xFF1E919E) : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5)),
        ],
      ),
    );
  }
}
