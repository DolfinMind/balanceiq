import 'package:feature_auth/domain/usecases/sign_in_with_google.dart';

import 'package:feature_auth/domain/usecases/get_current_user.dart';
import 'package:feature_auth/domain/usecases/sign_out.dart';
import 'package:feature_auth/domain/usecases/get_profile.dart';
import 'package:feature_chat/domain/usecases/get_chat_history.dart';
import 'package:feature_chat/domain/usecases/get_message_usage.dart';
import 'package:feature_chat/domain/usecases/get_messages.dart';
import 'package:feature_chat/domain/usecases/send_message.dart';
import 'package:feature_chat/domain/usecases/submit_feedback.dart';
import 'package:feature_chat/domain/usecases/update_message.dart';
import 'package:mocktail/mocktail.dart';

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockSignOut extends Mock implements SignOut {}

class MockGetProfile extends Mock implements GetProfile {}

class MockGetChatHistory extends Mock implements GetChatHistory {}

class MockGetMessageUsage extends Mock implements GetMessageUsage {}

class MockGetMessages extends Mock implements GetMessages {}

class MockSendMessage extends Mock implements SendMessage {}

class MockSubmitFeedback extends Mock implements SubmitFeedback {}

class MockUpdateMessage extends Mock implements UpdateMessage {}
