[English](README.md) | [한국어](README.ko.md)

# MDPeek

**macOS Markdown Quick Look** — Finder에서 `.md` 파일에 Space만 누르면 렌더링된 미리보기가 바로 열립니다.

macOS는 이미지, PDF, 텍스트 파일에 Quick Look을 기본 지원하지만, Markdown은 원문 그대로 보입니다. MDPeek은 `.md`와 `.markdown` 파일을 서식이 적용된 문서로 미리볼 수 있는 네이티브 Quick Look 확장 프로그램입니다. 별도 앱이나 Finder 설정 없이 바로 사용할 수 있습니다.

![preview](docs/preview.png)

## 기능

- **GFM 렌더링** — 제목, 목록, 표, 체크박스, 코드 블록
- **미리보기 / 소스 탭 전환** — 렌더링 결과와 원문 마크다운을 전환
- **Frontmatter 자동 숨김** — YAML frontmatter는 미리보기에서 제거됩니다; 소스 탭에서는 그대로 확인 가능
- **다크 모드** — 시스템 설정을 자동으로 따름
- **완전 오프라인** — marked.js가 번들로 포함되어 네트워크 불필요
- **Notion 스타일 타이포그래피** — 깔끔하고 읽기 편한 레이아웃

## 설치 (Xcode 불필요)

1. [Releases](https://github.com/dhd25/mdpeek/releases)에서 **MDPeek.zip** 다운로드 후 압축 해제
2. `MDPeek.app`을 `/Applications` 폴더로 이동
3. 확장 프로그램 등록을 위해 앱을 한 번 실행:
   ```bash
   open /Applications/MDPeek.app
   ```
4. Gatekeeper 우회 (공증되지 않은 앱에 필요):
   ```bash
   xattr -dr com.apple.quarantine /Applications/MDPeek.app
   ```
5. 확장 프로그램 활성화:
   - **macOS Ventura (13) 이상:** 시스템 설정 → **일반 → 로그인 항목 및 확장 프로그램** → 확장 프로그램 → Quick Look → **MDPeek** 체크
   - **macOS Monterey (12) 이하:** 시스템 설정 → **개인 정보 보호 및 보안 → 확장 프로그램** → Quick Look → **MDPeek** 체크

![setting](docs/setting.png)

Finder에서 `.md` 파일에 Space를 누르면 바로 사용할 수 있습니다.

---

## 소스 빌드

### 요구사항

- macOS 14 Sonoma 이상
- Xcode 15+ 및 XcodeGen (`brew install xcodegen`)

### 빌드 방법

```bash
git clone https://github.com/dhd25/mdpeek
cd mdpeek
xcodegen generate
open MDPeek.xcodeproj
```

Xcode에서:
1. **MDPeek** 스킴 선택
2. **Signing & Capabilities** → Team을 본인의 Apple ID로 설정 (무료 Personal Team 가능)
3. 빌드 ⌘B → 실행 ⌘R

앱 복사:

```bash
cp -R ~/Library/Developer/Xcode/DerivedData/MDPeek-*/Build/Products/Debug/MDPeek.app /Applications/
open /Applications/MDPeek.app
```

확장 프로그램 활성화:

- **macOS Ventura (13) 이상:** 시스템 설정 → **일반 → 로그인 항목 및 확장 프로그램** → 확장 프로그램 → Quick Look → **MDPeek** 체크
- **macOS Monterey (12) 이하:** 시스템 설정 → **개인 정보 보호 및 보안 → 확장 프로그램** → Quick Look → **MDPeek** 체크

등록 확인:

```bash
qlmanage -m plugins | grep -i mdpeek
```

## 개인정보 보호

MDPeek은 완전히 샌드박스 환경에서 실행되며 어떠한 데이터도 수집하지 않습니다.

- **파일 접근:** 미리보는 파일만 읽기 전용으로 접근
- **네트워크:** 마크다운 파일에 포함된 원격 이미지(`![](https://...)`) 로드 시에만 사용 — 추적이나 외부 호출 없음
- **분석, 추적, 외부 연결 없음**

## 알려진 제한사항

- **원격 이미지** — 인터넷 연결 시 표시, 오프라인 시 빈 박스로 표시.
- **로컬 이미지** — 마크다운 파일과 같은 폴더에 있는 이미지(`![](./image.png)`)는 표시됩니다.

## 스타일 커스터마이징

`MDPeekQL/Resources/style.css` 파일에서 시각적 스타일을 수정할 수 있습니다. 수정 후 앱을 다시 빌드하고 재설치하면 적용됩니다.

## 라이선스

MIT — [LICENSE](LICENSE) 참조
