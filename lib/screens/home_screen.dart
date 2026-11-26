import 'package:flutter/material.dart';

import '../data/sample_entries.dart';
import '../models/entry.dart';
import '../models/patient.dart';
import 'patient_list_screen.dart';
import '../widgets/app_sidebar.dart';
import '../widgets/month_calendar.dart';
import '../widgets/schedule_card.dart';

const _segmentNames = ['Morning', 'Afternoon', 'Evening'];

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  Patient? _selectedPatient;

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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Permanent sidebar on wide screens, drawer on phones.
        final wide = constraints.maxWidth >= 800;
        final sidebar = AppSidebar(selected: 0, onSelect: _onSidebarSelect);
        final patient = _selectedPatient;

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
                          _buildHeader(wide, patient),
                          Expanded(
                            child: patient == null
                                ? PatientListScreen(
                                    onPatientSelected: (selected) {
                                      setState(() {
                                        _selectedPatient = selected;
                                      });
                                    },
                                  )
                                : HomePage(
                                    key: ValueKey(patient.name),
                                    entries: sampleEntries,
                                    canEdit: true,
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool wide, Patient? patient) {
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
          if (patient != null)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back),
                tooltip: 'Back to patients',
                onPressed: () => setState(() {
                  _selectedPatient = null;
                }),
                visualDensity: VisualDensity.compact,
              ),
            ),
          Text(
            patient == null ? 'Patients' : 'Calendar',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          if (patient != null)
            Text(
              patient.name,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
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

class HomePage extends StatefulWidget {
  final List<Entry> entries;
  final bool canEdit;

  const HomePage({super.key, required this.entries, this.canEdit = false});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Use DateTime.now() here if you want to start on today's date.
  DateTime _selectedDate = DateTime(2026, 11, 12);
  late DateTime _visibleMonth = DateTime(
    _selectedDate.year,
    _selectedDate.month,
  );
  int _segment = 0;
  final List<Entry> _addedEntries = [];

  List<Entry> get _allEntries => [...widget.entries, ..._addedEntries];

  List<Entry> _entriesOn(DateTime date) {
    final list =
        _allEntries.where((e) => DateUtils.isSameDay(e.when, date)).toList()
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

  Future<void> _addActivity() async {
    final entry = await showDialog<Entry>(
      context: context,
      builder: (context) => _AddActivityDialog(initialDate: _selectedDate),
    );
    if (entry == null || !mounted) return;

    setState(() {
      _addedEntries.add(entry);
      _selectedDate = entry.when;
      _visibleMonth = DateTime(entry.when.year, entry.when.month);
      _segment = entry.segment;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dayEntries = _entriesOn(_selectedDate);
    final shown = dayEntries.where((e) => e.segment == _segment).toList();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
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
      ),
      floatingActionButton: widget.canEdit
          ? FloatingActionButton.extended(
              onPressed: _addActivity,
              icon: const Icon(Icons.add),
              label: const Text('Add activity'),
            )
          : null,
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
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
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

class _AddActivityDialog extends StatefulWidget {
  final DateTime initialDate;

  const _AddActivityDialog({required this.initialDate});

  @override
  State<_AddActivityDialog> createState() => _AddActivityDialogState();
}

class _AddActivityDialogState extends State<_AddActivityDialog> {
  final _titleController = TextEditingController();
  late DateTime _date = widget.initialDate;
  TimeOfDay _time = const TimeOfDay(hour: 9, minute: 0);
  EntryType _type = EntryType.appointment;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _chooseDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null) setState(() => _date = date);
  }

  Future<void> _chooseTime() async {
    final time = await showTimePicker(context: context, initialTime: _time);
    if (time != null) setState(() => _time = time);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add activity'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              autofocus: true,
              decoration: const InputDecoration(labelText: 'Activity name'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<EntryType>(
              initialValue: _type,
              decoration: const InputDecoration(labelText: 'Activity type'),
              items: const [
                DropdownMenuItem(
                  value: EntryType.appointment,
                  child: Text('Appointment'),
                ),
                DropdownMenuItem(
                  value: EntryType.medication,
                  child: Text('Medication'),
                ),
                DropdownMenuItem(
                  value: EntryType.nurseVisit,
                  child: Text('Other'),
                ),
              ],
              onChanged: (type) {
                if (type != null) setState(() => _type = type);
              },
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text('${_date.month}/${_date.day}/${_date.year}'),
                ),
                TextButton(
                  onPressed: _chooseDate,
                  child: const Text('Choose date'),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(child: Text(_time.format(context))),
                TextButton(
                  onPressed: _chooseTime,
                  child: const Text('Choose time'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _titleController.text.trim().isEmpty
              ? null
              : () {
                  Navigator.of(context).pop(
                    Entry(
                      _titleController.text.trim(),
                      _type,
                      DateTime(
                        _date.year,
                        _date.month,
                        _date.day,
                        _time.hour,
                        _time.minute,
                      ),
                    ),
                  );
                },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
