import 'package:dolfin_core/constants/app_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

/// Delete and Save/Edit action buttons
class DetailActionButtons extends StatelessWidget {
  final bool isEditMode;
  final VoidCallback onDelete;
  final VoidCallback onSaveOrEdit;

  const DetailActionButtons({
    super.key,
    required this.isEditMode,
    required this.onDelete,
    required this.onSaveOrEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.all(14),
              constraints: const BoxConstraints(),
              style: IconButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 400.ms, duration: 300.ms)
              .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 300.ms),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: onSaveOrEdit,
              icon: Icon(isEditMode ? Icons.check : Icons.edit, size: 20),
              label: Text(isEditMode
                  ? AppStrings.common.saveChanges
                  : AppStrings.common.edit),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
                .animate()
                .fadeIn(delay: 450.ms, duration: 300.ms)
                .slideY(begin: 0.2, end: 0, delay: 450.ms, duration: 300.ms),
          ),
        ],
      ),
    );
  }
}
