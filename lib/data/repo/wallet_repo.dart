import 'package:get/get.dart';

import '../api/api_client.dart';

class WalletRepo {
  final ApiClient apiClient;
  WalletRepo({required this.apiClient});

  Future<Response> initiatePayment(double amount) async {
    return await apiClient.postData('/v1/payment', {"amount": amount});
  }

  Future<Response> verifyPayment(String txRef, String transactionId) async {
    return await apiClient.getData('/v1/payment/verify?tx_ref=$txRef&transaction_id=$transactionId');
  }

  Future<Response> giftTokens(String recipientId, double tokens) async {
    return await apiClient.postData('/v1/payment/gift', {
      "recipientId": recipientId,
      "tokens": tokens
    });
  }

  Future<Response> getTokenTransactions(int page, int limit) async {
    return await apiClient.getData('/v1/payment/token/record?page=$page&limit=$limit');
  }

  Future<Response> getPaymentRecords() async {
    return await apiClient.getData('/v1/payment/record');
  }
}