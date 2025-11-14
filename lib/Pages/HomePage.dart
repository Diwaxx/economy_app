import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:economy_app/Pages/AddTransaction.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:economy_app/Customs/ToDoCard.dart';
import 'package:economy_app/Services/Auth_Service.dart';
import 'package:economy_app/pages/ProfilePage.dart';
import 'package:economy_app/pages/ViewData.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final Stream<QuerySnapshot> _stream =
      FirebaseFirestore.instance.collection("AddQuest").snapshots();

  AuthClass authClass = AuthClass();
  List<Select> selected = [];

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
      'Воскресенье'
    ];
    String weekday = russianWeekdays[DateTime.now().weekday - 1];

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
                fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          actions: [
            InkWell(
              onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const ProfilePage())),
              child: const CircleAvatar(
                backgroundImage: AssetImage(""),
              ),
            ),
            const SizedBox(
              width: 25,
            ),
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
                      color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.black87,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.home,
                size: 32,
                color: Colors.white,
              ),
              label: "",
            ),
            BottomNavigationBarItem(
              icon: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (builder) => const AddToDoPage()));
                },
                child: Container(
                  height: 52,
                  width: 52,
                  decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                          colors: [Colors.indigoAccent, Colors.purple])),
                  child: const Icon(
                    Icons.add,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
              ),
              label: "",
            ),
            const BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                size: 32,
                color: Colors.white,
              ),
              label: "",
            ),
          ],
        ),
        body: Column(
          children: [
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                  stream: _stream,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    // Синхронизируем список selected с текущими документами
                    if (selected.length != docs.length) {
                      selected = docs
                          .map((doc) => Select(id: doc.id, checkValue: false))
                          .toList();
                    }

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final rawData = docs[index].data();
                        final document = (rawData is Map)
                            ? Map<String, dynamic>.from(rawData)
                            : <String, dynamic>{};
                        final Timestamp timestamp = document["time"];
                        final DateTime utcDateTime = timestamp.toDate();
                        final DateTime mskDateTime =
                            utcDateTime.add(const Duration(hours: 3));
                        final String timeInMoscow =
                            DateFormat.Hm().format(mskDateTime);

                        IconData iconData;
                        Color iconColor;

                        switch (document["category"]) {
                          case "Тренировка":
                            iconData = Icons.run_circle_outlined;
                            iconColor = Colors.orange;
                            break;
                          case "Покупки":
                            iconData = Icons.shopping_cart;
                            iconColor = Colors.black;
                            break;
                          case "Обучение":
                            iconData = Icons.school;
                            iconColor = Colors.orange;
                            break;
                          case "Встреча":
                            iconData = Icons.library_books;
                            iconColor = Colors.black;
                            break;
                          default:
                            iconData = Icons.run_circle_outlined;
                            iconColor = Colors.white;
                        }

                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (builder) => ViewData(
                                          document: document,
                                          id: docs[index].id,
                                        )));
                          },
                          child: ToDoCard(
                            title: document["title"] ?? "",
                            check: selected[index].checkValue,
                            iconBgColor: Colors.white,
                            iconColor: iconColor,
                            iconData: iconData,
                            time: timeInMoscow,
                            onChange: onChange,
                            index: index,
                          ),
                        );
                      },
                    );
                  }),
            ),
          ],
        ),
      ),
    );
  }

  void onChange(int index) {
    setState(() {
      selected[index].checkValue = !(selected[index].checkValue ?? false);
    });
  }
}

class Select {
  String? id;
  bool? checkValue = false;
  Select({this.id, this.checkValue});
}