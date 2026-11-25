import 'package:flutter/material.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Patient Care',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MainShell(),
      // Register the screens the sidebar links to, e.g.:
      // routes: {
      //   '/appointments': (_) => const AppointmentsScreen(),
      //   '/medications': (_) => const MedicationsScreen(),
      // },
    );
  }
}

// ---------------------------------------------------------------------------
// Data
// ---------------------------------------------------------------------------

const _months = [
  'January', 'February', 'March', 'April', 'May', 'June', 'July',
  'August', 'September', 'October', 'November', 'December'
];
const _segmentNames = ['Morning', 'Afternoon', 'Evening'];

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

Entry _med(int day, int h, [int m = 0]) =>
    Entry('Medication', EntryType.medication, DateTime(2026, 11, day, h, m));
Entry _appt(int day, int h, [int m = 0]) =>
    Entry('Appointment', EntryType.appointment, DateTime(2026, 11, day, h, m));
Entry _nurse(int day, int h, [int m = 0]) =>
    Entry('Nurse Visit', EntryType.nurseVisit, DateTime(2026, 11, day, h, m));

// Sample data. Replace with your real data source (API, database, ...).
final List<Entry> sampleEntries = [
  _med(12, 8), _appt(12, 9), _nurse(12, 10), _med(12, 13), _med(12, 20),
  _med(13, 8), _appt(13, 15, 30),
  _nurse(14, 9), _med(14, 20),
  _appt(16, 11), _med(16, 8), _med(16, 13), _med(16, 21),
  _appt(18, 14), _med(18, 8),
  _nurse(20, 18),
  _med(23, 8), _appt(23, 10, 30),
  _med(25, 8), _nurse(25, 16),
];

// ---------------------------------------------------------------------------
// Shell: sidebar + header
// ---------------------------------------------------------------------------

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  // Sidebar destinations. Index 0 is this screen (null = stay here);
  // the others navigate to their own screens via named routes.
  static const List<String?> _routes = [null, '/appointments', '/medications'];

  void _onSidebarSelect(int i) {
    _scaffoldKey.currentState?.closeDrawer();
    final route = _routes[i];
    if (route != null) Navigator.of(context).pushNamed(route);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // Permanent sidebar on wide screens, drawer on phones.
      final wide = constraints.maxWidth >= 800;
      final sidebar = AppSidebar(selected: 0, onSelect: _onSidebarSelect);

      return Scaffold(
        key: _scaffoldKey,
        drawer: wide ? null : Drawer(child: sidebar),
        body: SafeArea(
          child: Row(
            children: [
              if (wide) SizedBox(width: 240, child: sidebar),
              Expanded(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 640),
                    child: Column(
                      children: [
                        _buildHeader(wide),
                        Expanded(child: HomePage(entries: sampleEntries)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildHeader(bool wide) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
      child: Row(
        children: [
          if (!wide)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.menu),
                onPressed: () => _scaffoldKey.currentState?.openDrawer(),
                visualDensity: VisualDensity.compact,
              ),
            ),
          const Text(
            'Home',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          const Text('Patient X',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(width: 8),
          const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFE2E5E8),
            child: Icon(Icons.person, size: 18, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

class AppSidebar extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const AppSidebar({super.key, required this.selected, required this.onSelect});

  static const _icons = [
    Icons.home_outlined,
    Icons.event_outlined,
    Icons.medication_outlined,
  ];
  static const _labels = ['Home', 'Appointments', 'Medications'];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF3F4F6),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 24, 12, 12),
          child: Column(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: _SidebarItem(
                    icon: _icons[i],
                    label: _labels[i],
                    selected: i == selected,
                    onTap: () => onSelect(i),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? const Color(0xFFDCCBFB) : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: 14),
              Text(
                label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Home page: calendar + Morning/Afternoon/Evening
// ---------------------------------------------------------------------------

class HomePage extends StatefulWidget {
  final List<Entry> entries;
  const HomePage({super.key, required this.entries});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Use DateTime.now() here if you want to start on today's date.
  DateTime _selectedDate = DateTime(2026, 11, 12);
  late DateTime _visibleMonth =
  DateTime(_selectedDate.year, _selectedDate.month);
  int _segment = 0;

  List<Entry> _entriesOn(DateTime date) {
    final list = widget.entries
        .where((e) => DateUtils.isSameDay(e.when, date))
        .toList()
      ..sort((a, b) => a.when.compareTo(b.when));
    return list;
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = date;
      // If the current tab is empty for this date, jump to the first tab
      // that has something scheduled.
      final day = _entriesOn(date);
      if (!day.any((e) => e.segment == _segment)) {
        for (var s = 0; s < 3; s++) {
          if (day.any((e) => e.segment == s)) {
            _segment = s;
            break;
          }
        }
      }
    });
  }

  void _changeMonth(int delta) {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + delta);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayEntries = _entriesOn(_selectedDate);
    final shown = dayEntries.where((e) => e.segment == _segment).toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          MonthCalendar(
            visibleMonth: _visibleMonth,
            selectedDate: _selectedDate,
            hasEntries: (d) => _entriesOn(d).isNotEmpty,
            onSelect: _selectDate,
            onPrev: () => _changeMonth(-1),
            onNext: () => _changeMonth(1),
          ),
          const SizedBox(height: 8),
          _buildSegmentedControl(dayEntries),
          const SizedBox(height: 8),
          if (shown.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: Center(
                child: Text(
                  'Nothing scheduled this ${_segmentNames[_segment].toLowerCase()}.',
                  style: const TextStyle(color: Colors.black54),
                ),
              ),
            )
          else
            for (final e in shown)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ScheduleCard(title: e.title, subtitle: e.time),
              ),
        ],
      ),
    );
  }

  Widget _buildSegmentedControl(List<Entry> dayEntries) {
    return Container(
      height: 40,
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: const Color(0xFFEDEEF0),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          for (var i = 0; i < _segmentNames.length; i++)
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _segment = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _segment == i ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(17),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _segmentNames[i],
                        style: const TextStyle(
                            fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      // Small dot = something is scheduled in this section.
                      if (dayEntries.any((e) => e.segment == i)) ...[
                        const SizedBox(width: 5),
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF8E63E8),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Calendar
// ---------------------------------------------------------------------------

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
    final daysInMonth =
        DateTime(visibleMonth.year, visibleMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday % 7; // Sunday = 0

    final monthName = _months[visibleMonth.month - 1];
    final headerText = DateUtils.isSameMonth(selectedDate, visibleMonth)
        ? '$monthName ${selectedDate.day}, ${visibleMonth.year}'
        : '$monthName ${visibleMonth.year}';

    final cells = <Widget>[
      for (final d in const ['Su', 'Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa'])
        Center(
          child: Text(d,
              style:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
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
                    child: Text(headerText,
                        style: const TextStyle(fontSize: 11)),
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

// ---------------------------------------------------------------------------
// List card
// ---------------------------------------------------------------------------

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
              child: Text('A',
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.w500)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
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
                  child: const Icon(Icons.landscape_outlined,
                      size: 32, color: Color(0xFFEDE4FD)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}