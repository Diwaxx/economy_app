import 'package:cloud_firestore/cloud_firestore.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String userId;
  final String title;
  final String category;
  final String description;
  final TransactionType type;
  final double amount;
  final String currency;
  final DateTime time;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.userId,
    required this.title,
    required this.category,
    required this.description,
    required this.type,
    required this.amount,
    required this.currency,
    required this.time,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'title': title,
      'category': category,
      'description': description,
      'type': type.toString().split('.').last,
      'amount': amount,
      'currency': currency,
      'time': Timestamp.fromDate(time),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Transaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Transaction(
      id: doc.id,
      userId: data['userId'],
      title: data['title'],
      category: data['category'],
      description: data['description'],
      type: data['type'] == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
      amount: (data['amount'] as num).toDouble(),
      currency: data['currency'] ?? 'RUB',
      time: (data['time'] as Timestamp).toDate(),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  // Вспомогательные методы
  bool get isIncome => type == TransactionType.income;
  bool get isExpense => type == TransactionType.expense;
}