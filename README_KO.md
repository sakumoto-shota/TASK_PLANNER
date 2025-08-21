# Task Planner

<div align="center">
  <img src="logo.png" alt="Task Planner Logo" width="400">
</div>

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Bash](https://img.shields.io/badge/Shell-Bash-green.svg)](https://www.gnu.org/software/bash/)
[![Claude AI](https://img.shields.io/badge/AI-Claude-blue.svg)](https://claude.ai/)

간단한 AI 작업 계획기 - 요구사항부터 구현까지 단계별로 지원하는 Bash 도구

> [English README](README_EN.md) | [日本語 README](README.md) | [中文 README](README_ZH.md) | [한국어 README](README_KO.md) | [Español README](README_ES.md) | [Français README](README_FR.md)

## 개요

Task Planner는 요구사항 정의부터 구현까지 다음 3단계를 통해 전체 프로세스를 지원합니다:

1. **Plan**: 요구사항을 바탕으로 상세한 구현 계획 생성
2. **Task**: 계획을 바탕으로 구체적인 작업 생성
3. **Execute**: 작업을 실행하고 PR 형식의 결과물 출력

## 기능

- 🎯 요구사항에서 계획, 작업, 구현을 단계별로 자동 생성
- 🤖 Claude AI와의 통합
- 📊 시각적 진행 상황 표시 (스피너, 상태, 경과 시간)
- 📝 구조화된 문서 생성 (PLAN.md → TASK.md → PR.md)
- 📋 작업 목록 관리
- ⚙️ 사용자 정의 가능한 프롬프트 템플릿 (config/ 디렉토리)

## 요구사항

- Bash (macOS/Linux)
- Claude CLI
- jq (JSON 파싱용, 선택사항)

## 설정

### 기본 설정

1. 스크립트를 실행 가능하게 만들기:

```bash
chmod +x task-planner.sh
```

2. AI 도구 설정:

```bash
./task-planner.sh config claude    # Claude CLI 사용
```

### 기존 프로젝트에 통합

기존 프로젝트에 Task Planner를 통합하는 단계:

#### 1. 파일 복사

```bash
# 기존 프로젝트 디렉토리로 이동
cd /path/to/your/project

# Task Planner 파일 복사
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/task-planner.sh
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/plan-prompt.md
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/task-prompt.md
curl -O https://raw.githubusercontent.com/sakumoto-shota/TASK_PLANNER/main/config/execute-prompt.md

# 또는 이 저장소에서 필요한 파일 복사
cp /path/to/task_planner/task-planner.sh .
cp -r /path/to/task_planner/config .
```

#### 2. 실행 권한 설정

```bash
chmod +x task-planner.sh
```

#### 3. 디렉토리 구조 확인

통합 후 프로젝트 구조 예시:

```
your-project/
├── src/                  # 기존 소스 코드
├── docs/                 # 기존 문서
├── task-planner.sh       # ✅ 추가됨
├── config/               # ✅ 추가됨
│   ├── plan-prompt.md
│   ├── task-prompt.md
│   └── execute-prompt.md
└── AI_TASKS/             # ✅ 실행 시 자동 생성
    └── [task-name]/
        ├── PLAN.md
        ├── TASK.md
        └── PR.md
```

#### 4. .gitignore 설정 (권장)

```bash
# .gitignore에 추가 (AI_TASKS 디렉토리 관리 여부는 프로젝트에 따라 결정)
echo "AI_TASKS/" >> .gitignore

# 또는 진행 중인 작업만 제외
echo "AI_TASKS/*/plan_prompt.txt" >> .gitignore
echo "AI_TASKS/*/stream_output.json" >> .gitignore
```

#### 5. 프로젝트별 사용자 정의

```bash
# 프로젝트의 기술 스택에 맞게 프롬프트 사용자 정의
vim config/plan-prompt.md
vim config/task-prompt.md
vim config/execute-prompt.md
```

## 사용법

### 3단계 워크플로

Task Planner는 요구사항부터 구현까지 다음 3단계로 진행됩니다:

#### 1. Plan 단계 - 요구사항 분석 및 설계

```bash
./task-planner.sh plan "웹 앱의 로그인 기능 구현" login-feature
```

- **입력**: 요구사항 텍스트와 작업 이름
- **처리**: AI가 요구사항을 분석하고 상세한 구현 계획 생성
- **출력**: `PLAN.md` - 아키텍처, 기술 스택, 상세한 구현 단계

#### 2. Task 단계 - 구체적인 작업 생성

```bash
./task-planner.sh task login-feature
```

- **입력**: 생성된 `PLAN.md`
- **처리**: 계획을 바탕으로 실행 가능한 구체적인 작업 목록 생성
- **출력**: `TASK.md` - 체크리스트 형식의 구현 단계

#### 3. Execute 단계 - 구현 실행

```bash
./task-planner.sh execute login-feature
```

- **입력**: 생성된 `TASK.md`
- **처리**: AI가 실제로 코드를 작성하고 파일을 생성/편집
- **출력**: `PR.md` - 구현 완료 보고서 및 결과물 문서

### 단계별 실행의 장점

- **단계별 확인**: 각 단계에서 내용을 검토하고 조정 가능
- **품질 향상**: 계획 → 작업 → 구현 순서로 세분화하여 품질 향상
- **위험 감소**: execute 단계 전에 계획과 작업을 검토할 수 있어 위험 감소

### 명령 목록

| 명령      | 설명                   | 사용 예시                                      |
| --------- | ---------------------- | ---------------------------------------------- |
| `plan`    | 요구사항에서 계획 생성 | `./task-planner.sh plan "요구사항..." [task-name]` |
| `task`    | 계획에서 작업 생성     | `./task-planner.sh task task-name`            |
| `execute` | 작업 실행              | `./task-planner.sh execute task-name`         |
| `list`    | 작업 목록 표시         | `./task-planner.sh list`                      |
| `config`  | AI 도구 설정           | `./task-planner.sh config claude`             |
| `help`    | 도움말 정보 표시       | `./task-planner.sh help`                      |

### 파일 구조

실행하면 다음 구조로 파일이 생성됩니다:

```
AI_TASKS/
└── [task-name]/
    ├── PLAN.md        # 상세한 구현 계획
    ├── TASK.md        # 구체적인 작업 절차
    └── PR.md          # 구현 완료 보고서 (최종 결과물)

config/
├── plan-prompt.md    # 계획 생성용 프롬프트 템플릿
├── task-prompt.md    # 작업 생성용 프롬프트 템플릿
└── execute-prompt.md # 실행용 프롬프트 템플릿
```

## 출력 예시

### 계획 생성 시

```
╭─────────────────────────────────────────────────────────────────╮
│                        Task Planner                           │
╰─────────────────────────────────────────────────────────────────╯

▶ 계획 생성
  작업 이름: login-feature
  요구사항: 웹 앱의 로그인 기능 구현

  AI가 계획을 생성 중 ✅ 완료 (01:23) [1250 tokens]

✅ 계획이 생성되었습니다: AI_TASKS/login-feature/PLAN.md
  다음 단계: ./task-planner.sh task login-feature
```

## 특징

- **단계별 접근**: 요구사항 → 계획 → 작업 → 구현의 명확한 흐름
- **실시간 피드백**: AI 처리 중 진행 상황 표시
- **구조화된 출력**: Markdown 형식의 통일된 문서
- **히스토리 관리**: 작업 진행 상황을 한눈에 확인 가능
- **사용자 정의 가능**: 프롬프트 템플릿을 편집하여 AI 출력 조정 가능

## ⚠️ 보안 및 안전 사용에 대한 중요 주의사항

### execute 명령의 파일 조작 권한

**execute 단계에서는 광범위한 파일 조작 권한이 부여됩니다**

`execute` 명령은 실제 구현을 수행하기 위해 Claude CLI에 `--dangerously-skip-permissions` 플래그를 자동으로 부여합니다.

#### 가능한 작업

- 파일 생성, 편집, 삭제
- 디렉토리 생성, 삭제
- 시스템 명령 실행
- 종속성 설치
- 구성 파일 수정

### 안전한 사용을 위한 체크리스트

**실행 전에 반드시 확인하세요:**

- [ ] 백업 생성

  ```bash
  # Git 저장소의 경우
  git add . && git commit -m "Execute 전 백업"

  # 중요한 파일 복사
  cp -r important_files/ backup/
  ```

- [ ] 실행 환경 확인

  - 프로덕션 환경이 아닌 개발 환경
  - 중요한 시스템 파일이 포함되지 않음
  - 쓰기 권한이 적절히 제한됨

- [ ] 계획 및 작업 사전 검토
  - `PLAN.md` 내용이 예상대로인지
  - `TASK.md` 구현 단계가 안전한지
  - 의심스러운 명령이나 위험한 작업이 포함되지 않았는지

### 권장 사용 환경

- **개발 디렉토리**: `/home/user/dev/`, `/Users/user/projects/` 등
- **가상 환경**: Docker 컨테이너, VM 내에서 실행
- **샌드박스**: 격리된 개발 환경
- **버전 관리**: Git 관리하에 있는 프로젝트

### 피해야 할 사용 장소

- 시스템 디렉토리 (`/usr/`, `/etc/`, `/System/` 등)
- 프로덕션 환경
- 공유 디렉토리
- 기밀 정보가 포함된 디렉토리

## 프롬프트 사용자 정의

`config/` 디렉토리의 Markdown 파일을 편집하여 각 단계에서의 AI 동작을 사용자 정의할 수 있습니다.

### 프롬프트 파일 구성

| 파일               | 용도               | 타이밍                            | 사용자 정의 예시                 |
| ------------------ | ------------------ | --------------------------------- | -------------------------------- |
| `plan-prompt.md`   | 계획 생성 시 지시  | `./task-planner.sh plan` 실행 시    | 설계 방법 지정, 출력 형식 조정   |
| `task-prompt.md`   | 작업 생성 시 지시  | `./task-planner.sh task` 실행 시    | 체크리스트 형식 지정, 우선순위 부여 |
| `execute-prompt.md`| 구현 실행 시 지시  | `./task-planner.sh execute` 실행 시 | 코딩 스타일, 테스트 절차 지시    |

### 사용 가능한 플레이스홀더

프롬프트 템플릿 내에서 다음 플레이스홀더가 자동으로 대체됩니다:

- `{{TASK_NAME}}`: 작업 이름
- `{{REQUIREMENT}}`: 요구사항 (plan-prompt.md용)
- `{{PLAN_CONTENT}}`: 계획 내용 (task-prompt.md용)
- `{{TASK_CONTENT}}`: 작업 내용 (execute-prompt.md용)

### 사용자 정의 예시

```markdown
# config/plan-prompt.md 예시

요구사항: {{REQUIREMENT}}
작업 이름: {{TASK_NAME}}

다음 관점에서 상세한 구현 계획을 작성하세요:

1. 아키텍처 설계
2. 보안 고려사항
3. 성능 최적화
4. 테스트 전략
5. 배포 절차
```

## 실용 예시 및 사용 사례

### 프로젝트별 활용 예시

#### 웹 애플리케이션 개발

```bash
# REST API 구현
./task-planner.sh plan "사용자 인증 기능이 있는 REST API" user-auth-api
./task-planner.sh task user-auth-api
./task-planner.sh execute user-auth-api

# 프론트엔드 기능
./task-planner.sh plan "React로 만든 대시보드 화면" react-dashboard
```

#### 데이터 처리 및 분석

```bash
# 데이터 파이프라인 구축
./task-planner.sh plan "CSV에서 PostgreSQL 변환 도구" csv-converter
./task-planner.sh task csv-converter

# 머신러닝 모델
./task-planner.sh plan "이미지 분류 ML 모델 구현" image-classifier
```

#### DevOps 및 자동화

```bash
# CI/CD 설정
./task-planner.sh plan "GitHub Actions 워크플로 설정" gh-workflow
./task-planner.sh task gh-workflow

# 인프라 구축
./task-planner.sh plan "Docker Compose 개발 환경" docker-env
```

### 권장 폴더 구조

```
project/
├── AI_TASKS/           # Task Planner로 관리하는 작업
│   ├── feature-a/
│   ├── bugfix-b/
│   └── refactor-c/
├── src/               # 구현된 소스 코드
├── docs/              # 문서
└── tests/             # 테스트 파일
```

## 문제 해결

### 일반적인 문제 및 해결 방법

#### 1. Claude CLI 관련

```bash
# Claude CLI를 찾을 수 없음
which claude
# → 설치: https://docs.anthropic.com/cli

# 인증 오류
claude auth
# → API 키 설정
```

#### 2. 권한 오류

```bash
# 실행 권한 없음
chmod +x task-planner.sh

# 디렉토리 생성 권한 없음
sudo chown $USER:$USER /path/to/project
```

#### 3. AI 처리 오류

- **네트워크 연결**: 인터넷 연결 확인
- **API 속도 제한**: 잠시 기다린 후 재실행
- **프롬프트가 너무 김**: 요구사항 텍스트를 줄이고 재실행

#### 4. 파일 처리 오류

```bash
# JSON 처리 오류 (jq는 필수가 아니지만 권장)
# macOS
brew install jq
# Ubuntu
sudo apt install jq

# 파일 생성 권한 오류
ls -la AI_TASKS/
# 권한을 확인하고 필요에 따라 수정
```

### 디버깅 방법

#### 로그 확인

```bash
# AI 처리 중 상세 로그 확인
tail -f AI_TASKS/[task-name]/stream_output.json

# 생성된 파일 확인
ls -la AI_TASKS/[task-name]/
```

#### 단계별 문제 식별

1. **plan 단계** 실패 → 요구사항 텍스트 검토
2. **task 단계** 실패 → PLAN.md 내용 확인
3. **execute 단계** 실패 → TASK.md 구현 지시 확인

### 성능 최적화

- **병렬 처리**: 여러 작업을 병렬로 plan → task 단계까지 진행 가능
- **프롬프트 최적화**: `config/` 파일을 조정하여 응답 속도 향상
- **캐시 활용**: 유사한 작업의 PLAN.md를 참조 템플릿으로 활용

## 라이선스 및 기여

### 라이선스

이 프로젝트는 [MIT 라이선스](LICENSE) 하에 공개됩니다.

### 기여 및 포크

- 🍴 **자유로운 포크**: 이 저장소를 자유롭게 포크하여 필요에 맞게 사용자 정의하세요
- 🛠️ **개선 제안**: Issues와 Pull Requests를 통한 개선 제안을 환영합니다
- 💡 **아이디어 공유**: 새로운 기능 아이디어와 사용 예시 공유도 환영합니다

모든 분들의 협력을 통해 더 나은 도구를 만들어 갑시다!