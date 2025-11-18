import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:economy_app/Pages/AddTransaction.dart';
import 'package:economy_app/Pages/all_operations_page.dart';
import 'package:economy_app/Pages/charts_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:economy_app/Customs/ToDoCard.dart';
import 'package:economy_app/Services/Auth_Service.dart';
import 'package:economy_app/Services/Firestore_Service.dart';
import 'package:economy_app/pages/ProfilePage.dart';
import 'package:economy_app/pages/ViewData.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authClass = AuthService();
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<QuerySnapshot> _stream;

  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _stream = _firestoreService.getUserTransactions();
  }

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final russianWeekdays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье',
    ];
    String weekday = russianWeekdays[today.weekday - 1];

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Scaffold(
        backgroundColor: Colors.black87,
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.black87,
          title: const Text(
            "Добрый день",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              ),
              child: const CircleAvatar(backgroundImage: AssetImage("")),
            ),
            const SizedBox(width: 25),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(35),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.only(left: 22),
                child: Text(
                  "$weekday, ${today.day}",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black87,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 32, color: Colors.white),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (builder) => const AddToDoPage(),
                    ),
                  );
                },
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.indigoAccent, Colors.purple],
                    ),
                  ),
                  child: const Icon(Icons.add, size: 32, color: Colors.white),
                ),
              ),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.settings, size: 32, color: Colors.white),
              label: "",
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 10),

            // Виджет "Все операции"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _NavigationButton(
                  icon: Icons.list_alt,
                  title: "Все операции",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllOperationsPage()),
                    );
                  },
                ),
               
                _NavigationButton(
                  icon: Icons.pie_chart,
                  title: "Диаграммы",
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ChartsPage()),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Ошибка: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'Нет транзакций',
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    );
                  }

                  final docs = snapshot.data!.docs;

                  // Показываем только последние 5 записей на главной странице
                  final recentDocs = docs.take(5).toList();

                  return ListView.builder(
                    itemCount: recentDocs.length,
                    itemBuilder: (context, index) {
                      final document = recentDocs[index].data() as Map<String, dynamic>;
                      final Timestamp timestamp = document["time"];
                      final DateTime utcDateTime = timestamp.toDate();
                      final DateTime mskDateTime = utcDateTime.add(
                        const Duration(hours: 3),
                      );
                      final String timeInMoscow = DateFormat.Hm().format(
                        mskDateTime,
                      );

                      IconData iconData;
                      Color iconColor;

                      switch (document["category"]) {
                        case "Еда":
                          iconData = Icons.restaurant;
                          iconColor = Colors.red;
                          break;
                        case "Транспорт":
                          iconData = Icons.directions_car;
                          iconColor = Colors.blue;
                          break;
                        case "Развлечения":
                          iconData = Icons.movie;
                          iconColor = Colors.purple;
                          break;
                        case "Одежда":
                          iconData = Icons.shopping_bag;
                          iconColor = Colors.pink;
                          break;
                        case "Здоровье":
                          iconData = Icons.local_hospital;
                          iconColor = Colors.green;
                          break;
                        case "Образование":
                          iconData = Icons.school;
                          iconColor = Colors.orange;
                          break;
                        case "Путешествия":
                          iconData = Icons.flight;
                          iconColor = Colors.cyan;
                          break;
                        case "Дом и быт":
                          iconData = Icons.home;
                          iconColor = Colors.brown;
                          break;
                        case "Техника":
                          iconData = Icons.computer;
                          iconColor = Colors.grey;
                          break;
                        default:
                          iconData = Icons.attach_money;
                          iconColor = Colors.white;
                      }

                      return InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (builder) => ViewData(
                                document: document,
                                id: recentDocs[index].id,
                              ),
                            ),
                          );
                        },
                        child: ToDoCard(
                          title: "${document["title"] ?? ""} ₽",
                          iconBgColor: Colors.white,
                          iconColor: iconColor,
                          iconData: iconData,
                          time: timeInMoscow,
                          index: index,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _NavigationButton({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xff2a2e3d),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(width: 10),
              Icon(
                icon,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: 11),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 11),
            ],
          ),
        ),
      ),
    );
  }
}