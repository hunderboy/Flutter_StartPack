# Common 도메인 설명

Common은 앱 전체에서 공통으로 사용하는 상수, 네트워크, 라우팅, 레이아웃, UI 컴포넌트를 담당합니다.
특정 도메인에 속하지 않는 재사용 가능한 코드들이 이 폴더에 위치합니다.

---

## 주요 Provider

| Provider | 역할 |
|----------|------|
| `routerProvider` | GoRouter 라우팅 설정 (userMeProvider 상태에 따른 리다이렉트 포함) |
| `routerGuardProvider` | Route 목록 + redirect 로직 (userMeProvider 변경 시 notifyListeners) |
| `dioProvider` | 공용 Dio (PrettyDioLogger + 토큰 자동 주입 인터셉터) |
| `secureStorageProvider` | FlutterSecureStorage (토큰 저장) |
| `sampleRepositoryProvider` | Retrofit Repository 예시 |
| `localNotificationProvider` | 로컬 알림 (즉시 / 예약 / 취소 / 권한 요청) |
| `notificationTapHandlerProvider` | 알림 탭 시 payload 경로로 화면 이동 (로그인 전이면 로그인 후 이동) |

## 라우팅 흐름

화면에서 직접 `context.go()` 하지 않고 `userMeProvider` 상태만 변경하면
`RouterGuardProvider.redirectLogic` 이 화면을 결정합니다.

```
UserModelLoading  → /splash 유지 (로그인 진행 중이면 /login 유지)
null / Error      → /login
UserModel         → /  (Lobby)
```

## 네트워크 (dio)

- `@Headers({'accessToken': 'true'})` 를 붙이면 `CustomInterceptor` 가 저장된 토큰으로 `authorization: Bearer ...` 를 주입합니다.
- 401 응답 시 refreshToken 으로 재발급 후 원래 요청을 재전송합니다.
  - `QueuedInterceptor` 라서 여러 요청이 동시에 401 을 받아도 재발급은 한 번만 하고, 나머지는 새 토큰으로 재전송합니다.
  - 재발급 API 가 401 / 403 이면 로그아웃, 그 밖의 오류(네트워크, 500 등)는 로그아웃 없이 에러만 전달합니다.
- 새 Repository 는 `dio/sample/sample_repository.dart` 를 복사해서 시작합니다.
- 모델 / Repository 수정 후 코드 생성 : `dart run build_runner build`

## 로컬 알림 (flutter_local_notifications)

- `main.dart` 에서 `LocalNotificationService.instance.init()` 으로 초기화합니다. (권한 팝업은 띄우지 않음)
- 알림을 보내기 전 `requestPermission()` 으로 권한을 요청합니다. (Android 13+ / iOS)
- `payload` 에 GoRouter 경로(`'/...'`)를 넣으면 알림 탭 시 해당 화면으로 이동합니다.
- 예약 알림은 Android 에서 inexact 모드라 수 분 늦을 수 있습니다. 정확한 시각이 필요하면 `SCHEDULE_EXACT_ALARM` 권한을 추가하세요.
- 네이티브 설정 : Android `build.gradle.kts` (desugaring), `AndroidManifest.xml` (예약 알림 receiver), iOS `AppDelegate.swift` (delegate 등록)
- 테스트 화면 : 마이 탭 → 알림 테스트

## 폴더 구조

```
common/
├── const/              # 상수값 (colors, data : 서버주소 / 토큰 key / splash 시간)
├── dio/                # Dio + Retrofit + JsonSerializable
│   ├── dio.dart        #   dioProvider, CustomInterceptor
│   ├── response/       #   ApiResponse (공통 응답 모델)
│   └── sample/         #   Retrofit Repository / JsonSerializable Model 예시
├── layout/             # DefaultLayout, LoaderOverlay (공통 레이아웃)
├── notification/       # 로컬 알림 서비스 + 알림 탭 라우팅
├── provider/route/     # go_router, router_guard_provider, app_routes
├── storage/            # SecureStorage
├── theme/              # 라이트/다크 테마
│   ├── app_colors.dart #   의미 기반 컬러 (ThemeExtension) : context.colors.xxx
│   ├── app_theme.dart  #   AppTheme.light / AppTheme.dark
│   └── theme_mode_provider.dart # 시스템/라이트/다크 전환 + 저장
├── view/               # SplashScreen, NotificationTestScreen
└── view_component/     # 공통 UI 컴포넌트 (SnackBar 등)
```
