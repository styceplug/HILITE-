class AppConstants {

  // basic
  static const String APP_NAME = 'HILITE';


  static const String BASE_URL = 'https://hilite-oq2v.onrender.com/api';

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
  static const String UPDATE_PROFILE_DETAILS = '/v1/user/personal/profile';






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
