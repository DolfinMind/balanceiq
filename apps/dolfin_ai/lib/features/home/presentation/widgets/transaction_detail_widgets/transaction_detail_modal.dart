import 'dart:ui';
import 'package:dolfin_core/constants/app_strings.dart';
import 'package:balance_iq/features/home/domain/entities/transaction.dart';
import 'package:balance_iq/features/home/presentation/widgets/transaction_detail_widgets/transaction_detail_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:dolfin_core/analytics/analytics_service.dart';

/// A professional modal for viewing, updating, and deleting transactions
class TransactionDetailModal extends StatefulWidget {
  final Transaction transaction;
  final Function(Transaction)? onUpdate;
  final Function(Transaction)? onDelete;

  const TransactionDetailModal({
    super.key,
    required this.transaction,
    this.onUpdate,
    this.onDelete,
  });

  /// Shows the modal as a bottom sheet
  static Future<void> show(
    BuildContext context, {
    required Transaction transaction,
    Function(Transaction)? onUpdate,
    Function(Transaction)? onDelete,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => TransactionDetailModal(
        transaction: transaction,
        onUpdate: onUpdate,
        onDelete: onDelete,
      ),
    );
  }

  @override
  State<TransactionDetailModal> createState() => _TransactionDetailModalState();
}

class _TransactionDetailModalState extends State<TransactionDetailModal> {
  bool _isEditMode = false;
  bool _isDeleting = false;

  // Form controllers
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late String _selectedType;
  late String _selectedCategory;
  late DateTime _selectedDate;

  // Available categories
  final List<String> _categories = [
    AppStrings.transactions.categoryFood,
    AppStrings.transactions.categoryTransport,
    AppStrings.transactions.categoryShopping,
    AppStrings.transactions.categoryEntertainment,
    AppStrings.transactions.categoryBills,
    AppStrings.transactions.categoryHealthcare,
    AppStrings.transactions.categoryEducation,
    AppStrings.transactions.categorySalary,
    AppStrings.transactions.categoryInvestment,
    AppStrings.transactions.categoryGift,
    AppStrings.transactions.categoryOther,
  ];

  @override
  void initState() {
    super.initState();
    _initializeFormValues();
  }

  void _initializeFormValues() {
    _descriptionController =
        TextEditingController(text: widget.transaction.description);
    _amountController = TextEditingController(
        text: widget.transaction.amount.toStringAsFixed(2));
    _selectedType = widget.transaction.type;
    _selectedCategory = widget.transaction.category;
    _selectedDate = widget.transaction.transactionDate;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (!_isEditMode) {
        // Reset form values when canceling edit
        _initializeFormValues();
      }
    });
  }

  void _handleUpdate() {
    final updatedTransaction = Transaction(
      transactionId: widget.transaction.transactionId,
      type: _selectedType,
      amount:
          double.tryParse(_amountController.text) ?? widget.transaction.amount,
      category: _selectedCategory,
      description: _descriptionController.text,
      transactionDate: _selectedDate,
      createdAt: widget.transaction.createdAt,
      relevanceScore: widget.transaction.relevanceScore,
      totalMatches: widget.transaction.totalMatches,
    );

    // Track detailed transaction update/add
    try {
      final analytics =
          sl.isRegistered<AnalyticsService>() ? sl<AnalyticsService>() : null;
      analytics?.logEvent(
        name: 'modify_transaction',
        parameters: {
          'action': 'update',
          'type': _selectedType,
          'category': _selectedCategory,
          'amount': updatedTransaction.amount,
        },
      );
    } catch (_) {
      // Ignore analytics failures
    }

    widget.onUpdate?.call(updatedTransaction);
    Navigator.pop(context);
  }

  void _handleDelete() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    Theme.of(context).colorScheme.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.delete_outline,
                  color: Theme.of(context).colorScheme.error, size: 24),
            ),
            const SizedBox(width: 12),
            Text(AppStrings.transactions.deleteTransaction),
          ],
        ),
        content: Text(
          AppStrings.transactions.deleteConfirmMessage,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              AppStrings.common.cancel,
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              // Capture context references before async gap
              final navigator = Navigator.of(context);

              navigator.pop(); // Close dialog
              setState(() => _isDeleting = true);

              final analytics = sl.isRegistered<AnalyticsService>()
                  ? sl<AnalyticsService>()
                  : null;
              analytics?.logEvent(
                name: 'modify_transaction',
                parameters: {
                  'action': 'delete',
                  'id': widget.transaction.transactionId.toString(),
                },
              );

              widget.onDelete?.call(widget.transaction);
              if (!mounted) return;
              navigator.pop(); // Close modal
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: Text(AppStrings.common.delete),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: Theme.of(context).colorScheme.primary,
                  onPrimary: Theme.of(context).colorScheme.onPrimary,
                ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: _isDeleting
          ? SizedBox(
              height: 200,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 16),
                    Text(
                      AppStrings.transactions.deleting,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 20),
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .outlineVariant
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),

                    // Header
                    DetailHeader(
                      isIncome: widget.transaction.isIncome,
                      isEditMode: _isEditMode,
                      transactionId:
                          widget.transaction.transactionId.toString(),
                      onToggleEdit: _toggleEditMode,
                    ),

                    // Content
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: _isEditMode
                          ? EditTransactionForm(
                              amountController: _amountController,
                              descriptionController: _descriptionController,
                              selectedType: _selectedType,
                              selectedCategory: _selectedCategory,
                              selectedDate: _selectedDate,
                              categories: _categories,
                              onTypeChanged: (type) =>
                                  setState(() => _selectedType = type),
                              onCategoryChanged: (category) =>
                                  setState(() => _selectedCategory = category),
                              onDateSelect: _selectDate,
                            )
                          : _buildDetailContent(),
                    ),

                    // Action buttons
                    DetailActionButtons(
                      isEditMode: _isEditMode,
                      onDelete: _handleDelete,
                      onSaveOrEdit:
                          _isEditMode ? _handleUpdate : _toggleEditMode,
                    ),

                    // Safe area padding
                    SizedBox(height: MediaQuery.of(context).padding.bottom),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildDetailContent() {
    final transaction = widget.transaction;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          AmountSection(
            amount: transaction.amount,
            isIncome: transaction.isIncome,
          ),
          const SizedBox(height: 20),
          DetailRow(
            icon: Icons.description_outlined,
            label: AppStrings.transactions.description,
            value: transaction.description.isNotEmpty
                ? transaction.description
                : AppStrings.transactions.noDescription,
            delayMs: 250,
          ),
          DetailRow(
            icon: Icons.category_outlined,
            label: AppStrings.transactions.category,
            value: transaction.category,
            delayMs: 300,
          ),
          DetailRow(
            icon: Icons.calendar_today_outlined,
            label: AppStrings.transactions.date,
            value: DateFormat('EEEE, MMMM d, yyyy')
                .format(transaction.transactionDate),
            delayMs: 350,
            isLast: true,
          ),
        ],
      ),
    );
  }
}
