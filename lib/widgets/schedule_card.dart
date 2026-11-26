import 'package:flutter/material.dart';

class ScheduleCard extends StatelessWidget {
  final String title;
  final String subtitle;

  const ScheduleCard({super.key, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Container(
        height: 64,
        color: const Color(0xFFEDEEF0),
        child: Row(
          children: [
            const SizedBox(width: 14),
            const CircleAvatar(
              radius: 17,
              backgroundColor: Color(0xFFE2E5E8),
              child: Text(
                'A',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(subtitle, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
            // Placeholder image: inset from the card edge with its own radius.
            Padding(
              padding: const EdgeInsets.all(6),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  width: 60,
                  color: const Color(0xFFDCCBFB),
                  child: const Icon(
                    Icons.landscape_outlined,
                    size: 32,
                    color: Color(0xFFEDE4FD),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
