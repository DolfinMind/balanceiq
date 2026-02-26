import 'package:dolfin_core/constants/app_strings.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:balance_iq/core/icons/app_icons.dart';
import 'package:balance_iq/features/home/domain/entities/transaction.dart';
import 'package:balance_iq/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:balance_iq/features/home/presentation/cubit/transactions_cubit.dart';
import 'package:balance_iq/features/home/presentation/cubit/transactions_state.dart';
import 'package:balance_iq/features/home/presentation/widgets/transaction_detail_widgets/transaction_detail_modal.dart';
import 'package:balance_iq/core/strings/dashboard_strings.dart';
import 'package:get_it/get_it.dart';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionHistoryWidget extends StatelessWidget {
  final VoidCallback onViewAll;
  final Future<void> Function()? onRefresh;

  const TransactionHistoryWidget({
    super.key,
    required this.onViewAll,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    // Capture parent context to ensure we have a stable context
    // that survives existing list items being unmounted during loading state
    final parentContext = context;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                GetIt.I<DashboardStrings>().recentTransactions,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  AppStrings.common.viewAll,
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        BlocBuilder<TransactionsCubit, TransactionsState>(
          builder: (context, state) {
            if (state is TransactionsLoading) {
              return const Center(
                  child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ));
            }

            if (state is TransactionsError) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  AppStrings.errors.loadFailed,
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              );
            }

            if (state is TransactionsLoaded) {
              if (state.transactions.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(GetIt.I<DashboardStrings>().noTransactions),
                );
              }

              return ListView.separated(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: state.transactions.length > 5
                    ? 5
                    : state.transactions.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12),
                itemBuilder: (itemContext, index) {
                  return _buildTransactionItem(
                      parentContext, state.transactions[index]);
                },
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  void _showTransactionDetail(BuildContext context, Transaction transaction) {
    TransactionDetailModal.show(
      context,
      transaction: transaction,
      onUpdate: (updatedTransaction) async {
        if (!context.mounted) {
          return;
        }

        await context
            .read<TransactionsCubit>()
            .updateTransaction(updatedTransaction);

        if (context.mounted) {
          if (onRefresh != null) {
            await onRefresh!();
          } else {
            context.read<DashboardCubit>().refreshDashboard();
          }
        }
      },
      onDelete: (deletedTransaction) async {
        if (!context.mounted) return;

        await context
            .read<TransactionsCubit>()
            .deleteTransaction(deletedTransaction.transactionId);

        if (context.mounted) {
          if (onRefresh != null) {
            await onRefresh!();
          } else {
            context.read<DashboardCubit>().refreshDashboard();
          }
        }
      },
    );
  }

  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    final isIncome = transaction.isIncome;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showTransactionDetail(context, transaction),
        borderRadius: BorderRadius.circular(12),
        splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
        highlightColor: Theme.of(context).primaryColor.withValues(alpha: 0.05),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerLow,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.2),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isIncome
                      ? Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.1)
                      : Theme.of(context)
                          .colorScheme
                          .error
                          .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: isIncome
                    ? GetIt.I<AppIcons>().dashboard.income(
                          size: 20,
                          color: Theme.of(context).colorScheme.primary,
                        )
                    : GetIt.I<AppIcons>().dashboard.expense(
                          size: 20,
                          color: Theme.of(context).colorScheme.error,
                        ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat('MMM d, h:mm a')
                          .format(transaction.createdAt.toLocal()),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.color
                                ?.withValues(alpha: 0.7),
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    sl<CurrencyCubit>().formatAmountWithSign(transaction.amount,
                        isIncome: isIncome),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isIncome
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).colorScheme.error,
                        ),
                  ),
                  const SizedBox(width: 4),
                  GetIt.I<AppIcons>().navigation.chevronRight(
                        size: 18,
                        color: isDark ? Colors.white38 : Colors.grey[400],
                      ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
