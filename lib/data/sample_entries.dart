import '../models/entry.dart';

Entry _med(int day, int h, [int m = 0]) =>
    Entry('Medication', EntryType.medication, DateTime(2026, 11, day, h, m));
Entry _appt(int day, int h, [int m = 0]) =>
    Entry('Appointment', EntryType.appointment, DateTime(2026, 11, day, h, m));
Entry _nurse(int day, int h, [int m = 0]) =>
    Entry('Nurse Visit', EntryType.nurseVisit, DateTime(2026, 11, day, h, m));

// Sample data. Replace with your real data source (API, database, ...).
final List<Entry> sampleEntries = [
  _med(12, 8),
  _appt(12, 9),
  _nurse(12, 10),
  _med(12, 13),
  _med(12, 20),
  _med(13, 8),
  _appt(13, 15, 30),
  _nurse(14, 9),
  _med(14, 20),
  _appt(16, 11),
  _med(16, 8),
  _med(16, 13),
  _med(16, 21),
  _appt(18, 14),
  _med(18, 8),
  _nurse(20, 18),
  _med(23, 8),
  _appt(23, 10, 30),
  _med(25, 8),
  _nurse(25, 16),
];
