import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ViewData extends StatefulWidget {
  const ViewData({super.key, this.document, this.id});
  final Map<String, dynamic>? document;
  final String? id;
  @override
  State<ViewData> createState() => _ViewDataState();
}

class _ViewDataState extends State<ViewData> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _desctiptionController = TextEditingController();
  String? type = "";
  String? category = "";
  late DateTime time;

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.document!["title"] ?? "";
    _desctiptionController.text = widget.document!["description"] ?? "";
    type = widget.document!["taskType"];
    category = widget.document!["category"];
    final timestamp = widget.document!["time"];
    if (timestamp != null && timestamp is Timestamp) {
      time = timestamp.toDate().add(const Duration(hours: 3));
    } else {
      time = DateTime.now(); // или null, если хотите
    }
    //print("Document in initState: ${widget.document}");
  }

  @override
  void dispose() {
    _titleController.dispose();
    _desctiptionController.dispose();
    super.dispose();
  }

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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        CupertinoIcons.arrow_left,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              FirebaseFirestore.instance
                                  .collection("AddQuest")
                                  .doc(widget.id)
                                  .delete()
                                  .then((value) {
                                Navigator.pop(context);
                              });
                            });
                          },
                          icon: const Icon(
                            CupertinoIcons.delete,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 25, vertical: 5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //title(""),

                      label("Название"),
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
                          typeSelect("Важное", 0xff2664fa),
                          const SizedBox(
                            width: 10,
                          ),
                          typeSelect("Запланнированное", 0xff2bc8d9),
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
                        runSpacing: 5,
                        children: [
                          categorySelect("Покупки", 0xffff6d6e),
                          const SizedBox(
                            width: 10,
                          ),
                          categorySelect("Встреча", 0xffff0000),
                          const SizedBox(
                            width: 10,
                          ),
                          categorySelect("Обучение", 0xffb74093),
                          const SizedBox(
                            width: 10,
                          ),
                          categorySelect("Тренировка", 0xfff29732),
                          const SizedBox(
                            width: 10,
                          ),
                          categorySelect("Прочее", 0xff9056e5),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      label("Время"),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: _pickTime,
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
                            "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}",
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

  Future<void> _pickTime() async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: time.hour, minute: time.minute),
    );
    if (pickedTime != null) {
      setState(() {
        time = DateTime(
          time.year,
          time.month,
          time.day,
          pickedTime.hour,
          pickedTime.minute,
        );
      });
    }
  }

  Widget colorButton() {
    return InkWell(
      onTap: () {
        FirebaseFirestore.instance
            .collection("AddQuest")
            .doc(widget.id)
            .update({
          "title": _titleController.text,
          "category": category,
          "description": _desctiptionController.text,
          "taskType": type,
          "time": Timestamp.fromDate(time.subtract(const Duration(hours: 3))),
          // сохраняем как Timestamp
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
              "Изменить",
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