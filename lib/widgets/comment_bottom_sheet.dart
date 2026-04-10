import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/models/user_model.dart';
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
      height: MediaQuery.of(context).size.height * 0.5, // 85% screen height
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
                                'https://placehold.net/avatar-2.png',
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
class _CommentInputField extends StatefulWidget {
  final String postId;

  const _CommentInputField({required this.postId});

  @override
  State<_CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<_CommentInputField> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final PostController _postController = Get.find<PostController>();
  final UserController _userController = Get.find<UserController>();

  Timer? _mentionDebounce;
  List<UserModel> _mentionSuggestions = <UserModel>[];
  UserModel? _selectedMentionUser;
  bool _isSearchingMentions = false;
  int _mentionSearchRequestId = 0;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_handleComposerChanged);
  }

  @override
  void dispose() {
    _mentionDebounce?.cancel();
    _textController.removeListener(_handleComposerChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _handleComposerChanged() {
    _syncSelectedMentionWithText();

    final query = _extractMentionQuery();
    _mentionDebounce?.cancel();

    if (query == null || query.isEmpty) {
      if (_mentionSuggestions.isNotEmpty || _isSearchingMentions) {
        setState(() {
          _mentionSuggestions = <UserModel>[];
          _isSearchingMentions = false;
        });
      }
      return;
    }

    _mentionDebounce = Timer(
      const Duration(milliseconds: 250),
      () => _searchMentionCandidates(query),
    );
  }

  String? _extractMentionQuery() {
    final fullText = _textController.text;
    final selection = _textController.selection;
    final cursorIndex =
        selection.baseOffset >= 0 ? selection.baseOffset : fullText.length;
    final safeCursorIndex = cursorIndex.clamp(0, fullText.length);
    final textBeforeCursor = fullText.substring(0, safeCursorIndex);

    final match = RegExp(
      r'(^|\s)@([A-Za-z0-9._]{1,30})$',
    ).firstMatch(textBeforeCursor);
    return match?.group(2);
  }

  void _syncSelectedMentionWithText() {
    final selectedMentionUser = _selectedMentionUser;
    if (selectedMentionUser == null) return;

    if (!_textController.text.contains('@${selectedMentionUser.username}')) {
      setState(() {
        _selectedMentionUser = null;
      });
    }
  }

  Future<void> _searchMentionCandidates(String query) async {
    final requestId = ++_mentionSearchRequestId;

    if (mounted) {
      setState(() {
        _isSearchingMentions = true;
      });
    }

    try {
      final response = await _userController.userRepo.searchUsersForMentions(
        query: query,
        limit: 5,
      );

      if (!mounted || requestId != _mentionSearchRequestId) return;

      final List<UserModel> users;
      if (response.statusCode == 200 && response.body?['code'] == '00') {
        final data = response.body?['data'];
        final rawUsers =
            data is Map<String, dynamic> ? (data['users'] as List? ?? []) : [];
        users =
            rawUsers
                .map(
                  (json) => UserModel.fromJson(Map<String, dynamic>.from(json)),
                )
                .where((user) => !_userController.isCurrentUser(user.id))
                .toList();
      } else {
        users = <UserModel>[];
      }

      setState(() {
        _mentionSuggestions = users;
        _isSearchingMentions = false;
      });
    } catch (_) {
      if (!mounted || requestId != _mentionSearchRequestId) return;

      setState(() {
        _mentionSuggestions = <UserModel>[];
        _isSearchingMentions = false;
      });
    }
  }

  void _selectMention(UserModel user) {
    final fullText = _textController.text;
    final selection = _textController.selection;
    final cursorIndex =
        selection.baseOffset >= 0 ? selection.baseOffset : fullText.length;
    final safeCursorIndex = cursorIndex.clamp(0, fullText.length);
    final textBeforeCursor = fullText.substring(0, safeCursorIndex);
    final mentionStart = textBeforeCursor.lastIndexOf('@');

    if (mentionStart == -1) return;

    if (mentionStart > 0 &&
        !RegExp(r'\s').hasMatch(fullText[mentionStart - 1])) {
      return;
    }

    final replacement = '@${user.username} ';
    final updatedText = fullText.replaceRange(
      mentionStart,
      safeCursorIndex,
      replacement,
    );
    final nextCursorIndex = mentionStart + replacement.length;

    _textController.value = TextEditingValue(
      text: updatedText,
      selection: TextSelection.collapsed(offset: nextCursorIndex),
    );

    setState(() {
      _selectedMentionUser = user;
      _mentionSuggestions = <UserModel>[];
      _isSearchingMentions = false;
    });

    _focusNode.requestFocus();
  }

  String? _activeMentionedUserId() {
    final selectedMentionUser = _selectedMentionUser;
    if (selectedMentionUser == null) return null;

    if (!_textController.text.contains('@${selectedMentionUser.username}')) {
      return null;
    }

    return selectedMentionUser.id;
  }

  Future<void> _submitComment() async {
    final content = _textController.text.trim();
    if (content.isEmpty) return;

    await _postController.submitComment(
      widget.postId,
      content,
      mentionedUserId: _activeMentionedUserId(),
    );

    if (!mounted) return;

    _textController.clear();
    setState(() {
      _selectedMentionUser = null;
      _mentionSuggestions = <UserModel>[];
      _isSearchingMentions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mentionSuggestionsVisible =
        _isSearchingMentions || _mentionSuggestions.isNotEmpty;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mentionSuggestionsVisible)
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            margin: const EdgeInsets.fromLTRB(15, 10, 15, 0),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child:
                _isSearchingMentions
                    ? const Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Searching users...',
                            style: TextStyle(color: Colors.white70),
                          ),
                        ],
                      ),
                    )
                    : ListView.separated(
                      shrinkWrap: true,
                      itemCount: _mentionSuggestions.length,
                      separatorBuilder:
                          (_, __) =>
                              const Divider(height: 1, color: Colors.white10),
                      itemBuilder: (context, index) {
                        final user = _mentionSuggestions[index];

                        return ListTile(
                          dense: true,
                          onTap: () => _selectMention(user),
                          leading: CircleAvatar(
                            radius: 18,
                            backgroundImage: NetworkImage(user.profilePicture),
                          ),
                          title: Text(
                            user.displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            '@${user.username}',
                            style: const TextStyle(color: Colors.white60),
                          ),
                        );
                      },
                    ),
          ),
        Container(
          padding: const EdgeInsets.only(
            bottom: 10,
            top: 10,
            left: 15,
            right: 5,
          ),
          decoration: const BoxDecoration(
            border: Border(top: BorderSide(color: Colors.white10, width: 0.5)),
            color: Colors.black,
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                backgroundImage: NetworkImage(
                  _userController.user.value?.profilePicture ??
                      'https://placehold.net/avatar-2.png',
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: CustomTextField(
                  hintText: 'Add a comment...',
                  controller: _textController,
                  focusNode: _focusNode,
                  hintStyle: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                  ),
                  textColor: Colors.white,
                  onChanged: (_) {},
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: _submitComment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
