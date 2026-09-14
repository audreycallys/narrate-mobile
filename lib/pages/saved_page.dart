import 'package:flutter/material.dart';

import 'package:narrate_blog/constants/app_colors.dart';
import 'package:narrate_blog/services/saved_service.dart';
import 'package:narrate_blog/widgets/article_card.dart';

class SavedPage extends StatefulWidget {
  const SavedPage({super.key});

  @override
  State<SavedPage> createState() => _SavedPageState();
}

class _SavedPageState extends State<SavedPage> {
  List savedPosts = [];
  bool isLoading = true;

  Future<void> getSavedPosts() async {
    try {
      final result = await SavedService.getSavedPosts();

      if (!mounted) return;

      setState(() {
        savedPosts = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Data tersimpan gagal diambil')),
      );
    }
  }

  Future<void> removeSavedPost(int postId) async {
    final success = await SavedService.deleteSavedPost(postId);

    if (!mounted) return;

    if (success) {
      await getSavedPosts();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikel dihapus dari tersimpan')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    getSavedPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(25, 30, 25, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tersimpan',
                style: TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),

              const SizedBox(height: 15),

              Expanded(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      )
                    : savedPosts.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircleAvatar(
                              radius: 31,
                              backgroundColor: Color(0xFFE6F6F7),
                              child: Icon(
                                Icons.bookmark_border,
                                size: 28,
                                color: AppColors.primary,
                              ),
                            ),

                            SizedBox(height: 15),

                            Text(
                              'Belum ada artikel tersimpan',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: savedPosts.length,
                        itemBuilder: (context, index) {
                          final saved = savedPosts[index];

                          final post = saved['post'] ?? saved;

                          return ArticleCard(
                            imageUrl: post['imageUrl'] ?? '',
                            title: post['title'] ?? '',
                            createdAt: post['createdAt'] ?? '',
                            content: post['content'] ?? '',
                            isSaved: true,

                            onBookmarkTap: () {
                              final postId = post['id'] ?? saved['postId'];

                              if (postId != null) {
                                removeSavedPost(postId);
                              }
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
