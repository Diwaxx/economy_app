import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:economy_app/Pages/HomePage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CompactCategoryDropdown extends StatelessWidget {
  final List<String> categories;
  final ValueChanged<String?>? onChanged;
  final String? value;

  const CompactCategoryDropdown({
    super.key,
    this.categories = const ['Еда', 'Транспорт', 'Развлечения', 'Другое'],
    this.onChanged,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      textStyle: TextStyle( color:Colors.white ),
      width: 180, // Более компактная ширина
      initialSelection: value,
      hintText: 'Категория',
      onSelected: onChanged,
      dropdownMenuEntries: categories
          .map<DropdownMenuEntry<String>>(
            (value) => DropdownMenuEntry(value: value, label: value),
          )
          .toList(),
    );
  }
}
const List<String> categoryList = <String>['One', 'Two', 'Three', 'Four'];

class AddToDoPage extends StatefulWidget {
  const AddToDoPage({super.key});

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _desctiptionController = TextEditingController();
  String type = "";
  String category = "";
  TimeOfDay? selectedTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Color(0xff1d1e26), Color(0xff252041)])),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 30,
                ),
                IconButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (builder) => const HomePage()));
                  },
                  icon: const Icon(
                    CupertinoIcons.arrow_left,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title("Добавить трату"),
                      const SizedBox(
                        height: 20,
                      ),
                      label("Сумма траты"),
                      const SizedBox(
                        height: 10,
                      ),
                      enterTitle(55, 1, "Введите название", _titleController),
                      const SizedBox(
                        height: 15,
                      ),
                      label("Тип"),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        children: [
                          typeSelect("Расход", 0xff2664fa),
                          const SizedBox(
                            width: 10,
                          ),
                          typeSelect("Доход", 0xff2bc8d9),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      label("Описание"),
                      const SizedBox(
                        height: 15,
                      ),
                      enterTitle(150, null, "Введите описание",
                          _desctiptionController),
                      const SizedBox(
                        height: 10,
                      ),
                      label("Категория"),
                      const SizedBox(
                        height: 10,
                      ),
                      Wrap(
                        children: [
    CompactCategoryDropdown(
      categories: const [
        'Еда',
        'Транспорт',
        'Развлечения',
        'Одежда',
        'Здоровье',
        'Образование',
        'Путешествия',
        'Дом и быт',
        'Техника',
        'Другое'
      ],
      value: category.isEmpty ? null : category,
      onChanged: (String? newValue) {
        setState(() {
          category = newValue ?? "";
        });
      },
    ),
  ],
                       // ну сделай типа лист
                      ),
                      const SizedBox(height: 15),
                      label("Время"),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => selectTime(context),
                        child: Container(
                          height: 50,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            color: const Color(0xff2a2e3d),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            selectedTime != null
                                ? selectedTime!.format(context)
                                : "Выберите время",
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 17),
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 30,
                      ),
                      colorButton(),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> selectTime(BuildContext context) async {
    final now = TimeOfDay.now();

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: now,
      builder: (BuildContext context, Widget? child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (pickedTime != null) {
      // Например, сохраним выбранное время в состоянии
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Widget colorButton() {
    return InkWell(
      onTap: () {
        final now = DateTime.now();

        final time = selectedTime ?? TimeOfDay.now();

        final dateTime = DateTime(
          now.year,
          now.month,
          now.day,
          time.hour,
          time.minute,
        );

// Преобразуем МСК-время в UTC
        final utcDateTime = dateTime.subtract(const Duration(hours: 3));

        FirebaseFirestore.instance.collection("AddQuest").add({
          "title": _titleController.text,
          "category": category,
          "description": _desctiptionController.text,
          "taskType": type,
          "time": Timestamp.fromDate(utcDateTime),
        });

        Navigator.pop(context);
      },
      child: Container(
          height: 50,
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(colors: [
                Color.fromARGB(255, 108, 142, 253),
                Color(0xffff9068),
                Color.fromARGB(255, 108, 176, 253)
              ])),
          child: const Center(
            child: Text(
              "Создать",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
          )),
    );
  }

  Widget label(String label) {
    return Text(
      label,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 17),
    );
  }

  Widget typeSelect(String label, int color) {
    return InkWell(
      onTap: () {
        setState(() {
          type = label;
        });
      },
      child: Chip(
        backgroundColor: type == label ? Colors.white54 : Color(color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        label: Text(
          label,
          style: TextStyle(
              color: type == label ? Colors.black : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      ),
    );
  }

  Widget categorySelect(String label, int color) {
    return InkWell(
      onTap: () {
        setState(() {
          category = label;
        });
      },
      child: Chip(
        backgroundColor: category == label ? Colors.white : Color(color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        label: Text(
          label,
          style: TextStyle(
              color: category == label ? Colors.black : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      ),
    );
  }

  Widget enterTitle(double height, int? maxlines, String hintText,
      TextEditingController? controller) {
    return Container(
      height: height,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
        color: const Color(0xff2a2e3d),
        borderRadius: BorderRadius.circular(15),
      ),
      child: TextFormField(
        controller: controller,
        maxLines: maxlines,
        style: const TextStyle(color: Colors.grey, fontSize: 17),
        decoration: InputDecoration(
            border: InputBorder.none,
            hintText: hintText,
            hintStyle: const TextStyle(color: Colors.grey, fontSize: 17),
            contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 5)),
      ),
    );
  }

  Widget title(String title) {
    return Text(
      title,
      style: const TextStyle(
          fontSize: 33,
          color: Colors.white,
          fontWeight: FontWeight.bold,
          letterSpacing: 2),
    );
  }
}