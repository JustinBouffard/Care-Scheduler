enum EntryType { medication, appointment, nurseVisit }

class Entry {
  final String title;
  final EntryType type;
  final DateTime when;

  const Entry(this.title, this.type, this.when);

  String get time => '${when.hour}:${when.minute.toString().padLeft(2, '0')}';

  /// 0 = morning (before 12:00), 1 = afternoon (12:00-16:59), 2 = evening.
  int get segment => when.hour < 12 ? 0 : (when.hour < 17 ? 1 : 2);
}
