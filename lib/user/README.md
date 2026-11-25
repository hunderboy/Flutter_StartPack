# User 도메인 설명

소셜 로그인(구글 / 애플 / 카카오 / 네이버)과 로그인 상태를 담당합니다.

## 상태 관리 구조

`userMeProvider` (StateNotifierProvider) 가 로그인 상태를 전역으로 관리합니다.

    null              → 로그아웃 상태
    UserModelLoading  → 앱 진입 중(Splash) 또는 로그인 처리 중
    UserModelError    → 로그인 실패
    UserModel         → 로그인 완료

## 현재 구현 상태

| 소셜 | 상태 |
|------|------|
| 구글 | Fake 로그인 (1초 후 더미 유저로 로그인 → Lobby 이동) |
| 애플 / 카카오 / 네이버 | 버튼만 존재 ("준비 중" 안내) |

실제 연동 시 `user_me_provider.dart` 의 각 메서드 TODO 를 채웁니다.

```
소셜 SDK 호출 → 플랫폼 토큰 획득
  → 서버에 토큰 전송 → accessToken / refreshToken 수신
  → SecureStorage 에 저장
  → state = UserModel (→ Lobby 자동 이동)
```

## 폴더 구조

```
user/
├── model/              # UserModel (sealed UserModelBase)
├── provider/           # userMeProvider
├── view/               # SocialLoginScreen
└── view_component/     # SocialLoginButton
```
