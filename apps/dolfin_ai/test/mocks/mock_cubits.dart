import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:dolfin_ui_kit/theme/theme_cubit.dart';
import 'package:dolfin_core/tour/product_tour_cubit.dart';
import 'package:feature_auth/presentation/cubit/interactive_onboarding/interactive_onboarding_cubit.dart';
import 'package:feature_auth/presentation/cubit/login/login_cubit.dart';

import 'package:feature_auth/presentation/cubit/session/session_cubit.dart';

import 'package:feature_chat/presentation/cubit/chat_cubit.dart';
import 'package:balance_iq/features/home/presentation/cubit/dashboard_cubit.dart';
import 'package:balance_iq/features/home/presentation/cubit/transaction_filter_cubit.dart';
import 'package:balance_iq/features/home/presentation/cubit/transactions_cubit.dart';
import 'package:feature_subscription/presentation/cubit/subscription_cubit.dart';
import 'package:dolfin_ui_kit/theme/theme_state.dart';
import 'package:dolfin_core/tour/product_tour_state.dart';
import 'package:balance_iq/features/home/presentation/cubit/dashboard_state.dart';
import 'package:balance_iq/features/home/presentation/cubit/transactions_state.dart';
import 'package:balance_iq/features/home/presentation/cubit/transaction_filter_state.dart';
import 'package:feature_chat/presentation/cubit/chat_state.dart';

import 'package:feature_subscription/presentation/cubit/subscription_state.dart';
import 'package:bloc_test/bloc_test.dart';

class MockThemeCubit extends MockCubit<ThemeState> implements ThemeCubit {}

class MockProductTourCubit extends MockCubit<ProductTourState>
    implements ProductTourCubit {}

class MockCurrencyCubit extends MockCubit<CurrencyState>
    implements CurrencyCubit {}

class MockDashboardCubit extends MockCubit<DashboardState>
    implements DashboardCubit {}

class MockTransactionsCubit extends MockCubit<TransactionsState>
    implements TransactionsCubit {}

class MockTransactionFilterCubit extends MockCubit<TransactionFilterState>
    implements TransactionFilterCubit {}

class MockChatCubit extends MockCubit<ChatState> implements ChatCubit {}

class MockInteractiveOnboardingCubit
    extends MockCubit<InteractiveOnboardingState>
    implements InteractiveOnboardingCubit {}

class MockLoginCubit extends MockCubit<LoginState> implements LoginCubit {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}

class MockSubscriptionCubit extends MockCubit<SubscriptionState>
    implements SubscriptionCubit {}
