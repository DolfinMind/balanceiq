import 'package:dolfin_core/error/failures.dart';
import 'package:dolfin_core/utils/snackbar_utils.dart';
import 'package:feature_chat/domain/entities/message_usage.dart';
import 'package:feature_chat/domain/usecases/get_message_usage.dart';
import 'package:feature_chat/domain/usecases/send_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

/// Bottom sheet for adding a transaction via chat API
class AddTransactionTab extends StatefulWidget {
  final VoidCallback onSuccess;

  const AddTransactionTab({
    super.key,
    required this.onSuccess,
  });

  @override
  State<AddTransactionTab> createState() => _AddTransactionTabState();
}

class _AddTransactionTabState extends State<AddTransactionTab> {
  static const Color _incomeColor = Color(0xFF34d399); // Soft Emerald
  static const Color _expenseColor = Color(0xFFf87171); // Soft Red

  final _amountController = TextEditingController();
  final _customCategoryController = TextEditingController();
  final _amountFocusNode = FocusNode();
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  bool _isCustomCategory = false;
  String _transactionType = 'Expense'; // Default to Expense
  DateTime _selectedDate = DateTime.now();
  bool _isLoading = false;
  bool _isCheckingUsage = true;
  MessageUsage? _messageUsage;

  @override
  void initState() {
    super.initState();
    _checkMessageUsage();
  }

  bool get _isLimitReached => _messageUsage?.isLimitReached ?? false;

  Future<void> _checkMessageUsage() async {
    try {
      final getMessageUsage = GetIt.I<GetMessageUsage>();
      final result = await getMessageUsage();

      if (!mounted) return;

      result.fold(
        (failure) {
          // On failure, allow usage (fail open)
          setState(() {
            _isCheckingUsage = false;
          });
        },
        (usage) {
          setState(() {
            _messageUsage = usage;
            _isCheckingUsage = false;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isCheckingUsage = false;
      });
    }
  }

  // Predefined categories
  static const List<String> _expenseCategories = [
    'Food & Dining',
    'Transportation',
    'Shopping',
    'Entertainment',
    'Bills & Utilities',
    'Healthcare',
    'Education',
    'Travel',
    'Groceries',
    'Personal Care',
    'Other',
    'Custom',
  ];

  static const List<String> _incomeCategories = [
    'Salary',
    'Freelance',
    'Business',
    'Investments',
    'Rental Income',
    'Gifts',
    'Refunds',
    'Other',
    'Custom',
  ];

  List<String> get _categories =>
      _transactionType == 'Income' ? _incomeCategories : _expenseCategories;

  @override
  void dispose() {
    _amountController.dispose();
    _customCategoryController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  void _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _onCategoryChanged(String? value) {
    setState(() {
      if (value == 'Custom') {
        _isCustomCategory = true;
        _selectedCategory = null;
      } else {
        _isCustomCategory = false;
        _selectedCategory = value;
        _customCategoryController.clear();
      }
    });
  }

  void _onTransactionTypeChanged(String type) {
    setState(() {
      _transactionType = type;
      _selectedCategory = null;
      _isCustomCategory = false;
      _customCategoryController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final amount = _amountController.text.trim();
    final category = _isCustomCategory
        ? _customCategoryController.text.trim()
        : _selectedCategory;

    if (category == null || category.isEmpty) {
      SnackbarUtils.showError(context, 'Please select a category');
      return;
    }

    final formattedDate = DateFormat('MMMM d, yyyy').format(_selectedDate);

    // Construct the message
    final message =
        'Add $amount BDT in $category as $_transactionType on $formattedDate';

    setState(() {
      _isLoading = true;
    });

    try {
      final sendMessage = GetIt.I<SendMessage>();
      final result = await sendMessage(
        botId: 'nai kichu', // Placeholder bot ID for manual transaction
        content: message,
      );

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _isLoading = false;
          });

          if (failure is ChatApiFailure) {
            _handleChatError(failure.failureType, failure.message);
          } else {
            SnackbarUtils.showError(context, failure.message);
          }
        },
        (response) {
          setState(() {
            _isLoading = false;
            // Clear inputs for the next time
            _amountController.clear();
            _customCategoryController.clear();
          });
          _showSuccessModal();
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      SnackbarUtils.showError(context, 'Error: ${e.toString()}');
    }
  }

  void _showSuccessModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: Icon(
            LucideIcons.circleCheck,
            size: 48,
            color: Theme.of(context).colorScheme.primary,
          ),
          title: const Text('Success!'),
          content: const Text(
            'Your transaction has been added successfully.',
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () {
                  Navigator.pop(context); // Close the dialog
                  widget.onSuccess(); // Go back to dashboard
                },
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text('Back to Dashboard'),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleChatError(ChatFailureType type, String message) {
    String title;
    String description;
    String buttonText;
    IconData icon;
    Color color;
    VoidCallback onButtonPressed;

    switch (type) {
      case ChatFailureType.emailNotVerified:
        title = 'Email Verification Required';
        description =
            'Please verify your email address to add transactions via AI.';
        buttonText = 'Verify Email';
        icon = LucideIcons.mailWarning;
        color = Colors.orange;
        onButtonPressed = () => Navigator.pushNamed(context, '/profile');
        break;

      case ChatFailureType.subscriptionRequired:
        title = 'Subscription Required';
        description =
            'You need an active subscription plan to use this feature.';
        buttonText = 'View Plans';
        icon = LucideIcons.crown;
        color = Colors.blue;
        onButtonPressed =
            () => Navigator.pushNamed(context, '/subscription-plans');
        break;

      case ChatFailureType.subscriptionExpired:
        title = 'Subscription Expired';
        description =
            'Your subscription has expired. Please renew to continue using this feature.';
        buttonText = 'Renew Subscription';
        icon = LucideIcons.calendarOff;
        color = Colors.red;
        onButtonPressed =
            () => Navigator.pushNamed(context, '/manage-subscription');
        break;

      case ChatFailureType.tokenLimitExceeded:
        title = 'Message Limit Exceeded';
        description =
            'You have reached your daily message limit. Resets at midnight.';
        buttonText = 'Upgrade Plan';
        icon = LucideIcons.messageSquareOff;
        color = Colors.purple;
        onButtonPressed =
            () => Navigator.pushNamed(context, '/subscription-plans');
        break;

      case ChatFailureType.rateLimitExceeded:
        title = 'Too Many Requests';
        description = 'Please wait a moment before trying again.';
        buttonText = 'Got it';
        icon = LucideIcons.clock;
        color = Colors.orange;
        onButtonPressed = () => Navigator.pop(context); // Just close dialog
        break;

      case ChatFailureType.currencyRequired:
        title = 'Currency Required';
        description =
            'Please set your preferred currency in your profile settings.';
        buttonText = 'Set Currency';
        icon = LucideIcons.coins;
        color = Colors.green;
        onButtonPressed = () => Navigator.pushNamed(context, '/profile',
            arguments: {'action': 'open_currency_selector'});
        break;

      case ChatFailureType.general:
        title = 'Something Went Wrong';
        description = message.isNotEmpty ? message : 'Please try again later.';
        buttonText = 'Retry';
        icon = LucideIcons.circleAlert;
        color = Colors.red;
        onButtonPressed = _submit;
        break;
    }

    // Since we are likely in a bottom sheet, showing a dialog on top is appropriate.
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 24),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    if (type != ChatFailureType.rateLimitExceeded &&
                        type != ChatFailureType.general) {
                      // For navigation actions, we might also want to close the bottom sheet?
                      // The user might want to come back to their input though.
                      // Let's keep the sheet open so they don't lose input.
                      onButtonPressed();
                    } else if (type == ChatFailureType.general) {
                      onButtonPressed(); // Retry
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(buttonText),
                ),
              ),
              if (type != ChatFailureType.rateLimitExceeded &&
                  type != ChatFailureType.general) ...[
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Theme.of(context).hintColor),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top, // Top safe area + padding
        left: 20,
        right: 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title
              Text(
                'Add Transaction',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              // Transaction Type Toggle
              _buildTransactionTypeToggle(context),
              const SizedBox(height: 16),

              // Amount Field
              _buildAmountField(context),
              const SizedBox(height: 16),

              // Date Picker
              _buildDatePicker(context),
              const SizedBox(height: 16),

              // Category Dropdown (now ChoiceChips)
              _buildCategoryDropdown(context),
              const SizedBox(height: 16),

              // Custom Category Field (if selected)
              if (_isCustomCategory) ...[
                _buildCustomCategoryField(context),
                const SizedBox(height: 16),
              ],

              // Submit Button
              _buildSubmitButton(context),
              SizedBox(height: 220)
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransactionTypeToggle(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Transaction Type',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildTypePill(context, 'Expense', _expenseColor),
            _buildTypePill(context, 'Income', _incomeColor),
          ],
        ),
      ],
    );
  }

  Widget _buildTypePill(
    BuildContext context,
    String type,
    Color color,
  ) {
    final isSelected = _transactionType == type;

    return Theme(
      data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
      child: ChoiceChip(
        label: Text(type),
        selected: isSelected,
        onSelected: _isLoading
            ? null
            : (selected) {
                if (selected) {
                  _onTransactionTypeChanged(type);
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

  Widget _buildAmountField(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Amount',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _amountController,
          focusNode: _amountFocusNode,
          enabled: !_isLoading,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            hintText: 'Enter amount',
            prefixIcon: const Icon(LucideIcons.banknote),
            suffixText: 'BDT',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            filled: true,
            fillColor: Theme.of(context).dividerColor.withValues(alpha: 0.05),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter an amount';
            }
            final amount = double.tryParse(value);
            if (amount == null || amount <= 0) {
              return 'Please enter a valid amount';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Category',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _categories.map((category) {
            final isSelected = (_isCustomCategory && category == 'Custom') ||
                (!_isCustomCategory && _selectedCategory == category);
            return Theme(
              data: Theme.of(context).copyWith(canvasColor: Colors.transparent),
              child: ChoiceChip(
                label: Text(category),
                selected: isSelected,
                onSelected: _isLoading
                    ? null
                    : (selected) {
                        if (selected) {
                          _onCategoryChanged(category);
                        }
                      },
                backgroundColor:
                    Theme.of(context).dividerColor.withValues(alpha: 0.05),
                selectedColor: Theme.of(context).colorScheme.primaryContainer,
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
                        : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                  ),
                ),
                showCheckmark: false,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildCustomCategoryField(BuildContext context) {
    return TextFormField(
      controller: _customCategoryController,
      enabled: !_isLoading,
      decoration: InputDecoration(
        labelText: 'Custom Category',
        hintText: 'Enter category name',
        prefixIcon: const Icon(LucideIcons.pencil),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        filled: true,
        fillColor: Theme.of(context).dividerColor.withValues(alpha: 0.05),
      ),
      validator: (value) {
        if (_isCustomCategory && (value == null || value.isEmpty)) {
          return 'Please enter a category name';
        }
        return null;
      },
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Date of transaction',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 12),
        InkWell(
          onTap: _isLoading ? null : _selectDate,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(16),
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
            ),
            child: Row(
              children: [
                Icon(
                  LucideIcons.calendar,
                  color: Theme.of(context).hintColor,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    DateFormat('EEEE, MMMM d, yyyy').format(_selectedDate),
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Icon(
                  LucideIcons.chevronRight,
                  color: Theme.of(context).hintColor,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubmitButton(BuildContext context) {
    final isDisabled = _isLoading || _isCheckingUsage || _isLimitReached;

    return Container(
      decoration: BoxDecoration(
        gradient: isDisabled
            ? null
            : LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
        color: isDisabled ? Theme.of(context).disabledColor : null,
        borderRadius: BorderRadius.circular(16),
        boxShadow: isDisabled
            ? null
            : [
                BoxShadow(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: ElevatedButton(
        onPressed: isDisabled ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _buildButtonContent(context),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (_isCheckingUsage) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }

    if (_isLimitReached) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                LucideIcons.circleAlert,
                size: 18,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
              const SizedBox(width: 8),
              Text(
                'Limit Reached',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.6),
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Resets on ${_messageUsage?.formattedResetDateTime ?? ''}',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.5),
                ),
          ),
        ],
      );
    }

    if (_isLoading) {
      return SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2.5,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(LucideIcons.plus, size: 20),
        const SizedBox(width: 8),
        Text(
          'Add',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Theme.of(context).colorScheme.onPrimary,
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
