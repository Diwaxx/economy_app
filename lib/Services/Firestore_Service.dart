import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> addTransaction({
    required String title,
    required String category,
    required String description,
    required String type,
    required DateTime time,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    await _firestore
        .collection("users")
        .doc(user.uid)
        .collection("transactions")
        .add({
          "title": title,
          "category": category,
          "description": description,
          "taskType": type,
          "time": Timestamp.fromDate(time),
          "userId": user.uid,
          "createdAt": FieldValue.serverTimestamp(),
        });
  }

  // Дополнительные методы для работы с транзакциями
  Stream<QuerySnapshot> getUserTransactions() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection("users")
        .doc(user.uid)
        .collection("transactions")
        .orderBy("time", descending: true)
        .snapshots();
  }
}