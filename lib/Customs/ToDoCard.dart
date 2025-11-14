
import 'package:flutter/material.dart';

class ToDoCard extends StatelessWidget {
  const ToDoCard(
      {super.key,
      this.title,
      this.iconData,
      this.iconColor,
      this.time,
      this.check,
      this.iconBgColor,
      this.onChange,
      this.index});

  final String? title;
  final IconData? iconData;
  final Color? iconColor;
  final String? time;
  final bool? check;
  final Color? iconBgColor;
  final Function? onChange;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      child: Row(
        children: [
          Theme(
            child: Transform.scale(
              scale: 1.5,
              child: Checkbox(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                activeColor: Color(0xff6cf8a9),
                checkColor: Color(0xff0e3e26),
                value: check,
                onChanged: (bool? value) {
                  onChange!(index);
                },
              ),
            ),
            data: ThemeData(
              primarySwatch: Colors.blue,
              unselectedWidgetColor: Color(0xff5e616a),
            ),
          ),
          Expanded(
            child: Container(
              height: 75,
              child: Card(
                color: Color(0xff2a2e3d),
                child: Row(
                  children: [
                    SizedBox(
                      width: 15,
                    ),
                    Container(
                      height: 33,
                      width: 36,
                      decoration: BoxDecoration(
                        color: iconBgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(iconData, color: iconColor),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                    Expanded(
                      child: Text(
                        title!,
                        style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: Colors.white),
                      ),
                    ),
                    Text(
                      time!,
                      style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.white),
                    ),
                    SizedBox(
                      width: 15,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
