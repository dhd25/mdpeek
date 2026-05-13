import Cocoa
import Quartz
import WebKit

final class PreviewViewController: NSViewController, QLPreviewingController {

    private var webView: WKWebView!
    private static let fiveMB = 5 * 1024 * 1024
    private static let sourceLimit = 100 * 1024

    override func loadView() {
        let config = WKWebViewConfiguration()
        config.defaultWebpagePreferences.allowsContentJavaScript = true
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.underPageBackgroundColor = .clear // transparent to match system (public API, macOS 12+)
        self.webView = wv
        self.view = wv
    }

    func preparePreviewOfFile(at url: URL) async throws {
        let (html, loadBaseURL) = try buildHTML(for: url)
        await MainActor.run {
            self.webView.loadHTMLString(html, baseURL: loadBaseURL)
        }
    }

    private func buildHTML(for url: URL) throws -> (String, URL?) {
        let bundle = Bundle(for: Self.self)

        let templateURL = bundle.url(forResource: "template", withExtension: "html")
        let styleURL = bundle.url(forResource: "style", withExtension: "css")
        let markedURL = bundle.url(forResource: "marked.min", withExtension: "js")
        guard let templateURL, let styleURL, let markedURL else {
            throw NSError(domain: "MDPeek", code: 1,
                          userInfo: [NSLocalizedDescriptionKey: "Bundle resources missing"])
        }

        let templateHTML = try String(contentsOf: templateURL, encoding: .utf8)
        let styleCSS = try String(contentsOf: styleURL, encoding: .utf8)
        let markedJS = try String(contentsOf: markedURL, encoding: .utf8)

        let fileSize = (try? FileManager.default.attributesOfItem(atPath: url.path)[.size] as? Int) ?? 0

        let markdown: String
        let banner: String?

        do {
            let read = try MarkdownRenderer.readMarkdown(from: url)
            if fileSize > Self.fiveMB {
                let trunc = MarkdownRenderer.truncateForSource(read.text, limitBytes: Self.sourceLimit)
                markdown = trunc.text
                banner = "File exceeds 5 MB. Source tab shows the first 100 KB only."
            } else if read.text.isEmpty {
                markdown = ""
                banner = "Empty file."
            } else {
                markdown = read.text
                banner = read.encoding == "utf-8" ? nil : "Encoding: \(read.encoding.uppercased())"
            }
        } catch {
            markdown = ""
            return (errorHTML("Cannot open file: \(url.lastPathComponent)"), bundle.resourceURL)
        }

        let html = try MarkdownRenderer.render(
            markdown: markdown,
            banner: banner,
            templateHTML: templateHTML,
            styleCSS: styleCSS,
            markedJS: markedJS
        )
        return (html, url.deletingLastPathComponent())
    }

    private func errorHTML(_ message: String) -> String {
        let escaped = message
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
            .replacingOccurrences(of: "\"", with: "&quot;")
            .replacingOccurrences(of: "'", with: "&#39;")
        return """
        <!DOCTYPE html><html><head><meta charset="utf-8">
        <style>body{font-family:-apple-system;padding:40px;color:#c00}</style>
        </head><body><h2>MDPeek</h2><p>\(escaped)</p></body></html>
        """
    }
}
