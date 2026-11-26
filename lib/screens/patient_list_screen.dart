import 'package:flutter/material.dart';

import '../data/sample_patients.dart';
import '../models/patient.dart';

class PatientListScreen extends StatefulWidget {
  final ValueChanged<Patient> onPatientSelected;

  const PatientListScreen({super.key, required this.onPatientSelected});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final patients = samplePatients
        .where((patient) => patient.name.toLowerCase().contains(_query))
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        const Text(
          'Select a patient to view their care calendar.',
          style: TextStyle(color: Colors.black54),
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            hintText: 'Search patients',
            prefixIcon: const Icon(Icons.search),
            filled: true,
            fillColor: const Color(0xFFF3F4F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: (value) => setState(() {
            _query = value.trim().toLowerCase();
          }),
        ),
        const SizedBox(height: 16),
        Text(
          'Patients (${patients.length})',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        if (patients.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: Text('No patients match your search.')),
          )
        else
          for (final patient in patients)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PatientCard(
                patient: patient,
                onTap: () => widget.onPatientSelected(patient),
              ),
            ),
      ],
    );
  }
}

class _PatientCard extends StatelessWidget {
  final Patient patient;
  final VoidCallback onTap;

  const _PatientCard({required this.patient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final initials = patient.name
        .split(' ')
        .map((part) => part[0])
        .take(2)
        .join();

    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(14),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFDCCBFB),
          child: Text(
            initials,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        title: Text(
          patient.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text('Age ${patient.age}'),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
