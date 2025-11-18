import 'package:flutter/material.dart';

class CategorySelectWidget extends StatelessWidget {
  final String label;
  final int color;
  final String selectedCategory;
  final Function(String) onCategorySelected;

  const CategorySelectWidget({
    Key? key,
    required this.label,
    required this.color,
    required this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onCategorySelected(label);
      },
      child: Chip(
        backgroundColor: selectedCategory == label ? Colors.white : Color(color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: selectedCategory == label ? Colors.black : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      ),
    );
  }
}