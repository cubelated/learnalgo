import 'package:flutter/material.dart';

import 'colors.dart';

class CustomText extends StatelessWidget {
  final String? text;
  final double? size;
  final Color? color;
  final FontWeight? weight;

  const CustomText(
      {Key? key, required this.text, this.size, this.color, this.weight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(text!,
        style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: size ?? 16,
            color: color ?? black,
            fontWeight: weight ?? FontWeight.normal));
  }
}
