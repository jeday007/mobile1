import 'package:flutter/material.dart';

import 'models/medication_dose.dart';
import 'screens/home_screen.dart';
import 'theme/dosezy_theme.dart';
import 'widgets/dosezy_bottom_navigation_bar.dart';

void main() {
  runApp(const DosezyApp());
}

class DosezyApp extends StatelessWidget {
  const DosezyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dosezy',
      debugShowCheckedModeBanner: false,
      theme: DosezyTheme.light,
      darkTheme: DosezyTheme.dark,
      themeMode: ThemeMode.system,
      home: const DosezyShell(),
    );
  }
}

class DosezyShell extends StatefulWidget {
  const DosezyShell({super.key});

  @override
  State<DosezyShell> createState() => _DosezyShellState();
}

class _DosezyShellState extends State<DosezyShell> {
  final List<MedicationDose> _doses = [];
  int _selectedIndex = 0;

  Future<void> _addMedication() async {
    final dose = await showModalBottomSheet<MedicationDose>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (context) => const _AddMedicationSheet(),
    );
    if (dose != null && mounted) {
      setState(() => _doses.add(dose));
    }
  }

  void _updateDoseStatus(String id, DoseStatus status) {
    setState(() {
      final index = _doses.indexWhere((dose) => dose.id == id);
      if (index != -1) {
        _doses[index] = _doses[index].copyWith(status: status);
      }
    });
  }

  void _selectTab(int index) {
    if (index == 2) {
      _addMedication();
      return;
    }
    setState(() => _selectedIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final body = _selectedIndex == 0
        ? HomeScreen(
            doses: _doses,
            onAddMedication: _addMedication,
            onDoseStatusChanged: _updateDoseStatus,
          )
        : _UnimplementedTab(
            title: const ['Accueil', 'Programme', '', 'Médicaments', 'Menu']
                [_selectedIndex],
          );

    return Scaffold(
      body: body,
      bottomNavigationBar: DosezyBottomNavigationBar(
        selectedIndex: _selectedIndex,
        onSelected: _selectTab,
      ),
    );
  }
}

class _UnimplementedTab extends StatelessWidget {
  const _UnimplementedTab({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title sera disponible dans une prochaine étape de la migration.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}

class _AddMedicationSheet extends StatefulWidget {
  const _AddMedicationSheet();

  @override
  State<_AddMedicationSheet> createState() => _AddMedicationSheetState();
}

class _AddMedicationSheetState extends State<_AddMedicationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dosageController = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();

  @override
  void dispose() {
    _nameController.dispose();
    _dosageController.dispose();
    super.dispose();
  }

  Future<void> _selectTime() async {
    final selected = await showTimePicker(context: context, initialTime: _time);
    if (selected != null && mounted) {
      setState(() => _time = selected);
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final now = DateTime.now();
    Navigator.of(context).pop(
      MedicationDose(
        id: '${now.microsecondsSinceEpoch}',
        name: _nameController.text.trim(),
        dosage: _dosageController.text.trim(),
        scheduledAt: DateTime(
          now.year,
          now.month,
          now.day,
          _time.hour,
          _time.minute,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(24, 20, 24, 24 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ajouter un médicament',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Nom du médicament',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Saisissez un nom.'
                  : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _dosageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Dosage (ex. 1 comprimé)',
                border: OutlineInputBorder(),
              ),
              validator: (value) => value == null || value.trim().isEmpty
                  ? 'Saisissez un dosage.'
                  : null,
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _selectTime,
              icon: const Icon(Icons.schedule),
              label: Text('Heure du rappel : ${_time.format(context)}'),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _save,
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }
}
