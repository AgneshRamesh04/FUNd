import 'package:flutter/material.dart';

class MiniChart extends StatelessWidget {
  final List<double> data;
  final Color color;

  const MiniChart({super.key, required this.data, required this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 24, // Fixed height for the chart area
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end, // Align bars to the bottom
        children: data.map((value) {
          return Flexible(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.5),
              width: 8,
              // Calculate height as a percentage of the container height
              height: (24 * value).clamp(4.0, 24.0),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2), // Light transparent fill per mock
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class LeaveProgressBar extends StatelessWidget {
  final int used;
  final int total;

  const LeaveProgressBar({super.key, required this.used, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (index) {
        bool isUsed = index < used;
        return Expanded(
          child: Container(
            height: 6,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: isUsed ? Colors.black : Colors.grey.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }),
    );
  }
}