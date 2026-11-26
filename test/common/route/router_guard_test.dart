import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_start_pack/common/dio/sample/sample_repository.dart';
import 'package:flutter_start_pack/common/notification/notification_tap_handler.dart';
import 'package:flutter_start_pack/common/view/splash_screen.dart';
import 'package:flutter_start_pack/lobby/lobby_screen.dart';
import 'package:flutter_start_pack/main.dart';
import 'package:flutter_start_pack/user/model/user_model.dart';
import 'package:flutter_start_pack/user/provider/user_me_provider.dart';
import 'package:flutter_start_pack/user/view/social_login_screen.dart';

/// Splash 대기(getMe) 없이 상태를 직접 바꿀 수 있는 테스트용 Notifier
class FakeUserMeNotifier extends UserMeStateNotifier {
  FakeUserMeNotifier() : super(storage: const FlutterSecureStorage());

  @override
  Future<void> getMe() async {}

  void setUser(UserModelBase? user) => state = user;
}

final _dummyUser = UserModel(
  id: 1,
  name: '테스트',
  email: 'test@example.com',
  loginType: SocialLoginType.google,
);

void main() {
  late FakeUserMeNotifier userMe;

  setUp(() {
    FlutterSecureStorage.setMockInitialValues({});
    userMe = FakeUserMeNotifier();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userMeProvider.overrideWith((ref) => userMe),
          notificationTapHandlerProvider.overrideWith((ref) {}),
          samplePostsProvider.overrideWith((ref) async => []),
        ],
        child: const App(),
      ),
    );
    await tester.pump();
  }

  /// Splash 의 CircularProgressIndicator 때문에 pumpAndSettle 대신 몇 프레임만 진행한다.
  Future<void> changeUser(WidgetTester tester, UserModelBase? user) async {
    userMe.setUser(user);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('앱 진입 시(Loading) Splash 화면을 보여준다', (tester) async {
    await pumpApp(tester);

    expect(find.byType(SplashScreen), findsOneWidget);
  });

  testWidgets('로그인 정보가 없으면(null) 로그인 화면으로 이동한다', (tester) async {
    await pumpApp(tester);
    await changeUser(tester, null);

    expect(find.byType(SocialLoginScreen), findsOneWidget);
  });

  testWidgets('로그인에 실패하면(Error) 로그인 화면에 머무른다', (tester) async {
    await pumpApp(tester);
    await changeUser(tester, null);
    await changeUser(tester, UserModelError(message: 'fail'));

    expect(find.byType(SocialLoginScreen), findsOneWidget);
  });

  testWidgets('로그인하면(UserModel) Lobby 로, 로그아웃하면 다시 로그인 화면으로 이동한다', (tester) async {
    await pumpApp(tester);
    await changeUser(tester, null);
    await changeUser(tester, _dummyUser);

    expect(find.byType(LobbyScreen), findsOneWidget);

    await changeUser(tester, null);

    expect(find.byType(SocialLoginScreen), findsOneWidget);
  });
}
