# API 규약 — 차세대 전환(TKLaundry Next)

> 목적: “앱 ↔ API” 계약을 고정해서 병행 운영 중에도 변경이 혼란을 만들지 않게 한다.

---

## 1. 기본 규칙

- Base path: `/api`
- Content-Type: `application/json; charset=utf-8`
- 인증: 초기에는 단순화(필요 시 `Authorization` 도입)
- 응답은 항상 UTF-8

---

## 2. 공통 헤더/트레이싱

- 요청 헤더(선택):
  - `X-Request-Id`: 클라이언트에서 생성 가능(없으면 서버 생성)
- 응답 헤더(권장):
  - `X-Request-Id`: 최종 traceId 반환

---

## 3. 표준 오류 응답(필수)

### 3.1 형식

```json
{
  "code": "STRING_ENUM",
  "message": "사용자에게 보여줄 수 있는 메시지",
  "traceId": "요청 식별자",
  "details": {
    "optional": "디버그용 추가 정보(운영에서 제한 가능)"
  }
}
```

### 3.2 코드 예시

- `VALIDATION_ERROR`
- `NOT_FOUND`
- `CONFLICT`
- `DB_ERROR`
- `INTERNAL_ERROR`

---

## 4. 엔드포인트(최소 스캐폴딩)

### 4.1 로그인

- `POST /api/auth/login`
- Request JSON:

```json
{ "userId": "문자열", "password": "문자열" }
```

- 200 응답:

```json
{ "userId": "...", "userName": "..." }
```

- 실패: `401`, 표준 오류 본문(`code`: `UNAUTHORIZED`).

### 4.2 Health(선택)

- `GET /api/health` — 필요 시 별도 추가

---

## 5. P0 예시 엔드포인트(초안)

> 실제 필드/테이블 매핑은 `05_DB_병행_및_마이그레이션.md`에서 확정한다.

### 5.1 접수 목록 조회(초안)

- `GET /api/orders`
- Query(예):
  - `from` / `to` (YYYY-MM-DD)
  - `status` (enum)
  - `q` (전화/고객명 부분검색)

응답(예):

```json
{
  "items": [
    {
      "id": 123,
      "receivedAt": "2026-04-27T10:15:00+09:00",
      "customerName": "홍길동",
      "phone": "010-****-1234",
      "status": "RECEIVED",
      "totalAmount": 12000
    }
  ],
  "total": 1
}
```

### 5.2 접수 상세 조회(초안)

- `GET /api/orders/{id}`

### 5.3 상태 변경 1개(초안)

- `POST /api/orders/{id}/complete` (또는 `/release` 등 1개로 시작)
- 충돌 방지(권장):
  - 요청에 `expectedStatus` 포함 또는
  - 서버에서 현재 상태 확인 후 불일치면 409 반환

---

## 6. 버전/호환성

- 초기에는 v1만 유지하고, **깨지는 변경은 금지**
- 꼭 필요하면:
  - (선택) `/api/v1` 도입
  - 또는 필드 추가는 허용(삭제/타입변경은 금지)

