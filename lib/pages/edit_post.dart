import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:narrate_blog/constants/app_colors.dart';
import 'package:narrate_blog/services/category_service.dart';
import 'package:narrate_blog/services/post_service.dart';
import 'package:narrate_blog/services/tag_service.dart';

class EditPostPage extends StatefulWidget {
  final Map post;

  const EditPostPage({super.key, required this.post});

  @override
  State<EditPostPage> createState() => _EditPostPageState();
}

class _EditPostPageState extends State<EditPostPage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  final tagController = TextEditingController();

  List categories = [];
  List tags = [];

  int? selectedCategoryId;

  List<int> selectedTagIds = [];

  String selectedStatus = 'published';

  File? selectedImage;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    titleController.text = widget.post['title'] ?? '';

    contentController.text = widget.post['content'] ?? '';

    selectedCategoryId = widget.post['categoryId'];

    selectedStatus = widget.post['status'] ?? 'published';

    final postTags = widget.post['tags'];

    if (postTags is List) {
      selectedTagIds = postTags.map<int>((tag) => tag['id'] as int).toList();
    }

    getCategories();

    if (selectedCategoryId != null) {
      getTags(selectedCategoryId!);
    }
  }

  Future<void> getCategories() async {
    try {
      final result = await CategoryService.getCategories();

      if (!mounted) return;

      setState(() {
        categories = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Kategori gagal diambil')));
    }
  }

  Future<void> getTags(int categoryId) async {
    try {
      final result = await TagService.getTags(categoryId);

      if (!mounted) return;

      setState(() {
        tags = result;
      });
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tag gagal diambil')));
    }
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();

    final pickedImage = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );

    if (pickedImage == null) {
      return;
    }

    final imageSize = await pickedImage.length();

    if (imageSize > 5 * 1024 * 1024) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ukuran gambar maksimal 5MB')),
      );

      return;
    }

    setState(() {
      selectedImage = File(pickedImage.path);
    });
  }

  Future<void> showAddTagDialog() async {
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori terlebih dahulu')),
      );

      return;
    }

    tagController.clear();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Tambah Tag',
            style: TextStyle(
              fontFamily: 'PlusJakartaSans',
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: TextField(
            controller: tagController,
            autofocus: true,
            style: const TextStyle(fontFamily: 'PlusJakartaSans', fontSize: 12),
            decoration: InputDecoration(
              hintText: 'Nama tag',
              hintStyle: const TextStyle(
                fontFamily: 'PlusJakartaSans',
                fontSize: 12,
                color: Colors.grey,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = tagController.text.trim();

                if (name.isEmpty) {
                  return;
                }

                final existingTag = tags.where(
                  (tag) =>
                      tag['name'].toString().toLowerCase() ==
                      name.toLowerCase(),
                );

                if (existingTag.isNotEmpty) {
                  final tagId = existingTag.first['id'];

                  if (!selectedTagIds.contains(tagId)) {
                    setState(() {
                      selectedTagIds.add(tagId);
                    });
                  }

                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }

                  return;
                }

                await TagService.createTag(
                  categoryId: selectedCategoryId!,
                  name: name,
                );

                if (!mounted) return;

                final newTags = await TagService.getTags(selectedCategoryId!);

                if (!mounted) return;

                final newTag = newTags.firstWhere(
                  (tag) =>
                      tag['name'].toString().toLowerCase() ==
                      name.toLowerCase(),
                );

                setState(() {
                  tags = newTags;

                  if (!selectedTagIds.contains(newTag['id'])) {
                    selectedTagIds.add(newTag['id']);
                  }
                });

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Tambah'),
            ),
          ],
        );
      },
    );
  }

  Future<void> updatePost() async {
    if (titleController.text.trim().isEmpty ||
        contentController.text.trim().isEmpty ||
        selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lengkapi postingan terlebih dahulu')),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final success = await PostService.updatePost(
        postId: widget.post['id'],
        title: titleController.text.trim(),
        content: contentController.text.trim(),
        categoryId: selectedCategoryId!,
        status: selectedStatus,
        tagIds: selectedTagIds,
        imagePath: selectedImage?.path,
      );

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postingan berhasil diperbarui')),
        );

        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Postingan gagal diperbarui')),
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Postingan gagal diperbarui')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(25, 30, 25, 25),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // HEADER
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
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F1F1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            size: 17,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const Text(
                      'Edit Postingan',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 25),

                // COVER
                InkWell(
                  onTap: pickImage,
                  borderRadius: BorderRadius.circular(14),
                  child: Container(
                    width: double.infinity,
                    height: 165,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F4F4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: const Color(0xFFBDBDBD)),
                    ),
                    child: selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Image.file(
                              selectedImage!,
                              width: double.infinity,
                              height: 165,
                              fit: BoxFit.cover,
                            ),
                          )
                        : widget.post['imageUrl'] != null &&
                              widget.post['imageUrl'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(14),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                Image.network(
                                  widget.post['imageUrl'].toString(),
                                  fit: BoxFit.cover,
                                ),
                                Container(
                                  alignment: Alignment.bottomCenter,
                                  padding: const EdgeInsets.all(10),
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black54,
                                      ],
                                    ),
                                  ),
                                  child: const Text(
                                    'Ketuk untuk mengganti gambar',
                                    style: TextStyle(
                                      fontFamily: 'PlusJakartaSans',
                                      fontSize: 10,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.image_outlined,
                                size: 38,
                                color: Color(0xFF777777),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'Unggah gambar sampul',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'JPG, PNG atau WEBP (maksimal 5MB)',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                // JUDUL
                const Text(
                  'Judul',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: titleController,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Ketik judul...',
                    hintStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 11,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // KATEGORI
                const Text(
                  'Kategori',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                DropdownButtonFormField<int>(
                  value: selectedCategoryId,
                  hint: const Text(
                    'Pilih satu kategori',
                    style: TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 9,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                  items: categories.map<DropdownMenuItem<int>>((category) {
                    return DropdownMenuItem<int>(
                      value: category['id'],
                      child: Text(
                        category['name'],
                        style: const TextStyle(
                          fontFamily: 'PlusJakartaSans',
                          fontSize: 12,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      selectedCategoryId = value;

                      selectedTagIds.clear();

                      tags = [];
                    });

                    getTags(value);
                  },
                ),

                const SizedBox(height: 14),

                // TAGS
                const Text(
                  'Tags',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 7),

                Wrap(
                  spacing: 7,
                  runSpacing: 7,
                  children: [
                    ...selectedTagIds.map((tagId) {
                      final matching = tags.where((tag) => tag['id'] == tagId);

                      if (matching.isEmpty) {
                        return const SizedBox.shrink();
                      }

                      final tag = matching.first;

                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFDDF3F5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              tag['name'],
                              style: const TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 9,
                              ),
                            ),
                            const SizedBox(width: 4),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selectedTagIds.remove(tagId);
                                });
                              },
                              child: const Icon(Icons.close, size: 13),
                            ),
                          ],
                        ),
                      );
                    }),

                    ...tags
                        .where((tag) => !selectedTagIds.contains(tag['id']))
                        .map((tag) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                selectedTagIds.add(tag['id']);
                              });
                            },
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF1F1F1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag['name'],
                                style: const TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 9,
                                ),
                              ),
                            ),
                          );
                        }),

                    InkWell(
                      onTap: showAddTagDialog,
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF1F1F1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Tambah tag',
                              style: TextStyle(
                                fontFamily: 'PlusJakartaSans',
                                fontSize: 9,
                              ),
                            ),
                            SizedBox(width: 3),
                            Icon(Icons.add, size: 13),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                // KONTEN
                const Text(
                  'Konten',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 6),

                TextField(
                  controller: contentController,
                  maxLines: 5,
                  style: const TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 12,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tulis isi artikel...',
                    hintStyle: const TextStyle(
                      fontFamily: 'PlusJakartaSans',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Color(0xFFBDBDBD)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // STATUS
                const Text(
                  'Status',
                  style: TextStyle(
                    fontFamily: 'PlusJakartaSans',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 5),

                Row(
                  children: [
                    Radio<String>(
                      value: 'published',
                      groupValue: selectedStatus,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    const Text(
                      'Publik',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 25),
                    Radio<String>(
                      value: 'draft',
                      groupValue: selectedStatus,
                      activeColor: AppColors.primary,
                      onChanged: (value) {
                        setState(() {
                          selectedStatus = value!;
                        });
                      },
                    ),
                    const Text(
                      'Draf',
                      style: TextStyle(
                        fontFamily: 'PlusJakartaSans',
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: isLoading ? null : updatePost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.save_outlined, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Simpan Perubahan',
                                style: TextStyle(
                                  fontFamily: 'PlusJakartaSans',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    tagController.dispose();

    super.dispose();
  }
}
