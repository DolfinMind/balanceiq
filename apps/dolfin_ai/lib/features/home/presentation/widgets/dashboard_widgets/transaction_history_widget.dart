import 'package:dolfin_core/constants/app_strings.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
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
import '../../utils/category_styles.dart';

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
                itemCount: state.transactions.length > 3
                    ? 3
                    : state.transactions.length,
                separatorBuilder: (context, index) => const SizedBox(height: 8),
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
    final catColor = CategoryStyles.colorFor(transaction.category);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _showTransactionDetail(context, transaction),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: catColor.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: catColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  CategoryStyles.iconFor(transaction.category),
                  size: 18,
                  color: catColor,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.category,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      DateFormat('MMM d')
                          .format(transaction.createdAt.toLocal()),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                sl<CurrencyCubit>().formatAmountWithSign(transaction.amount,
                    isIncome: isIncome),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: isIncome
                          ? Theme.of(context).colorScheme.primary
                          : colorScheme.onSurface,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
