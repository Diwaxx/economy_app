import 'package:economy_app/Pages/HomePage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:intl/date_symbol_data_file.dart';
import 'package:economy_app/Services/Auth_Service.dart';
import 'package:economy_app/pages/AddSpending.dart';
import 'package:economy_app/pages/SingInPage.dart';
import 'package:economy_app/pages/SingUpPage.dart';
import 'package:economy_app/pages/WidgetDropdown.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase Init Demo',
      home: FutureBuilder(
        future: _initialization,
        builder: (context, snapshot) {
          // Если инициализация завершилась с ошибкой
          if (snapshot.hasError) {
            return Scaffold(
              body: Center(child: Text('Ошибка инициализации Firebase')),
            );
          }

          // Если инициализация завершилась успешно
          if (snapshot.connectionState == ConnectionState.done) {
            return MyHomePage();
          }

          // Пока инициализация в процессе — показываем индикатор загрузки
          return Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Widget currPage = HomePage();
  AuthClass authClass = AuthClass();

  void checkLogin() async {
    String token = (await authClass.getToken());
    if (token != "") {
      setState(() {
        currPage = HomePage();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: currPage);
  }
}