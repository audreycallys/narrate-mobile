import 'package:flutter/material.dart';
import 'package:narrate_blog/pages/detail_article.dart';
import 'package:narrate_blog/services/post_service.dart';
import 'package:narrate_blog/services/saved_service.dart';
import 'package:narrate_blog/widgets/article_card.dart';

class CategoryDetailPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryDetailPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryDetailPage> createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List posts = [];
  Set<int> savedPostIds = {};

  Future<void> getPosts() async {
    final result = await PostService.getPosts();

    final filteredPosts = result.where((post) {
      return post['categoryId'] == widget.categoryId;
    }).toList();

    if (!mounted) return;

    setState(() {
      posts = filteredPosts;
    });
  }

  Future<void> getSavedPosts() async {
    final savedPosts = await SavedService.getSavedPosts();

    if (!mounted) return;

    setState(() {
      savedPostIds = savedPosts.map<int>((saved) {
        final nestedPost = saved['post'];

        final postId =
            saved['postId'] ??
            (nestedPost is Map ? nestedPost['id'] : saved['id']);

        return postId as int;
      }).toSet();
    });
  }

  Future<void> toggleSaved(Map post) async {
    final int postId = post['id'];

    final bool alreadySaved = savedPostIds.contains(postId);

    bool success;

    if (alreadySaved) {
      success = await SavedService.deleteSavedPost(postId);
    } else {
      success = await SavedService.savePost(postId);
    }

    if (!mounted) return;

    if (success) {
      setState(() {
        if (alreadySaved) {
          savedPostIds.remove(postId);
        } else {
          savedPostIds.add(postId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            alreadySaved
                ? 'Artikel dihapus dari tersimpan'
                : 'Artikel berhasil disimpan',
          ),
        ),
      );
    }
  }

  Future<void> openPostDetail(Map post) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) =>
            DetailArticlePage(post: post, categoryName: widget.categoryName),
      ),
    );

    if (!mounted) return;

    if (changed == true) {
      await getPosts();
    }

    await getSavedPosts();
  }

  @override
  void initState() {
    super.initState();

    getPosts();
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
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: const BoxDecoration(
                          color: Color(0xFFF1F1F1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          size: 18,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  Text(
                    widget.categoryName,
                    style: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(
                'Artikel seputar ${widget.categoryName.toLowerCase()}',
                style: const TextStyle(
                  fontFamily: 'PlusJakartaSans',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 28),
              Expanded(
                child: posts.isEmpty
                    ? const Center(
                        child: Text(
                          'Belum ada artikel di kategori ini.',
                          style: TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 13,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: posts.length,
                        itemBuilder: (context, index) {
                          final post = posts[index];

                          return ArticleCard(
                            imageUrl: post['imageUrl'],
                            title: post['title'],
                            createdAt: post['createdAt'],
                            content: post['content'],
                            isSaved: savedPostIds.contains(post['id']),
                            onTap: () async {
                              await openPostDetail(post);
                            },
                            onBookmarkTap: () {
                              toggleSaved(post);
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
