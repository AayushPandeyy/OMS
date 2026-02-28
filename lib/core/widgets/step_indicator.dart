import 'package:flutter/material.dart';

Widget buildStepIndicator(int stepIndex) {
  final labels = [
    'Account',
    'Restaurant',
    'Branch',
    'Operations',
    'Tax & Pricing',
  ];

  return Container(
    color: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
    child: Row(
      children: List.generate(labels.length, (index) {
        final isActive = index == stepIndex;
        final isCompleted = index < stepIndex;

        return Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Circle
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive || isCompleted
                      ? const Color(0xFFFC5E03)
                      : Colors.grey[300],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: isActive ? Colors.white : Colors.grey[600],
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 6),

              // Label (single line guaranteed)
              Text(
                labels[index],
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  color: isActive ? const Color(0xFFFC5E03) : Colors.grey[500],
                ),
              ),
            ],
          ),
        );
      }),
    ),
  );
}
