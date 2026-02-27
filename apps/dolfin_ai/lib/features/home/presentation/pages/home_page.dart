import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:balance_iq/core/di/injection_container.dart';
import 'package:dolfin_core/analytics/analytics_service.dart';
import 'package:balance_iq/core/tour/tour.dart';
import 'package:feature_auth/data/datasources/auth_local_datasource.dart';
import 'package:balance_iq/features/home/presentation/cubit/dashboard_state.dart';
import 'package:balance_iq/features/home/presentation/widgets/dashboard_widgets/dashboard_shimmer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:dolfin_core/utils/app_logger.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/transactions_cubit.dart';
import '../widgets/calendar_widgets/date_selector_bottom_sheet.dart';
import '../widgets/dashboard_layout.dart';
import 'error_page.dart';
import 'welcome_page.dart';
import '../widgets/calendar_widgets/custom_calendar_date_range_picker.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionsCubit>(
      create: (context) => sl<TransactionsCubit>()..loadTransactions(limit: 5),
      child: const DashboardView(),
    );
  }
}

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  String _userName = 'User';
  String? _profileUrl;
  DateTime? _startDate;
  DateTime? _endDate;
  bool _tourCheckDone = false;
  String? _selectedDateLabel = 'Last 30 Days'; // Initialize with default label

  final GlobalKey _profileIconKey = GlobalKey();
  late DashboardTourController _tourController;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tourController = DashboardTourController(
        context: context,
        profileIconKey: _profileIconKey,
      );
      _checkInitialDashboardState();
    });

    _loadUser();

    // Initialize with last 30 days
    final now = DateTime.now();
    _startDate = now.subtract(const Duration(days: 30));
    _endDate = now;

    _loadDashboard();

    // Log screen view
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (sl.isRegistered<AnalyticsService>()) {
        sl<AnalyticsService>().logEvent(
          name: 'screen_view',
          parameters: {'screen_name': 'dashboard'},
        );
      }
    });
  }

  @override
  void dispose() {
    _tourController.dispose();
    super.dispose();
  }

  void _checkInitialDashboardState() {
    final state = context.read<DashboardCubit>().state;
    if (state is DashboardLoaded && !_tourCheckDone) {
      final isOnboarded = state.summary.onboarded;

      _tourController.checkAndTriggerTour(
        isOnboarded: isOnboarded,
        onTourCheckDone: () {
          _tourCheckDone = true;
        },
      );
    }
  }

  Future<void> _loadUser() async {
    final authLocalDataSource = sl<AuthLocalDataSource>();
    final cachedUser = await authLocalDataSource.getCachedUser();

    if (cachedUser != null) {
      setState(() {
        _userName = cachedUser.name;
        _profileUrl = cachedUser.photoUrl;
      });
    }
  }

  void _loadDashboard() {
    String? startDateStr;
    String? endDateStr;

    if (_startDate != null && _endDate != null) {
      startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
      endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);
    }

    context.read<DashboardCubit>().loadDashboard(
          startDate: startDateStr,
          endDate: endDateStr,
        );

    // Now this works because context is under BlocProvider
    context.read<TransactionsCubit>().loadTransactions(
          limit: 5,
          startDate: startDateStr,
          endDate: endDateStr,
        );
  }

  Future<void> _refreshDashboard() async {
    AppLogger.debug('HomePage._refreshDashboard called',
        name: 'DashboardDebug');
    String? startDateStr;
    String? endDateStr;

    if (_startDate != null && _endDate != null) {
      startDateStr = DateFormat('yyyy-MM-dd').format(_startDate!);
      endDateStr = DateFormat('yyyy-MM-dd').format(_endDate!);
    }

    final dashboardFuture = context.read<DashboardCubit>().refreshDashboard(
          startDate: startDateStr,
          endDate: endDateStr,
        );

    final transactionsFuture =
        context.read<TransactionsCubit>().loadTransactions(
              limit: 5,
              startDate: startDateStr,
              endDate: endDateStr,
            );

    await Future.wait([dashboardFuture, transactionsFuture]);
  }

  void _selectDateRange() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) => DateSelectorBottomSheet(
        currentLabel: _selectedDateLabel,
        onDateSelected: (start, end, label) {
          // Navigator.pop handled by DateSelectorBottomSheet for presets
          setState(() {
            _startDate = start;
            _endDate = end;
            _selectedDateLabel = label;
          });
          _loadDashboard();
        },
        onCustomRangePressed: () async {
          Navigator.pop(bottomSheetContext);

          final now = DateTime.now();
          await showDialog(
            context: context,
            builder: (context) => CustomCalendarDateRangePicker(
              minDate: DateTime(2020),
              maxDate: now.add(const Duration(days: 365)),
              onDateRangeSelected: (startDate, endDate) {
                setState(() {
                  _startDate = startDate;
                  _endDate = endDate;
                  _selectedDateLabel = null; // Reset label for custom range
                });
                _loadDashboard();
              },
            ),
          );
        },
      ),
    );
  }

  String _getFormattedDateRange() {
    if (_startDate == null || _endDate == null) return 'Select Date';

    // Priority: Explicit label from preset
    if (_selectedDateLabel != null) {
      return _selectedDateLabel!;
    }

    final start = _startDate!;
    final end = _endDate!;
    final now = DateTime.now();

    // Check if it's the current month fully selected
    if (start.year == now.year &&
        start.month == now.month &&
        start.day == 1 &&
        end.month == now.month &&
        end.day == DateTime(now.year, now.month + 1, 0).day) {
      return DateFormat('MMMM yyyy').format(start);
    }

    // Check if it's any full month
    if (start.day == 1 &&
        end.year == start.year &&
        end.month == start.month &&
        end.day == DateTime(start.year, start.month + 1, 0).day) {
      return DateFormat('MMMM yyyy').format(start);
    }

    // Same year
    if (start.year == end.year) {
      if (start.month == end.month) {
        return '${DateFormat('MMM d').format(start)} - ${DateFormat('d, yyyy').format(end)}';
      }
      return '${DateFormat('MMM d').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
    }

    // Different years
    return '${DateFormat('MMM d, yyyy').format(start)} - ${DateFormat('MMM d, yyyy').format(end)}';
  }

  Future<void> _onViewAllTransactions() async {
    // Navigate to transactions page and wait for result (hasChanges)
    final hasChanges = await Navigator.pushNamed(context, '/transactions');

    // If changes were made and we are still mounted, refresh the dashboard
    if (hasChanges == true && mounted) {
      await _refreshDashboard();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProductTourCubit, ProductTourState>(
      listener: (context, tourState) {
        if (tourState is TourActive &&
            tourState.currentStep == TourStep.dashboardProfileIcon &&
            !tourState.isTransitioning) {
          // Show tour after a small delay to ensure widgets are built
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _tourController.showProfileIconTour();
          });
        }
      },
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) async {
          if (didPop) return;
          await showDialog<bool>(
            context: context,
            barrierColor: Colors.black.withValues(alpha: 0.5),
            builder: (context) => _buildExitDialog(context),
          );
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: BlocBuilder<CurrencyCubit, CurrencyState>(
            bloc: sl<CurrencyCubit>(),
            builder: (context, currencyState) {
              // This BlocBuilder ensures widgets rebuild when currency changes
              return BlocConsumer<DashboardCubit, DashboardState>(
                listener: (context, state) {
                  if (state is DashboardLoaded && !_tourCheckDone) {
                    _tourCheckDone = true;
                    // Dashboard loaded - check if we need to start the tour
                    final isOnboarded = state.summary.onboarded;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final tourCubit = context.read<ProductTourCubit>();
                      tourCubit.checkAndStartTourIfNeeded(
                          isOnboarded: isOnboarded);

                      // If tour is already active at dashboard step, show it
                      Future.delayed(const Duration(milliseconds: 500), () {
                        if (mounted &&
                            tourCubit.isAtStep(TourStep.dashboardProfileIcon)) {
                          _tourController.showProfileIconTour();
                        }
                      });
                    });
                  }
                },
                builder: (context, state) {
                  if (state is DashboardLoading) {
                    return const DashboardShimmer();
                  }

                  if (state is DashboardError) {
                    if (state.message.contains('No dashboard data')) {
                      return WelcomePage(
                        userName: _userName,
                        onGetStarted: _loadDashboard,
                      );
                    }

                    // Check if error is authentication-related
                    final isAuthError =
                        state.message.toLowerCase().contains('unauthorized') ||
                            state.message
                                .toLowerCase()
                                .contains('unauthenticated') ||
                            state.message.toLowerCase().contains('token') ||
                            state.message.toLowerCase().contains('login');

                    return Error404Page(
                      errorMessage: state.message,
                      isAuthError: isAuthError,
                      onRetry: isAuthError
                          ? () {
                              // Navigate to login page
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                '/login',
                                (route) => false,
                              );
                            }
                          : _loadDashboard,
                    );
                  }

                  if (state is DashboardLoaded) {
                    final summary = state.summary;

                    return DashboardLayout(
                      summary: summary,
                      onRefresh: _refreshDashboard,
                      onTapProfileIcon: () {
                        final tourCubit = context.read<ProductTourCubit>();
                        if (tourCubit.isAtStep(TourStep.dashboardProfileIcon)) {
                          tourCubit.onProfileIconTapped();
                        }
                        Navigator.pushNamed(context, '/profile');
                      },
                      onViewAll: _onViewAllTransactions,
                      onChatReturn: _loadDashboard,
                      profileUrl: _profileUrl ?? '',
                      userName: _userName,
                      displayDate: _getFormattedDateRange(),
                      onTapDateRange: _selectDateRange,
                      profileIconKey: _profileIconKey,
                    );
                  }

                  return const SizedBox.shrink();
                },
              ); // End BlocConsumer
            },
          ), // End BlocBuilder for CurrencyCubit
        ),
      ),
    );
  }

  Widget _buildExitDialog(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Exit App',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text(
              'Do you want to exit the app?',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                    SystemNavigator.pop();
                  },
                  child: const Text('Yes'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
