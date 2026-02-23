import Foundation

@MainActor
final class ReaderViewModel: ObservableObject {
    @Published var content: String = ""
    @Published var selectedTheme: ReaderTheme = .paper
    @Published var isToolbarVisible = true
    @Published var progress: Double = 0
    @Published var currentPage = 1
    @Published var totalPages = 1

    private let contentLoader = BookContentLoader()
    private var openDate: Date = .now

    func load(book: Book, url: URL, initialProgress: Double) {
        progress = initialProgress
        do {
            content = try contentLoader.loadContent(for: book, fileURL: url)
            let roughPageCount = max(1, content.count / 1200)
            totalPages = roughPageCount
            currentPage = max(1, Int(round(Double(roughPageCount) * progress)))
        } catch {
            content = String(format: NSLocalizedString("open_failed", comment: ""), error.localizedDescription)
        }
        openDate = .now
    }

    func toggleToolbar() {
        isToolbarVisible.toggle()
    }

    func simulatePageTurn(next: Bool) {
        if next {
            currentPage = min(totalPages, currentPage + 1)
        } else {
            currentPage = max(1, currentPage - 1)
        }
        progress = Double(currentPage) / Double(max(1, totalPages))
    }

    func sessionSeconds() -> TimeInterval {
        Date().timeIntervalSince(openDate)
    }
}
