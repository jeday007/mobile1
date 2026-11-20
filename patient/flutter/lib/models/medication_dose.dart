enum DoseStatus { pending, taken, skipped }

class MedicationDose {
  const MedicationDose({
    required this.id,
    required this.name,
    required this.dosage,
    required this.scheduledAt,
    this.status = DoseStatus.pending,
  });

  final String id;
  final String name;
  final String dosage;
  final DateTime scheduledAt;
  final DoseStatus status;

  MedicationDose copyWith({DoseStatus? status}) {
    return MedicationDose(
      id: id,
      name: name,
      dosage: dosage,
      scheduledAt: scheduledAt,
      status: status ?? this.status,
    );
  }
}
