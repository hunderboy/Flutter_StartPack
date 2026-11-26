# Flutter Start Pack

새 Flutter 프로젝트를 시작할 때 매번 만드는 기본 구조(상태관리[riverpod], 라우팅, 네트워크, 로그인 흐름, 테마, 알림)를 미리 갖춰둔 스타트 팩입니다.

## 포함된 기능

| 영역 | 사용 기술 | 내용 |
|------|-----------|------|
| 상태관리 | flutter_riverpod | 전역 Provider 구조, 로그인 상태(`userMeProvider`) |
| 라우팅 | go_router | 로그인 상태에 따라 Splash / Login / Lobby 자동 전환 (RouterGuard) |
| 네트워크 | dio + retrofit + json_serializable | 토큰 자동 주입, 401 시 토큰 재발급 후 재전송 (동시 요청 대응) |
| 저장소 | flutter_secure_storage | 토큰 / 테마 설정 저장 |
| 로그인 | (Fake) | 구글 / 애플 / 카카오 / 네이버 버튼과 흐름 (실제 SDK 연동은 TODO) |
| 테마 | Material 3 + ThemeExtension | 라이트 / 다크 / 시스템 전환, `context.colors.xxx` |
| 알림 | flutter_local_notifications | 즉시 / 예약 알림, 알림 탭 시 payload 경로로 이동 |

## 시작하기

```bash
flutter pub get
```

```bash
flutter run
```

서버 주소는 빌드할 때 주입합니다. (기본값 : `lib/common/const/data.dart` 의 `serverIP`)

```bash
flutter run --dart-define=SERVER_URL=https://api.example.com
```

### 코드 생성

모델(`@JsonSerializable`)이나 Repository(`@RestApi`)를 수정한 뒤에는 코드를 다시 생성합니다.

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 테스트

```bash
flutter test
```

| 테스트 | 확인 내용 |
|--------|-----------|
| `test/common/dio/custom_interceptor_test.dart` | 토큰 주입, 동시 401 시 재발급 1회, Refresh 만료 시 로그아웃 |
| `test/common/route/router_guard_test.dart` | 유저 상태에 따른 Splash / Login / Lobby 화면 전환 |

## 폴더 구조

기능(도메인) 단위로 폴더를 나누고, 각 폴더의 README 에 자세한 설명이 있습니다.

```
lib/
├── main.dart     # 앱 진입점 (세로 고정, 알림 초기화, ProviderScope)
├── common/       # 공통 : 상수, dio, 라우팅, 테마, 알림, 공통 UI   → lib/common/README.md
├── user/         # 소셜 로그인, 로그인 상태(userMeProvider)          → lib/user/README.md
└── lobby/        # 로그인 후 메인 화면 (탭 : 홈 / 검색 / 마이)       → lib/lobby/README.md
```

각 도메인 폴더 안은 아래 규칙을 따릅니다.

```
model/            # 데이터 모델
provider/         # Riverpod Provider
repository/       # Retrofit Repository (필요할 때 추가, common/dio/sample 참고)
view/             # 화면
view_component/   # 해당 도메인 전용 UI 컴포넌트
```

## 화면 전환 흐름

화면에서 직접 `context.go()` 하지 않고 `userMeProvider` 상태만 바꾸면 `RouterGuardProvider` 가 화면을 결정합니다.

```
앱 실행 → UserModelLoading → /splash
           ├─ null / UserModelError → /login
           └─ UserModel             → /  (Lobby)
로그아웃 → null → /login
```

## 새 프로젝트로 가져갈 때 할 일

- [ ] `pubspec.yaml` 의 `name`, `description` 변경 (import 경로 `package:flutter_start_pack/` 일괄 변경)
- [ ] Android `applicationId` / iOS Bundle Identifier, 앱 이름 변경
- [ ] `lib/common/const/data.dart` 의 `serverIP` 기본값 변경
- [ ] `lib/common/dio/dio.dart` 의 토큰 재발급 경로(`refreshPath`)와 응답 파싱을 서버 스펙에 맞게 수정
- [ ] `lib/user/provider/user_me_provider.dart` 의 자동 로그인(`getMe`), 소셜 로그인 TODO 채우기
- [ ] 사용하지 않는 샘플 정리 (`common/dio/sample/`, 알림 테스트 화면)
