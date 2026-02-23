import Foundation

struct BookContentLoader {
    func loadContent(for book: Book, fileURL: URL) throws -> String {
        switch book.format {
        case .txt:
            return try String(contentsOf: fileURL, encoding: .utf8)
        case .epub:
            return try loadEPUBText(from: fileURL)
        case .pdf:
            return NSLocalizedString("pdf_placeholder", comment: "")
        case .other:
            return NSLocalizedString("unsupported_format", comment: "")
        }
    }

    private func loadEPUBText(from url: URL) throws -> String {
        // MVP fallback: Display helper message. Hook in full EPUB parser on macOS/iOS using ZIPArchive + XHTML spine parsing.
        // This keeps the app deployable while leaving a clear extension point.
        return String(format: NSLocalizedString("epub_placeholder", comment: ""), url.lastPathComponent)
    }
}
