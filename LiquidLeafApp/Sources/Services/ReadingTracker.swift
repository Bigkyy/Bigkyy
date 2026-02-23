import Foundation

@MainActor
final class ReadingTracker: ObservableObject {
    @Published private(set) var states: [UUID: ReadingState] = [:]
    @Published private(set) var recents: [RecentEntry] = []

    private let fileManager = FileManager.default

    private var appSupportURL: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("LiquidLeaf", isDirectory: true)
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    private var stateFileURL: URL { appSupportURL.appendingPathComponent("reading_state.json") }
    private var recentsFileURL: URL { appSupportURL.appendingPathComponent("recent_history.json") }

    func load() {
        if let data = try? Data(contentsOf: stateFileURL),
           let decoded = try? JSONDecoder().decode([UUID: ReadingState].self, from: data) {
            states = decoded
        }

        if let data = try? Data(contentsOf: recentsFileURL),
           let decoded = try? JSONDecoder().decode([RecentEntry].self, from: data) {
            recents = decoded
        }
    }

    func state(for bookID: UUID) -> ReadingState {
        states[bookID] ?? .empty
    }

    func update(bookID: UUID, title: String, progress: Double, locator: String, sessionSeconds: TimeInterval) {
        var current = states[bookID] ?? .empty
        current.progress = max(0, min(1, progress))
        current.lastOpenedAt = .now
        current.lastLocator = locator
        current.readingSeconds += sessionSeconds
        states[bookID] = current

        recents.removeAll { $0.bookID == bookID }
        recents.insert(.init(id: UUID(), bookID: bookID, title: title, openedAt: .now), at: 0)
        recents = Array(recents.prefix(30))

        persist()
    }

    private func persist() {
        if let data = try? JSONEncoder().encode(states) {
            try? data.write(to: stateFileURL, options: .atomic)
        }

        if let data = try? JSONEncoder().encode(recents) {
            try? data.write(to: recentsFileURL, options: .atomic)
        }
    }
}
