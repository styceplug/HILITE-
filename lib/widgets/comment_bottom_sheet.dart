import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_textfield.dart';

import '../controllers/post_controller.dart';

class CommentsBottomSheet extends StatelessWidget {
  final String postId;
  final PostController postController = Get.find<PostController>();

  CommentsBottomSheet({required this.postId, super.key});

  String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    final weeks = diff.inDays ~/ 7;
    if (weeks < 4) return '${weeks}w ago';

    final months = diff.inDays ~/ 30;
    if (months < 12) return '${months}mo ago';

    final years = diff.inDays ~/ 365;
    return '${years}y ago';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85, // 85% screen height
      decoration: const BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
            child: Text(
              'Comments (${postController.comments.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Divider(color: Colors.grey, height: 1),

          Expanded(
            child: Obx(() {
              if (postController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }
              if (postController.comments.isEmpty) {
                return const Center(
                  child: Text(
                    'Be the first to comment!',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.builder(
                itemCount: postController.comments.length,
                itemBuilder: (context, index) {
                  final comment = postController.comments[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 10,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundImage: NetworkImage(
                            comment.user.profilePicture ??
                                'https://via.placeholder.com/150',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username and Time
                              Text(
                                '${comment.user.username} · ${timeAgo(comment.createdAt)}',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              // Comment Content
                              Text(
                                comment.content,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),

                      ],
                    ),
                  );
                },
              );
            }),
          ),

          // 2. Comment Input Field
          _CommentInputField(postId: postId),
          SizedBox(height: Dimensions.height30),
        ],
      ),
    );
  }
}

// Separate Widget for the Input Field
class _CommentInputField extends StatelessWidget {
  final String postId;

  // We'll set up the controller later
  final TextEditingController textController = TextEditingController();
  PostController postController = Get.find<PostController>();

  _CommentInputField({required this.postId});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(bottom: 10, top: 10, left: 15, right: 5),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
        color: Colors.black,
      ),
      child: Row(
        children: [
          // User Avatar (Placeholder)
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.white,
            backgroundImage: NetworkImage(
              Get.find<UserController>().user.value?.profilePicture ??
                  'https://via.placeholder.com/150',
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: CustomTextField(
              hintText: 'Add a comment...',
              controller: textController,
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
              textColor: Colors.white,
            ),
          ),
          // Send Button (Optional)
          IconButton(
            icon: const Icon(Icons.send, color: Colors.blue),
            onPressed: () {
              postController.submitComment(postId, textController.text.trim());
              textController.clear();
            },
          ),
        ],
      ),
    );
  }
}
