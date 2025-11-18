import 'package:flutter/material.dart';

class TypeSelectWidget extends StatelessWidget {
  final String label;
  final int color;
  final String selectedType;
  final Function(String) onTypeSelected;

  const TypeSelectWidget({
    Key? key,
    required this.label,
    required this.color,
    required this.selectedType,
    required this.onTypeSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTypeSelected(label);
      },
      child: Chip(
        backgroundColor: selectedType == label ? Colors.white54 : Color(color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        label: Text(
          label,
          style: TextStyle(
            color: selectedType == label ? Colors.black : Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
      ),
    );
  }
}