# opencode용 한국어 창작 에이전트 팩 (Korean Creative Agents for opencode)

opencode를 위한 계층형 한국어 창작 에이전트 팩입니다. **Novelist**(소설가) 라우터 에이전트가 사용자의 요청을 분석하고, 원본 원고를 다루는 Draft Pipeline과 검증된 원고를 EPUB으로 빌드하는 Build Pipeline을 분리해 전문 서브 에이전트들에게 작업을 위임합니다.

## 에이전트 (Agents)

### 소설 시스템 (Novelist System)

| 에이전트 | 역할 |
|-------|------|
| `/novelist` | **라우터 (Router)** — draft 작업과 EPUB build 작업을 분리해 라우팅합니다. |
| `/novelist-writer` | 소설 집필: 씬, 대사, 서사, 캐릭터 감정 묘사, 회차 초고를 작성합니다. |
| `/novelist-editor` | 소설 퇴고: 플롯 논리, 캐릭터 일관성, 문체 리듬, 템포/페이스 조절 및 피드백을 제공합니다. |
| `/novelist-researcher` | 연구 및 LaTeX 논문 작성: 실험 데이터 분석 및 학술적 글쓰기를 담당합니다. |
| `/novelist-loremaster` | 설정 기록가: 파일 내 설정 정보를 검색하여 구조화된 설정 자료 문서를 취합합니다. |
| `/novelist-otaku` | 설정 검증가: 집필된 초고가 기설정된 세계관 및 설정 가이드와 일치하는지 철저히 대조합니다. |
| `/novelist-publisher` | EPUB 빌드 에이전트: 검증이 끝난 드래프트를 수정 가능한 EPUB source로 만들고, 시스템 zip 명령어로 `.epub` 파일을 빌드합니다. |

### 스킬 (Skill - 에이전트와 함께 설치됨)

| 스킬 | 사용처 | 목적 |
|-------|---------|---------|
| `setting-collapse-detector` | Loremaster, Otaku | 캐릭터, 타임라인, 지리, 세계관 규칙, 소지품, 대사의 일관성 및 설정 붕괴를 체계적으로 감지하는 프레임워크 |

## Draft / Build 파이프라인

그냥 쓰고 싶은 소설, 장면, 회차, 이어쓰기, 수정 요청을 말하면 **Draft Pipeline**으로 갑니다. `/novelist`는 원본 `drafts/`를 작성, 검증, 원장/manifest/evidence 갱신까지만 수행하고 EPUB은 만들지 않습니다.

EPUB을 만들려면 `build`, `epub build`, `EPUB로 만들어`, `출판`, `패키징`처럼 명시적인 build 명령을 사용합니다. 이때 **Build Pipeline**이 이미 검증된 draft를 읽어 `epub-src/`라는 수정 가능한 EPUB source를 만들거나 갱신한 뒤 `volume-N.epub`으로 패키징합니다.

EPUB 수정은 source 기반입니다. 레이아웃, CSS, metadata, 목차, title page, XHTML packaging 수정은 `epub-src/`에서 처리하고 재빌드합니다. 문장, 사건, 캐릭터, 설정을 바꾸는 수정은 먼저 Draft Pipeline으로 돌아가 검증한 뒤 다시 build해야 합니다.

## Draft 피드백 루프 (Draft Feedback Loop)

Novelist 라우터는 문단별/비트별로 점진적으로 원고를 쌓아 올리는 체계적인 피드백 루프를 가동합니다. 한 번에 전체 씬을 모두 작성하는 대신, 접두어 제약 구조(prefix-constrained architecture)를 사용하여 각 세그먼트를 순차적으로 생성하고 엄격하게 검증합니다.

```
  ① Loremaster → 설정 데이터 및 최근 서사 상태 수집 (설정만 수집, 문체는 관여 안 함)
         │
   ② Router → 사용자 브리프를 순차적 씬 비트/문단 아웃라인으로 분해
         │
   ┌─────►③ 루프: 각 씬 비트(Scene-Beat)에 대해:
   │      │
   │   ④ Writer → 누적된 기검증 원고(Prefix)와 설정에 맞추어 다음 비트 집필
   │      │
   │   ⑤ Otaku → 새 드래프트의 설정 일관성 검증 및 검증 보고서 발행
   │      │
   │   ⑥ Editor → 항상 실행. 문장 스타일, 어투, 서식 정돈 및 Otaku가 제기한 설정 오류 수정
   │      │
   │   ⑦ Otaku (최종 확인) → Editor가 다듬은 드래프트 최종 검증
   │     ╱ ╲
   │  통과(PASS) 실패(FAIL) ──> ⑥ Editor로 루프백하여 수정 및 재검증
   │    │      (또는 해결 불가 시, 루프 일시 정지 및 채팅창을 통해 협업 토론 시작)
   │    ▼
   └─── 검증된 비트를 누적 원고(Prefix)에 영구 병합 (모든 비트 완료 시까지 반복)
          │
          ▼
      ⑧ 완료 → 검증된 원본 draft, 원장, manifest, evidence 갱신
```

### 루프 안정성 및 협업 토론 (Loop Safety & Collaborative Discussion)
- **점진적 빌드업(Step-by-Step Buildup)**: 원고의 각 문단/비트는 개별적으로 작성, 검증, 수정됩니다. 한 번 검증이 완료되어 병합되면 이는 영구적인 캐논(Prefix Context)이 되어 이후에 작성될 비트들의 절대적인 기준이 되며 변경되지 않습니다.
- **설정 우선순위 분쟁 해결 계층**: 설정 충돌이 발생할 경우 에이전트는 다음 우선순위에 따라 자동으로 모순을 해결합니다:
  - **우선순위 1: 개별 캐릭터/인물 설정 문서** — 최상위 캐논 (예: 주인공 설정 시트).
  - **우선순위 2: 일반 세계관 및 시스템 설정 문서** — 플롯의 인과율보다 우선합니다.
  - **우선순위 3: 최근 서사 상태 및 시리즈 바이블** — 사용자의 일시적인 즉흥 프롬프트보다 우선합니다.
  - **우선순위 4: 사용자 브리프 / 일시적 프롬프트** — 가장 낮은 우선순위로, 기존 설정이나 캐논을 임의로 파괴할 수 없습니다.
- **엄격한 검증**: 루프 최대 반복 횟수 제한이나 검증 경고 우회 등의 타협 없이 100% 엄격한 설정 검증이 적용됩니다.
- **협업 토론 프로토콜(Collaborative Discussion Protocol)**: 설정 시트 간 정면 충돌이 발생하거나 사용자가 직접 개입하여 기존 세계관 규칙을 수정하려 할 경우, 루프를 **일시 정지(Halt)**하고 채팅창에 관련 설정 우선순위 정보(Priority 1, 2, 3)를 제시하며 해결 방안을 묻는 토론 모드로 자동 전환됩니다.

## 설치 및 세팅 (Install & Setup)

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

설치 대상 선택 프롬프트가 표시됩니다:
- **`1`** — 현재 프로젝트에 설치 (`.opencode/agents/`)
- **`2`** — 글로벌 설치 (`~/.config/opencode/agents/`)

템플릿과 지원 skill은 agent discovery 밖에 설치됩니다. 프로젝트 설치는 `.opencode/novelist/templates/`와 `.opencode/novelist/skills/`, 글로벌 설치는 `~/.config/opencode/novelist/templates/`와 `~/.config/opencode/novelist/skills/`를 사용합니다. `agents/` 디렉터리 아래에 템플릿이나 skill을 복사하지 마세요. opencode가 Markdown 지원 파일을 호출 가능한 에이전트로 노출할 수 있습니다.

### 옵션 2: 한 줄 명령어로 자동 설치 (인자 전달)

#### Linux / macOS (Bash)

* **현재 프로젝트 경로에 설치** (`.opencode/agents/`):
  ```bash
  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- 1
  ```

* **글로벌 경로에 설치** (`~/.config/opencode/agents/`):
  ```bash
  curl -sSL https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.sh | sh -s -- 2
  ```

#### Windows (PowerShell)

* **현재 프로젝트 경로에 설치** (`.opencode/agents/`):
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1))) 1
  ```

* **글로벌 경로에 설치** (`~/.config/opencode/agents/`):
  ```powershell
  & ([scriptblock]::Create((irm https://raw.githubusercontent.com/bbggkkk/opencode-novelist/master/install.ps1))) 2
  ```

### 옵션 3: 수동 복사 설치

```bash
# 글로벌 설치
mkdir -p ~/.config/opencode/agents
mkdir -p ~/.config/opencode/novelist/templates
mkdir -p ~/.config/opencode/novelist/skills
cp -r agents/* ~/.config/opencode/agents/
cp -r templates/* ~/.config/opencode/novelist/templates/
cp -r skills/* ~/.config/opencode/novelist/skills/

# 프로젝트 로컬 설치
mkdir -p .opencode/agents
mkdir -p .opencode/novelist/templates
mkdir -p .opencode/novelist/skills
cp -r agents/* .opencode/agents/
cp -r templates/* .opencode/novelist/templates/
cp -r skills/* .opencode/novelist/skills/
```

설치를 완료한 후 반영을 위해 opencode 세션을 재시작해 주세요:

```bash
exit  # 또는 Ctrl+D를 입력해 세션을 종료한 후 opencode 재시작
```

## 3단계 계층 구조 (프랜차이즈, 작품, 권) 레이아웃

대규모 공유 세계관(프랜차이즈), 다권 분량의 시리즈물, 혹은 지금은 한 작품뿐이지만 나중에 작품이 늘어날 수 있는 경우까지 모두 지원하기 위해, 프로젝트는 항상 동일한 3단계 디렉토리 레이아웃을 사용합니다.

1. **프랜차이즈 레벨 (Franchise Level)**: 프로젝트의 최상위 루트 디렉토리. 전역 `settings/` 폴더(전체 시리즈가 공유하는 공통 세계관 로어, 인물, 물리 법칙 등)를 가집니다.
2. **작품 레벨 (Work Level)**: 특정 시리즈물 또는 독립 작품을 나타내는 하위 폴더 (예: `work-a/`). 개별 작품 단위의 시리즈 바이블(`series-bible.md`) 및 작품 전용 로컬 `settings/` 폴더(해당 작품 전용 등장인물, 설정 덮어쓰기)를 포함합니다.
3. **권 레벨 (Volume Level)**: 작품 하위의 개별 책 단위 폴더 (예: `work-a/volume-1/`). 해당 권의 아웃라인(`outline.md`) 및 문단별 드래프트 원고(`drafts/`)가 저장됩니다.

### 1. 공유 세계관 다작품 구조 (Shared Universe Franchise Layout)
```text
[project-root]/               # === 1단계: 프랜차이즈 레벨 (Franchise) ===
├── settings/                # 프랜차이즈 공통 설정 (전역 세계관 로어)
│   ├── magic-system.md
│   └── characters/
│       └── legendary-hero.md
│
├── [work-a]/                # === 2단계: 작품 레벨 (Work A) ===
│   ├── series-bible.md      # 작품 A 시리즈 바이블
│   ├── settings/            # 작품 A 전용 설정 (로컬 캐릭터/아이템)
│   │
│   ├── volume-1/            # === 3단계: 권 레벨 (Volume 1 of Work A) ===
│   │   ├── outline.md       # 1권 아웃라인 및 비트
│   │   ├── drafts/          # 1권 문단/챕터 드래프트
│   │   ├── epub-src/        # build가 생성하는 수정 가능한 EPUB source
│   │   └── volume-1.epub    # 빌드된 EPUB 산출물
│   └── volume-2/            # 3단계: 권 레벨 (Volume 2 of Work A)
│
└── [work-b]/                # === 2단계: 작품 레벨 (Work B) ===
    ├── series-bible.md
    └── volume-1/            # === 3단계: 권 레벨 (Volume 1 of Work B) ===
```

### 2. 한 작품 프랜차이즈 구조 (Single Work Franchise Layout)
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

### 시리즈 바이블 및 스타일 가이드 (`series-bible.md` & `settings/style-guide.md`)
`series-bible.md` 파일은 연대기, 이전 권수 줄거리 요약, 캐릭터 상태 진화 로그(예: 권별 나이 변화, 부상 내역, 인물 관계 변화), 그리고 이 작품의 미해결 플롯 스레드를 기록 관리합니다. 

**작품 레벨 문체 가이드 (Style Guide)**: 소설의 문장 스타일(어투, 톤앤매너, 금지/권장 어휘, 넓은 창작 참고 특성 등)은 개별 작품 폴더 내의 `[Active Work Path]settings/style-guide.md` 파일 또는 시리즈 바이블의 `## Style Guide` 섹션에 선언되어 중앙 관리됩니다. 라우터 에이전트 `@novelist`는 이 설정을 자동으로 상속하여 다른 서브 에이전트(Writer, Editor)에게 전파하므로, 매번 명령어를 보낼 때마다 문체를 지정하지 않아도 해당 작품에 소속된 모든 권수와 문단은 **항상 일관된 톤앤매너와 어조로 집필 및 퇴고**됩니다.

문체가 명시되지 않은 경우 기본값은 **우아하고 절제된, 유명하고 경력 있는 전문 소설가의 문장**입니다. 이 기본 문체는 정확한 이미지, 자연스러운 한국어 호흡, 감정의 과잉 설명 배제, 장면 속 행동과 침묵으로 감정을 드러내는 방식을 우선합니다.

`settings/style-guide.md`에는 작품 전체의 Style Contract와 Character Voice Matrix가 저장됩니다. Narrative mode lock은 POV person, tense, viewpoint anchor, head-hopping rule을 기록해 장면 압력이 커져도 화자와 시점이 조용히 바뀌지 않게 합니다. Character Voice Matrix는 인물별 말투, 존댓말/반말 경계, 금지 어휘, 습관적 표현, 침묵 패턴, 감정이 흔들릴 때의 행동 단서를 기록합니다. Writer와 Editor는 이를 문체 유지 기준으로 사용하고, Otaku는 캐릭터 붕괴 검증 기준으로 사용합니다.

각 권 폴더의 `narrative-state.md`는 현재 시점, 누적 검증 원고 요약, 인물 위치, 부상, 소지품, Location / World Canon References, Inventory Canon References, 감정 상태, 관계 변화, 미해결 훅을 기록하는 연속성 원장입니다. 검증을 통과한 비트가 병합될 때마다 이 원장을 갱신하여 다음 비트에서 설정 붕괴가 일어나지 않게 합니다.

각 권 폴더의 `verification-manifest.md`는 template의 정확한 컬럼 순서를 유지하며 각 드래프트를 정확히 한 번씩 `Draft SHA256`, `Canon Snapshot SHA256`, 최종 Otaku PASS, Editor Style Drift Audit PASS, Editor Character Voice Audit PASS, ledger update 요약, approved unknowns, 그리고 연결된 Verification Evidence report로 기록합니다. Publisher는 manifest schema가 온전하고, 패키징 대상 드래프트가 실제 파일로 존재하고, 기록된 `Draft SHA256`과 일치하고, canon bundle이 기록된 `Canon Snapshot SHA256`과 일치하며, manifest에 `Final Otaku Verdict: PASS`, `Style Drift Audit: PASS`, `Character Voice Audit: PASS`가 기록되어 있고, approved unknowns가 `None`이거나 `narrative-state.md` Open Hooks에 계속 추적되고, evidence report가 같은 증명 필드를 반복하고, 연속성/retcon 안전/문체/기본 문장/캐릭터 voice checklist가 모두 PASS이며, Retcon Approval이 `None`이거나 사용자 승인 근거와 영향 canon 증명을 담은 승인된 `retcons/*.md` proposal을 가리키고, Evidence Anchors table이 모든 checklist 항목을 안전한 source path와 실제 source file 안에 존재하는 evidence phrase에 연결하고, Ledger Update Anchors가 durable ledger fact를 manifest summary와 `narrative-state.md` 양쪽 문구에 연결하고, report 안에 `FAIL`, `PENDING`, `UNVERIFIED` 판정이 없어야 EPUB를 만들 수 있습니다.

새 작품을 시작할 때 사용할 수 있는 `style-guide.md`, `character-sheet.md`, `item-sheet.md`, `location-sheet.md`, `world-rule-sheet.md`, `series-bible.md`, `narrative-state.md`, `verification-manifest.md`, `verification-evidence.md`, `retcon-proposal.md` 기본 스캐폴드는 `templates/` 폴더에 포함되어 있습니다.

프로덕션 집필 전에는 `scripts/validate-production-artifacts.sh [work-path] [volume-path]`를 실행하거나 라우터의 Artifact Preflight Gate가 같은 검사를 수행해야 합니다. 이 게이트는 Writer가 초안을 쓰기 전에 `TBD` placeholder, 빈 style contract 항목, 누락된 Required Style Anchors, 누락된 Forbidden Style Drift, 누락된 Style Verification Questions, 누락된 POV person, 누락된 tense, 누락된 viewpoint anchor, 누락된 head-hopping rule, artifact table schema drift, 누락된 Series Bible chronology source file, 누락된 Chronology evidence phrase, 누락된 캐릭터 voice row, 누락된 캐릭터 설정 파일, voice matrix와 character sheet mismatch, 누락된 character knowledge boundaries, 누락된 forbidden drift guards, 누락된 active state anchors, `narrative-state.md`에 존재하지 않는 active state anchors, voice matrix와 캐릭터 시트에 연결되지 않은 narrative-state 활성 캐릭터 또는 Series Bible evolution character, Location / World Canon References가 없는 활성 장소/세계 규칙 훅, 누락된 location/world setting file, 누락된 location active constraints, 누락된 world rule statements, Inventory Canon References가 없는 추적 대상 소지품, 누락된 item setting file, item holder mismatch, 누락된 item limitations, 약한 narrative-state ledger를 차단합니다.

## 사용 예시 (Usage Examples)

### Novelist 라우터 (자동 라우팅 및 피드백 루프 실행)

```text
/novelist 다크 판타지 1장 오프닝 씬 써줘
  → ①Loremaster → ②Writer → ③Otaku (설정 검증) → ④Editor (문체 다듬기 및 설정 수정) → ⑤Otaku (최종 확인) → ⑥완료

/novelist 이 씬의 전개 속도가 너무 느린데 수정해 줘
  → @novelist-editor → @novelist-otaku 검증

/novelist 이 프로젝트 실험 결과를 바탕으로 LaTeX 논문을 작성해 줘
  → @novelist-researcher
```

### 개별 에이전트 직접 호출

```text
/novelist-writer 현대 판타지 3장 오프닝 씬 써줘.
/novelist-editor 캐릭터 행동과 플롯 일관성에 맞춰서 이 챕터를 교정해 줘.
/novelist-loremaster 주인공 캐릭터에 관한 모든 설정을 모아줘.
/novelist-otaku 기설정된 세계관과 비교해서 이 드래프트 원고를 검증해 줘.
```

`novelist-writer`와 `novelist-editor`를 직접 호출한 결과는 임시 산출물입니다. 출력에는 반드시 `UNVERIFIED DRAFT` 또는 `UNVERIFIED REVISION` 상태가 표시되어야 하며, 라우터가 최종 `@novelist-otaku` 검증을 통과시키고 `verification-manifest.md`에 PASS를 기록하기 전까지는 정식 원고, 출판 가능 원고, 적용 가능한 수정본으로 취급하지 않습니다.

## 언어, 문화 및 창작 프로필 설정 방침 (Language, Culture & Creative Profiling)

에이전트는 사용자가 요청한 언어와 스타일에 엄격히 맞추어 글을 작성합니다.

1. **사전 정보 수집**: 문체/스타일, 분위기, 타깃 언어, 문화적 배경 등 핵심 매개변수가 누락되었거나 명확하지 않은 경우, 라우터 에이전트(`/novelist`)는 집필 시작 전에 사용자에게 단 한 번 질문하여 창작 프로필을 일치시킵니다.
2. **단일 프로필 준수**: 수집된 매개변수들은 하나의 **'창작 프로필(Creative Profile)'**로 통합 관리되며, 라우터는 집필, 리뷰, 퇴고, 설정 검증의 전 과정에 참여하는 모든 서브 에이전트에게 이 프로필을 전파하여 일관된 어조와 감성을 유지합니다.
3. **기본 언어 설정**: 명시적인 지정이 없는 한, 기본 집필 언어는 **한국어**입니다.
4. **문화적 맥락 추론**: 타깃 언어에 맞는 적절한 문화적 감성을 추론하여 적용하며, 모호할 경우 사용자에게 피드백을 구합니다.
5. **한국어 맞춤 창작**: 한국어로 작성할 경우, 한국어 고유의 자연스러운 문장 호흡과 어조, 실감 나는 한국어 대사 스타일, 장르별 클리셰 배제 등을 최우선으로 반영합니다.

## 문체 및 원본성 방침 (Style & Originality Policy)

에이전트 팩은 유연하고 강력한 문체 지정을 지원합니다. 사용자는 다음과 같이 두 가지 방식으로 소설의 문체를 지정할 수 있습니다:
1. **직접 서술**: 문장 특징을 구체적으로 설명합니다 (예: "건조하고 간결한 하드보일드 문체, 짧은 호흡").
2. **특정 작가/인물 참조**: 특정 작가나 인물을 창작 특성의 참고점으로 제시할 수 있지만, 에이전트는 이를 넓은 특성으로만 변환합니다 (예: "도시적 고독감, 낮은 은유 밀도, 느린 관찰 리듬", "빠른 장면 전환, 건조한 유머, 현대적 대사 감각").

집필(`novelist-writer`) 및 퇴고(`novelist-editor`) 에이전트는 지정된 스타일의 특징(문장 구조, 어휘 선택 경향, 템포, 대사 질감, 정서 온도)을 분석하되, 생존 작가의 문장을 직접 모방하지 않고 폭넓은 창작 특성으로 변환하여 독자적인 문장으로 반영합니다.

올바른 요청 예시:
```text
조용한 초현실적 고독감, 절제된 이미지, 느린 리듬으로 어두운 도시 판타지 Chapter 1 오프닝 씬을 작성해 줘.
건조하고 간결한 하드보일드 문체로 다음 문단을 작성해 줘.
```

## 예시 파일 (Examples)

프로젝트 루트의 `examples/` 폴더 내에 수록된 파일들을 참고하세요:
- `examples/novel-brief.md`
- `examples/revision-request.md`
- `examples/production-continuity-scenario.md`
- `examples/style-character-drift-scenario.md`
- `examples/sample-work/` — 설정, 문체 가이드, 시리즈 바이블, 연속성 원장, 드래프트를 포함한 전체 샘플 작품 구조

## 수정 및 설정 변경 안전장치 (Revision And Retcon Safety)

기존 원고 수정 요청은 보호된 revision loop를 사용합니다. `@novelist-loremaster`가 설정과 문체 문맥을 먼저 로드하고, `@novelist-editor`는 승인된 editable span만 수정하며, `@novelist-otaku`가 잠긴 앞뒤 문맥과 비교해 PASS를 내기 전까지 파일에 변경을 적용하지 않습니다.

기존 설정, 캐릭터 특성, 관계, 문체 계약, 과거 사건을 바꾸는 요청은 setting-change request로 처리됩니다. 라우터는 변경 유형을 분류하고 영향 파일을 스캔하며, Priority 1/2/3 캐논과 충돌하면 사용자 승인 없이 조용히 retcon하지 않고 협업 토론으로 멈춥니다. 승인된 migration은 `templates/retcon-proposal.md`에서 만든 `retcons/*.md`에 기록하고, 영향을 받은 Verification Evidence report는 그 승인된 Retcon Approval 파일을 연결해야 합니다.

출판은 `verification-manifest.md`로 gate됩니다. 누락, manifest 중복, stale manifest entry, draft hash mismatch, canon hash mismatch, 대기, 실패, 미검증, 문체 drift, 캐릭터 어투 drift, hard indent, conflict marker, raw HTML 오염, Character Voice Matrix taboo expression 포함, Style Guide Forbidden Literal Phrase 포함 상태의 드래프트는 EPUB로 패키징할 수 없습니다.

## 검증 (Validation)

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

전체 검증은 agent frontmatter, 프롬프트 불변조건, 템플릿, 설치 동작, 연속성 시나리오, 샘플 작품 fixture를 함께 확인합니다.

연속성 fixture만 따로 확인하려면 다음을 실행하세요:

```bash
scripts/validate-continuity-scenario.sh
```

문체 및 캐릭터 드리프트 fixture만 따로 확인하려면 다음을 실행하세요:

```bash
scripts/validate-style-character-drift-scenario.sh
```

전체 샘플 작품 fixture를 확인하려면 다음을 실행하세요:

```bash
scripts/validate-sample-work.sh
```

프로덕션 artifact preflight만 확인하려면 다음을 실행하세요:

```bash
scripts/validate-production-artifacts.sh examples/sample-work volume-1
```

특정 권의 verification manifest만 확인하려면 다음을 실행하세요:

```bash
scripts/validate-verification-manifest.sh examples/sample-work/volume-1
```

전체 검증은 manifest negative test도 실행하여 누락된 draft 항목, `PENDING` 판정, placeholder ledger summary, placeholder 또는 추적되지 않는 approved unknowns, manifest에 없는 추가 draft, 누락되거나 불일치하는 Verification Evidence report, 누락된 Evidence Anchors, 누락된 Ledger Update Anchors, 안전하지 않은 anchor path, source file에 존재하지 않는 anchor phrase를 실제로 거부하는지 확인합니다.

동일한 검증 suite는 push 및 pull request에서 실행되도록 `.github/workflows/validate.yml`에 연결되어 있습니다. CI는 Windows PowerShell installer smoke test도 실행하여 `install.ps1`이 agents, skills, templates를 설치하는지 확인합니다.

요구사항별 릴리스 감사는 `docs/production-readiness-audit.md`를 참고하세요.

## 라이선스 (License)

MIT
