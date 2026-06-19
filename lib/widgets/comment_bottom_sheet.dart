import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:hilite/models/user_model.dart';
import 'package:hilite/utils/dimensions.dart';
import 'package:hilite/widgets/custom_textfield.dart';
import 'package:hilite/widgets/snackbars.dart';

import '../controllers/post_controller.dart';
import '../models/comment_model.dart';

class CommentsBottomSheet extends StatelessWidget {
  final String postId;
  final PostController postController = Get.find<PostController>();

  CommentsBottomSheet({required this.postId, super.key});

  String timeAgo(DateTime date) {
    final Duration diff = DateTime.now().difference(date);
    if (diff.inDays >= 365) {
      final int years = (diff.inDays / 365).floor();
      return '${years}y';
    } else if (diff.inDays >= 30) {
      final int months = (diff.inDays / 30).floor();
      return '${months}mo';
    } else if (diff.inDays >= 1) {
      return '${diff.inDays}d';
    } else if (diff.inHours >= 1) {
      return '${diff.inHours}h';
    } else if (diff.inMinutes >= 1) {
      return '${diff.inMinutes}m';
    } else if (diff.inSeconds >= 5) {
      return '${diff.inSeconds}s';
    } else {
      return 'Now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // Increased to 65% for a better reading experience
      height: MediaQuery.of(context).size.height * 0.65,
      decoration: const BoxDecoration(
        color: Color(0xFF0A0A0A), // Slightly off-black for depth
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          // Header
          Padding(
            padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
            child: Obx(() => Text(
              'Comments (${postController.comments.length})',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            )),
          ),
          const Divider(color: Colors.white10, height: 1, thickness: 1),

          // Comments List
          Expanded(
            child: Obx(() {
              final sortedComments = List<CommentModel>.from(postController.comments)
                ..sort((a, b) => a.createdAt.compareTo(b.createdAt));

              if (postController.isLoading.value) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                );
              }

              if (postController.comments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.chat_bubble_outline, color: Colors.white.withOpacity(0.2), size: 50),
                      const SizedBox(height: 12),
                      const Text(
                        'Be the first to comment!',
                        style: TextStyle(color: Colors.grey, fontSize: 14),
                      ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                itemCount: sortedComments.length,
                itemBuilder: (context, index) {
                  final comment = sortedComments[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.white12,
                          backgroundImage: NetworkImage(
                            (comment.user.profilePicture?.trim().isNotEmpty ?? false)
                                ? comment.user.profilePicture!
                                : _CommentInputFieldState._fallbackAvatarUrl,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Username and Time (Hierarchical)
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: comment.user.username,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                      ),
                                    ),
                                    TextSpan(
                                      text: '  ·  ${timeAgo(comment.createdAt)}',
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.5),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              // Comment Content
                              Text(
                                comment.content,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.95),
                                  fontSize: 14,
                                  height: 1.3, // Better readability
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

          // Comment Input Field
          _CommentInputField(postId: postId),

          // Padding for modern iOS/Android home indicators
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}

class _CommentInputField extends StatefulWidget {
  final String postId;

  const _CommentInputField({required this.postId});

  @override
  State<_CommentInputField> createState() => _CommentInputFieldState();
}

class _CommentInputFieldState extends State<_CommentInputField> {
  static const String _fallbackAvatarUrl = 'https://placehold.net/avatar-2.png';
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final PostController _postController = Get.find<PostController>();
  final UserController _userController = Get.find<UserController>();

  Timer? _mentionDebounce;
  List<UserModel> _mentionSuggestions = <UserModel>[];
  UserModel? _selectedMentionUser;
  bool _isSearchingMentions = false;
  bool _isSubmittingComment = false;
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
      final responseBody =
          response.body is Map
              ? Map<String, dynamic>.from(response.body as Map)
              : <String, dynamic>{};

      if (response.statusCode == 200 && responseBody['code'] == '00') {
        final data = responseBody['data'];
        final rawUsers =
            data is Map<String, dynamic>
                ? ((data['users'] as List?) ??
                    (data['accounts'] as List?) ??
                    (data['results'] as List?) ??
                    const [])
                : (data is List ? data : const []);
        users =
            rawUsers
                .map(
                  (json) => UserModel.fromJson(Map<String, dynamic>.from(json)),
                )
                .where(
                  (user) =>
                      user.id.isNotEmpty &&
                      user.username.trim().isNotEmpty &&
                      !_userController.isCurrentUser(user.id),
                )
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
    final escapedUsername = RegExp.escape(selectedMentionUser.username);

    final mentionPattern = RegExp(
      '(^|\\s)@$escapedUsername(?=\\s|[.,!?]|' + r'$' + ')',
      caseSensitive: false,
    );

    if (!mentionPattern.hasMatch(_textController.text)) {
      return null;
    }

    return selectedMentionUser.id;
  }

  Future<void> _submitComment() async {
    final content = _textController.text.trim();
    if (content.isEmpty || _isSubmittingComment) return;

    final mentionedUserId = _activeMentionedUserId();
    if (_selectedMentionUser != null &&
        (mentionedUserId == null || mentionedUserId.isEmpty)) {
      CustomSnackBar.failure(
        message: 'Please reselect the tagged user before sending.',
      );
      return;
    }

    setState(() {
      _isSubmittingComment = true;
    });

    final submitted = await _postController.submitComment(
      widget.postId,
      content,
      mentionedUserId: mentionedUserId,
    );

    if (!mounted) return;

    if (submitted) {
      _textController.clear();
      setState(() {
        _selectedMentionUser = null;
        _mentionSuggestions = <UserModel>[];
        _isSearchingMentions = false;
        _isSubmittingComment = false;
      });
      return;
    }

    setState(() {
      _isSubmittingComment = false;
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
                            backgroundImage: NetworkImage(
                              user.profilePicture.trim().isNotEmpty
                                  ? user.profilePicture
                                  : _fallbackAvatarUrl,
                            ),
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
                  (_userController.user.value?.profilePicture
                              .trim()
                              .isNotEmpty ??
                          false)
                      ? _userController.user.value!.profilePicture
                      : _fallbackAvatarUrl,
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
                icon:
                    _isSubmittingComment
                        ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                        : const Icon(Icons.send, color: Colors.blue),
                onPressed: _isSubmittingComment ? null : _submitComment,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
