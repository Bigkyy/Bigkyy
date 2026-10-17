import Foundation

struct ReaderDocument: Identifiable, Hashable {
    let id = UUID()
    let fileName: String
    let fileURL: URL
    let importedAt: Date
    let content: String
    let fileType: ReaderFileType
}

enum ReaderFileType: String {
    case txt
    case epub
    case md
    case rtf
    case unknown

    init(pathExtension: String) {
        switch pathExtension.lowercased() {
        case "txt": self = .txt
        case "epub": self = .epub
        case "md": self = .md
        case "rtf": self = .rtf
        default: self = .unknown
        }
    }
}

enum ReaderBackgroundStyle: String, CaseIterable, Identifiable {
    case paper
    case night
    case mint
    case sky

    var id: String { rawValue }
}
