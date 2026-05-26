# opencode용 한국어 창작 에이전트 팩 (Korean Creative Agents for opencode)

opencode를 위한 계층형 한국어 창작 에이전트 팩입니다. **Novelist**(소설가) 라우터 에이전트가 사용자의 요청을 분석하고, 체계적인 피드백 루프를 통해 전문 서브 에이전트들에게 작업을 위임합니다.

## 에이전트 (Agents)

### 소설 시스템 (Novelist System)

| 에이전트 | 역할 |
|-------|------|
| `/novelist` | **라우터 (Router)** — 요청을 분석하고 피드백 루프를 제어합니다. |
| `/novelist-writer` | 소설 집필: 씬, 대사, 서사, 캐릭터 감정 묘사, 회차 초고를 작성합니다. |
| `/novelist-editor` | 소설 퇴고: 플롯 논리, 캐릭터 일관성, 문체 리듬, 템포/페이스 조절 및 피드백을 제공합니다. |
| `/novelist-researcher` | 연구 및 LaTeX 논문 작성: 실험 데이터 분석 및 학술적 글쓰기를 담당합니다. |
| `/novelist-loremaster` | 설정 기록가: 파일 내 설정 정보를 검색하여 구조화된 설정 자료 문서를 취합합니다. |
| `/novelist-otaku` | 설정 검증가: 집필된 초고가 기설정된 세계관 및 설정 가이드와 일치하는지 철저히 대조합니다. |
| `/novelist-publisher` | EPUB 출판가: 검증이 끝난 드래프트를 시맨틱 XHTML 챕터로 포맷팅하고, 시스템 zip 명령어를 이용해 CSS가 포함된 표준 EPUB 도서 파일로 빌드합니다. |

### 스킬 (Skill - 에이전트와 함께 설치됨)

| 스킬 | 사용처 | 목적 |
|-------|---------|---------|
| `setting-collapse-detector` | Loremaster, Otaku | 캐릭터, 타임라인, 지리, 세계관 규칙, 소지품, 대사의 일관성 및 설정 붕괴를 체계적으로 감지하는 프레임워크 |

## 피드백 루프 (Feedback Loop)

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
      ⑧ 완료 및 출판 → 최종 병합된 소설 원고를 Publisher를 통해 EPUB 책으로 빌드
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
cp -r agents/* ~/.config/opencode/agents/

# 프로젝트 로컬 설치
mkdir -p .opencode/agents
cp -r agents/* .opencode/agents/
```

설치를 완료한 후 반영을 위해 opencode 세션을 재시작해 주세요:

```bash
exit  # 또는 Ctrl+D를 입력해 세션을 종료한 후 opencode 재시작
```

## 3단계 계층 구조 (프랜차이즈, 작품, 권) 레이아웃

대규모 공유 세계관(프랜차이즈), 다권 분량의 시리즈물, 혹은 단권 단독 소설 작성을 모두 지원하기 위해, 프로젝트는 일관성 있는 동형적(Isomorphic) 3단계 디렉토리 레이아웃을 사용합니다.

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
│   │   └── volume-1.epub    # 1권 출판 EPUB
│   └── volume-2/            # 3단계: 권 레벨 (Volume 2 of Work A)
│
└── [work-b]/                # === 2단계: 작품 레벨 (Work B) ===
    ├── series-bible.md
    └── volume-1/            # === 3단계: 권 레벨 (Volume 1 of Work B) ===
```

### 2. 단독 작품 구조 (Standalone Work Layout - Isomorphic Fallback)
만약 프로젝트 최상위 루트에 `series-bible.md`가 바로 위치해 있다면, 단독 단편/장편 구조로 인식합니다. 루트 디렉토리가 프랜차이즈 겸 작품 레벨 역할을 동시에 수행하며, 각 권 폴더(`volume-N/`)가 최상위 루트 아래에 직접 배치됩니다:
```text
[project-root]/               # === 1단계 & 2단계 통합: 프랜차이즈 & 작품 레벨 ===
├── settings/                # 이 작품의 설정
├── series-bible.md          # 이 작품의 시리즈 바이블
│
├── volume-1/                # === 3단계: 권 레벨 (Volume 1) ===
│   ├── outline.md
│   └── drafts/
└── volume-2/                # === 3단계: 권 레벨 (Volume 2) ===
```

### 시리즈 바이블 및 스타일 가이드 (`series-bible.md` & `settings/style-guide.md`)
`series-bible.md` 파일은 연대기, 이전 권수 줄거리 요약, 캐릭터 상태 진화 로그(예: 권별 나이 변화, 부상 내역, 인물 관계 변화), 그리고 이 작품의 미해결 플롯 스레드를 기록 관리합니다. 

**작품 레벨 문체 가이드 (Style Guide)**: 소설의 문장 스타일(어투, 톤앤매너, 금지/권장 어휘, 특정 작가/인물 모방 타깃 등)은 개별 작품 폴더 내의 `[Active Work Path]settings/style-guide.md` 파일 또는 시리즈 바이블의 `## Style Guide` 섹션에 선언되어 중앙 관리됩니다. 라우터 에이전트 `@novelist`는 이 설정을 자동으로 상속하여 다른 서브 에이전트(Writer, Editor)에게 전파하므로, 매번 명령어를 보낼 때마다 문체를 지정하지 않아도 해당 작품에 소속된 모든 권수와 문단은 **항상 일관된 톤앤매너와 어조로 집필 및 퇴고**됩니다.

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

## 언어, 문화 및 창작 프로필 설정 방침 (Language, Culture & Creative Profiling)

에이전트는 사용자가 요청한 언어와 스타일에 엄격히 맞추어 글을 작성합니다.

1. **사전 정보 수집**: 문체/스타일, 분위기, 타깃 언어, 문화적 배경 등 핵심 매개변수가 누락되었거나 명확하지 않은 경우, 라우터 에이전트(`/novelist`)는 집필 시작 전에 사용자에게 단 한 번 질문하여 창작 프로필을 일치시킵니다.
2. **단일 프로필 준수**: 수집된 매개변수들은 하나의 **'창작 프로필(Creative Profile)'**로 통합 관리되며, 라우터는 집필, 리뷰, 퇴고, 설정 검증의 전 과정에 참여하는 모든 서브 에이전트에게 이 프로필을 전파하여 일관된 어조와 감성을 유지합니다.
3. **기본 언어 설정**: 명시적인 지정이 없는 한, 기본 집필 언어는 **한국어**입니다.
4. **문화적 맥락 추론**: 타깃 언어에 맞는 적절한 문화적 감성을 추론하여 적용하며, 모호할 경우 사용자에게 피드백을 구합니다.
5. **한국어 맞춤 창작**: 한국어로 작성할 경우, 한국어 고유의 자연스러운 문장 호흡과 어조, 실감 나는 한국어 대사 스타일, 장르별 클리셰 배제 등을 최우선으로 반영합니다.

## 문체 및 모방 방침 (Style & Imitation Policy)

에이전트 팩은 유연하고 강력한 문체 모사를 지원합니다. 사용자는 다음과 같이 두 가지 방식으로 소설의 문체를 지정할 수 있습니다:
1. **직접 서술**: 문장 특징을 구체적으로 설명합니다 (예: "건조하고 간결한 하드보일드 문체, 짧은 호흡").
2. **특정 작가/인물 모방**: 특정 작가나 인물의 고유한 문체를 흉내 내도록 요청할 수 있습니다 (예: "무라카미 하루키 스타일", "김영하 작가 문체").

집필(`novelist-writer`) 및 퇴고(`novelist-editor`) 에이전트는 지정된 작가나 인물 스타일의 특징(문장 구조, 어휘 선택 경향, 템포, 대사 스타일)을 분석하여 원고와 피드백에 충실히 반영합니다.

올바른 요청 예시:
```text
무라카미 하루키 스타일로 어두운 도시 판타지 Chapter 1 오프닝 씬을 작성해 줘.
건조하고 간결한 하드보일드 문체로 다음 문단을 작성해 줘.
```

## 예시 파일 (Examples)

프로젝트 루트의 `examples/` 폴더 내에 수록된 파일들을 참고하세요:
- `examples/novel-brief.md`
- `examples/revision-request.md`

## 라이선스 (License)

MIT
