import 'package:dosezy_flutter/models/medication_dose.dart';
import 'package:dosezy_flutter/screens/home_screen.dart';
import 'package:dosezy_flutter/theme/dosezy_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('empty home offers to add a medication', (tester) async {
    var addPressed = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: DosezyTheme.light,
        home: HomeScreen(
          doses: const [],
          onAddMedication: () => addPressed = true,
          onDoseStatusChanged: (_, __) {},
        ),
      ),
    );

    expect(find.text('Aucun médicament'), findsOneWidget);
    await tester.tap(find.text('Ajouter un médicament'));
    expect(addPressed, isTrue);
  });

  testWidgets('taking a scheduled dose reports the taken status',
      (tester) async {
    final dose = MedicationDose(
      id: 'dose-1',
      name: 'Vitamine',
      dosage: '1 comprimé',
      scheduledAt: DateTime.now(),
    );
    String? changedId;
    DoseStatus? changedStatus;

    await tester.pumpWidget(
      MaterialApp(
        theme: DosezyTheme.light,
        home: HomeScreen(
          doses: [dose],
          onAddMedication: () {},
          onDoseStatusChanged: (id, status) {
            changedId = id;
            changedStatus = status;
          },
        ),
      ),
    );

    await tester.tap(find.text('Prendre'));
    expect(changedId, 'dose-1');
    expect(changedStatus, DoseStatus.taken);
  });
}
