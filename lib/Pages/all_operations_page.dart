import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:economy_app/Customs/type_select.dart';
import 'package:economy_app/Services/Firestore_Service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:economy_app/Customs/ToDoCard.dart';
import 'package:economy_app/pages/ViewData.dart';

class AllOperationsPage extends StatefulWidget {
  const AllOperationsPage({super.key});

  @override
  State<AllOperationsPage> createState() => _AllOperationsPageState();
}

class _AllOperationsPageState extends State<AllOperationsPage> {
  final FirestoreService _firestoreService = FirestoreService();
  late Stream<QuerySnapshot> _stream;
  
  String type = "Все";
  String category = "";
  DateTime _selectedDate = DateTime.now();
  String _viewMode = "День";
  DateTime _selectedMonth = DateTime.now();
  
  @override
  void initState() {
    super.initState();
    _initializeStream();
  }

  void _initializeStream() {
    _stream = _firestoreService.getUserTransactions();
  }
  // Русские названия месяцев
  final List<String> _russianMonths = [
    'Январь', 'Февраль', 'Март', 'Апрель', 'Май', 'Июнь',
    'Июль', 'Август', 'Сентябрь', 'Октябрь', 'Ноябрь', 'Декабрь'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          "Все операции",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          
          // Контейнер с выбором режима просмотра
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff2a2e3d),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Просмотр:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    _buildViewModeButton("День"),
                    const SizedBox(width: 10),
                    _buildViewModeButton("Месяц"),
                  ],
                ),
              ],
            ),
          ),

          // Контейнер с выбором даты/месяца
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff2a2e3d),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _viewMode == "День" ? "Дата:" : "Месяц:",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                InkWell(
                  onTap: _viewMode == "День" ? _selectDate : _selectMonth,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Text(
                          _viewMode == "День" 
                            ? DateFormat('dd.MM.yyyy').format(_selectedDate)
                            : '${_russianMonths[_selectedMonth.month - 1]} ${_selectedMonth.year}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          _viewMode == "День" 
                            ? Icons.calendar_today 
                            : Icons.calendar_view_month,
                          color: Colors.white,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Контейнер с виджетами выбора типа
          Container(
            height: 60,
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xff2a2e3d),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                typeSelect("Доход", 0xff2a2e3d),
                typeSelect("Расход", 0xff2a2e3d),
                typeSelect("Все", 0xff2a2e3d),
              ],
            ),
          ),
          
          const SizedBox(height: 10),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
                stream: _stream,
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data!.docs;

                  // Фильтруем документы по выбранному типу и дате/месяцу
                  final filteredDocs = docs.where((doc) {
                    final rawData = doc.data();
                    final document = (rawData is Map)
                        ? Map<String, dynamic>.from(rawData)
                        : <String, dynamic>{};
                    
                    final documentType = document["taskType"]?.toString() ?? "";
                    final documentDate = document["time"] as Timestamp?;
                    
                    // Проверяем тип
                    final typeMatch = type == "Все" || documentType == type;
                    
                    // Проверяем дату/месяц
                    bool dateMatch = true;
                    if (documentDate != null) {
                      final docDateTime = documentDate.toDate();
                      
                      if (_viewMode == "День") {
                        // Фильтрация по дню
                        final selectedDateStart = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                        );
                        final selectedDateEnd = DateTime(
                          _selectedDate.year,
                          _selectedDate.month,
                          _selectedDate.day,
                          23,
                          59,
                          59,
                        );
                        
                        dateMatch = docDateTime.isAfter(selectedDateStart) && 
                                   docDateTime.isBefore(selectedDateEnd);
                      } else {
                        // Фильтрация по месяцу
                        final monthStart = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month,
                          1,
                        );
                        final monthEnd = DateTime(
                          _selectedMonth.year,
                          _selectedMonth.month + 1,
                          0,
                          23,
                          59,
                          59,
                        );
                        
                        dateMatch = docDateTime.isAfter(monthStart) && 
                                   docDateTime.isBefore(monthEnd);
                      }
                    }
                    
                    return typeMatch && dateMatch;
                  }).toList();

                  // Синхронизируем список selected с отфильтрованными документами
                

                  // Показываем сообщение если нет элементов после фильтрации
                  if (filteredDocs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.receipt_long,
                            color: Colors.white54,
                            size: 64,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _getEmptyStateMessage(),
                            style: const TextStyle(
                              color: Colors.white54,
                              fontSize: 18,
                              
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  // Сортируем по дате (сначала новые)
                  filteredDocs.sort((a, b) {
                    final aData = a.data() as Map<String, dynamic>;
                    final bData = b.data() as Map<String, dynamic>;
                    final aTime = (aData["time"] as Timestamp).toDate();
                    final bTime = (bData["time"] as Timestamp).toDate();
                    return bTime.compareTo(aTime);
                  });

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      final rawData = filteredDocs[index].data();
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
                                        id: filteredDocs[index].id,
                                      )));
                        },
                        child: ToDoCard(
                          title: document["title"] ?? "",
                  
                          iconBgColor: Colors.white,
                          iconColor: iconColor,
                          iconData: iconData,
                          time: timeInMoscow,
                          index: index,
                        ),
                      );
                    },
                  );
                }),
          ),
        ],
      ),
    );
  }

  // Виджет кнопки выбора режима просмотра
  Widget _buildViewModeButton(String mode) {
    return InkWell(
      onTap: () {
        setState(() {
          _viewMode = mode;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _viewMode == mode ? Colors.purple : Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          mode,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: _viewMode == mode ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // Функция для выбора даты
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Colors.purple,
              onPrimary: Colors.white,
              surface: Color(0xff2a2e3d),
              onSurface: Colors.white,
            ),
            dialogBackgroundColor: Colors.black87,
          ),
          child: child!,
        );
      },
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  // Функция для выбора месяца
  Future<void> _selectMonth() async {
    int tempYear = _selectedMonth.year;
    int tempMonth = _selectedMonth.month;

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: const Color(0xff2a2e3d),
              title: const Text(
                'Выберите месяц и год',
                style: TextStyle(color: Colors.white),
              ),
              content: SizedBox(
                width: 300,
                height: 400,
                child: Column(
                  children: [
                    // Выбор года
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                            onPressed: () {
                              setDialogState(() {
                                tempYear--;
                              });
                            },
                          ),
                          Text(
                            '$tempYear',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                            onPressed: () {
                              setDialogState(() {
                                tempYear++;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Выбор месяца
                    Expanded(
                      child: GridView.builder(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: 12,
                        itemBuilder: (context, index) {
                          final month = index + 1;
                          final isSelected = month == tempMonth;
                          
                          return InkWell(
                            onTap: () {
                              setDialogState(() {
                                tempMonth = month;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.purple : Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  _russianMonths[index],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Кнопки подтверждения/отмены
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text(
                            'Отмена',
                            style: TextStyle(color: Colors.white54),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _selectedMonth = DateTime(tempYear, tempMonth);
                            });
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                          ),
                          child: const Text(
                            'Выбрать',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Сообщение когда нет записей
  String _getEmptyStateMessage() {
    if (_viewMode == "День") {
      return type == "Все" 
        ? "Нет записей за ${DateFormat('dd.MM.yyyy').format(_selectedDate)}" 
        : "Нет записей с типом '$type' за ${DateFormat('dd.MM.yyyy').format(_selectedDate)}";
    } else {
      final monthName = '${_russianMonths[_selectedMonth.month - 1]} ${_selectedMonth.year}';
      return type == "Все" 
        ? "Нет записей за $monthName" 
        : "Нет записей с типом '$type' за $monthName";
    }
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
}
