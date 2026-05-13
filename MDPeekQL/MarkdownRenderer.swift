import Foundation

enum MarkdownRenderer {

    static func base64(_ string: String) -> String {
        Data(string.utf8).base64EncodedString()
    }

    /// Assembles final HTML by substituting placeholders in the template.
    /// - Parameters:
    ///   - markdown: Raw markdown text
    ///   - banner: Optional warning text; nil or empty means no banner
    ///   - templateHTML: The HTML template containing {{STYLE}}, {{MD_B64}}, {{BANNER}}
    ///   - styleCSS: Stylesheet content to inline
    static func render(
        markdown: String,
        banner: String?,
        templateHTML: String,
        styleCSS: String,
        markedJS: String
    ) throws -> String {
        let b64 = base64(markdown)
        let bannerText = (banner?.isEmpty == false) ? banner! : ""
        return templateHTML
            .replacingOccurrences(of: "{{MARKED_JS}}", with: markedJS)
            .replacingOccurrences(of: "{{STYLE}}", with: styleCSS)
            .replacingOccurrences(of: "{{MD_B64}}", with: b64)
            .replacingOccurrences(of: "{{BANNER}}", with: bannerText)
    }

    struct ReadResult {
        let text: String
        let encoding: String
    }

    enum ReadError: Error { case unreadable }

    struct TruncateResult {
        let text: String
        let wasTruncated: Bool
    }

    /// Truncates `text` so its UTF-8 byte count does not exceed `limitBytes`.
    /// Always cuts on a valid UTF-8 boundary (Character-wise).
    static func truncateForSource(_ text: String, limitBytes: Int) -> TruncateResult {
        if text.utf8.count <= limitBytes {
            return TruncateResult(text: text, wasTruncated: false)
        }
        var result = ""
        var running = 0
        for char in text {
            let charBytes = String(char).utf8.count
            if running + charBytes > limitBytes { break }
            result.append(char)
            running += charBytes
        }
        return TruncateResult(text: result, wasTruncated: true)
    }

    static func readMarkdown(from url: URL) throws -> ReadResult {
        let data = try Data(contentsOf: url)
        if let s = String(data: data, encoding: .utf8) {
            return ReadResult(text: s, encoding: "utf-8")
        }
        // Only attempt UTF-16 if a BOM is present (0xFF 0xFE or 0xFE 0xFF)
        let hasUTF16BOM = data.count >= 2 &&
            ((data[0] == 0xFF && data[1] == 0xFE) || (data[0] == 0xFE && data[1] == 0xFF))
        if hasUTF16BOM, let s = String(data: data, encoding: .utf16) {
            return ReadResult(text: s, encoding: "utf-16")
        }
        if let s = String(data: data, encoding: .isoLatin1) {
            return ReadResult(text: s, encoding: "latin1")
        }
        throw ReadError.unreadable
    }
}
