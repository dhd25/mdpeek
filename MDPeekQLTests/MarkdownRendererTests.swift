import XCTest
@testable import MDPeekQL

final class MarkdownRendererTests: XCTestCase {

    func testBase64RoundTripAsciiMarkdown() throws {
        let md = "# Hello\n\nSome **bold** text."
        let b64 = MarkdownRenderer.base64(md)
        let decoded = Data(base64Encoded: b64).flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(decoded, md)
    }

    func testBase64RoundTripKoreanAndEmoji() throws {
        let md = "# 안녕하세요 🦊\n\n한글 **굵게** 이모지 🐱."
        let b64 = MarkdownRenderer.base64(md)
        let decoded = Data(base64Encoded: b64).flatMap { String(data: $0, encoding: .utf8) }
        XCTAssertEqual(decoded, md)
    }

    func testRenderInjectsBase64AndStyleAndEmptyBanner() throws {
        let html = try MarkdownRenderer.render(
            markdown: "# Hi",
            banner: nil,
            templateHTML: "<body>{{STYLE}}|{{MD_B64}}|{{BANNER}}</body>",
            styleCSS: "body{color:red}"
        )
        XCTAssertTrue(html.contains("body{color:red}"))
        let expectedB64 = Data("# Hi".utf8).base64EncodedString()
        XCTAssertTrue(html.contains(expectedB64))
        XCTAssertFalse(html.contains("{{STYLE}}"))
        XCTAssertFalse(html.contains("{{MD_B64}}"))
        XCTAssertFalse(html.contains("{{BANNER}}"))
    }

    func testRenderInjectsBannerWhenProvided() throws {
        let html = try MarkdownRenderer.render(
            markdown: "x",
            banner: "파일이 너무 큽니다",
            templateHTML: "<body>{{BANNER}}</body>",
            styleCSS: ""
        )
        XCTAssertTrue(html.contains("파일이 너무 큽니다"))
    }

    func testReadFileDecodesUTF8() throws {
        let url = try writeTempFile(contents: "안녕 world", encoding: .utf8)
        defer { try? FileManager.default.removeItem(at: url) }
        let result = try MarkdownRenderer.readMarkdown(from: url)
        XCTAssertEqual(result.text, "안녕 world")
        XCTAssertEqual(result.encoding, "utf-8")
    }

    func testReadFileFallsBackToUTF16() throws {
        let url = try writeTempFile(contents: "한글 UTF-16", encoding: .utf16)
        defer { try? FileManager.default.removeItem(at: url) }
        let result = try MarkdownRenderer.readMarkdown(from: url)
        XCTAssertEqual(result.text, "한글 UTF-16")
        XCTAssertEqual(result.encoding, "utf-16")
    }

    func testReadFileFallsBackToLatin1() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".md")
        let latin1Bytes: [UInt8] = [0xE9, 0x20, 0x63, 0x61, 0x66, 0xE9] // "é café" in Latin-1
        try Data(latin1Bytes).write(to: url)
        defer { try? FileManager.default.removeItem(at: url) }
        let result = try MarkdownRenderer.readMarkdown(from: url)
        XCTAssertEqual(result.text, "é café")
        XCTAssertEqual(result.encoding, "latin1")
    }

    func testTruncationBelowThresholdReturnsOriginal() {
        let md = String(repeating: "a", count: 1000)
        let result = MarkdownRenderer.truncateForSource(md, limitBytes: 100_000)
        XCTAssertEqual(result.text, md)
        XCTAssertFalse(result.wasTruncated)
    }

    func testTruncationAboveThresholdCutsToLimit() {
        let md = String(repeating: "a", count: 200_000)
        let result = MarkdownRenderer.truncateForSource(md, limitBytes: 100_000)
        XCTAssertTrue(result.wasTruncated)
        XCTAssertLessThanOrEqual(result.text.utf8.count, 100_000)
    }

    func testTruncationPreservesValidUTF8() {
        let md = String(repeating: "한", count: 50_000) // 한 = 3 bytes UTF-8
        let result = MarkdownRenderer.truncateForSource(md, limitBytes: 10_000)
        XCTAssertTrue(result.wasTruncated)
        XCTAssertLessThanOrEqual(result.text.utf8.count, 10_000)
        XCTAssertFalse(result.text.isEmpty)
        XCTAssertNotNil(result.text.data(using: .utf8))
    }

    private func writeTempFile(contents: String, encoding: String.Encoding) throws -> URL {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString + ".md")
        guard let data = contents.data(using: encoding) else {
            throw NSError(domain: "test", code: 0)
        }
        try data.write(to: url)
        return url
    }
}
