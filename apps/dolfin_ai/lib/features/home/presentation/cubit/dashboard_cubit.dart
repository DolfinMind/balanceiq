import 'package:dolfin_core/utils/app_logger.dart';
import 'package:bloc/bloc.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/get_user_dashbaord.dart';
import '../../domain/entities/dashbaord_summary.dart';
import 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardSummary getDashboardSummary;

  DashboardCubit({required this.getDashboardSummary})
      : super(DashboardInitial());

  String? _currentStartDate;
  String? _currentEndDate;

  Future<void> loadDashboard({String? startDate, String? endDate}) async {
    AppLogger.debug(
        'DashboardCubit.loadDashboard called. Args: start=$startDate, end=$endDate. Cached: start=$_currentStartDate, end=$_currentEndDate',
        name: 'DashboardDebug');
    emit(DashboardLoading());

    // Update cached dates if provided
    if (startDate != null && endDate != null) {
      _currentStartDate = startDate;
      _currentEndDate = endDate;
    }

    // Use cached dates or default to current month
    String? finalStartDate = _currentStartDate;
    String? finalEndDate = _currentEndDate;

    if (finalStartDate == null || finalEndDate == null) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, 1);
      final end = DateTime(now.year, now.month + 1, 0);

      // Basic ISO 8601 format YYYY-MM-DD
      finalStartDate =
          "${start.year}-${start.month.toString().padLeft(2, '0')}-${start.day.toString().padLeft(2, '0')}";
      finalEndDate =
          "${end.year}-${end.month.toString().padLeft(2, '0')}-${end.day.toString().padLeft(2, '0')}";

      // Update cache with defaults so refresh uses them
      _currentStartDate = finalStartDate;
      _currentEndDate = finalEndDate;
    }

    final result = await getDashboardSummary(
      startDate: finalStartDate,
      endDate: finalEndDate,
    );

    result.fold(
      (failure) {
        if (failure.message.contains('No dashboard data')) {
          emit(DashboardLoaded(DashboardSummary.empty()));
        } else {
          emit(DashboardError(failure.message));
        }
      },
      (summary) => emit(DashboardLoaded(summary)),
    );
  }

  Future<void> refreshDashboard({String? startDate, String? endDate}) {
    AppLogger.debug(
        'DashboardCubit.refreshDashboard called. Args: start=$startDate, end=$endDate',
        name: 'DashboardDebug');
    // If args provided, update cache and load.
    // If not, loadDashboard will use cache.
    if (startDate != null && endDate != null) {
      _currentStartDate = startDate;
      _currentEndDate = endDate;
    }
    return loadDashboard(); // Uses cached values
  }
}
