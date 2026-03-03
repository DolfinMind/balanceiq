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

  static const Color _incomeColor = Color(0xFF34d399); // Soft Emerald
  static const Color _expenseColor = Color(0xFFf87171); // Soft Red

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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Transaction Type
          _buildFormSection(
            context,
            label: AppStrings.transactions.transactionType,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTypePill(context, 'Expense', _expenseColor),
                _buildTypePill(context, 'Income', _incomeColor),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Amount
          _buildFormSection(
            context,
            label: AppStrings.transactions.amount,
            child: TextField(
              controller: amountController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
              decoration: InputDecoration(
                hintText: 'Enter amount',
                prefixIcon: const Icon(Icons
                    .money), // Using standard icon if Lucide not heavily imported
                suffixText: sl<CurrencyCubit>().symbol,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor:
                    Theme.of(context).dividerColor.withValues(alpha: 0.05),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Date
          _buildFormSection(
            context,
            label: AppStrings.transactions.date,
            child: InkWell(
              onTap: onDateSelect,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(
                    color:
                        Theme.of(context).dividerColor.withValues(alpha: 0.3),
                  ),
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      color: Theme.of(context).hintColor,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        DateFormat('EEEE, MMMM d, yyyy').format(selectedDate),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).hintColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Category
          _buildFormSection(
            context,
            label: AppStrings.transactions.category,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((category) {
                final isSelected = selectedCategory == category;
                return Theme(
                  data: Theme.of(context)
                      .copyWith(canvasColor: Colors.transparent),
                  child: ChoiceChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) {
                        onCategoryChanged(category);
                      }
                    },
                    backgroundColor:
                        Theme.of(context).dividerColor.withValues(alpha: 0.05),
                    selectedColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Theme.of(context).colorScheme.onPrimaryContainer
                          : Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.3)
                            : Theme.of(context)
                                .dividerColor
                                .withValues(alpha: 0.1),
                      ),
                    ),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Description
          _buildFormSection(
            context,
            label: AppStrings.transactions.description,
            child: TextField(
              controller: descriptionController,
              maxLines: 2,
              decoration: InputDecoration(
                hintText: AppStrings.transactions.descriptionHint,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                filled: true,
                fillColor:
                    Theme.of(context).dividerColor.withValues(alpha: 0.05),
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
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildTypePill(
    BuildContext context,
    String type,
    Color color,
  ) {
    // Treat 'Income' matching 'INCOME' if necessary, since selectedType might be upper case.
    final bool isSelected = selectedType.toUpperCase() == type.toUpperCase();
    final String serverTypeValue = type.toUpperCase(); // EXPENSE or INCOME

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        label: Text(type),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            onTypeChanged(serverTypeValue);
          }
        },
        backgroundColor: Theme.of(context).dividerColor.withValues(alpha: 0.05),
        selectedColor: color.withValues(alpha: 0.15),
        labelStyle: TextStyle(
          color: isSelected
              ? color
              : Theme.of(context).textTheme.bodyMedium?.color,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected
                ? color.withValues(alpha: 0.3)
                : Theme.of(context).dividerColor.withValues(alpha: 0.1),
          ),
        ),
        showCheckmark: false,
      ),
    );
  }
}
