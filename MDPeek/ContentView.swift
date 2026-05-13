import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("MDPeek")
                .font(.system(size: 26, weight: .bold))
                .padding(.bottom, 6)
            Text("Finder에서 .md 파일을 선택하고 스페이스바를 누르면 미리보기가 열립니다.")
                .foregroundStyle(.secondary)
                .font(.system(size: 13))
                .padding(.bottom, 24)

            Divider()
                .padding(.bottom, 24)

            Text("확장 프로그램 활성화")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(.secondary)
                .padding(.bottom, 12)

            setupBlock(
                label: "macOS Ventura (13) 이상",
                steps: [
                    "시스템 설정 열기",
                    "일반 → 로그인 항목 및 확장 프로그램",
                    "확장 프로그램 → Quick Look → MDPeek 체크"
                ]
            )
            .padding(.bottom, 12)

            setupBlock(
                label: "macOS Monterey (12) 이하",
                steps: [
                    "시스템 설정 열기",
                    "개인 정보 보호 및 보안 → 확장 프로그램",
                    "Quick Look → MDPeek 체크"
                ]
            )
            .padding(.bottom, 24)

            Button("시스템 설정 열기") {
                if let url = URL(string: "x-apple.systempreferences:com.apple.ExtensionsPreferences") {
                    NSWorkspace.shared.open(url)
                }
            }

            Spacer()
        }
        .padding(32)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    @ViewBuilder
    private func setupBlock(label: String, steps: [String]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(alignment: .top, spacing: 8) {
                        Text("\(index + 1).")
                            .font(.system(size: 13))
                            .foregroundStyle(.secondary)
                            .frame(width: 16, alignment: .leading)
                        Text(step)
                            .font(.system(size: 13))
                    }
                }
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.quaternary.opacity(0.5))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    ContentView()
        .frame(width: 600, height: 480)
}
