import 'package:hilite/models/user_model.dart';

class TokenTransactionModel {
  final String id;
  final UserModel? giver;
  final UserModel? receiver;
  final double tokens;
  final String type;
  final String transactionType;
  final bool isGift;
  final bool isPurchase;
  final DateTime createdAt;

  TokenTransactionModel({
    required this.id,
    this.giver,
    this.receiver,
    required this.tokens,
    required this.type,
    required this.transactionType,
    required this.isGift,
    required this.isPurchase,
    required this.createdAt,
  });

  factory TokenTransactionModel.fromJson(Map<String, dynamic> json) {
    return TokenTransactionModel(
      id: json['_id'] ?? '',
      giver: json['giver'] != null ? UserModel.fromJson(json['giver']) : null,
      receiver: json['reciever'] != null ? UserModel.fromJson(json['reciever']) : null,
      tokens: (json['tokens'] is int)
          ? (json['tokens'] as int).toDouble()
          : (json['tokens'] ?? 0.0),
      type: json['type'] ?? '',
      transactionType: json['transactionType'] ?? '',
      isGift: json['isGift'] ?? false,
      isPurchase: json['isPurchase'] ?? false,
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}

class PaymentRecordModel {
  final String id;
  final String status;
  final double amountPaid;
  final double tokensGranted;
  final String txRef;
  final DateTime createdAt;

  PaymentRecordModel({
    required this.id,
    required this.status,
    required this.amountPaid,
    required this.tokensGranted,
    required this.txRef,
    required this.createdAt,
  });

  factory PaymentRecordModel.fromJson(Map<String, dynamic> json) {
    return PaymentRecordModel(
      id: json['_id'] ?? '',
      status: json['status'] ?? 'pending',
      amountPaid: (json['amountPaid'] ?? 0).toDouble(),
      tokensGranted: (json['tokensGranted'] ?? 0).toDouble(),
      txRef: json['tx_ref'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}