import 'package:get/get.dart';

import 'package:get/get.dart';
import 'package:hilite/controllers/user_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/repo/wallet_repo.dart';
import '../helpers/global_loader_controller.dart';
import '../models/wallet_model.dart';
import '../widgets/payment_webview.dart';
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
  // inside WalletController.dart

  Future<void> initiatePurchase(double amount) async {
    print("🚀 initiatePurchase called with amount: $amount");
    try {
      loader.showLoader();
      Response response = await walletRepo.initiatePayment(amount);
      loader.hideLoader();

      if (response.statusCode == 200 && response.body['code'] == '00') {
        String paymentLink;
        var data = response.body['data'];

        // Handle parsing
        if (data is String) {
          paymentLink = data;
        } else {
          paymentLink = data['link'];
        }

        print("🔗 Payment Link: $paymentLink");

        // REPLACE launchUrl WITH WebView --------------------------------------

        // Open WebView and wait for result
        final result = await Get.to(() => PaymentWebView(initialUrl: paymentLink));

        // If result is not null, it means we captured the ID!
        if (result != null && result is Map) {
          String txRef = result['ref'];
          String transactionId = result['id'];

          print("✅ Captured ID: $transactionId, Ref: $txRef");

          // Now we can verify!
          await verifyPurchase(txRef, transactionId);

        } else {
          print("❌ Payment cancelled or no ID captured");
          // Optionally refresh just in case they paid but we missed the intercept
          userController.getUserProfile();
        }
        // ---------------------------------------------------------------------

      } else {
        CustomSnackBar.failure(message: response.body['message'] ?? "Failed to initiate");
      }
    } catch (e, s) {
      loader.hideLoader();
      print("🔥 Exception: $e, $s");
      CustomSnackBar.failure(message: "Error: $e");
    }
  }

  // --------------------
  // 2. VERIFY PURCHASE (Optional/DeepLink)
  // --------------------
  Future<void> verifyPurchase(String txRef, String transactionId) async {
    print("🔍 verifyPurchase called: Ref=$txRef, ID=$transactionId"); // DEBUG PRINT
    try {
      loader.showLoader();
      Response response = await walletRepo.verifyPayment(txRef, transactionId);
      loader.hideLoader();

      print("📩 Verify Response: ${response.statusCode}"); // DEBUG PRINT
      print("📦 Body: ${response.body}"); // DEBUG PRINT

      if (response.statusCode == 200 && response.body['code'] == '00') {
        var tokensGranted = response.body['data']['tokensGranted'];

        print("✅ Payment Verified. Tokens Granted: $tokensGranted"); // DEBUG PRINT

        await userController.getUserProfile();
        CustomSnackBar.success(message: "Success! $tokensGranted tokens added.");
        getTransactions(isRefresh: true);
      } else {
        print("⚠️ Verification Failed: ${response.body['message']}"); // DEBUG PRINT
        CustomSnackBar.failure(message: response.body['message'] ?? "Verification failed");
      }
    } catch (e, s) {
      loader.hideLoader();
      print("🔥 Exception in verifyPurchase: $e"); // DEBUG PRINT
      print(s);
    }
  }

  // --------------------
  // 3. GIFTING FLOW
  // --------------------
  Future<void> giftTokens(String recipientId, double amount) async {
    print("🎁 giftTokens called: Recipient=$recipientId, Amount=$amount"); // DEBUG PRINT

    // 1. Check local balance first
    double currentBalance = double.tryParse(userController.user.value?.tokenBalance ?? "0") ?? 0;
    if (currentBalance < amount) {
      print("❌ Insufficient balance. Current: $currentBalance, Needed: $amount"); // DEBUG PRINT
      CustomSnackBar.failure(message: "Insufficient token balance");
      return;
    }

    try {
      loader.showLoader();
      Response response = await walletRepo.giftTokens(recipientId, amount);
      loader.hideLoader();

      print("📩 Gift Response: ${response.statusCode}"); // DEBUG PRINT
      print("📦 Body: ${response.body}"); // DEBUG PRINT

      if (response.statusCode == 200 && response.body['code'] == '00') {
        print("✅ Gift sent successfully");

        Get.dialog(
          GiftSuccessDialog(amount: amount),
          barrierDismissible: false,
        );

        userController.getUserProfile();
        getTransactions(isRefresh: true);

      } else {
        print("⚠️ Gifting Failed: ${response.body['message']}"); // DEBUG PRINT
        CustomSnackBar.failure(message: response.body['message'] ?? "Gifting failed");
      }
    } catch (e, s) {
      loader.hideLoader();
      print("🔥 Exception in giftTokens: $e"); // DEBUG PRINT
      print(s);
      CustomSnackBar.failure(message: "Error sending gift");
    }
  }

  // --------------------
  // 4. HISTORY
  // --------------------
  Future<void> getTransactions({bool isRefresh = false}) async {
    if (isRefresh) {
      print("🔄 Refreshing transactions..."); // DEBUG PRINT
      currentPage = 1;
      hasNextPage = true;
      transactionHistory.clear();
    }

    if (!hasNextPage) return;

    isLoadingHistory.value = true;

    try {
      print("📥 Fetching Transactions Page: $currentPage"); // DEBUG PRINT
      Response response = await walletRepo.getTokenTransactions(currentPage, 20);

      if (response.statusCode == 200 && response.body['code'] == '00') {
        List<dynamic> data = response.body['data'];
        print("✅ Transactions Fetched: ${data.length} items"); // DEBUG PRINT

        var newData = data.map((e) => TokenTransactionModel.fromJson(e)).toList();
        transactionHistory.addAll(newData);

        var pagination = response.body['pagination'];

        if (pagination != null) {
          hasNextPage = pagination['hasNextPage'] ?? false;
          if (hasNextPage) currentPage++;
        } else {
          hasNextPage = false;
        }
      } else {
        print("⚠️ Error fetching history: ${response.statusText}"); // DEBUG PRINT
      }
    } catch (e, s) {
      print("🔥 Exception in getTransactions: $e"); // DEBUG PRINT
      print(s);
    } finally {
      isLoadingHistory.value = false;
    }
  }
}