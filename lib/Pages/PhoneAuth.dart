import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:economy_app/Services/Auth_Service.dart';
import 'package:economy_app/Pages/HomePage.dart';

class PhoneAuthPage extends StatefulWidget {
  const PhoneAuthPage({super.key});

  @override
  State<PhoneAuthPage> createState() => _PhoneAuthPageState();
}

class _PhoneAuthPageState extends State<PhoneAuthPage> {
  int _countdown = 30;
  bool _isCodeSent = false;
  bool _isLoading = false;
  String _sendButtonText = "Отправить";
  final TextEditingController _phoneController = TextEditingController();
  final AuthService _authService = AuthService();
  String _verificationId = "";
  String _smsCode = "";
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    _phoneController.dispose();
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(oneSec, (timer) {
      if (_countdown == 0) {
        setState(() {
          timer.cancel();
        });
      } else {
        setState(() {
          _countdown--;
        });
      }
    });
  }

  Future<void> _verifyPhoneNumber() async {
    final phoneText = _phoneController.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (phoneText.isEmpty || phoneText.length != 10) {
      _authService.showErrorSnackBar(context, "Введите корректный номер телефона (10 цифр)");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String phoneNumber = "+7$phoneText";

    await _authService.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      context: context,
      onCodeSent: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
          _isCodeSent = true;
          _isLoading = false;
          _countdown = 30;
          _sendButtonText = "Повторить";
        });
        _startCountdown();
        _authService.showSuccessSnackBar(context, "Код отправлен на ваш номер");
      },
      onVerificationCompleted: (PhoneAuthCredential credential) async {
        // Автоматическая верификация - используем прямой вход
        try {
          final UserCredential userCredential = 
              await FirebaseAuth.instance.signInWithCredential(credential);
          
          if (userCredential.user != null) {
            // Создаем профиль через AuthService
            // await _authService._createOrUpdateUserProfile(userCredential.user!);
            // await _authService._storeAuthData(userCredential);
            
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => HomePage()),
              (route) => false,
            );
          }
        } catch (e) {
          _authService.showErrorSnackBar(context, "Ошибка автоматического входа");
        }
      },
    );

    setState(() {
      _isLoading = false;
    });
  }

  // Future<void> _signInWithSmsCode() async {
  //   if (_smsCode.isEmpty || _smsCode.length != 6) {
  //     _authService.showErrorSnackBar(context, "Введите корректный 6-значный код");
  //     return;
  //   }

  //   setState(() {
  //     _isLoading = true;
  //   });

  //   try {
  //     final user = await _authService.signInWithPhoneNumber(
  //       verificationId: _verificationId,
  //       smsCode: _smsCode,
  //       context: context,
  //     );

  //     if (user != null) {
  //       // Навигация происходит внутри AuthService
  //       Navigator.pushAndRemoveUntil(
  //         context,
  //         MaterialPageRoute(builder: (context) => HomePage()),
  //         (route) => false,
  //       );
  //     }
  //   } catch (e) {
  //     _authService.showErrorSnackBar(context, "Ошибка входа: ${e.toString()}");
  //   } finally {
  //     setState(() {
  //       _isLoading = false;
  //     });
  //   }
  // }

  void _resetFlow() {
    setState(() {
      _verificationId = "";
      _smsCode = "";
      _isCodeSent = false;
      _countdown = 30;
      _sendButtonText = "Отправить";
      _isLoading = false;
    });
    _timer?.cancel();
  }

  void _resendCode() {
    if (_countdown == 0) {
      _verifyPhoneNumber();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text("Регистрация", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        actions: [
          if (_isCodeSent)
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _resetFlow,
              tooltip: "Сбросить",
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              _buildPhoneInputSection(),
              const SizedBox(height: 40),
              if (_isCodeSent) _buildCodeInputSection(),
              const Spacer(),
              // if (_isCodeSent) _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Введите номер телефона",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Мы отправим SMS с кодом подтверждения",
          style: TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 20),
        Container(
          height: 60,
          decoration: BoxDecoration(
            color: const Color(0xff1d1d1d),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  "+7",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "900 123 45 67",
                    hintStyle: TextStyle(color: Colors.white54),
                    contentPadding: EdgeInsets.symmetric(vertical: 18),
                  ),
                  onChanged: (value) {
                    // Автоформатирование номера
                    final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                    if (digits.length <= 10) {
                      String formatted = '';
                      if (digits.length >= 3) {
                        formatted += '${digits.substring(0, 3)} ';
                        if (digits.length >= 6) {
                          formatted += '${digits.substring(3, 6)} ';
                          if (digits.length >= 8) {
                            formatted += '${digits.substring(6, 8)} ';
                            if (digits.length >= 10) {
                              formatted += digits.substring(8, 10);
                            } else {
                              formatted += digits.substring(6);
                            }
                          } else {
                            formatted += digits.substring(3);
                          }
                        } else {
                          formatted += digits.substring(3);
                        }
                      } else {
                        formatted = digits;
                      }
                      
                      if (value != formatted) {
                        _phoneController.value = TextEditingValue(
                          text: formatted,
                          selection: TextSelection.collapsed(offset: formatted.length),
                        );
                      }
                    }
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: _isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : TextButton(
                        onPressed: _isCodeSent ? null : _verifyPhoneNumber,
                        child: Text(
                          _sendButtonText,
                          style: TextStyle(
                            color: _isCodeSent ? Colors.grey : Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCodeInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Введите код из SMS",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          "Отправлено на номер +7${_phoneController.text}",
          style: const TextStyle(color: Colors.white54),
        ),
        const SizedBox(height: 20),
        _buildOtpField(),
        const SizedBox(height: 20),
        _buildCountdownText(),
      ],
    );
  }

  Widget _buildOtpField() {
    return OtpTextField(
      numberOfFields: 6,
      borderColor: const Color(0xFF512DA8),
      focusedBorderColor: Colors.blue,
      cursorColor: Colors.white,
      textStyle: const TextStyle(color: Colors.white, fontSize: 18),
      fieldWidth: 45,
      borderRadius: BorderRadius.circular(10),
      showFieldAsBox: true,
      keyboardType: TextInputType.number,
      onCodeChanged: (String code) {
        // Можно добавить валидацию при вводе
      },
      onSubmit: (String verificationCode) {
        setState(() {
          _smsCode = verificationCode;
        });
        // Автоматическая отправка при полном вводе кода
        if (verificationCode.length == 6) {
          // _signInWithSmsCode();
        }
      },
    );
  }

  Widget _buildCountdownText() {
    return GestureDetector(
      onTap: _countdown == 0 ? _resendCode : null,
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: "Отправить код повторно ",
              style: TextStyle(
                color: _countdown == 0 ? Colors.blue : Colors.white54,
              ),
            ),
            if (_countdown > 0) ...[
              TextSpan(
                text: "через ",
                style: const TextStyle(color: Colors.white54),
              ),
              TextSpan(
                text: "00:${_countdown.toString().padLeft(2, '0')}",
                style: TextStyle(
                  color: _countdown <= 10 ? Colors.red : Colors.pinkAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Widget _buildContinueButton() {
  //   return SizedBox(
  //     width: double.infinity,
  //     child: ElevatedButton(
  //       onPressed: _isLoading ? null : _signInWithSmsCode,
  //       style: ElevatedButton.styleFrom(
  //         backgroundColor: Colors.blue,
  //         padding: const EdgeInsets.symmetric(vertical: 16),
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(15),
  //         ),
  //       ),
  //       child: _isLoading
  //           ? SizedBox(
  //               width: 20,
  //               height: 20,
  //               child: CircularProgressIndicator(
  //                 strokeWidth: 2,
  //                 color: Colors.white,
  //               ),
  //             )
  //           : const Text(
  //               "Продолжить",
  //               style: TextStyle(
  //                 color: Colors.white,
  //                 fontSize: 18,
  //                 fontWeight: FontWeight.bold,
  //               ),
  //             ),
  //     ),
  //   );
  // }
}