# tklaundry_app

TKLaundry 차세대 Windows 관리자 앱 (Flutter)

## 실행

```powershell
cd app/tklaundry_app
flutter run -d windows
```

## lib 구조 (Clean Architecture)

```
lib/
├── main.dart                 # 진입점
├── tklaundry_app.dart        # MaterialApp (bootstrap 위젯만)
├── core/                     # 앱 전역 인프라·설정
│   ├── constants/            # API URL, 라우트 경로
│   ├── providers/            # Riverpod (API·auth DI)
│   ├── enums/                # domain·UI 공유 enum
│   ├── errors/
│   ├── network/
│   ├── router/               # GoRouter
│   └── theme/                # 디자인 시스템 (09_디자인_시스템.md)
├── shared/                   # feature 무관 UI
│   ├── layout/               # AppShell (사이드바·TopBar)
│   └── widgets/              # TkButton, TkStatusBadge 등
└── features/                 # feature 단위
    └── {feature}/
        ├── domain/           # entity, repository interface, usecase
        ├── data/             # model, datasource, repository impl
        └── presentation/     # page, providers
```

### 계층 역할

| 폴더 | 역할 |
|------|------|
| `core/` | feature에 종속되지 않는 공통 코드 (네트워크, 테마, 라우팅, providers) |
| `shared/` | 여러 feature에서 쓰는 UI (레이아웃·위젯) |
| `features/` | 업무 단위 — domain → data → presentation 의존 방향 |

> 이전 `lib/app/` 폴더는 `core/`·`shared/`·`lib/tklaundry_app.dart`로 통합했다.

## API

기본 Base URL: `http://127.0.0.1:8080` (`core/constants/api_constants.dart`)
