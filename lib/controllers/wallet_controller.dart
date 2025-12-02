import 'package:get/get.dart';

class WalletController extends GetxController {
  RxInt userCoins = 1500.obs;

  // You would implement methods like:
  // Future<void> fetchBalance() async { ... }
  // Future<void> depositCoins() async { ... }
  // bool canAfford(int cost) => userCoins.value >= cost;

  void deductCoins(int amount) {
    if (canAfford(amount)) {
      userCoins.value -= amount;
      // TODO: Call API to confirm deduction
    }
  }

  bool canAfford(int cost) {
    return userCoins.value >= cost;
  }
}