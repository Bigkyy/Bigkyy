import Foundation

struct ReadingState: Codable, Hashable {
    var progress: Double
    var lastOpenedAt: Date
    var lastLocator: String
    var readingSeconds: TimeInterval

    static let empty = ReadingState(
        progress: 0,
        lastOpenedAt: .now,
        lastLocator: "0",
        readingSeconds: 0
    )
}

struct RecentEntry: Identifiable, Codable, Hashable {
    let id: UUID
    let bookID: UUID
    let title: String
    let openedAt: Date
}
