
import 'package:flutter/material.dart';

class ToDoCard extends StatelessWidget {
  const ToDoCard(
      {super.key,
      this.title,
      this.iconData,
      this.iconColor,
      this.time,
      this.iconBgColor,
      this.onChange,
      this.index});

  final String? title;
  final IconData? iconData;
  final Color? iconColor;
  final String? time;
  final Color? iconBgColor;
  final Function? onChange;
  final int? index;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Theme(
            data: ThemeData(
              primarySwatch: Colors.blue,
              unselectedWidgetColor: Color(0xff5e616a),
            ),
            child: Transform.scale(
              scale: 1.5,
              
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
