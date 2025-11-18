class AppConstants {
  static const appName = 'Finance Tracker';
  static const defaultCurrency = 'RUB';
  static const supportedCurrencies = ['RUB', 'USD', 'EUR', 'KZT'];
  
  static const dateFormat = 'dd.MM.yyyy';
  static const timeFormat = 'HH:mm';
  static const dateTimeFormat = '$dateFormat $timeFormat';
  
  static const defaultCategories = _DefaultCategories();
}

class _DefaultCategories {
  const _DefaultCategories();
  
  List<Map<String, dynamic>> get income => [
    {'name': 'Зарплата', 'icon': '💼', 'color': '#4CAF50'},
    {'name': 'Фриланс', 'icon': '💻', 'color': '#2196F3'},
    {'name': 'Инвестиции', 'icon': '📈', 'color': '#FF9800'},
    {'name': 'Подарок', 'icon': '🎁', 'color': '#9C27B0'},
  ];
  
  List<Map<String, dynamic>> get expense => [
    {'name': 'Еда', 'icon': '🍕', 'color': '#F44336'},
    {'name': 'Транспорт', 'icon': '🚗', 'color': '#3F51B5'},
    {'name': 'Развлечения', 'icon': '🎬', 'color': '#E91E63'},
    {'name': 'Жилье', 'icon': '🏠', 'color': '#795548'},
    {'name': 'Здоровье', 'icon': '🏥', 'color': '#00BCD4'},
    {'name': 'Одежда', 'icon': '👕', 'color': '#FF5722'},
  ];
}