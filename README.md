<p align="center">
  <img src="docs/assets/comux_logo.png" width="88" alt="Comux" />
</p>

<h1 align="center">Comux</h1>

<p align="center">
  AI 에이전트를 위한 터미널 멀티플렉서<br />
  <sub>Claude Code를 여러 개 띄우고, 무엇을 하고 있는지 한 화면에서 지켜보세요</sub>
</p>

<p align="center">
  <a href="https://github.com/Jeonghyeon-Ryu/Comux-Release/releases/latest"><img alt="release" src="https://img.shields.io/github/v/release/Jeonghyeon-Ryu/Comux-Release?color=7c82ff" /></a>
  <img alt="platform" src="https://img.shields.io/badge/platform-Windows%20%7C%20Linux-555" />
  <a href="https://jeonghyeon-ryu.github.io/Comux-Release/"><img alt="download page" src="https://img.shields.io/badge/download-page-7c82ff" /></a>
</p>

<p align="center">
  <img src="docs/assets/comux-full.png" width="900" alt="Comux 인터페이스" />
</p>

---

## 설치

| 대상 | 설치 | 직접 받기 |
|:--|:--|:--|
| **Windows** 데스크톱 | zip 압축 해제 후 실행 | [`comux-1.1.2-win-x64.zip`](https://github.com/Jeonghyeon-Ryu/Comux-Release/releases/download/v1.1.2/comux-1.1.2-win-x64.zip) |
| **Linux** 데스크톱 | `apt install comux` | [AppImage](https://github.com/Jeonghyeon-Ryu/Comux-Release/releases/download/v1.1.2/Comux-1.1.2.AppImage) · [.deb](https://github.com/Jeonghyeon-Ryu/Comux-Release/releases/download/v1.1.2/comux_1.1.2_amd64.deb) |
| **Linux** 서버 / SSH | 설치 스크립트 한 줄 | [`comux-tui-1.1.2-linux-x64.tar.gz`](https://github.com/Jeonghyeon-Ryu/Comux-Release/releases/download/v1.1.2/comux-tui-1.1.2-linux-x64.tar.gz) |

<details open>
<summary><b>Windows</b></summary>

1. 내려받은 zip **우클릭 → 속성 → 차단 해제(Unblock)** 체크 &nbsp;<sub>(Mark of the Web)</sub>
2. 원하는 폴더에 압축 해제
3. `Comux.exe` 실행

설치 프로그램·관리자 권한이 필요 없습니다.

</details>

<details open>
<summary><b>Linux 데스크톱 — APT</b></summary>

서명된 APT 저장소를 제공합니다. 등록해 두면 이후 업데이트는 `apt upgrade` 로 함께 받습니다.

```bash
sudo install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://jeonghyeon-ryu.github.io/Comux-Release/apt/comux.gpg \
  | sudo tee /etc/apt/keyrings/comux.gpg > /dev/null

echo "deb [arch=amd64 signed-by=/etc/apt/keyrings/comux.gpg] \
https://jeonghyeon-ryu.github.io/Comux-Release/apt stable main" \
  | sudo tee /etc/apt/sources.list.d/comux.list

sudo apt update && sudo apt install comux
```

AppImage를 선호한다면 `chmod +x Comux-1.1.2.AppImage` 후 실행하세요.
FUSE 오류가 나면 `--appimage-extract-and-run` 을 붙입니다.

</details>

<details open>
<summary><b>Linux 서버 / SSH (TUI)</b></summary>

**root도 Node도 필요 없습니다** — 런타임이 번들에 들어 있고 홈 디렉터리에 설치됩니다.

```bash
curl -fsSL https://jeonghyeon-ryu.github.io/Comux-Release/install.sh | sh
```

`~/.local/share/comux` 에 풀리고 `~/.local/bin/comux` 명령이 생깁니다 (sha256 검증 포함).
`~/.local/bin` 이 `PATH` 에 없다면 설치 스크립트가 추가 방법을 알려줍니다.

```bash
comux                             # 데몬 기동 + 접속
ssh -t user@host bash -lc comux   # SSH에서 곧바로
```

</details>

---

## 빠른 시작

### 데스크톱 (Windows / Linux)

앱을 실행하면 첫 실행 튜토리얼이 안내를 시작합니다. 처음 켤 때 Claude Code 훅·브라우저 연동·오케스트레이터 플러그인이 **자동으로 구성**되므로 별도 설정이나 API 키가 필요 없습니다.

1. `Ctrl+D` 로 화면을 분할하고, 각 패널에서 `claude` 를 실행합니다.
2. 에이전트가 작업 중이면 사이드바 점이 **주황색**, 끝나면 **녹색**으로 바뀝니다.
3. 에이전트가 웹을 열면 오른쪽 **브라우저 패널**에 그대로 보입니다.

### TUI (SSH)

터미널 전용 버전은 **데몬이 세션을 소유**합니다. SSH 연결이 끊겨도 셸과 에이전트는 계속 실행됩니다.

```bash
comux                # 접속 (데몬이 없으면 자동 기동)
#   … 작업 …
#   Ctrl+B 누른 뒤 q  → 분리 (셸은 계속 실행)
comux                # 다시 접속하면 그대로 복구
```

---

## 단축키

### 데스크톱

| 단축키 | 동작 |
|:--|:--|
| `Ctrl+N` | 새 워크스페이스 |
| `Ctrl+T` | 새 탭 |
| `Ctrl+D` / `Ctrl+Shift+D` | 오른쪽 / 아래로 분할 |
| `Ctrl+W` | 패널 닫기 |
| `Alt+←↑↓→` | 패널 포커스 이동 |
| `Ctrl+Shift+Enter` | 패널 확대(줌) |
| `Ctrl+PgUp` / `Ctrl+PgDn` | 이전 / 다음 워크스페이스 |
| `Ctrl+B` | 사이드바 토글 |
| `Ctrl+Shift+I` | 브라우저 패널 |
| `Ctrl+Shift+E` | 코드 패널 |
| `Ctrl+Shift+P` | 명령 팔레트 |
| `Ctrl+,` | 설정 (모든 단축키 재지정 가능) |

### TUI — `Ctrl+B` 를 누른 **뒤** 키를 입력합니다

데스크톱 단축키와 같은 글자를 씁니다. SSH에서는 `Ctrl+Shift+…` 조합이 전달되지 않기 때문에 tmux처럼 프리픽스 방식을 사용합니다.

| `Ctrl+B` + | 동작 | 데스크톱 |
|:--|:--|:--|
| `←↑↓→` | 패널 포커스 이동 | `Alt+←↑↓→` |
| `d` / `Shift+D` | 오른쪽 / 아래로 분할 | `Ctrl+D` |
| `w` | 패널 닫기 | `Ctrl+W` |
| `Enter` | 패널 확대(줌) | `Ctrl+Shift+Enter` |
| `=` / `-` | 패널 크기 조절 | `Ctrl+=` / `Ctrl+-` |
| `t` | 새 탭 | `Ctrl+T` |
| `]` / `[` | 다음 / 이전 탭 | `Ctrl+Shift+]` |
| `n` | 새 워크스페이스 | `Ctrl+N` |
| `PgUp` / `PgDn` | 이전 / 다음 워크스페이스 | `Ctrl+PgUp` |
| `c` | 스크롤백(복사 모드) — `y` 복사, `q` 종료 | — |
| `u` | **버전 / 업데이트 패널** | 타이틀바 버전 배지 |
| `q` | 분리 (데몬은 계속 실행) | — |
| `?` | **단축키 도움말 오버레이** | — |

> **마우스도 지원합니다** — 클릭으로 패널 포커스, 휠로 스크롤백.
> tmux 사용자를 위한 별칭(`%` `"` `x` `z` `<` `>` `(` `)`)도 그대로 동작합니다.

---

## CLI

실행 중인 Comux를 명령줄에서 제어합니다. 데스크톱·TUI 모두 동일합니다.

```bash
comux ls                                  # 모든 워크스페이스의 터미널 목록
comux new-workspace --title "api"         # 워크스페이스 생성
comux split --down                        # 패널 분할
comux send "npm test"                     # 터미널에 텍스트 입력
comux read-screen --lines 50              # 터미널 화면 읽기
comux notify "빌드 완료"                   # 알림 보내기

# 에이전트
comux agent spawn --cmd "claude" --label dev
comux agent list
comux agent kill <agent-id>

# 내장 브라우저 (데스크톱)
comux browser open localhost:3000
comux browser snapshot                    # 접근성 트리 (@e1, @e2 …)
comux browser click @e5
```

설치 스크립트나 apt로 설치했다면 `comux` 는 이미 `PATH` 에 있습니다. tar.gz를 직접 풀었다면 `comux-linux-x64/comux …` 로 실행하세요.

---

## 자주 묻는 질문

**Windows에서 SmartScreen 경고가 떠요**
코드 서명이 되어 있지 않아 생기는 경고입니다. 압축을 풀기 **전에** zip 우클릭 → 속성 → 차단 해제를 체크하면 사라집니다.

**TUI에서 `Ctrl+B` 뒤에 뭘 눌러야 할지 모르겠어요**
`Ctrl+B` 를 누른 뒤 `?` 를 누르면 전체 단축키 표가 화면에 뜹니다. 아무 키나 누르면 닫힙니다.

**SSH가 끊기면 작업이 사라지나요?**
아닙니다. 데몬이 세션을 유지하므로 다시 `run.sh` 로 접속하면 그대로 이어집니다.

**여러 대에서 같은 세션에 붙을 수 있나요?**
가능합니다. 화면 크기는 가장 작은 클라이언트에 맞춰지며, 보기 전용으로 붙으려면 `comux attach --read-only` 를 사용하세요.

**업데이트는 어떻게 확인하나요?**
새 릴리즈가 나오면 상태줄에 `⬆ 1.1.2 (^B u)` 배지가 뜹니다. `Ctrl+B u` 를 누르면 이 설치본(apt / install.sh)에 맞는 업그레이드 명령이 나옵니다. 셸에서는 `comux upgrade` 로도 확인할 수 있습니다.
데스크톱 앱은 타이틀바의 버전 배지를 누르세요 — Windows는 제자리 업데이트, Linux는 `apt upgrade` 명령을 알려줍니다.
자동 확인을 끄려면 `COMUX_NO_UPDATE_CHECK=1` 을 설정하세요.

**`apt update` 에서 서명 오류가 나요**
키가 `/etc/apt/keyrings/comux.gpg` 에 있는지, `sources.list.d/comux.list` 의 `signed-by=` 경로가 같은지 확인하세요.
저장소 키 지문은 `9ED2 41E5 188E 1CE5 BF2A 073B 792F 5F77 BDDF F368` 입니다.

---

## 링크

- **[다운로드 페이지](https://jeonghyeon-ryu.github.io/Comux-Release/)** — 설치 안내와 매뉴얼
- **[APT 저장소](https://jeonghyeon-ryu.github.io/Comux-Release/apt/)** — Debian / Ubuntu
- **[전체 릴리즈](https://github.com/Jeonghyeon-Ryu/Comux-Release/releases)** — 이전 버전
- **[이슈](https://github.com/Jeonghyeon-Ryu/Comux-Release/issues)** — 버그 신고, 기능 제안

<sub>Comux는 [cmux](https://github.com/manaflow-ai/cmux)에서 출발한 오픈소스 프로젝트입니다 · AGPL-3.0</sub>
