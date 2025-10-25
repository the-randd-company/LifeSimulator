import 'package:flutter/material.dart';

class ProgressBar extends StatelessWidget {
  final String label;
  final int value;
  final Color color;
  
  const ProgressBar({
    super.key,
    required this.label,
    required this.value,
    required this.color,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value', style: const TextStyle(fontSize: 12)),
        SizedBox(
          height: 8,
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}