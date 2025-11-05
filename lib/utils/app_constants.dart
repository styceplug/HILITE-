class AppConstants {

  // basic
  static const String APP_NAME = 'HILITE';


  static const String BASE_URL = '';

  //TOKEN
  static const authToken = 'authToken';
  static const header = 'header';
  static const String lastVersionCheck = 'lastVersionCheck';

  //update
  static const String VERSION_CHECK = '';







  static const String FIRST_INSTALL = 'first-install';
  static const String REMEMBER_KEY = 'remember-me';



  static String getPngAsset(String image) {
    return 'assets/images/$image.png';
  }
  static String getGifAsset(String image) {
    return 'assets/gifs/$image.gif';
  }

}
