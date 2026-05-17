import 'package:get/get.dart';

import '../controllers/user_controller.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

PostModel personalToPostModel(PersonalPostModel personal, {UserModel? authorProfile}) {
  final me = Get.find<UserController>().user.value;

  // We just use the provided profile, or fallback to the logged-in user!
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
    author: finalAuthor,         // <-- Successfully passing the UserModel
    authorId: finalAuthor?.id,   // Keep the authorId synced
    video: (personal.type == 'video') ? videoContent : null,
    image: null,
    likes: [],
    comments: [],
    isLiked: false,
  );
}