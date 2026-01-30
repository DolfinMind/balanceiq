import 'package:bloc_test/bloc_test.dart';
import 'package:feature_auth/data/datasources/auth_local_datasource.dart';
import 'package:feature_auth/data/datasources/auth_remote_datasource.dart';
import 'package:feature_auth/domain/repositories/auth_repository.dart';
import 'package:feature_auth/domain/usecases/get_current_user.dart';
import 'package:feature_auth/domain/usecases/get_profile.dart';
import 'package:feature_auth/domain/usecases/save_user.dart';
import 'package:feature_auth/domain/usecases/sign_in_with_google.dart';
import 'package:feature_auth/domain/usecases/sign_out.dart';
import 'package:feature_auth/domain/usecases/update_currency.dart';
import 'package:feature_auth/domain/usecases/update_profile.dart';
import 'package:dolfin_core/currency/currency_cubit.dart';
import 'package:dolfin_core/analytics/analytics_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:feature_auth/presentation/cubit/session/session_cubit.dart';

// Data Sources
class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAuthRepository extends Mock implements AuthRepository {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockSignOut extends Mock implements SignOut {}

class MockGetProfile extends Mock implements GetProfile {}

class MockSaveUser extends Mock implements SaveUser {}

class MockUpdateProfile extends Mock implements UpdateProfile {}

class MockUpdateCurrency extends Mock implements UpdateCurrency {}

class MockCurrencyCubit extends MockCubit<CurrencyState>
    implements CurrencyCubit {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockSessionCubit extends MockCubit<SessionState>
    implements SessionCubit {}
