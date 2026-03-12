class AppConstants {
  // basic
  static const String APP_NAME = 'HILITE';

  // static const String BASE_URL = 'https://hilite-oq2v.onrender.com/api';
  // static const String BASE_URL = 'http://72.62.60.218:5000/api';
  static const String BASE_URL = 'https://api.hiliteapp.net/api';
  static const String SOCKET_BASE_URL = 'https://api.hiliteapp.net';


  //TOKEN
  static const authToken = 'authToken';
  static const header = 'header';
  static const String lastVersionCheck = 'lastVersionCheck';

  //update
  static const String VERSION_CHECK = '/version-check';

  //auth
  static const String POST_LOGIN = '/v1/auth/login';
  static const String POST_REGISTER_FAN = '/v1/auth/register/fan';
  static const String POST_REGISTER_OTHERS = '/v1/auth/register/others';
  static const String GET_USERNAME_AVAILABILITY = '/v1/auth/username';
  static const String POST_PASS_RESET = '/v1/auth/password/initiate-reset';

  //user
  static const String GET_PROFILE = '/v1/auth/profile';
  static const String UPDATE_PROFILE_IMAGE = '/v1/user/personal/profile/avatar';
  static const String DELETE_AVATAR = '/v1/user/personal/profile/avatar';
  static const String UPDATE_PROFILE_DETAILS = '/v1/user/personal/profile';
  static const String GET_RECOMMENDED_ACCOUNTS = '/v1/recommendation/users';
  static const String SEARCH_ACCOUNTS = '/v1/search/global';
  static const String GET_RECOMMENDED_POSTS = '/v1/recommendation/posts';


  static String GET_SINGLE_POST(String postId) => '/v1/post/retrieve/$postId';



  static String FOLLOW_ACCOUNT(String targetId) =>
      '/v1/user/external/$targetId/follow';

  static String UNFOLLOW_ACCOUNT(String targetId) =>
      '/v1/user/external/$targetId/unfollow';

  static String BLOCK_ACCOUNT(String targetId) =>
      '/v1/user/external/$targetId/block';

  static String GET_OTHERS_PROFILE(String targetId) =>
      '/v1/user/external/$targetId/profile';

  static String UNLIKE_POST(String postId) =>
      '/v1/post/retrieve/$postId/unlike';


  static String DELETE_POST(String postId) =>
      '/v1/post/retrieve/$postId';

  static String LIKE_POST(String postId) => '/v1/post/retrieve/$postId/like';

  static String BOOKMARK_POST(String postId) =>
      '/v1/post/retrieve/$postId/bookmark';

  static String UNBOOKMARK_POST(String postId) =>
      '/v1/post/retrieve/$postId/unbookmark';

  static String GET_POST_COMMENTS(String postId) =>
      '/v1/post/retrieve/$postId/comment';

  static String POST_NEW_COMMENTS(String postId) =>
      '/v1/post/retrieve/$postId/comment';
  static const String UPLOAD_IMAGE_POST = '/v1/post/upload/image';
  static const String UPLOAD_VIDEO_POST = '/v1/post/upload/video';
  static const String GET_PERSONAL_RELATIONSHIPS = '/v1/user/personal/accounts';
  static const String GET_BOOKMARKED_POST = '/v1/user/personal/bookmarks';

  //trials
  static const String POST_TRIAL = '/v1/trial';
  static const String GET_TRIALS = '/v1/trial';

  static String GET_SINGLE_TRIALS(String trialId) => '/v1/trial/$trialId';

  static String EDIT_TRIALS(String trialId) => '/v1/trial/$trialId';

  static String DELETE_TRIALS(String trialId) => '/v1/trial/$trialId';



  static String REGISTER_FOR_TRIALS(String trialId) =>
      '/v1/trial/$trialId/register';

  //competition
  static const String GET_COMPETITION = '/v1/competition';
  static const String CREATE_COMPETITION = '/v1/competition';



  static String GET_COMPETITION_DETAILS(String competitionId) =>
      '/v1/competition/$competitionId';

  static const String GET_MY_POSTS = '/v1/user/personal/posts';

  static const String GET_NOTIFICATIONS = '/v1/notification';
  static const String MARK_NOTIFICATIONS_AS_READ = '/v1/notification';
static String MARK_SINGLE_NOTIFICATION_AS_READ(String notificationId) => '/v1/notification/$notificationId/read';


  static const String POST_DEVICE_TOKEN =
      '/v1/user/personal/profile/device-token';

  static const String FIRST_INSTALL = 'first-install';
  static const String REMEMBER_KEY = 'remember-me';

  static String getPngAsset(String image) {
    return 'assets/images/$image.png';
  }

  static String getGifAsset(String image) {
    return 'assets/gifs/$image.gif';
  }

  static String getLeagueAsset(String image) {
    return 'assets/league/$image.png';
  }
}
