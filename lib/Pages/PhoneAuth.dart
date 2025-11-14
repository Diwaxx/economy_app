import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:economy_app/Services/Auth_Service.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  int start = 30;
  bool wait = false;
  String buttonName = "Send";
  TextEditingController phoneController = TextEditingController();
  AuthClass authClass = AuthClass();
  String verificationIdFinal = "";
  String smsCode = "";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text("Регистрация", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                height: 150,
              ),
              textField(),
              SizedBox(
                height: 40,
              ),
              Container(
                width: MediaQuery.of(context).size.width - 30,
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey,
                        margin: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                    Text(
                      "Введите шестизначный код",
                      style: TextStyle(color: Colors.white),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: Colors.grey,
                        margin: EdgeInsets.symmetric(horizontal: 12),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 20,
              ),
              otpField(),
              SizedBox(
                height: 20,
              ),
              RichText(
                  text: TextSpan(children: [
                TextSpan(
                    text: "Отправить повторно через ",
                    style: TextStyle(color: Colors.yellowAccent)),
                TextSpan(
                    text: "00:$start",
                    style: TextStyle(color: Colors.pinkAccent)),
                TextSpan(
                    text: " секунд",
                    style: TextStyle(color: Colors.pinkAccent)),
              ])),
              SizedBox(
                height: 150,
              ),
              colorButton(),
            ],
          ),
        ),
      ),
    );
  }

  void startTimer() {
    const onsec = Duration(seconds: 1);
    Timer timer = Timer.periodic(onsec, (timer) {
      if (start == 0) {
        setState(() {
          timer.cancel();
          wait = false;
        });
      } else {
        setState(() {
          start--;
        });
      }
    });
  }

  Widget colorButton() {
    return InkWell(
      onTap: () {
        authClass.signInwithPhoneNumber(verificationIdFinal, smsCode, context);
      },
      child: Container(
          height: 60,
          width: MediaQuery.of(context).size.width - 90,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(colors: [
                Color.fromARGB(255, 108, 142, 253),
                Color(0xffff9068),
                Color.fromARGB(255, 108, 176, 253)
              ])),
          child: Center(
            child: Text(
              "Продолжить",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          )),
    );
  }

  Widget otpField() {
    return OtpTextField(
      numberOfFields: 6,
      borderColor: Color(0xFF512DA8),
      textStyle: TextStyle(color: Colors.white),
      //set to true to show as box or false to show as dash
      showFieldAsBox: true,
      //runs when a code is typed in
      onCodeChanged: (String code) {
        //handle validation or checks here
      },
      //runs when every textfield is filled
      onSubmit: (String verificationCode) {
        setState(() {
          smsCode = verificationCode;
        });
        (smsCode = verificationCode);
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Verification Code"),
                content: Text('Code entered is $verificationCode'),
              );
            });
      }, // end onSubmit
    );
  }

  Widget textField() {
    return Container(
      width: MediaQuery.of(context).size.width - 40,
      height: 60,
      decoration: BoxDecoration(
          color: Color(0xff1d1d1d), borderRadius: BorderRadius.circular(15)),
      child: TextFormField(
        controller: phoneController,
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: "Введите ваш номер",
          hintStyle: TextStyle(color: Colors.white54),
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 8),
          prefixIcon: Padding(
            padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
            child: Text(" (+7) ",
                style: TextStyle(
                  color: Colors.white,
                )),
          ),
          suffixIcon: InkWell(
            onTap: wait
                ? null
                : () async {
                    setState(() {
                      start = 30;
                      wait = true;
                      buttonName = "Повторить";
                    });
                    await authClass.verifyPhoneNumber(
                        "+7 ${phoneController.text}", context, setData);
                  },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 15),
              child: Text(buttonName,
                  style: TextStyle(
                    color: wait ? Colors.grey : Colors.white,
                  )),
            ),
          ),
        ),
      ),
    );
  }

  void setData(String verificationId) {
    setState(() {
      verificationIdFinal = verificationId;
    });
    startTimer();
  }
}