class FirebaseConfig {
  static const collections = _Collections();
  static const storage = _StoragePaths();
  static const security = _SecurityRules();
}

class _Collections {
  const _Collections();
  
  String get users => 'users';
  String get transactions => 'transactions';
  String get categories => 'categories';
  
  String userDocument(String uid) => 'users/$uid';
  String userTransactions(String uid) => 'users/$uid/transactions';
  String userCategories(String uid) => 'users/$uid/categories';
  
}

class _StoragePaths {
  const _StoragePaths();
  
  String userAvatars(String uid) => 'user_avatars/$uid/profile.jpg';
  String receipts(String userId, String transactionId) => 
      'receipts/$userId/$transactionId.jpg';
}

class _SecurityRules {
  const _SecurityRules();
  
  // Константы для правил безопасности
  static const maxTransactionAmount = 1000000; // Макс. сумма транзакции
  static const maxTitleLength = 100;
  static const maxDescriptionLength = 500;
}