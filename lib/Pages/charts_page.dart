import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:economy_app/Services/Firestore_Service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
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
  DateTime _selectedDate = DateTime.now();
  String _viewMode = "День";
  DateTime _selectedMonth = DateTime.now();
  String _chartType = "Доходы"; // Доходы или Расходы

  // Русские названия месяцев
  final List<String> _russianMonths = [
    'Январь',
    'Февраль',
    'Март',
    'Апрель',
    'Май',
    'Июнь',
    'Июль',
    'Август',
    'Сентябрь',
    'Октябрь',
    'Ноябрь',
    'Декабрь',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        title: const Text(
          "Диаграммы",
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

          // Контейнер с выбором типа диаграммы (Доходы/Расходы)
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
                  "Тип:",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Row(
                  children: [
                    _buildChartTypeButton("Доходы"),
                    const SizedBox(width: 10),
                    _buildChartTypeButton("Расходы"),
                  ],
                ),
              ],
            ),
          ),

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
                      horizontal: 16,
                      vertical: 8,
                    ),
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

          const SizedBox(height: 20),

          // Диаграмма по центру
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _stream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                // Фильтруем данные по выбранному типу (Доходы/Расходы) и периоду
                final filteredData = docs.where((doc) {
                  final rawData = doc.data();
                  final document = (rawData is Map)
                      ? Map<String, dynamic>.from(rawData)
                      : <String, dynamic>{};

                  final documentType = document["taskType"]?.toString() ?? "";
                  final documentDate = document["time"] as Timestamp?;

                  // Проверяем тип (Доходы или Расходы)
                  final typeMatch = _chartType == "Доходы"
                      ? documentType == "Доход"
                      : documentType == "Расход";

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

                      dateMatch =
                          docDateTime.isAfter(selectedDateStart) &&
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

                      dateMatch =
                          docDateTime.isAfter(monthStart) &&
                          docDateTime.isBefore(monthEnd);
                    }
                  }

                  return typeMatch && dateMatch;
                }).toList();

                // Группируем по категориям и суммируем суммы
                final Map<String, double> categorySums = {};

                for (final doc in filteredData) {
                  final document = doc.data() as Map<String, dynamic>;
                  final category = document["category"]?.toString() ?? "Другое";
                  final amount =
                      double.tryParse(document["title"]?.toString() ?? "0") ??
                      0;

                  categorySums.update(
                    category,
                    (value) => value + amount,
                    ifAbsent: () => amount,
                  );
                }

                // Преобразуем в данные для диаграммы
                final chartData = categorySums.entries.map((entry) {
                  return _ChartData(entry.key, entry.value);
                }).toList();

                // Если нет данных
                if (chartData.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 16),
                        Text(
                          _viewMode == "День"
                              ? "Нет $_chartType за ${DateFormat('dd.MM.yyyy').format(_selectedDate)}"
                              : "Нет $_chartType за ${_russianMonths[_selectedMonth.month - 1]} ${_selectedMonth.year}",
                          style: const TextStyle(
                            color: Colors.white54,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // Общая сумма
                final totalAmount = chartData.fold(
                  0.0,
                  (sum, item) => sum + item.value,
                );

                return Column(
                  children: [
                    // Общая сумма
                    Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xff2a2e3d),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(width: 10),
                          Text(
                            "${_chartType == "Доходы" ? "Общий доход" : "Общий расход"}: ${totalAmount.toStringAsFixed(2)} ₽",
                            style: TextStyle(
                              color: _chartType == "Доходы"
                                  ? Colors.green
                                  : Colors.red,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Диаграмма
                    // Диаграмма
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            // Уменьшенная диаграмма
                            SizedBox(
                              height:
                                  MediaQuery.of(context).size.height *
                                  0.4, // Уменьшил высоту
                              child: SfCircularChart(
                                palette: const [
                                  Colors.purple,
                                  Colors.blue,
                                  Colors.green,
                                  Colors.orange,
                                  Colors.red,
                                  Colors.pink,
                                  Colors.teal,
                                  Colors.amber,
                                ],

                                legend: Legend(
                                  isVisible: true,
                                  position: LegendPosition.bottom,
                                  textStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  overflowMode: LegendItemOverflowMode.wrap,
                                ),
                                series: <CircularSeries>[
                                  PieSeries<_ChartData, String>(
                                    dataSource: chartData,
                                    xValueMapper: (_ChartData data, _) =>
                                        data.category,
                                    yValueMapper: (_ChartData data, _) =>
                                        data.value,
                                    dataLabelMapper: (_ChartData data, _) =>
                                        '${(data.value / totalAmount * 100).toStringAsFixed(1)}%', // Проценты вместо суммы
                                    dataLabelSettings: const DataLabelSettings(
                                      isVisible: true,
                                      textStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10, // Уменьшил размер шрифта
                                        fontWeight: FontWeight.bold,
                                      ),
                                      labelPosition: ChartDataLabelPosition
                                          .inside, // Текст внутри сегментов
                                      useSeriesColor:
                                          true, // Цвет текста как у сегмента
                                    ),
                                    explode: true,
                                    explodeIndex: 0,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),
                            // Детализация под диаграммой
                            // Детализация под диаграммой
                            Expanded(
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xff2a2e3d),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize
                                      .min, 
                                  children: [
                                    Expanded(
                                      child: SingleChildScrollView(
                                        physics: const ClampingScrollPhysics(),
                                        child: Column(
                                          mainAxisSize: MainAxisSize
                                              .min, // Минимальный размер
                                          children: [
                                            for (
                                              int index = 0;
                                              index < chartData.length;
                                              index++
                                            )
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  bottom:
                                                      index ==
                                                          chartData.length - 1
                                                      ? 0
                                                      : 8, // Нет отступа у последнего
                                                ),
                                                child: Row(
                                                  children: [
                                                    // Цветной индикатор
                                                    Container(
                                                      width: 12,
                                                      height: 12,
                                                      decoration: BoxDecoration(
                                                        color: const [
                                                          Colors.purple,
                                                          Colors.blue,
                                                          Colors.green,
                                                          Colors.orange,
                                                          Colors.red,
                                                          Colors.pink,
                                                          Colors.teal,
                                                          Colors.amber,
                                                        ][index % 8],
                                                        shape: BoxShape.circle,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Expanded(
                                                      child: Text(
                                                        chartData[index]
                                                            .category,
                                                        style: const TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 14,
                                                        ),
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                      ),
                                                    ),
                                                    Text(
                                                      '${chartData[index].value.toStringAsFixed(2)} ₽',
                                                      style: const TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.bold,
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      '(${(chartData[index].value / totalAmount * 100).toStringAsFixed(1)}%)',
                                                      style: TextStyle(
                                                        color: Colors.white54,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Виджет кнопки выбора типа диаграммы
  Widget _buildChartTypeButton(String type) {
    return InkWell(
      onTap: () {
        setState(() {
          _chartType = type;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: _chartType == type
              ? (type == "Доходы" ? Colors.green : Colors.red)
              : Colors.white24,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          type,
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: _chartType == type
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
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
                            icon: const Icon(
                              Icons.arrow_back_ios,
                              color: Colors.white,
                            ),
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
                            icon: const Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.white,
                            ),
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
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                                color: isSelected
                                    ? Colors.purple
                                    : Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Text(
                                  _russianMonths[index],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
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
}

// Класс для данных диаграммы
class _ChartData {
  final String category;
  final double value;

  _ChartData(this.category, this.value);
}
