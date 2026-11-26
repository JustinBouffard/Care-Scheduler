import 'package:flutter/material.dart';

const _months = [
  'January',
  'February',
  'March',
  'April',
  'May',
  'June',
  'July',
  'August',
  'September',
  'October',
  'November',
  'December',
];

class MonthCalendar extends StatelessWidget {
  final DateTime visibleMonth;
  final DateTime selectedDate;
  final bool Function(DateTime) hasEntries;
  final ValueChanged<DateTime> onSelect;
  final VoidCallback onPrev;
  final VoidCallback onNext;

  const MonthCalendar({
    super.key,
    required this.visibleMonth,
    required this.selectedDate,
    required this.hasEntries,
    required this.onSelect,
    required this.onPrev,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final firstOfMonth = DateTime(visibleMonth.year, visibleMonth.month, 1);
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday = 0

    final monthName = _months[visibleMonth.month - 1];
    final headerText = DateUtils.isSameMonth(selectedDate, visibleMonth)
        ? '$monthName ${selectedDate.day}, ${visibleMonth.year}'
        : '$monthName ${visibleMonth.year}';

    final cells = <Widget>[
      for (final d in const ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'])
        Center(
          child: Text(
            d,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      for (var i = 0; i < leadingBlanks; i++) const SizedBox.shrink(),
      for (var day = 1; day <= daysInMonth; day++) _dayCell(day),
    ];

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD0D0D0)),
        borderRadius: BorderRadius.circular(4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          Container(
            color: const Color(0xFFE8E8E8),
            height: 28,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              children: [
                InkWell(
                  onTap: onPrev,
                  child: const Icon(Icons.arrow_left, size: 20),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      headerText,
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
                ),
                InkWell(
                  onTap: onNext,
                  child: const Icon(Icons.arrow_right, size: 20),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
            child: GridView.count(
              crossAxisCount: 7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              childAspectRatio: 1.15,
              children: cells,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dayCell(int day) {
    final date = DateTime(visibleMonth.year, visibleMonth.month, day);
    final selected = DateUtils.isSameDay(date, selectedDate);
    final marked = hasEntries(date);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelect(date),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF222222) : Colors.transparent,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$day',
              style: TextStyle(
                fontSize: 11,
                color: selected ? Colors.white : Colors.black,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Container(
            width: 4,
            height: 4,
            decoration: BoxDecoration(
              color: marked ? const Color(0xFF8E63E8) : Colors.transparent,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }
}
