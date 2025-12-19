import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../controllers/user_controller.dart';
import '../../controllers/wallet_controller.dart';
import '../../widgets/top_up_bottom_sheet.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final walletController = Get.put(WalletController(walletRepo: Get.find()));
    final userController = Get.find<UserController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("My Wallet"),
        centerTitle: true,
        elevation: 0,
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await userController.getUserProfile();
          await walletController.getTransactions(isRefresh: true);
        },
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 1. Balance Card
            Obx(() {
              var user = userController.user.value;

              // 1. Safely parse the balance to a number
              var rawBalance = user?.tokenBalance ?? 0;
              double parsedBalance = double.tryParse(rawBalance.toString()) ?? 0;

              // 2. Format with commas
              final formatter = NumberFormat("#,###");
              String formattedBalance = formatter.format(parsedBalance);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 5))
                    ]
                ),
                child: Column(
                  children: [
                    const Text("Token Balance", style: TextStyle(color: Colors.white70, fontSize: 14)),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.token, color: Colors.amber, size: 28),
                        const SizedBox(width: 10),
                        Text(
                          formattedBalance, // <--- UPDATED HERE
                          style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Get.bottomSheet(
                          const TopUpBottomSheet(),
                          isScrollControlled: true,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue[800],
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12)
                      ),
                      child: const Text("Top Up Tokens"),
                    )
                  ],
                ),
              );
            }),
            const SizedBox(height: 25),

            // 2. Transaction History Header
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text("Transaction History", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),

            const SizedBox(height: 10),

            // 3. Transaction List
            Expanded(
              child: Obx(() {
                if (walletController.isLoadingHistory.value && walletController.transactionHistory.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (walletController.transactionHistory.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.history, size: 50, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("No transactions yet"),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: walletController.transactionHistory.length,
                  itemBuilder: (context, index) {
                    var txn = walletController.transactionHistory[index];

                    // Determine styling based on type
                    bool isCredit = txn.transactionType == 'received';
                    String title = "";
                    String subtitle = "";

                    if (txn.isPurchase) {
                      title = "Token Purchase";
                      subtitle = DateFormat.yMMMd().format(txn.createdAt);
                    } else if (txn.isGift) {
                      if (isCredit) {
                        title = "Gift from ${txn.giver?.username ?? 'Unknown'}";
                      } else {
                        title = "Gift to ${txn.receiver?.username ?? 'Unknown'}";
                      }
                      subtitle = DateFormat.yMMMd().add_jm().format(txn.createdAt);
                    }

                    final tokenFormatter = NumberFormat("#,###");
                    final nairaFormatter = NumberFormat.currency(symbol: "₦", decimalDigits: 0);

                    double ngnValue = txn.tokens * 10;

                    return Card(
                      elevation: 0,
                      color: Colors.grey[50],
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        leading: CircleAvatar(
                          backgroundColor: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          child: Icon(
                            isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                            color: isCredit ? Colors.green : Colors.red,
                            size: 20,
                          ),
                        ),
                        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(subtitle, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min, // Important for ListTile trailing
                          children: [
                            // Token Amount
                            Text(
                              "${isCredit ? '+' : '-'}${tokenFormatter.format(txn.tokens)}",
                              style: TextStyle(
                                  color: isCredit ? Colors.green : Colors.red,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16
                              ),
                            ),
                            const SizedBox(height: 4),
                            // NGN Equivalent
                            Text(
                              "≈ ${nairaFormatter.format(ngnValue)}",
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );

                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showTopUpDialog(BuildContext context, WalletController controller) {
    final TextEditingController amountController = TextEditingController();
    Get.defaultDialog(
        title: "Buy Tokens",
        content: Column(
          children: [
            const Text("1000 NGN = 100 Tokens", style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 15),
            TextField(
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  hintText: "Enter amount in NGN",
                  border: OutlineInputBorder(),
                  prefixText: "₦ "
              ),
            ),
          ],
        ),
        textConfirm: "Pay Now",
        textCancel: "Cancel",
        confirmTextColor: Colors.white,
        onConfirm: () {
          if (amountController.text.isNotEmpty) {
            double? amount = double.tryParse(amountController.text);
            if (amount != null && amount > 0) {
              Get.back(); // Close dialog
              controller.initiatePurchase(amount);
            }
          }
        }
    );
  }
}