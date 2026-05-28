# opencode용 한국어 창작 에이전트 팩

opencode를 위한 계층형 한국어 창작 에이전트 팩입니다. **Novelist** 라우터 에이전트가 사용자의 요청을 분석하고, 원본 원고를 다루는 초고 파이프라인과 검증된 원고를 EPUB으로 빌드하는 빌드 파이프라인을 분리해 전문 서브 에이전트들에게 작업을 위임합니다.

## 에이전트

### 소설 시스템

| 에이전트 | 역할 |
|-------|------|
| `/novelist` | **라우터** — 초고 작업과 EPUB 빌드 작업을 분리해 라우팅합니다. |
| `/novelist-writer` | 소설 집필: 씬, 대사, 서사, 캐릭터 감정 묘사, 회차 초고를 작성합니다. |
| `/novelist-editor` | 소설 퇴고: 플롯 논리, 캐릭터 일관성, 문체 리듬, 템포/페이스 조절 및 피드백을 제공합니다. |
| `/novelist-researcher` | 소설 맥락 조사: 현재 장면의 관점과 설정을 기준으로 현실성, 절차, 지역/시대/기술 정보를 조사합니다. |
| `/novelist-loremaster` | 설정 기록가: 파일 내 설정 정보를 검색하여 구조화된 설정 자료 문서를 취합합니다. |
| `/novelist-otaku` | 설정 검증가: 집필된 초고가 기설정된 세계관 및 설정 가이드와 일치하는지 철저히 대조합니다. |
| `/novelist-publisher` | EPUB 빌드 에이전트: 검증이 끝난 초고를 수정 가능한 EPUB 원본으로 만들고, 시스템 zip 명령어로 `.epub` 파일을 빌드합니다. |

### 스킬

| 스킬 | 사용처 | 목적 |
|-------|---------|---------|
| `setting-collapse-detector` | 설정 기록가, 설정 검증가 | 캐릭터, 타임라인, 지리, 세계관 규칙, 소지품, 대사의 일관성 및 설정 붕괴를 체계적으로 감지하는 틀 |

## 초고 / 빌드 파이프라인

그냥 쓰고 싶은 소설, 장면, 회차, 이어쓰기, 수정 요청을 말하면 **초고 파이프라인**으로 갑니다. `/novelist`는 원본 `drafts/`를 작성, 검증, 원장/검증 목록/증거 갱신까지만 수행하고 EPUB은 만들지 않습니다.

EPUB을 만들려면 `build`, `epub build`, `EPUB로 만들어`, `출판`, `패키징`처럼 명시적인 빌드 명령을 사용합니다. 이때 **빌드 파이프라인**이 이미 검증된 초고를 읽어 `epub-src/`라는 수정 가능한 EPUB 원본을 만들거나 갱신한 뒤 `volume-N.epub`으로 패키징합니다.

EPUB 수정은 원본 기반입니다. 레이아웃, CSS, 메타데이터, 목차, 표제면, XHTML 패키징 수정은 `epub-src/`에서 처리하고 다시 빌드합니다. 문장, 사건, 캐릭터, 설정을 바꾸는 수정은 먼저 초고 파이프라인으로 돌아가 검증한 뒤 다시 빌드해야 합니다.

## 초고 피드백 루프

Novelist 라우터는 문단별/비트별로 점진적으로 원고를 쌓아 올리는 체계적인 피드백 루프를 가동합니다. 한 번에 전체 장면을 모두 작성하는 대신, 접두어 제약 구조를 사용하여 각 단위를 순차적으로 생성하고 엄격하게 검증합니다.

집필과 수정 단계는 의도적으로 순차 실행하며 병렬 실행하지 않습니다. 라우터는 작가/편집자/설정 검증가의 원고 작업을 여러 비트나 여러 수정 구간에 대해 동시에 실행하지 않습니다. 각 비트와 수정 구간은 직전 단계에서 확정된 누적 원고, 잠금 문맥, 원장 상태, 검증 결과를 반드시 받아야 하기 때문입니다.

```
  ① 설정 기록가 → 설정 데이터 및 최근 서사 상태 수집 (설정만 수집, 문체는 관여 안 함)
         │
   ② 라우터 → 사용자 요청을 순차적 장면 비트/문단 개요로 분해
         │
   ┌─────►③ 루프: 각 장면 비트에 대해:
   │      │
   │   ④ 작가 → 누적된 기검증 원고와 설정에 맞추어 다음 비트 집필
   │      │
   │   ⑤ 설정 검증가 → 새 초고의 설정 일관성 검증 및 검증 보고서 발행
   │      │
   │   ⑥ 편집자 → 항상 실행. 문장 스타일, 어투, 서식 정돈 및 설정 검증가가 제기한 오류 수정
   │      │
   │   ⑦ 설정 검증가 (최종 확인) → 편집자가 다듬은 초고 최종 검증
   │     ╱ ╲
   │  통과 / 실패 ──> ⑥ 편집자로 루프백하여 수정 및 재검증
   │    │      (또는 해결 불가 시, 루프 일시 정지 및 채팅창을 통해 협업 토론 시작)
   │    ▼
   └─── 검증된 비트를 누적 원고에 영구 병합 (모든 비트 완료 시까지 반복)
          │
          ▼
      ⑧ 완료 → 검증된 원본 초고, 원장, 검증 목록, 증거 갱신
```

### 루프 안정성 및 협업 토론
- **점진적 빌드업**: 원고의 각 문단/비트는 개별적으로 작성, 검증, 수정됩니다. 한 번 검증이 완료되어 병합되면 이는 영구적인 캐논이 되어 이후에 작성될 비트들의 절대적인 기준이 되며 변경되지 않습니다.
- **병렬 집필/수정 금지**: 작가, 편집자, 설정 검증가, 원고 수정, 원장 갱신, 검증 목록 갱신, 커밋은 순차 실행합니다. 병렬 실행은 서로 독립적인 읽기 전용 문맥 수집에만 허용됩니다.
- **중단 후 재개 가능 세션**: 긴 신규 작성, 이어쓰기, 수정, 설정 변경 이전, 빌드 작업은 `writing-session.md`에 파일 기반 체크포인트를 남기고, 검증 전 임시 작업은 `.session/` 아래에 격리합니다. 프로세스가 중단되면 `/novelist resume` 또는 이어쓰기 요청이 초고 해시, 검증 목록 행, 증거, 서사 상태 원장, 수정 잠금 문맥을 검증한 뒤 계속합니다.
- **설정 우선순위 분쟁 해결 계층**: 설정 충돌이 발생할 경우 에이전트는 다음 우선순위에 따라 자동으로 모순을 해결합니다:
  - **우선순위 1: 개별 캐릭터/인물 설정 문서** — 최상위 캐논 (예: 주인공 설정 시트).
  - **우선순위 2: 일반 세계관 및 시스템 설정 문서** — 플롯의 인과율보다 우선합니다.
  - **우선순위 3: 최근 서사 상태 및 시리즈 바이블** — 사용자의 일시적인 즉흥 프롬프트보다 우선합니다.
  - **우선순위 4: 사용자 브리프 / 일시적 프롬프트** — 가장 낮은 우선순위로, 기존 설정이나 캐논을 임의로 파괴할 수 없습니다.
- **엄격한 검증**: 루프 최대 반복 횟수 제한이나 검증 경고 우회 등의 타협 없이 100% 엄격한 설정 검증이 적용됩니다.
- **협업 토론 프로토콜**: 설정 시트 간 정면 충돌이 발생하거나 사용자가 직접 개입하여 기존 세계관 규칙을 수정하려 할 경우, 루프를 **일시 정지**하고 채팅창에 관련 설정 우선순위 정보를 제시하며 해결 방안을 묻는 토론 모드로 자동 전환됩니다.

## 설치 및 세팅

### 옵션 1: 클론 후 대화형 실행 (추천)

* **Linux / macOS (Bash)**:
  ```bash
  git clone https://github.com/bbggkkk/opencode-novelist.git
  cd opencode-novelist
  ./install.sh
  ```

* **Windows (PowerShell)**:
  ```powershell
  git clone https://github.com/bbggkkk/opencode-novelist.git
  cd opencode-novelist
  .\install.ps1
  ```

대화형 설치 스크립트는 설치 대상을 물어봅니다:
- **프로젝트 로컬 설치** — 선택한 프로젝트의 `.opencode/agents/`에 설치
- **글로벌 설치** — `~/.config/opencode/agents/`에 설치

저장소를 먼저 복제하지 않아도 대화형 설치를 실행할 수 있습니다:

* **Linux / macOS (Bash)**:
  ```bash
  sh -c "$(curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh)"
  ```

* **Windows (PowerShell)**:
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1)))
  ```

템플릿은 에이전트 탐색 경로 밖에 설치되고, 지원 스킬은 OpenCode의 스킬 탐색 경로에 설치됩니다. 프로젝트 설치는 `.opencode/novelist/templates/`와 `.opencode/skills/`, 글로벌 설치는 `~/.config/opencode/novelist/templates/`와 `~/.config/opencode/skills/`를 사용합니다. `agents/` 디렉터리 아래에 템플릿이나 스킬을 복사하지 마세요. opencode가 Markdown 지원 파일을 호출 가능한 에이전트로 노출할 수 있습니다.

### 옵션 2: 에이전트 / 스크립트용 한 줄 설치

에이전트나 자동화가 설치할 때는 비대화형 플래그를 사용합니다. 프로젝트 로컬 설치는 별도 경로를 주지 않으면 명령을 실행 중인 현재 경로에 설치합니다.

#### Linux / macOS (Bash)

* **현재 경로에 프로젝트 로컬 설치**:
  ```bash
  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- --project
  ```

* **명시한 프로젝트 경로에 로컬 설치**:
  ```bash
  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- --project /path/to/project
  ```

* **전역 경로에 설치** (`~/.config/opencode/agents/`):
  ```bash
  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- --global
  ```

#### Windows (PowerShell)

* **현재 경로에 프로젝트 로컬 설치**:
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1))) --project
  ```

* **명시한 프로젝트 경로에 로컬 설치**:
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1))) --project C:\path\to\project
  ```

* **전역 경로에 설치** (`~/.config/opencode/agents/`):
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1))) --global
  ```

기존 호환 별칭도 유지됩니다: `./install.sh 1 [project-dir]`, `./install.sh 2`, `.\install.ps1 1 [project-dir]`, `.\install.ps1 2`.

### 옵션 3: 수동 복사 설치

```bash
# 글로벌 설치
mkdir -p ~/.config/opencode/agents
mkdir -p ~/.config/opencode/novelist/templates
mkdir -p ~/.config/opencode/skills
cp -r agents/* ~/.config/opencode/agents/
cp -r templates/* ~/.config/opencode/novelist/templates/
cp -r skills/* ~/.config/opencode/skills/

# 프로젝트 로컬 설치
mkdir -p .opencode/agents
mkdir -p .opencode/novelist/templates
mkdir -p .opencode/skills
cp -r agents/* .opencode/agents/
cp -r templates/* .opencode/novelist/templates/
cp -r skills/* .opencode/skills/
```

설치를 완료한 후 반영을 위해 opencode 세션을 재시작해 주세요:

```bash
exit  # 또는 Ctrl+D를 입력해 세션을 종료한 후 opencode 재시작
```

## 3단계 계층 구조 (프랜차이즈, 작품, 권) 레이아웃

대규모 공유 세계관(프랜차이즈), 다권 분량의 시리즈물, 혹은 지금은 한 작품뿐이지만 나중에 작품이 늘어날 수 있는 경우까지 모두 지원하기 위해, 프로젝트는 항상 동일한 3단계 디렉토리 레이아웃을 사용합니다.

1. **프랜차이즈 레벨**: 프로젝트의 최상위 루트 디렉토리입니다. 전역 `settings/` 폴더(전체 시리즈가 공유하는 공통 세계관 설정, 인물, 물리 법칙 등)를 가집니다.
2. **작품 레벨**: 특정 시리즈물 또는 독립 작품을 나타내는 하위 폴더입니다(예: `work-a/`). 개별 작품 단위의 시리즈 바이블(`series-bible.md`) 및 작품 전용 로컬 `settings/` 폴더(해당 작품 전용 등장인물, 설정 덮어쓰기)를 포함합니다.
3. **권 레벨**: 작품 하위의 개별 책 단위 폴더입니다(예: `work-a/volume-1/`). 해당 권의 개요(`outline.md`) 및 문단별 초고 원고(`drafts/`)가 저장됩니다.

### 1. 공유 세계관 다작품 구조
```text
[project-root]/               # === 1단계: 프랜차이즈 레벨 ===
├── settings/                # 프랜차이즈 공통 설정 (전역 세계관 로어)
│   ├── magic-system.md
│   └── characters/
│       └── legendary-hero.md
│
├── [work-a]/                # === 2단계: 작품 A ===
│   ├── series-bible.md      # 작품 A 시리즈 바이블
│   ├── settings/            # 작품 A 전용 설정 (로컬 캐릭터/아이템)
│   │
│   ├── volume-1/            # === 3단계: 작품 A의 1권 ===
│   │   ├── outline.md       # 1권 아웃라인 및 비트
│   │   ├── drafts/          # 1권 문단/챕터 드래프트
│   │   ├── epub-src/        # 빌드가 생성하는 수정 가능한 EPUB 원본
│   │   └── volume-1.epub    # 빌드된 EPUB 산출물
│   └── volume-2/            # 3단계: 작품 A의 2권
│
└── [work-b]/                # === 2단계: 작품 B ===
    ├── series-bible.md
    └── volume-1/            # === 3단계: 작품 B의 1권 ===
```

### 2. 한 작품 프랜차이즈 구조
현재 작품이 하나뿐이어도 다작품 프랜차이즈와 같은 구조를 유지합니다. 프로젝트 루트는 언제나 프랜차이즈 레벨이고, 작품은 별도 하위 폴더를 가져야 나중에 다른 작품을 추가해도 마이그레이션이 필요 없습니다:
```text
[project-root]/               # === 1단계: 프랜차이즈 레벨 ===
├── settings/                # 선택 사항: 나중에 여러 작품이 공유할 전역 설정
│
└── [first-work]/            # === 2단계: 작품 레벨 ===
    ├── series-bible.md
    ├── settings/
    ├── volume-1/            # === 3단계: 권 레벨 ===
    │   ├── outline.md
    │   └── drafts/
    └── volume-2/
```

루트 바로 아래의 `series-bible.md`는 프로덕션 레이아웃으로 인정하지 않습니다. `[project-root]/[work-slug]/series-bible.md`처럼 작품 폴더 안으로 옮겨야 합니다.

### 시리즈 바이블 및 스타일 가이드
`series-bible.md` 파일은 연대기, 이전 권수 줄거리 요약, 캐릭터 상태 진화 로그(예: 권별 나이 변화, 부상 내역, 인물 관계 변화), 그리고 이 작품의 미해결 플롯 스레드를 기록 관리합니다. 

**작품 레벨 문체 가이드**: 소설의 문장 스타일(어투, 톤앤매너, 금지/권장 어휘, 넓은 창작 참고 특성 등)은 개별 작품 폴더 내의 `[Active Work Path]settings/style-guide.md` 파일 또는 시리즈 바이블의 `## Style Guide` 섹션에 선언되어 중앙 관리됩니다. 라우터 에이전트 `@novelist`는 이 설정을 자동으로 상속하여 다른 서브 에이전트(작가, 편집자)에게 전파하므로, 매번 명령어를 보낼 때마다 문체를 지정하지 않아도 해당 작품에 소속된 모든 권수와 문단은 **항상 일관된 톤앤매너와 어조로 집필 및 퇴고**됩니다.

문체가 명시되지 않은 경우 기본값은 **우아하고 절제된, 유명하고 경력 있는 전문 소설가의 문장**입니다. 이 기본 문체는 정확한 이미지, 자연스러운 한국어 호흡, 감정의 과잉 설명 배제, 장면 속 행동과 침묵으로 감정을 드러내는 방식을 우선합니다.

`settings/style-guide.md`에는 작품 전체의 문체 계약과 캐릭터 음성표가 저장됩니다. 서술 모드 잠금은 인칭, 시제, 시점 기준점, 시점 이동 규칙을 기록해 장면 압력이 커져도 화자와 시점이 조용히 바뀌지 않게 합니다. 캐릭터 음성표는 인물별 말투, 존댓말/반말 경계, 금지 어휘, 습관적 표현, 침묵 패턴, 감정이 흔들릴 때의 행동 단서를 기록합니다. 작가와 편집자는 이를 문체 유지 기준으로 사용하고, 설정 검증가는 캐릭터 붕괴 검증 기준으로 사용합니다.

각 권 폴더의 `narrative-state.md`는 현재 시점, 누적 검증 원고 요약, 인물 위치, 부상, 소지품, 장소/세계관 캐논 참조, 소지품 캐논 참조, 감정 상태, 관계 변화, 미해결 훅을 기록하는 연속성 원장입니다. 검증을 통과한 비트가 병합될 때마다 이 원장을 갱신하여 다음 비트에서 설정 붕괴가 일어나지 않게 합니다.

각 권 폴더의 `writing-session.md`는 중단된 작업을 재시작하기 위한 체크포인트입니다. 작업 유형(`NEW_DRAFT`, `CONTINUATION`, `REVISION`, `SETTING_CHANGE_MIGRATION`, `BUILD`, `VERIFY_ONLY`), 대상 초고, 현재 단위, 다음 행동, 마지막 최종 통과 비트/구간, 초고/캐논 해시, 검증 목록 행, 증거 경로, 서사 상태 원장 갱신 내용, Git 커밋, 수정 요청의 잠긴 문맥 해시를 기록합니다. 검증 전 임시 작업은 최종 설정 검증가 통과 전까지 `.session/current-work.md`에만 둡니다.

각 권 폴더의 `verification-manifest.md`는 템플릿의 정확한 열 순서를 유지하며 각 초고를 정확히 한 번씩 `Draft SHA256`, `Canon Snapshot SHA256`, 최종 설정 검증 통과, 편집자 문체 표류 감사 통과, 편집자 캐릭터 음성 감사 통과, 원장 갱신 요약, 승인된 미확정 사항, 그리고 연결된 검증 증거 보고서로 기록합니다. 출판 에이전트는 검증 목록 스키마가 온전하고, 패키징 대상 초고가 실제 파일로 존재하고, 기록된 `Draft SHA256`과 일치하고, 캐논 묶음이 기록된 `Canon Snapshot SHA256`과 일치하며, 검증 목록에 `Final Otaku Verdict: PASS`, `Style Drift Audit: PASS`, `Character Voice Audit: PASS`가 기록되어 있고, 승인된 미확정 사항이 `None`이거나 `narrative-state.md`의 열린 훅에 계속 추적되고, 증거 보고서가 같은 증명 필드를 반복하고, 연속성/설정 변경 안전/문체/기본 문장/캐릭터 음성 점검표가 모두 통과이며, 설정 변경 승인이 `None`이거나 사용자 승인 근거와 영향 캐논 증명을 담은 승인된 `retcons/*.md` 제안서를 가리키고, 증거 기준점 표가 모든 점검 항목을 안전한 원본 경로와 실제 원본 파일 안에 존재하는 증거 문구에 연결하고, 원장 갱신 기준점이 지속 원장 사실을 검증 목록 요약과 `narrative-state.md` 양쪽 문구에 연결하고, 보고서 안에 실패, 대기, 미검증 판정이 없어야 EPUB를 만들 수 있습니다.

새 작품을 시작할 때 사용할 수 있는 `style-guide.md`, `character-sheet.md`, `item-sheet.md`, `location-sheet.md`, `world-rule-sheet.md`, `series-bible.md`, `narrative-state.md`, `writing-session.md`, `verification-manifest.md`, `verification-evidence.md`, `retcon-proposal.md` 기본 스캐폴드는 `templates/` 폴더에 포함되어 있습니다.

프로덕션 집필 전에는 `scripts/validate-production-artifacts.sh [work-path] [volume-path]`를 실행하거나 라우터의 산출물 사전 점검 관문이 같은 검사를 수행해야 합니다. 이 관문은 작가가 초안을 쓰기 전에 `TBD` 자리표시자, 빈 문체 계약 항목, 누락된 필수 문체 기준점, 누락된 금지 문체 표류, 누락된 문체 검증 질문, 누락된 인칭, 누락된 시제, 누락된 시점 기준점, 누락된 시점 이동 규칙, 산출물 표 스키마 표류, 누락된 시리즈 바이블 연대기 원본 파일, 누락된 연대기 증거 문구, 누락된 캐릭터 음성 행, 누락된 캐릭터 설정 파일, 음성표와 캐릭터 시트 불일치, 누락된 캐릭터 지식 경계, 누락된 금지 표류 안전장치, 누락된 활성 상태 기준점, `narrative-state.md`에 존재하지 않는 활성 상태 기준점, 음성표와 캐릭터 시트에 연결되지 않은 서사 상태 원장의 활성 캐릭터 또는 시리즈 바이블 진화 캐릭터, 장소/세계관 캐논 참조가 없는 활성 장소/세계 규칙 훅, 누락된 장소/세계관 설정 파일, 누락된 장소 활성 제약, 누락된 세계 규칙 진술, 소지품 캐논 참조가 없는 추적 대상 소지품, 누락된 물품 설정 파일, 물품 보유자 불일치, 누락된 물품 제한, 약한 서사 상태 원장을 차단합니다.

## 사용 예시

### Novelist 라우터

```text
/novelist 다크 판타지 1장 오프닝 씬 써줘
  → ①설정 기록가 → ②작가 → ③설정 검증가 → ④편집자 → ⑤설정 검증가 최종 확인 → ⑥완료

/novelist 이 씬의 전개 속도가 너무 느린데 수정해 줘
  → @novelist-editor → @novelist-otaku 검증

/novelist 이 장면의 응급실 절차가 현실적으로 맞는지 조사해 줘
  → @novelist-researcher
```

### 개별 에이전트 직접 호출

```text
/novelist-writer 현대 판타지 3장 오프닝 씬 써줘.
/novelist-editor 캐릭터 행동과 플롯 일관성에 맞춰서 이 챕터를 교정해 줘.
/novelist-loremaster 주인공 캐릭터에 관한 모든 설정을 모아줘.
/novelist-otaku 기설정된 세계관과 비교해서 이 드래프트 원고를 검증해 줘.
```

`novelist-writer`와 `novelist-editor`를 직접 호출한 결과는 임시 산출물입니다. 출력에는 반드시 `UNVERIFIED DRAFT` 또는 `UNVERIFIED REVISION` 상태가 표시되어야 하며, 라우터가 최종 `@novelist-otaku` 검증을 통과시키고 `verification-manifest.md`에 통과를 기록하기 전까지는 정식 원고, 출판 가능 원고, 적용 가능한 수정본으로 취급하지 않습니다.

## 언어, 문화 및 창작 프로필 설정 방침

에이전트는 사용자가 요청한 언어와 스타일에 엄격히 맞추어 글을 작성합니다.

1. **사전 정보 수집**: 문체/스타일, 분위기, 타깃 언어, 문화적 배경 등 핵심 매개변수가 누락되었거나 명확하지 않은 경우, 라우터 에이전트(`/novelist`)는 집필 시작 전에 사용자에게 단 한 번 질문하여 창작 프로필을 일치시킵니다.
2. **단일 프로필 준수**: 수집된 매개변수들은 하나의 **창작 프로필**로 통합 관리되며, 라우터는 집필, 검토, 퇴고, 설정 검증의 전 과정에 참여하는 모든 서브 에이전트에게 이 프로필을 전파하여 일관된 어조와 감성을 유지합니다.
3. **기본 언어 설정**: 명시적인 지정이 없는 한, 기본 집필 언어는 **한국어**입니다.
4. **문화적 맥락 추론**: 타깃 언어에 맞는 적절한 문화적 감성을 추론하여 적용하며, 모호할 경우 사용자에게 피드백을 구합니다.
5. **한국어 맞춤 창작**: 한국어로 작성할 경우, 한국어 고유의 자연스러운 문장 호흡과 어조, 실감 나는 한국어 대사 스타일, 장르별 클리셰 배제 등을 최우선으로 반영합니다.

## 문체 및 원본성 방침

에이전트 팩은 유연하고 강력한 문체 지정을 지원합니다. 사용자는 다음과 같이 두 가지 방식으로 소설의 문체를 지정할 수 있습니다:
1. **직접 서술**: 문장 특징을 구체적으로 설명합니다 (예: "건조하고 간결한 하드보일드 문체, 짧은 호흡").
2. **특정 작가/인물 참조**: 특정 작가나 인물을 창작 특성의 참고점으로 제시할 수 있지만, 에이전트는 이를 넓은 특성으로만 변환합니다 (예: "도시적 고독감, 낮은 은유 밀도, 느린 관찰 리듬", "빠른 장면 전환, 건조한 유머, 현대적 대사 감각").

집필(`novelist-writer`) 및 퇴고(`novelist-editor`) 에이전트는 지정된 스타일의 특징(문장 구조, 어휘 선택 경향, 템포, 대사 질감, 정서 온도)을 분석하되, 생존 작가의 문장을 직접 모방하지 않고 폭넓은 창작 특성으로 변환하여 독자적인 문장으로 반영합니다.

올바른 요청 예시:
```text
조용한 초현실적 고독감, 절제된 이미지, 느린 리듬으로 어두운 도시 판타지 Chapter 1 오프닝 씬을 작성해 줘.
건조하고 간결한 하드보일드 문체로 다음 문단을 작성해 줘.
```

## 예시 파일

프로젝트 루트의 `examples/` 폴더 내에 수록된 파일들을 참고하세요:
- `examples/novel-brief.md`
- `examples/revision-request.md`
- `examples/production-continuity-scenario.md`
- `examples/style-character-drift-scenario.md`
- `examples/sample-work/` — 설정, 문체 가이드, 시리즈 바이블, 연속성 원장, 초고를 포함한 전체 샘플 작품 구조

## 수정 및 설정 변경 안전장치

기존 원고 수정 요청은 보호된 수정 루프를 사용합니다. `@novelist-loremaster`가 설정과 문체 문맥을 먼저 로드하고, `@novelist-editor`는 승인된 수정 가능 구간만 수정하며, `@novelist-otaku`가 잠긴 앞뒤 문맥과 비교해 통과를 내기 전까지 파일에 변경을 적용하지 않습니다.

기존 설정, 캐릭터 특성, 관계, 문체 계약, 과거 사건을 바꾸는 요청은 설정 변경 요청으로 처리됩니다. 라우터는 변경 유형을 분류하고 영향 파일을 스캔하며, 1/2/3순위 캐논과 충돌하면 사용자 승인 없이 조용히 설정을 변경하지 않고 협업 토론으로 멈춥니다. 승인된 이전 작업은 `templates/retcon-proposal.md`에서 만든 `retcons/*.md`에 기록하고, 영향을 받은 검증 증거 보고서는 그 승인된 설정 변경 승인 파일을 연결해야 합니다.

집필 중 새로 등장한 지속 설정 사실은 자동 거절하지 않고 캐논 확장 검토로 처리합니다. 라우터는 작품을 풍부하게 만드는 일관된 추가 설정을 수락하는 쪽을 우선하되, 먼저 새 설정 자체의 내부 모순을 확인하고 이전 초고와 캐논 전체의 충돌 가능성을 스캔한 뒤, 설정 파일에 기록하거나 사용자 승인 이전을 요청하거나 해당 비트를 다시 쓰게 합니다.

출판은 `verification-manifest.md`로 차단됩니다. 누락, 검증 목록 중복, 오래된 검증 목록 항목, 초고 해시 불일치, 캐논 해시 불일치, 대기, 실패, 미검증, 문체 표류, 캐릭터 어투 표류, 하드코딩된 들여쓰기, 충돌 표식, 원시 HTML 오염, 캐릭터 음성표 금지 표현 포함, 문체 가이드 금지 문구 포함 상태의 초고는 EPUB로 패키징할 수 없습니다.

## 검증

변경사항을 배포하기 전 전체 검증을 실행하세요:

```bash
make validate
```

또는:

```bash
scripts/validate-all.sh
```

프로덕션 불변조건만 따로 확인하려면 다음을 실행하세요:

```bash
scripts/validate-production-invariants.sh
```

전체 검증은 에이전트 앞부분 설정, 프롬프트 불변조건, 템플릿, 설치 동작, 연속성 시나리오, 샘플 작품 고정 자료를 함께 확인합니다.

연속성 고정 자료만 따로 확인하려면 다음을 실행하세요:

```bash
scripts/validate-continuity-scenario.sh
```

문체 및 캐릭터 표류 고정 자료만 따로 확인하려면 다음을 실행하세요:

```bash
scripts/validate-style-character-drift-scenario.sh
```

전체 샘플 작품 고정 자료를 확인하려면 다음을 실행하세요:

```bash
scripts/validate-sample-work.sh
```

프로덕션 산출물 사전 점검만 확인하려면 다음을 실행하세요:

```bash
scripts/validate-production-artifacts.sh examples/sample-work volume-1
```

특정 권의 검증 목록만 확인하려면 다음을 실행하세요:

```bash
scripts/validate-verification-manifest.sh examples/sample-work/volume-1
```

전체 검증은 검증 목록 부정 테스트도 실행하여 누락된 초고 항목, `PENDING` 판정, 자리표시자 원장 요약, 자리표시자 또는 추적되지 않는 승인된 미확정 사항, 검증 목록에 없는 추가 초고, 누락되거나 불일치하는 검증 증거 보고서, 누락된 증거 기준점, 누락된 원장 갱신 기준점, 안전하지 않은 기준점 경로, 원본 파일에 존재하지 않는 기준점 문구를 실제로 거부하는지 확인합니다.

동일한 검증 묶음은 푸시 및 풀 리퀘스트에서 실행되도록 `.github/workflows/validate.yml`에 연결되어 있습니다. 지속적 통합은 Windows PowerShell 설치 스모크 테스트도 실행하여 `install.ps1`이 에이전트, 스킬, 템플릿을 설치하는지 확인합니다.

요구사항별 릴리스 감사는 `docs/production-readiness-audit.md`를 참고하세요.

## 라이선스

MIT
