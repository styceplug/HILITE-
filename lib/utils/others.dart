import 'package:get/get.dart';

import '../controllers/user_controller.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

PostModel personalToPostModel(PersonalPostModel personal, {UserModel? authorProfile}) {
  final me = Get.find<UserController>().user.value;

  final UserModel? finalAuthor = authorProfile ?? me;

  final videoContent = ContentDetails(
    url: personal.mediaUrl,
    title: personal.text,
    description: personal.text,
    thumbnailUrl: personal.thumbnail,
    duration: personal.duration,
  );

  return PostModel(
    id: personal.id ?? '',
    type: personal.type ?? 'video',
    text: personal.text,
    author: finalAuthor,
    authorId: finalAuthor?.id,
    video: (personal.type == 'video') ? videoContent : null,
    image: null,
    likes: [],
    comments: [],
    isLiked: false,
  );
}