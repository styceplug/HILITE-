import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import '../controllers/user_controller.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

PostModel personalToPostModel(PersonalPostModel personal, {UserModel? authorProfile}) {
  final me = Get.find<UserController>().user.value;

  final UserModel? finalAuthor = authorProfile ?? me;

  bool amILiked = false;
  if (me != null) {
    amILiked = personal.likes.any((like) {
      if (like is String) return like == me.id;
      if (like is Map) return like['_id'] == me.id;
      return false;
    });
  }

  // 1. Prepare Video Details
  final videoContent = ContentDetails(
    url: personal.mediaUrl,
    title: personal.text,
    description: personal.text,
    thumbnailUrl: personal.thumbnail,
    duration: personal.duration,
  );

  // 2. Prepare Image Details (This was missing!)
  final imageContent = ContentDetails(
    url: personal.mediaUrl,
    title: personal.text,
    description: personal.text,
  );

  return PostModel(
    id: personal.id ?? '',
    type: personal.type ?? 'video',
    text: personal.text,
    author: finalAuthor,
    authorId: finalAuthor?.id,
    taggedUsers: personal.taggedUsers ?? [],
    video: (personal.type == 'video') ? videoContent : null,
    image: (personal.type == 'image') ? imageContent : null,

    likes: personal.likes,
    comments: personal.comments,
    isLiked: amILiked,
    createdAt: personal.createdAt,
  );
}

class MentionText extends StatelessWidget {
  final String text;
  final TextStyle? defaultStyle;
  final TextStyle? mentionStyle;
  final Function(String) onMentionTap;

  const MentionText({
    Key? key,
    required this.text,
    required this.onMentionTap,
    this.defaultStyle,
    this.mentionStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final RegExp mentionRegex = RegExp(r'(@\w+)');
    final List<TextSpan> spans = [];

    text.splitMapJoin(
      mentionRegex,
      onMatch: (Match match) {
        final String mention = match.group(0)!;
        spans.add(
          TextSpan(
            text: mention,
            style: mentionStyle ??
                defaultStyle?.copyWith(
                  color: Colors.blueAccent,
                  fontWeight: FontWeight.bold,
                ),
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                onMentionTap(mention.substring(1));
              },
          ),
        );
        return mention;
      },
      onNonMatch: (String nonMatch) {
        spans.add(TextSpan(text: nonMatch, style: defaultStyle));
        return nonMatch;
      },
    );

    return RichText(
      text: TextSpan(children: spans),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    );
  }
}