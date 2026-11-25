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
- 401 응답 시 refreshToken 으로 재발급 후 원래 요청을 재전송하고, 실패 시 로그아웃합니다.
- 새 Repository 는 `dio/sample/sample_repository.dart` 를 복사해서 시작합니다.
- 모델 / Repository 수정 후 코드 생성 : `dart run build_runner build`

## 폴더 구조

```
common/
├── const/              # 상수값 (colors, data : 서버주소 / 토큰 key / splash 시간)
├── dio/                # Dio + Retrofit + JsonSerializable
│   ├── dio.dart        #   dioProvider, CustomInterceptor
│   ├── response/       #   ApiResponse (공통 응답 모델)
│   └── sample/         #   Retrofit Repository / JsonSerializable Model 예시
├── layout/             # DefaultLayout, LoaderOverlay (공통 레이아웃)
├── provider/route/     # go_router, router_guard_provider, app_routes
├── storage/            # SecureStorage
├── view/               # SplashScreen
└── view_component/     # 공통 UI 컴포넌트 (SnackBar 등)
```
