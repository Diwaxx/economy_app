import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:economy_app/FireBase/Models/transaction_model.dart';

class Category {
  final String id;
  final String userId;
  final String name;
  final TransactionType type;
  final String colorHex;
  final String icon;
  final int orderIndex;
  final bool isDefault;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.colorHex,
    required this.icon,
    this.orderIndex = 0,
    this.isDefault = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'type': type.toString().split('.').last,
      'colorHex': colorHex,
      'icon': icon,
      'orderIndex': orderIndex,
      'isDefault': isDefault,
    };
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      userId: data['userId'],
      name: data['name'],
      type: data['type'] == 'income' 
          ? TransactionType.income 
          : TransactionType.expense,
      colorHex: data['colorHex'],
      icon: data['icon'],
      orderIndex: data['orderIndex'] ?? 0,
      isDefault: data['isDefault'] ?? false,
    );
  }
}