import 'package:flutter/material.dart';

class CircularProgressWidget extends StatelessWidget {
  final double percent;
  const CircularProgressWidget({super.key, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(value: percent, strokeWidth: 10),
              Text('${(percent * 100).toStringAsFixed(0)}%'),
            ],
          ),
        ),
      ],
    );
  }
}
