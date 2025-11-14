// ignore: file_names
import 'package:economy_app/Pages/HomePage.dart';
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
  firebase_auth.FirebaseAuth firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  AuthClass authClass = AuthClass();
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
            const SizedBox(
              height: 20,
            ),
            buttonItem("assets/google.svg", "Войти через гугл", 25, () async {
              await authClass.googleSignIn(context);
            }),
            const SizedBox(
              height: 15,
            ),
            buttonItem("assets/phone.svg", "Войти через телефон", 25, () {}),
            const SizedBox(
              height: 15,
            ),
            textItem("Почта ", _emailController, false),
            const SizedBox(
              height: 15,
            ),
            textItem("Пароль ", _passwordController, true),
            const SizedBox(
              height: 30,
            ),
            colorButton(context),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Еще нет аккаунта? ",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    )),
                InkWell(
                  onTap: () {
                    Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => SignUpPage()),
                        (route) => false);
                  },
                  child: const Text("Зарегестрироваться",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold)),
                ),
              ],
            )
          ],
        ),
      )),
    );
  }

  Widget colorButton(BuildContext context) {
    return InkWell(
      onTap: () async {
        try {
          firebase_auth.UserCredential userCredential =
              await firebaseAuth.signInWithEmailAndPassword(
                  email: _emailController.text,
                  password: _passwordController.text);
          if (context.mounted) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (builder) => HomePage()),
                (route) => false);
          }
        } catch (e) {
          final snackbar = SnackBar(content: Text(e.toString()));
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(snackbar);
          }
        }
      },
      child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width - 90,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(colors: [
                Color.fromARGB(255, 108, 142, 253),
                Color(0xffff9068),
                Color.fromARGB(255, 108, 176, 253)
              ])),
          child: const Center(
            child: Text(
              "Войти",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          )),
    );
  }

  Widget buttonItem(String image, String btnname, double size, Function ontap) {
    return InkWell(
      onTap: () => ontap(),
      child: SizedBox(
        height: 60,
        width: MediaQuery.of(context).size.width - 90,
        child: Card(
          color: Colors.black,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
              side: const BorderSide(width: 1, color: Colors.grey)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset(
                image,
                height: size,
                width: size,
              ),
              const SizedBox(
                width: 15,
              ),
              Text(btnname,
                  style: const TextStyle(
                      fontSize: 17,
                      color: Colors.white,
                      fontWeight: FontWeight.bold)),
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
        style: const TextStyle(
          color: Colors.white,
        ),
        obscureText: hide,
        controller: controller,
        decoration: InputDecoration(
            labelText: text,
            labelStyle: const TextStyle(
                fontSize: 17,
                color: Colors.white,
                fontWeight: FontWeight.bold)),
      ),
    );
  }
}