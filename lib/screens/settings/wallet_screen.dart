import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:hilite/utils/colors.dart';
import 'package:hilite/widgets/custom_appbar.dart';
import 'package:intl/intl.dart';

import '../../controllers/user_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../routes/routes.dart';
import '../../widgets/top_up_bottom_sheet.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Definining custom colors based on the image design
    const scaffoldBackground = Color(0xFF030712); // Total screen background
    const surfaceColor = Color(0xFF111827); // Darker surface like cards
    const opaqueButtonBackground = Color(0xFF1F2937); // Opaque circular back button
    const primaryBlue = Color(0xFF2563EB); // "Top Up Tokens" button color
    const lightGrey = Color(0xFF9CA3AF); // Subtitle/placeholder text color
    const textGrey = Color(0xFF6B7280); // Subtitle text color in history items
    const creditGreen = Color(0xFF10B981); // Positive amount color
    const debitRed = Color(0xFFEF4444); // Negative amount color

    final walletController = Get.put(WalletController(walletRepo: Get.find()));
    final userController = Get.find<UserController>();

    return Scaffold(
      appBar: CustomAppbar(
        leadingIcon:  Icon(Icons.arrow_back_ios_new, color: Colors.white),
        title: 'My Wallet',
      ),
      backgroundColor: scaffoldBackground,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await userController.getUserProfile();
            await walletController.getTransactions(isRefresh: true);
          },
          child: Column(
            children: [

              Obx(() {
                var user = userController.user.value;

                var rawBalance = user?.tokenBalance ?? 0;
                double parsedBalance = double.tryParse(rawBalance.toString()) ?? 0;
                final formatter = NumberFormat("#,###");
                String formattedBalance = formatter.format(parsedBalance);

                return Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(color: surfaceColor, borderRadius: BorderRadius.circular(25), boxShadow: [
                    // Very subtle shadow for depth
                    BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                  ]),
                  child: Column(
                    children: [
                      const Text("Token Balance", style: TextStyle(color: lightGrey, fontSize: 16)),
                      const SizedBox(height: 15),
                      // Composite row for coin icon and large amount text
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Custom composite widget for the detailed golden coin
                          const Stack(
                            alignment: Alignment.center,
                            children: [
                              Icon(Icons.circle, color: Colors.amber, size: 36), // Outer coin shape
                              Icon(Icons.stars, color: Color(0xFFFFD700), size: 28), // Star emblem
                              Icon(Icons.stars, color: Colors.white70, size: 28), // Emblem lighting effect
                            ],
                          ),
                          const SizedBox(width: 15),
                          Text(
                            formattedBalance,
                            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 30),
                      // Blue-filled button with custom styling
                      ElevatedButton(
                        onPressed: () {
                          Get.bottomSheet(
                            const TopUpBottomSheet(),
                            isScrollControlled: true,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                            backgroundColor: primaryBlue,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                        child: const Text("Top Up Tokens"),
                      )
                    ],
                  ),
                );
              }),
              const SizedBox(height: 30),

              // --- 3. Transaction History Header ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Recent Transactions", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                    // "View All" button with right arrow icon
                    TextButton(
                      onPressed: () {
                        // Get.toNamed(AppRoutes.transactionHistoryScreen);
                      },
                      style: TextButton.styleFrom(foregroundColor: lightGrey),
                      child:  Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text("View All"),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 5),

              // --- 4. Transaction List ---
              Expanded(
                child: Obx(() {
                  if (walletController.isLoadingHistory.value && walletController.transactionHistory.isEmpty) {
                    return const Center(child: CircularProgressIndicator(color: primaryBlue));
                  }

                  if (walletController.transactionHistory.isEmpty) {
                    return const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.history, size: 50, color: textGrey),
                          SizedBox(height: 10),
                          Text("No transactions yet", style: TextStyle(color: textGrey)),
                        ],
                      ),
                    );
                  }

                  return ListView.builder(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: walletController.transactionHistory.length,
                    itemBuilder: (context, index) {
                      var txn = walletController.transactionHistory[index];

                      // Determine styling based on type (Credit vs Debit)
                      bool isCredit = txn.transactionType == 'received';
                      String title = "";
                      String subtitle = "";

                      if (txn.isPurchase) {
                        title = "Token Purchase";
                        subtitle = DateFormat('MMM d, h:mm a').format(txn.createdAt);
                      } else if (txn.isGift) {
                        if (isCredit) {
                          title = "Gift from ${txn.giver?.username ?? 'Unknown'}";
                        } else {
                          title = "Gift to ${txn.receiver?.username ?? 'Unknown'}";
                        }
                        subtitle = DateFormat('MMM d, yyyy - h:mm a').format(txn.createdAt);
                      }

                      final tokenFormatter = NumberFormat("#,###");

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Custom circular icon container
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCredit ? creditGreen.withOpacity(0.15) : debitRed.withOpacity(0.15),
                              ),
                              child: Icon(
                                isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                                color: isCredit ? creditGreen : debitRed,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 15),
                            // Title and subtitle text
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 2),
                                  Text(subtitle, style: const TextStyle(color: textGrey, fontSize: 13)),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            // Trailing column for dynamic token amount and static comparison value
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                // Token Amount text with larger, colored, bold font
                                Text(
                                  "${isCredit ? '+' : '-'}${tokenFormatter.format(txn.tokens)}",
                                  style: TextStyle(color: isCredit ? creditGreen : debitRed, fontWeight: FontWeight.bold, fontSize: 18),
                                ),
                                const SizedBox(height: 4),
                                // Static grey text for comparison per design literal
                                const Text(
                                  "= 5,000",
                                  style: TextStyle(color: textGrey, fontSize: 12, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
