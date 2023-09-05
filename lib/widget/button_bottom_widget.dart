import 'package:flutter/material.dart';

class ButtonBottomWidget extends StatelessWidget {
  const ButtonBottomWidget(
      {super.key,
      required this.isActiveColor,
      required this.function,
      required this.title,
      required this.iconData});
  final bool isActiveColor;
  final Text title;
  final Icon iconData;
  final Function function;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: () {
          function();
        },
        child: Container(
          decoration: BoxDecoration(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(3), topRight: Radius.circular(3)),
              color: isActiveColor ? Colors.blue : Colors.white),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(child: iconData),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                child: title,
              )
            ],
          ),
        ),
      ),
    );
  }
}
