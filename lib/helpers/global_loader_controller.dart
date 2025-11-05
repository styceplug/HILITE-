import 'package:get/get.dart';

class GlobalLoaderController extends GetxController {
  var isLoading = false.obs;

  void showLoader() => isLoading.value = true;
  void hideLoader() => isLoading.value = false;
}



final loader = Get.find<GlobalLoaderController>();