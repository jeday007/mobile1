import 'package:flutter/material.dart';

class DosezyBottomNavigationBar extends StatelessWidget {
  const DosezyBottomNavigationBar({
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final items = [
      (label: 'Accueil', icon: Icons.home_outlined, selected: Icons.home),
      (
        label: 'Programme',
        icon: Icons.calendar_month_outlined,
        selected: Icons.calendar_month,
      ),
      (label: 'Ajouter', icon: Icons.add, selected: Icons.add),
      (
        label: 'Médicaments',
        icon: Icons.medication_outlined,
        selected: Icons.medication,
      ),
      (label: 'Menu', icon: Icons.menu, selected: Icons.menu),
    ];

    return SafeArea(
      top: false,
      child: Container(
        height: 70,
        decoration: BoxDecoration(
          color: colorScheme.surface,
          border: Border(
            top: BorderSide(color: colorScheme.outlineVariant),
          ),
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Row(
          children: [
            for (var index = 0; index < items.length; index++)
              Expanded(
                child: _NavigationItem(
                  label: items[index].label,
                  icon: index == selectedIndex
                      ? items[index].selected
                      : items[index].icon,
                  selected: index == selectedIndex,
                  onTap: () => onSelected(index),
                  isAdd: index == 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavigationItem extends StatelessWidget {
  const _NavigationItem({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
    required this.isAdd,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final bool isAdd;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF2084E4) : const Color(0xFF9CA3AF);
    return Semantics(
      button: true,
      label: label,
      selected: selected,
      child: InkWell(
        onTap: onTap,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isAdd)
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF2084E4),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icon, color: Colors.white, size: 28),
              )
            else ...[
              Icon(icon, color: color, size: 24),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                style: TextStyle(
                  color: color,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
