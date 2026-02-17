import 'package:get/get.dart';

import '../controllers/user_controller.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

PostModel personalToPostModel(PersonalPostModel personal, {UserModel? authorProfile}) {
  final me = Get.find<UserController>().user.value;

  final author = Author(
    id: authorProfile?.id ?? me?.id ?? '',
    username: authorProfile?.username ?? me?.username ?? 'Unknown',
    profilePicture: authorProfile?.profilePicture ?? me?.profilePicture ?? '',
  );

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
    author: author,
    video: (personal.type == 'video') ? videoContent : null,
    image: null, // if you want images too, map image here
    likes: [],
    comments: [],
    isLiked: false,
  );
}