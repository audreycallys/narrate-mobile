import 'package:flutter/material.dart';

import 'package:narrate_blog/constants/app_colors.dart';
import 'package:narrate_blog/services/saved_service.dart';
import 'package:narrate_blog/widgets/article_card.dart';
import 'package:narrate_blog/pages/detail_article.dart';
import 'package:narrate_blog/services/category_service.dart';

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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artikel gagal dihapus dari tersimpan')),
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

                          final nestedPost = saved['post'];

                          final Map<String, dynamic> post = nestedPost is Map
                              ? Map<String, dynamic>.from(nestedPost)
                              : Map<String, dynamic>.from(saved);

                          // PENTING:
                          // Utamakan postId dari saved.
                          // Jangan sampai memakai ID
                          // record saved sebagai ID artikel.
                          final rawPostId = saved['postId'] ?? post['id'];

                          final int? postId = rawPostId is int
                              ? rawPostId
                              : int.tryParse(rawPostId?.toString() ?? '');

                          final Map<String, dynamic> detailPost =
                              Map<String, dynamic>.from(post);

                          if (postId != null) {
                            detailPost['id'] = postId;
                          }

                          return ArticleCard(
                            imageUrl: post['imageUrl'] ?? '',
                            title: post['title'] ?? '',
                            createdAt: post['createdAt'] ?? '',
                            content: post['content'] ?? '',
                            isSaved: true,

                            // BOOKMARK DI CARD SAVED
                            onBookmarkTap: () {
                              if (postId != null) {
                                removeSavedPost(postId);
                              }
                            },

                            // BUKA DETAIL
                            onTap: () async {
                              if (postId == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('ID artikel tidak ditemukan'),
                                  ),
                                );

                                return;
                              }

                              final categories =
                                  await CategoryService.getCategories();

                              final category = categories.firstWhere(
                                (category) =>
                                    category['id'] == detailPost['categoryId'],
                                orElse: () => {'name': 'Artikel'},
                              );

                              if (!context.mounted) {
                                return;
                              }

                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailArticlePage(
                                    post: detailPost,
                                    categoryName: category['name'],
                                    initiallySaved: true,
                                  ),
                                ),
                              );

                              if (!mounted) {
                                return;
                              }

                              await getSavedPosts();
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
