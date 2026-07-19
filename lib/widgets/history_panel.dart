import 'package:flutter/material.dart';

import '../engine/calculator_controller.dart';
import '../theme/app_theme.dart';
import 'glass_container.dart';

/// پنل تاریخچهٔ محاسبات که از پایین صفحه بالا می‌آید.
class HistoryPanel extends StatelessWidget {
  final List<HistoryEntry> entries;
  final void Function(HistoryEntry) onSelect;
  final VoidCallback onClear;
  final VoidCallback onClose;

  const HistoryPanel({
    super.key,
    required this.entries,
    required this.onSelect,
    required this.onClear,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return GlassContainer(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      tint: const Color(0xCC101635),
      child: SizedBox(
        height: 360,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'تاریخچه',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: onClear,
                      icon: const Icon(Icons.delete_outline, color: AppTheme.neonPink),
                    ),
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close, color: Colors.white70),
                    ),
                  ],
                ),
              ],
            ),
            const Divider(color: Colors.white24),
            Expanded(
              child: entries.isEmpty
                  ? const Center(
                      child: Text(
                        'هنوز محاسبه‌ای انجام نشده',
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.builder(
                      itemCount: entries.length,
                      itemBuilder: (context, index) {
                        final HistoryEntry entry = entries[index];
                        return ListTile(
                          onTap: () => onSelect(entry),
                          title: Text(
                            entry.expression,
                            style: const TextStyle(color: Colors.white70),
                          ),
                          trailing: Text(
                            '= ${entry.result}',
                            style: const TextStyle(
                              color: AppTheme.neonCyan,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
