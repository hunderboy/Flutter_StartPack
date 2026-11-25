# Lobby 도메인 설명

Lobby는 로그인 후 가장 먼저 진입하는 메인 화면입니다.
BottomNavigationBar 를 통해 탭을 전환하며, `IndexedStack` 으로 각 탭의 상태를 유지합니다.

## 탭 구성

| 탭 인덱스 | 화면 | 역할 |
|----------|------|------|
| 0 | HomeTab | 샘플 API 목록 (Dio + Retrofit 동작 확인) |
| 1 | SearchTab | 검색 화면 예시 |
| 2 | MyPageTab | 유저 정보 + 로그아웃 |

탭 추가/삭제는 `lobby_main_content.dart` 의 `_tabs` 목록만 수정하면 됩니다.

## 폴더 구조

```
lobby/
├── lobby_screen.dart       # 메인 로비 화면 (탭 인덱스 상태 관리)
├── view/                   # 각 탭 화면
└── view_component/         # 로비 전용 UI 컴포넌트 (본문 + BottomNavigationBar)
```
