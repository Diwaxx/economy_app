import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:economy_app/Pages/HomePage.dart';
import 'package:economy_app/FireBase/Configurations/app_constants.dart';
import 'package:economy_app/FireBase/Models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  // Singleton pattern
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  // Stream для отслеживания состояния аутентификации
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Текущий пользователь
  User? get currentUser => _auth.currentUser;

  // **GOOGLE SIGN IN**
  Future<UserModel?> signInWithGoogle(BuildContext context) async {
    try {
      showLoadingSnackBar(context, "Вход через Google...");

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        showErrorSnackBar(context, "Вход отменен");
        return null;
      }

      final GoogleSignInAuthentication googleAuth = 
          await googleUser.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        // Создаем или обновляем профиль пользователя
        final UserModel userModel = await _createOrUpdateUserProfile(
          userCredential.user!,
        );

        await _storeAuthData(userCredential);
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => HomePage()),
          (route) => false,
        );

        showSuccessSnackBar(context, "Добро пожаловать!");
        return userModel;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
      return null;
    } catch (e) {
      showErrorSnackBar(context, "Ошибка входа: ${e.toString()}");
      return null;
    }
  }

  // **EMAIL/PASSWORD SIGN UP**
  Future<UserModel?> signUpWithEmail({
    required BuildContext context,
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      showLoadingSnackBar(context, "Создание аккаунта...");

      final UserCredential userCredential = 
          await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Обновляем displayName
        await userCredential.user!.updateDisplayName(displayName);

        final UserModel userModel = await _createOrUpdateUserProfile(
          userCredential.user!,
          displayName: displayName,
        );

        await _storeAuthData(userCredential);
        showSuccessSnackBar(context, "Аккаунт создан!");
        return userModel;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
      return null;
    }
  }

  // **EMAIL/PASSWORD SIGN IN**
  Future<UserModel?> signInWithEmail({
    required BuildContext context,
    required String email,
    required String password,
  }) async {
    try {
      showLoadingSnackBar(context, "Вход...");

      final UserCredential userCredential = 
          await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (userCredential.user != null) {
        // Обновляем время последнего входа
        await _updateLastLogin(userCredential.user!);
        
        await _storeAuthData(userCredential);
        showSuccessSnackBar(context, "Добро пожаловать!");
        
        return UserModel.fromFirestore(
          await _firestore.collection('users').doc(userCredential.user!.uid).get()
        );
      }

      return null;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
      return null;
    }
  }

  // **PHONE AUTHENTICATION**
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required BuildContext context,
    required Function(String) onCodeSent,
    required Function(PhoneAuthCredential) onVerificationCompleted,
  }) async {
    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: onVerificationCompleted,
        verificationFailed: (FirebaseAuthException e) {
          showErrorSnackBar(context, "Ошибка верификации: ${e.message}");
        },
        codeSent: (String verificationId, int? forceResendingToken) {
          onCodeSent(verificationId);
          showSuccessSnackBar(context, "Код отправлен на ваш номер");
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          showInfoSnackBar(context, "Время ожидания истекло");
        },
      );
    } catch (e) {
      showErrorSnackBar(context, "Ошибка: ${e.toString()}");
    }
  }

  Future<UserModel?> signInWithPhoneNumber(String verificationIdFinal, {
    required String verificationId,
    required String smsCode,
    required BuildContext context,
  }) async {
    try {
      showLoadingSnackBar(context, "Проверка кода...");

      final AuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final UserCredential userCredential = 
          await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        final UserModel userModel = await _createOrUpdateUserProfile(
          userCredential.user!,
        );

        await _storeAuthData(userCredential);
        
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => HomePage()),
          (route) => false,
        );

        showSuccessSnackBar(context, "Вход выполнен!");
        return userModel;
      }

      return null;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
      return null;
    }
  }

  // **CREATE/UPDATE USER PROFILE**
  Future<UserModel> _createOrUpdateUserProfile(
    User user, {
    String? displayName,
  }) async {
    final userRef = _firestore.collection('users').doc(user.uid);
    final userDoc = await userRef.get();

    final UserModel userModel = UserModel(
      uid: user.uid,
      email: user.email!,
      displayName: displayName ?? user.displayName,
      photoURL: user.photoURL,
      createdAt: userDoc.exists 
          ? (userDoc.data()!['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      lastLogin: DateTime.now(),
      preferences: userDoc.exists 
          ? userDoc.data()!['preferences'] 
          : {
              'currency': AppConstants.defaultCurrency,
              'theme': 'light',
              'notifications': true,
              'language': 'ru',
            },
    );

    await userRef.set(userModel.toMap(), SetOptions(merge: true));
    return userModel;
  }

  Future<void> _updateLastLogin(User user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'lastLogin': Timestamp.fromDate(DateTime.now()),
    });
  }

  // **PASSWORD RESET**
  Future<void> sendPasswordResetEmail({
    required String email,
    required BuildContext context,
  }) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      showSuccessSnackBar(context, "Письмо для сброса пароля отправлено");
    } on FirebaseAuthException catch (e) {
      _handleAuthError(context, e);
    }
  }

  // **LOGOUT**
  Future<void> signOut(BuildContext context) async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      await _storage.deleteAll();
      
      showSuccessSnackBar(context, "Вы вышли из аккаунта");
    } catch (e) {
      showErrorSnackBar(context, "Ошибка при выходе: ${e.toString()}");
    }
  }

  // **TOKEN MANAGEMENT**
  Future<void> _storeAuthData(UserCredential userCredential) async {
    try {
      final idToken = await userCredential.user!.getIdToken();
      await _storage.write(key: "token", value: idToken);
      await _storage.write(key: "userId", value: userCredential.user!.uid);
    } catch (e) {
      print("Error storing auth data: $e");
    }
  }

  Future<String?> getToken() async {
    return await _storage.read(key: "token");
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: "userId");
  }

  // **ERROR HANDLING**
  void _handleAuthError(BuildContext context, FirebaseAuthException e) {
    String errorMessage;
    
    switch (e.code) {
      case 'user-not-found':
        errorMessage = "Пользователь не найден";
        break;
      case 'wrong-password':
        errorMessage = "Неверный пароль";
        break;
      case 'email-already-in-use':
        errorMessage = "Email уже используется";
        break;
      case 'invalid-email':
        errorMessage = "Неверный формат email";
        break;
      case 'weak-password':
        errorMessage = "Пароль слишком слабый";
        break;
      case 'network-request-failed':
        errorMessage = "Ошибка сети";
        break;
      default:
        errorMessage = "Ошибка: ${e.message}";
    }
    
    showErrorSnackBar(context, errorMessage);
  }

  // **SNACKBAR HELPERS**
  void showLoadingSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const CircularProgressIndicator(color: Colors.white),
            const SizedBox(width: 12),
            Text(message),
          ],
        ),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void showInfoSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
      ),
    );
  }

  // **CHECK IF USER EXISTS**
  Future<bool> checkUserExists(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists;
  }
  
}