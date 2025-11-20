// ignore: file_names
import 'package:economy_app/Pages/HomePage.dart';
import 'package:economy_app/pages/PhoneAuth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:economy_app/Services/Auth_Service.dart';
import 'package:economy_app/pages/SingUpPage.dart';

class SingInPage extends StatefulWidget {
  const SingInPage({super.key});

  @override
  State<SingInPage> createState() => _SingInPageState();
}

class _SingInPageState extends State<SingInPage> {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();
  bool _isLoading = false;

  Future<void> _signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithGoogle(context);
      if (user != null) {
        // ДОБАВЬТЕ НАВИГАЦИЮ ЗДЕСЬ
        _navigateToHome();
      }
    } catch (e) {
      // Ошибка обрабатывается в AuthService
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signInWithEmail() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _authService.showErrorSnackBar(context, "Заполните все поля");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final user = await _authService.signInWithEmail(
        context: context,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (user != null) {
        // ДОБАВЬТЕ НАВИГАЦИЮ ЗДЕСЬ
        _navigateToHome();
      }
    } catch (e) {
      // Ошибка обрабатывается в AuthService
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // ДОБАВЬТЕ ЭТОТ МЕТОД ДЛЯ НАВИГАЦИИ
  void _navigateToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (builder) => HomePage()),
      (route) => false,
    );
  }

  void _navigateToPhoneAuth() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (builder) => PhoneAuthPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
        color: Colors.black,
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Вход",
                style: TextStyle(
                    fontSize: 35,
                    color: Colors.white,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            buttonItem("assets/google.svg", "Войти через гугл", 25, () async {
              await _signInWithGoogle();
            }),
            const SizedBox(height: 15),
            buttonItem("assets/phone.svg", "Войти через телефон", 25, () {
              _navigateToPhoneAuth();
            }),
            const SizedBox(height: 15),
            textItem("Почта ", _emailController, false),
            const SizedBox(height: 15),
            textItem("Пароль ", _passwordController, true),
            const SizedBox(height: 30),
            _buildSignInButton(context),
            const SizedBox(height: 20),
            _buildSignUpLink(),
            if (_isLoading) 
              const Padding(
                padding: EdgeInsets.only(top: 20),
                child: CircularProgressIndicator(color: Colors.white),
              ),
          ],
        ),
      )),
    );
  }

  Widget _buildSignInButton(BuildContext context) {
    return InkWell(
      onTap: _isLoading ? null : _signInWithEmail,
      child: Container(
        height: 60,
        width: MediaQuery.of(context).size.width - 90,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(colors: [
            Color.fromARGB(255, 108, 142, 253),
            Color(0xffff9068),
            Color.fromARGB(255, 108, 176, 253)
          ]),
        ),
        child: Center(
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text(
                  "Войти",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSignUpLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Еще нет аккаунта? ",
          style: TextStyle(
            color: Colors.white,
            fontSize: 15,
          ),
        ),
        InkWell(
          onTap: _isLoading ? null : () {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (builder) => SignUpPage()),
              (route) => false,
            );
          },
          child: const Text(
            "Зарегистрироваться",
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget buttonItem(String image, String btnname, double size, Function ontap) {
    return InkWell(
      onTap: _isLoading ? null : () => ontap(),
      child: SizedBox(
        height: 60,
        width: MediaQuery.of(context).size.width - 90,
        child: Card(
          color: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
            side: const BorderSide(width: 1, color: Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                image,
                height: size,
                width: size,
              ),
              const SizedBox(width: 15),
              Text(
                btnname,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget textItem(String text, TextEditingController controller, bool hide) {
    return SizedBox(
      height: 55,
      width: MediaQuery.of(context).size.width - 90,
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        obscureText: hide,
        controller: controller,
        enabled: !_isLoading,
        decoration: InputDecoration(
          labelText: text,
          labelStyle: const TextStyle(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(color: Colors.blue),
          ),
        ),
      ),
    );
  }
}