import 'package:dolfin_core/constants/app_strings.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

/// Form for editing transaction details
class EditTransactionForm extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController descriptionController;
  final String selectedType;
  final String selectedCategory;
  final DateTime selectedDate;
  final List<String> categories;
  final ValueChanged<String> onTypeChanged;
  final ValueChanged<String> onCategoryChanged;
  final VoidCallback onDateSelect;

  static const Color _incomeColor = Color(0xFF10b981);
  static const Color _expenseColor = Color(0xFFef4444);

  const EditTransactionForm({
    super.key,
    required this.amountController,
    required this.descriptionController,
    required this.selectedType,
    required this.selectedCategory,
    required this.selectedDate,
    required this.categories,
    required this.onTypeChanged,
    required this.onCategoryChanged,
    required this.onDateSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Type
          _buildFormSection(
            context,
            label: AppStrings.transactions.transactionType,
            child: Row(
              children: [
                Expanded(
                  child: _buildTypeChip(
                    context,
                    'INCOME',
                    'Income',
                    Icons.arrow_downward,
                    _incomeColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeChip(
                    context,
                    'EXPENSE',
                    'Expense',
                    Icons.arrow_upward,
                    _expenseColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Amount
          _buildFormSection(
            context,
            label: AppStrings.transactions.amount,
            child: TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                prefixText: '${sl<CurrencyCubit>().symbol} ',
                prefixStyle: TextStyle(
                  color:
                      selectedType == 'INCOME' ? _incomeColor : _expenseColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              ),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Description
          _buildFormSection(
            context,
            label: AppStrings.transactions.description,
            child: TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: AppStrings.transactions.descriptionHint,
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.all(16),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Category
          _buildFormSection(
            context,
            label: AppStrings.transactions.category,
            child: DropdownButtonFormField<String>(
              value: categories.contains(selectedCategory)
                  ? selectedCategory
                  : categories.last,
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              items: categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  onCategoryChanged(value);
                }
              },
            ),
          ),

          const SizedBox(height: 20),

          // Date
          _buildFormSection(
            context,
            label: AppStrings.transactions.date,
            child: InkWell(
              onTap: onDateSelect,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const Spacer(),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).hintColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .slideY(begin: 0.05, end: 0, duration: 300.ms);
  }

  Widget _buildFormSection(BuildContext context,
      {required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildTypeChip(BuildContext context, String type, String label,
      IconData icon, Color color) {
    final isSelected = selectedType == type;

    return InkWell(
      onTap: () => onTypeChanged(type),
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.15)
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? color : Theme.of(context).hintColor,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? color : Theme.of(context).hintColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
