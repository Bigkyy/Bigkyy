import Foundation

@MainActor
final class LibraryStore: ObservableObject {
    @Published private(set) var books: [Book] = []

    private let fileManager = FileManager.default

    private var appSupportURL: URL {
        let base = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        let folder = base.appendingPathComponent("LiquidLeaf", isDirectory: true)
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    private var libraryFileURL: URL {
        appSupportURL.appendingPathComponent("library.json")
    }

    private var documentsFolderURL: URL {
        let folder = appSupportURL.appendingPathComponent("ImportedBooks", isDirectory: true)
        if !fileManager.fileExists(atPath: folder.path) {
            try? fileManager.createDirectory(at: folder, withIntermediateDirectories: true)
        }
        return folder
    }

    func loadLibrary() {
        guard let data = try? Data(contentsOf: libraryFileURL) else { return }
        let decoded = try? JSONDecoder().decode([Book].self, from: data)
        books = decoded ?? []
    }

    func importBook(from sourceURL: URL) throws {
        let ext = sourceURL.pathExtension.lowercased()
        let format = Book.Format(rawValue: ext) ?? .other
        let destinationName = "\(UUID().uuidString).\(ext.isEmpty ? "bin" : ext)"
        let destinationURL = documentsFolderURL.appendingPathComponent(destinationName)

        if sourceURL.startAccessingSecurityScopedResource() {
            defer { sourceURL.stopAccessingSecurityScopedResource() }
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        } else {
            try fileManager.copyItem(at: sourceURL, to: destinationURL)
        }

        let title = sourceURL.deletingPathExtension().lastPathComponent
        let book = Book(title: title, fileName: destinationName, format: format)
        books.insert(book, at: 0)
        try persist()
    }

    func url(for book: Book) -> URL {
        documentsFolderURL.appendingPathComponent(book.fileName)
    }

    private func persist() throws {
        let data = try JSONEncoder().encode(books)
        try data.write(to: libraryFileURL, options: .atomic)
    }
}
