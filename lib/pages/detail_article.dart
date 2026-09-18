import 'package:flutter/material.dart';

import 'package:narrate_blog/constants/app_colors.dart';
import 'package:narrate_blog/services/saved_service.dart';
import 'package:narrate_blog/pages/edit_post.dart';
import 'package:narrate_blog/services/post_service.dart';

class DetailArticlePage extends StatefulWidget {
  final Map post;
  final String categoryName;
  final bool initiallySaved;

  const DetailArticlePage({
    super.key,
    required this.post,
    required this.categoryName,
    this.initiallySaved = false,
  });

  @override
  State<DetailArticlePage> createState() => _DetailArticlePageState();
}

class _DetailArticlePageState extends State<DetailArticlePage> {
  bool isSaved = false;
  bool isSaving = false;

  String displayTagName(dynamic value) {
    final name = value
        .toString()
        .replaceAll('#', '')
        .replaceAll(RegExp(r'\s+'), '');

    return '#$name';
  }

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

  Future<void> saveArticle() async {
    if (isSaving) return;

    setState(() {
      isSaving = true;
    });

    try {
      final postId = widget.post['id'];

      final success = isSaved
          ? await SavedService.deleteSavedPost(postId)
          : await SavedService.savePost(postId);

      if (!mounted) return;

      setState(() {
        isSaving = false;

        if (success) {
          isSaved = !isSaved;
        }
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              isSaved
                  ? 'Artikel berhasil disimpan'
                  : 'Artikel dihapus dari tersimpan',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Artikel gagal disimpan')));
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isSaving = false;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Artikel gagal disimpan')));
    }
  }

  Future<void> checkSavedStatus() async {
    final savedPosts = await SavedService.getSavedPosts();
    final postId = widget.post['id'];

    final alreadySaved = savedPosts.any((saved) {
      final post = saved['post'] ?? saved;
      final savedId = post['id'] ?? saved['postId'];

      return savedId == postId;
    });

    if (!mounted) return;

    setState(() {
      isSaved = alreadySaved;
    });
  }

  Future<void> archivePost() async {
    final postTags = widget.post['tags'] ?? [];

    final List<int> tagIds = postTags
        .map<int>((tag) => tag['id'] as int)
        .toList();

    final success = await PostService.updatePost(
      postId: widget.post['id'],
      title: widget.post['title'],
      content: widget.post['content'],
      categoryId: widget.post['categoryId'],
      status: 'archived',
      tagIds: tagIds,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil diarsipkan')),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan gagal diarsipkan')),
      );
    }
  }

  Future<void> deletePost() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Hapus Postingan',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 17,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: const Text(
            'Apakah kamu yakin ingin menghapus postingan ini?',
            style: TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text(
                'Hapus',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final success = await PostService.deletePost(widget.post['id']);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan berhasil dihapus')),
      );

      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Postingan gagal dihapus')));
    }
  }

  @override
  void initState() {
    super.initState();

    isSaved = widget.initiallySaved;
    checkSavedStatus();
  }

  @override
  Widget build(BuildContext context) {
    final tags = widget.post['tags'] ?? [];

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.network(
                  widget.post['imageUrl'],
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
                            InkWell(
                              onTap: isSaving ? null : saveArticle,
                              borderRadius: BorderRadius.circular(50),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                ),
                                child: isSaving
                                    ? const Padding(
                                        padding: EdgeInsets.all(12),
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.primary,
                                        ),
                                      )
                                    : Icon(
                                        isSaved
                                            ? Icons.bookmark
                                            : Icons.bookmark_border,
                                        size: 24,
                                        color: isSaved
                                            ? AppColors.primary
                                            : Colors.black,
                                      ),
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
                              child: PopupMenuButton<String>(
                                padding: EdgeInsets.zero,
                                icon: const Icon(
                                  Icons.more_vert,
                                  size: 24,
                                  color: Colors.black,
                                ),
                                onSelected: (value) async {
                                  if (value == 'Edit') {
                                    final updated = await Navigator.push<bool>(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            EditPostPage(post: widget.post),
                                      ),
                                    );

                                    if (updated == true && mounted) {
                                      Navigator.pop(context, true);
                                    }

                                    return;
                                  }

                                  if (value == 'Arsipkan') {
                                    await archivePost();
                                    return;
                                  }

                                  if (value == 'Hapus') {
                                    await deletePost();
                                    return;
                                  }
                                },
                                itemBuilder: (context) {
                                  return const [
                                    PopupMenuItem(
                                      value: 'Edit',
                                      child: Text('Edit'),
                                    ),
                                    PopupMenuItem(
                                      value: 'Arsipkan',
                                      child: Text('Arsipkan'),
                                    ),
                                    PopupMenuItem(
                                      value: 'Hapus',
                                      child: Text('Hapus'),
                                    ),
                                  ];
                                },
                              ),
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
                          widget.categoryName,
                          style: const TextStyle(
                            fontFamily: 'PlusJakartaSans',
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Text(
                        '${calculateReadingTime(widget.post['content'])} Menit Baca',
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
                    widget.post['title'],
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
                            formatDate(widget.post['createdAt']),
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
                            displayTagName(tag['name']),
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
                    widget.post['content'],
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
