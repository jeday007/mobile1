import 'package:flutter/material.dart';

import '../models/medication_dose.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.doses,
    required this.onAddMedication,
    required this.onDoseStatusChanged,
    super.key,
  });

  final List<MedicationDose> doses;
  final VoidCallback onAddMedication;
  final void Function(String id, DoseStatus status) onDoseStatusChanged;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _timelineMode = false;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayDoses = widget.doses
        .where(
          (dose) =>
              dose.scheduledAt.year == now.year &&
              dose.scheduledAt.month == now.month &&
              dose.scheduledAt.day == now.day,
        )
        .toList()
      ..sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    final groupedDoses = <DateTime, List<MedicationDose>>{};
    for (final dose in todayDoses) {
      final slot = DateTime(
        dose.scheduledAt.year,
        dose.scheduledAt.month,
        dose.scheduledAt.day,
        dose.scheduledAt.hour,
        dose.scheduledAt.minute,
      );
      groupedDoses.putIfAbsent(slot, () => []).add(dose);
    }

    return Column(
      children: [
        _HomeHeader(
          timelineMode: _timelineMode,
          onToggleTimeline: todayDoses.isEmpty
              ? null
              : () => setState(() => _timelineMode = !_timelineMode),
        ),
        Expanded(
          child: todayDoses.isEmpty
              ? _EmptyHomeState(onAddMedication: widget.onAddMedication)
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final slot in groupedDoses.entries) ...[
                      if (_timelineMode)
                        _TimelineSlot(
                          time: slot.key,
                          doses: slot.value,
                          onStatusChanged: widget.onDoseStatusChanged,
                        )
                      else
                        _StandardSlot(
                          time: slot.key,
                          doses: slot.value,
                          onStatusChanged: widget.onDoseStatusChanged,
                        ),
                      const SizedBox(height: 16),
                    ],
                    if (todayDoses.every(
                      (dose) => dose.status != DoseStatus.pending,
                    ))
                      const _AllDoneBanner(),
                  ],
                ),
        ),
      ],
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader({
    required this.timelineMode,
    required this.onToggleTimeline,
  });

  final bool timelineMode;
  final VoidCallback? onToggleTimeline;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final greeting = switch (now.hour) {
      >= 5 && < 12 => 'Bonjour',
      >= 12 && < 17 => 'Bon après-midi',
      >= 17 && < 22 => 'Bonsoir',
      _ => 'Bonne nuit',
    };
    final weekday = [
      'lundi',
      'mardi',
      'mercredi',
      'jeudi',
      'vendredi',
      'samedi',
      'dimanche',
    ][now.weekday - 1];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$greeting !',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Prenez soin de vous',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Tooltip(
                    message: 'Les rappels seront configurés dans une prochaine étape',
                    child: Icon(
                      Icons.notifications_active_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (onToggleTimeline != null)
                    IconButton(
                      tooltip: timelineMode ? 'Vue standard' : 'Vue chronologique',
                      onPressed: onToggleTimeline,
                      icon: Icon(
                        timelineMode ? Icons.view_agenda : Icons.timeline,
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  Text(
                    'Médicaments du jour',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    weekday,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHomeState extends StatelessWidget {
  const _EmptyHomeState({required this.onAddMedication});

  final VoidCallback onAddMedication;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(28),
              ),
              child: Icon(
                Icons.medication_outlined,
                size: 48,
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Aucun médicament',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez un médicament pour commencer à organiser vos prises.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onAddMedication,
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un médicament'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StandardSlot extends StatelessWidget {
  const _StandardSlot({
    required this.time,
    required this.doses,
    required this.onStatusChanged,
  });

  final DateTime time;
  final List<MedicationDose> doses;
  final void Function(String id, DoseStatus status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final timeLabel = TimeOfDay.fromDateTime(time).format(context);
    return Column(
      children: [
        Text(
          timeLabel,
          style: Theme.of(context)
              .textTheme
              .headlineSmall
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          _slotStatus(doses),
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 16),
        for (final dose in doses) ...[
          _MedicationCard(dose: dose, onStatusChanged: onStatusChanged),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _TimelineSlot extends StatelessWidget {
  const _TimelineSlot({
    required this.time,
    required this.doses,
    required this.onStatusChanged,
  });

  final DateTime time;
  final List<MedicationDose> doses;
  final void Function(String id, DoseStatus status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 38,
          child: Column(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.schedule, color: Colors.white, size: 18),
              ),
              Container(
                width: 3,
                height: 28,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    TimeOfDay.fromDateTime(time).format(context),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                ),
                for (final dose in doses) ...[
                  _MedicationCard(dose: dose, onStatusChanged: onStatusChanged),
                  const SizedBox(height: 8),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MedicationCard extends StatelessWidget {
  const _MedicationCard({
    required this.dose,
    required this.onStatusChanged,
  });

  final MedicationDose dose;
  final void Function(String id, DoseStatus status) onStatusChanged;

  @override
  Widget build(BuildContext context) {
    final isTaken = dose.status == DoseStatus.taken;
    final isSkipped = dose.status == DoseStatus.skipped;
    final colors = Theme.of(context).colorScheme;
    final buttonColor = isTaken || isSkipped
        ? colors.surfaceContainerHighest
        : colors.primary;
    final buttonForeground =
        isTaken || isSkipped ? colors.onSurfaceVariant : colors.onPrimary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: colors.primaryContainer.withOpacity(0.35),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(Icons.medication, color: colors.primary, size: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dose.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dose.dosage,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                SizedBox(
                  width: 112,
                  height: 40,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: buttonColor,
                      foregroundColor: buttonForeground,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    onPressed: isTaken || isSkipped
                        ? null
                        : () => onStatusChanged(dose.id, DoseStatus.taken),
                    child: Text(
                      isTaken
                          ? 'Pris'
                          : isSkipped
                              ? 'Ignoré'
                              : 'Prendre',
                      maxLines: 1,
                    ),
                  ),
                ),
                if (!isTaken && !isSkipped)
                  TextButton(
                    onPressed: () =>
                        onStatusChanged(dose.id, DoseStatus.skipped),
                    style: TextButton.styleFrom(
                      minimumSize: const Size(88, 30),
                      padding: EdgeInsets.zero,
                    ),
                    child: const Text('Ignorer'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AllDoneBanner extends StatelessWidget {
  const _AllDoneBanner();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Card(
      color: colors.primaryContainer.withOpacity(0.5),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: colors.primary.withOpacity(0.3)),
      ),
      child: const ListTile(
        leading: Icon(Icons.check_circle_outline),
        title: Text('C’est fait pour aujourd’hui'),
        subtitle: Text('Toutes les prises prévues ont été enregistrées.'),
      ),
    );
  }
}

String _slotStatus(List<MedicationDose> doses) {
  if (doses.every((dose) => dose.status == DoseStatus.taken)) {
    return 'Tous les médicaments sont pris';
  }
  if (doses.every((dose) => dose.status == DoseStatus.skipped)) {
    return 'Prises ignorées';
  }
  if (doses.every((dose) => dose.status != DoseStatus.pending)) {
    return 'Créneau terminé avec des prises ignorées';
  }
  return 'Prévu à cette heure';
}
