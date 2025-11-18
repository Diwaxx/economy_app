import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:economy_app/Customs/type_select.dart';
import 'package:economy_app/Pages/HomePage.dart';
import 'package:economy_app/Services/Firestore_Service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:economy_app/Services/Firestore_Service.dart';

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
      textStyle: TextStyle(color: Colors.white),
      width: 180,
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

class AddToDoPage extends StatefulWidget {
  const AddToDoPage({super.key});

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  String type = "";
  String category = "";
  TimeOfDay? selectedTime;
  bool _isLoading = false;

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
                const SizedBox(height: 30),
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
                      const SizedBox(height: 20),
                      label("Сумма траты"),
                      const SizedBox(height: 10),
                      enterTitle(55, 1, "Введите сумму", _titleController),
                      const SizedBox(height: 15),
                      label("Тип"),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          typeSelect("Расход", 0xff2664fa),
                          const SizedBox(width: 10),
                          typeSelect("Доход", 0xff2bc8d9),
                        ],
                      ),
                      const SizedBox(height: 15),
                      label("Описание"),
                      const SizedBox(height: 15),
                      enterTitle(150, null, "Введите описание",
                          _descriptionController),
                      const SizedBox(height: 10),
                      label("Категория"),
                      const SizedBox(height: 10),
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
                      ),
                      const SizedBox(height: 15),
                      label("Время"),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _isLoading ? null : () => selectTime(context),
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
                      const SizedBox(height: 30),
                      _buildCreateButton(),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          ),
                        ),
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
      setState(() {
        selectedTime = pickedTime;
      });
    }
  }

  Widget _buildCreateButton() {
    return InkWell(
      onTap: _isLoading ? null : _addTransaction,
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width,
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
                  "Создать",
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

  Future<void> _addTransaction() async {
    // Валидация полей
    if (_titleController.text.isEmpty) {
      _showSnackBar("Введите сумму");
      return;
    }

    if (type.isEmpty) {
      _showSnackBar("Выберите тип");
      return;
    }

    if (category.isEmpty) {
      _showSnackBar("Выберите категорию");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final time = selectedTime ?? TimeOfDay.now();
      final dateTime = DateTime(
        now.year,
        now.month,
        now.day,
        time.hour,
        time.minute,
      );
      final utcDateTime = dateTime.subtract(const Duration(hours: 3));

      // Используем FirestoreService для добавления транзакции
      await _firestoreService.addTransaction(
        title: _titleController.text,
        category: category,
        description: _descriptionController.text,
        type: type,
        time: utcDateTime,
      );

      // Очистка полей после успешного добавления
      _titleController.clear();
      _descriptionController.clear();
      
      // Навигация обратно
      if (mounted) {
        Navigator.pop(context);
      }

    } catch (e) {
      if (mounted) {
        _showSnackBar("Ошибка при создании: ${e.toString()}");
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
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
    return TypeSelectWidget(
      label: label,
      color: color,
      selectedType: type,
      onTypeSelected: (selectedLabel) {
        setState(() {
          type = selectedLabel;
        });
      },
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
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        maxLines: maxlines,
        style: const TextStyle(color: Colors.grey, fontSize: 17),
        decoration: InputDecoration(
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey, fontSize: 17),
          contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 5),
        ),
        enabled: !_isLoading,
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
        letterSpacing: 2,
      ),
    );
  }
}