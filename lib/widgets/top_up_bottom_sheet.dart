import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/wallet_controller.dart';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

class TopUpBottomSheet extends StatefulWidget {
  const TopUpBottomSheet({super.key});

  @override
  State<TopUpBottomSheet> createState() => _TopUpBottomSheetState();
}

class _TopUpBottomSheetState extends State<TopUpBottomSheet> {
  final TextEditingController _amountController = TextEditingController();
  final WalletController walletController = Get.find<WalletController>();

  final List<int> _quickAmounts = [1000, 2000, 5000, 10000];
  int? _selectedAmount;

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Dynamic calculation for the preview
    double enteredAmount = double.tryParse(_amountController.text) ?? 0;
    int expectedTokens = (enteredAmount / 10).floor(); // 10 NGN = 1 Token
    final formatter = NumberFormat("#,###");

    return Container(
      // Padding handles keyboard sliding up
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF1F2937), // Elevated dark surface color
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- Drag Handle ---
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 25),

          // --- Header ---
          const Text(
            "Top Up Wallet",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 5),
          Text(
            "10 NGN = 1 Token",
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14),
          ),

          const SizedBox(height: 25),

          // --- Quick Select Grid ---
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _quickAmounts.map((amount) {
              bool isSelected = _selectedAmount == amount;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedAmount = amount;
                    _amountController.text = amount.toString();
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF2563EB) : Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: isSelected ? const Color(0xFF2563EB) : Colors.white.withOpacity(0.1),
                    ),
                  ),
                  child: Text(
                    "₦${formatter.format(amount)}",
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const SizedBox(height: 25),

          // --- Custom Input ---
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            onChanged: (val) {
              setState(() {
                _selectedAmount = null; // Deselect chips if typing manually
              });
            },
            decoration: InputDecoration(
              labelText: "Enter Amount (NGN)",
              labelStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
              prefixText: "₦ ",
              prefixStyle: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.1)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(color: Color(0xFF2563EB), width: 2),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // --- Real-time Token Preview ---
          if (expectedTokens > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "You will receive: ",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const Icon(Icons.circle, color: Colors.amber, size: 16), // Substitute with your custom token icon
                const SizedBox(width: 6),
                Text(
                  "${formatter.format(expectedTokens)} Tokens",
                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),

          const SizedBox(height: 25),

          // --- Pay Button ---
          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: () {
                if (_amountController.text.isNotEmpty) {
                  double? amount = double.tryParse(_amountController.text);
                  if (amount != null && amount > 0) {
                    Get.back(); // Close sheet
                    walletController.initiatePurchase(amount);
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB), // Primary Blue
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: const Text(
                "Proceed to Payment",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(height: 10), // Bottom padding
        ],
      ),
    );
  }
}