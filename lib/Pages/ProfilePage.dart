import 'package:economy_app/FireBase/Models/user_model.dart';
import 'package:economy_app/Pages/SingInPage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:economy_app/Services/Auth_Service.dart';
import 'package:economy_app/Pages/HomePage.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = true;
  final Map<String, String> _currencyOptions = {
    'RUB': 'Рубли (₽)',
    'USD': 'Доллары (\$)',
    'EUR': 'Евро (€)',
    'KZT': 'Тенге (₸)',
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (userDoc.exists) {
          setState(() {
            _user = UserModel.fromFirestore(userDoc);
          });
        }
      }
    } catch (e) {
      print('Ошибка загрузки данных пользователя: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateUserPreferences(Map<String, dynamic> newPreferences) async {
    if (_user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(_user!.uid)
          .update({
            'preferences': newPreferences,
          });

      // Обновляем локальные данные пользователя
      setState(() {
        _user = UserModel(
          uid: _user!.uid,
          email: _user!.email,
          displayName: _user!.displayName,
          photoURL: _user!.photoURL,
          createdAt: _user!.createdAt,
          lastLogin: _user!.lastLogin,
          preferences: newPreferences,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Настройки обновлены'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ошибка обновления: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showCurrencyDialog() async {
    String? selectedCurrency = _user?.preferences?['currency'] ?? 'RUB';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xff2a2e3d),
        title: Text(
          'Выберите валюту',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _currencyOptions.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(
                entry.value,
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              value: entry.key,
              groupValue: selectedCurrency,
              onChanged: (value) {
                setState(() {
                  selectedCurrency = value!;
                });
                Navigator.pop(context);
                _updateUserPreferences({
                  ..._user!.preferences ?? {},
                  'currency': selectedCurrency,
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _showThemeDialog() async {
    String? selectedTheme = _user?.preferences?['theme'] ?? 'light';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xff2a2e3d),
        title: Text(
          'Выберите тему',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: Text(
                'Светлая',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              value: 'light',
              groupValue: selectedTheme,
              onChanged: (value) {
                setState(() {
                  selectedTheme = value!;
                });
                Navigator.pop(context);
                _updateUserPreferences({
                  ..._user!.preferences ?? {},
                  'theme': selectedTheme,
                });
              },
            ),
            RadioListTile<String>(
              title: Text(
                'Темная',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              value: 'dark',
              groupValue: selectedTheme,
              onChanged: (value) {
                setState(() {
                  selectedTheme = value!;
                });
                Navigator.pop(context);
                _updateUserPreferences({
                  ..._user!.preferences ?? {},
                  'theme': selectedTheme,
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _logout() async {
    final confirmed = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xff2a2e3d),
        title: Text(
          'Выход',
          style: TextStyle(color: Colors.white, fontSize: 20),
        ),
        content: Text(
          'Вы уверены, что хотите выйти?',
          style: TextStyle(color: Colors.white70, fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Отмена',
              style: TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Выйти', 
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _authService.signOut(context);
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (builder) => const SingInPage()),
          (route) => false,
        );
      }
    }
  }

  Widget _buildUserInfo() {
    if (_user == null) {
      return ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        ),
        title: Text(
          'Пользователь не найден',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      );
    }

    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue,
            backgroundImage: _user!.photoURL != null 
                ? NetworkImage(_user!.photoURL!) 
                : null,
            child: _user!.photoURL == null 
                ? Icon(Icons.person, color: Colors.white, size: 24)
                : null,
          ),
          title: Text(
            _user!.displayName ?? _user!.email!.split('@')[0],
            style: TextStyle(
              color: Colors.white, 
              fontSize: 18, 
              fontWeight: FontWeight.bold
            ),
          ),
          subtitle: Text(
            _user!.email!,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
        Divider(color: Colors.white30),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    final currency = _user?.preferences?['currency'] ?? 'RUB';
    final theme = _user?.preferences?['theme'] ?? 'light';
    final notifications = _user?.preferences?['notifications'] ?? true;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Настройки',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        _buildPreferenceItem(
          icon: Icons.currency_exchange,
          title: 'Валюта',
          value: _currencyOptions[currency] ?? 'Рубли (₽)',
          onTap: _showCurrencyDialog,
        ),
        _buildPreferenceItem(
          icon: Icons.color_lens,
          title: 'Тема',
          value: theme == 'light' ? 'Светлая' : 'Темная',
          onTap: _showThemeDialog,
        ),
        Container(
          color: Color(0xff2a2e3d),
          child: SwitchListTile(
            secondary: Icon(Icons.notifications, color: Colors.white),
            title: Text(
              'Уведомления',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            subtitle: Text(
              'Получать уведомления о расходах',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
            value: notifications,
            activeColor: Colors.blue,
            onChanged: (value) {
              _updateUserPreferences({
                ..._user!.preferences ?? {},
                'notifications': value,
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem({
    required IconData icon,
    required String title,
    required String value,
    required VoidCallback onTap,
  }) {
    return Container(
      color: Color(0xff2a2e3d),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        subtitle: Text(
          value,
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white70),
        onTap: onTap,
      ),
    );
  }

  Widget _buildStatsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Статистика',
            style: TextStyle(
              color: Colors.white, 
              fontSize: 20, 
              fontWeight: FontWeight.bold
            ),
          ),
        ),
        Container(
          color: Color(0xff2a2e3d),
          child: ListTile(
            leading: Icon(Icons.calendar_today, color: Colors.white),
            title: Text(
              'Дата регистрации',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            subtitle: Text(
              _user != null 
                  ? '${_user!.createdAt.day}.${_user!.createdAt.month}.${_user!.createdAt.year}'
                  : 'Неизвестно',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
        SizedBox(height: 1),
        Container(
          color: Color(0xff2a2e3d),
          child: ListTile(
            leading: Icon(Icons.login, color: Colors.white),
            title: Text(
              'Последний вход',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            subtitle: Text(
              _user != null 
                  ? '${_user!.lastLogin.day}.${_user!.lastLogin.month}.${_user!.lastLogin.year} ${_user!.lastLogin.hour}:${_user!.lastLogin.minute.toString().padLeft(2, '0')}'
                  : 'Неизвестно',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: Text(
          'Профиль',
          style: TextStyle(color: Colors.white, fontSize: 24),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  _buildUserInfo(),
                  _buildPreferencesSection(),
                  _buildStatsSection(),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _logout,
                        child: Text(
                          'Выйти из аккаунта',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            ),
    );
  }
}