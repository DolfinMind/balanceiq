import 'package:balance_iq/features/home/domain/entities/transaction.dart';
import 'package:balance_iq/features/home/presentation/cubit/transaction_filter_cubit.dart';
import 'package:balance_iq/features/home/presentation/cubit/transactions_cubit.dart';
import 'package:balance_iq/features/home/presentation/cubit/transactions_state.dart';
import 'package:balance_iq/features/home/presentation/widgets/transactions_page_widgets/transaction_list_item.dart';
import 'package:balance_iq/features/home/presentation/widgets/transactions_page_widgets/transactions_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class TransactionsList extends StatelessWidget {
  final Function(Transaction) onTransactionTap;

  const TransactionsList({super.key, required this.onTransactionTap});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TransactionsCubit, TransactionsState>(
      builder: (context, transactionsState) {
        if (transactionsState is TransactionsLoading) {
          return const TransactionsShimmer();
        }

        if (transactionsState is TransactionsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.grey)
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .shake(delay: 200.ms, duration: 500.ms),
                const SizedBox(height: 16),
                Text('Error: ${transactionsState.message}')
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms),
                ElevatedButton(
                  onPressed: () {
                    final filterState =
                        context.read<TransactionFilterCubit>().state;
                    context.read<TransactionsCubit>().loadTransactions(
                          search: filterState.searchQuery,
                          category: filterState.selectedCategory,
                          type: filterState.selectedType,
                          startDate: filterState.startDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(filterState.startDate!)
                              : null,
                          endDate: filterState.endDate != null
                              ? DateFormat('yyyy-MM-dd')
                                  .format(filterState.endDate!)
                              : null,
                          limit: 50,
                        );
                  },
                  child: const Text('Retry'),
                ).animate().fadeIn(delay: 200.ms, duration: 400.ms).scaleXY(
                    begin: 0.9, end: 1, delay: 200.ms, duration: 400.ms),
              ],
            ),
          );
        }

        if (transactionsState is TransactionsLoaded) {
          if (transactionsState.transactions.isEmpty) {
            return Center(
              child: const Text('No transactions found matching your criteria.')
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, duration: 400.ms),
            );
          }

          return NotificationListener<ScrollNotification>(
            onNotification: (scrollInfo) {
              if (scrollInfo.metrics.pixels ==
                  scrollInfo.metrics.maxScrollExtent) {
                context.read<TransactionsCubit>().loadMoreTransactions();
              }
              return false;
            },
            child: RefreshIndicator(
              onRefresh: () async {
                final filterState =
                    context.read<TransactionFilterCubit>().state;
                context.read<TransactionsCubit>().loadTransactions(
                      search: filterState.searchQuery,
                      category: filterState.selectedCategory,
                      type: filterState.selectedType,
                      startDate: filterState.startDate != null
                          ? DateFormat('yyyy-MM-dd')
                              .format(filterState.startDate!)
                          : null,
                      endDate: filterState.endDate != null
                          ? DateFormat('yyyy-MM-dd')
                              .format(filterState.endDate!)
                          : null,
                      limit: 50,
                    );
              },
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: transactionsState.transactions.length +
                    (transactionsState.isMoreLoading ? 1 : 0),
                separatorBuilder: (context, index) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  if (index == transactionsState.transactions.length) {
                    return const Center(
                        child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator()));
                  }
                  return TransactionListItem(
                    transaction: transactionsState.transactions[index],
                    index: index,
                    onTap: onTransactionTap,
                  );
                },
              ),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }
}
