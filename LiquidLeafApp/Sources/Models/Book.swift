import Foundation

struct Book: Identifiable, Codable, Hashable {
    enum Format: String, Codable, CaseIterable {
        case epub
        case txt
        case pdf
        case other
    }

    let id: UUID
    var title: String
    var author: String
    var fileName: String
    var format: Format
    var addedAt: Date

    init(
        id: UUID = UUID(),
        title: String,
        author: String = NSLocalizedString("unknown_author", comment: ""),
        fileName: String,
        format: Format,
        addedAt: Date = .now
    ) {
        self.id = id
        self.title = title
        self.author = author
        self.fileName = fileName
        self.format = format
        self.addedAt = addedAt
    }
}
