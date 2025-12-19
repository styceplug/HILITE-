import 'package:get/get.dart';

import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/repo/wallet_repo.dart';
import '../helpers/global_loader_controller.dart';
import '../models/wallet_model.dart';
import '../widgets/snackbars.dart';


class WalletController extends GetxController {
  final WalletRepo walletRepo;
  WalletController({required this.walletRepo});

  final UserController userController = Get.find<UserController>();
  final GlobalLoaderController loader = Get.find<GlobalLoaderController>();

  var transactionHistory = <TokenTransactionModel>[].obs;
  var isLoadingHistory = false.obs;

  int currentPage = 1;
  bool hasNextPage = true;

  @override
  void onInit() {
    super.onInit();
    getTransactions(isRefresh: true);
  }

  // --------------------
  // 1. BUY TOKENS FLOW
  // --------------------
  Future<void> initiatePurchase(double amount) async {
    try {
      loader.showLoader();
      Response response = await walletRepo.initiatePayment(amount);
      loader.hideLoader();

      if (response.statusCode == 200 && response.body['code'] == '00') {
        String paymentLink = response.body['data']['link'];

        // Launch Flutterwave Link
        final Uri url = Uri.parse(paymentLink);
        if (await canLaunchUrl(url)) {
          await launchUrl(url, mode: LaunchMode.externalApplication);

          // Optional: Show dialog asking user to confirm when they return
          Get.defaultDialog(
              title: "Confirm Payment",
              middleText: "Did you complete the payment?",
              textConfirm: "Yes, I Paid",
              textCancel: "Cancel",
              onConfirm: () {
                Get.back(); // Close dialog
                // Usually, you might ask user for TxID or just refresh profile
                // If your API supports verification without ID (via Webhook), just refresh:
                userController.getUserProfile();
                getTransactions(isRefresh: true);
              }
          );
        }
      } else {
        CustomSnackBar.failure(message: response.body['message'] ?? "Failed to initiate payment");
      }
    } catch (e) {
      loader.hideLoader();
      CustomSnackBar.failure(message: "Error: $e");
    }
  }

  // If you have a way to get tx_ref and transaction_id (e.g. from Deep Link)
  Future<void> verifyPurchase(String txRef, String transactionId) async {
    try {
      loader.showLoader();
      Response response = await walletRepo.verifyPayment(txRef, transactionId);
      loader.hideLoader();

      if (response.statusCode == 200 && response.body['code'] == '00') {
        // Update local user balance from response
        var userData = response.body['data']['user'];
        var tokensGranted = response.body['data']['tokensGranted'];

        // Update logic in UserController
        await userController.getUserProfile(); // Sync fully
        CustomSnackBar.success(message: "Success! $tokensGranted tokens added.");
        getTransactions(isRefresh: true);
      } else {
        CustomSnackBar.failure(message: response.body['message'] ?? "Verification failed");
      }
    } catch (e) {
      loader.hideLoader();
      print(e);
    }
  }

  // --------------------
  // 2. GIFTING FLOW
  // --------------------
  Future<void> giftTokens(String recipientId, double amount) async {
    // 1. Check local balance first
    double currentBalance = double.tryParse(userController.user.value?.tokenBalance ?? "0") ?? 0;
    if (currentBalance < amount) {
      CustomSnackBar.failure(message: "Insufficient token balance");
      return;
    }

    try {
      loader.showLoader();
      Response response = await walletRepo.giftTokens(recipientId, amount);
      loader.hideLoader();

      if (response.statusCode == 200 && response.body['code'] == '00') {
        CustomSnackBar.success(message: "Gift sent successfully!");

        // Refresh User Balance & History
        userController.getUserProfile();
        getTransactions(isRefresh: true);

        Get.back(); // Close bottom sheet if open
      } else {
        CustomSnackBar.failure(message: response.body['message'] ?? "Gifting failed");
      }
    } catch (e) {
      loader.hideLoader();
      CustomSnackBar.failure(message: "Error sending gift");
    }
  }

  // --------------------
  // 3. HISTORY
  // --------------------


  Future<void> getTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      hasNextPage = true;
      transactionHistory.clear();
    }

    if (!hasNextPage) return;

    isLoadingHistory.value = true;

    try {
      Response response = await walletRepo.getTokenTransactions(currentPage, 20);

      if (response.statusCode == 200 && response.body['code'] == '00') {
        List<dynamic> data = response.body['data'];
        var newData = data.map((e) => TokenTransactionModel.fromJson(e)).toList();

        transactionHistory.addAll(newData);

        // FIX: Check if pagination exists before accessing it
        var pagination = response.body['pagination'];

        if (pagination != null) {
          hasNextPage = pagination['hasNextPage'] ?? false;
          if (hasNextPage) currentPage++;
        } else {
          // If no pagination object is sent, assume no next page
          hasNextPage = false;
        }
      }
    } catch (e) {
      print("Error loading history: $e");
    } finally {
      isLoadingHistory.value = false;
    }
  }
}