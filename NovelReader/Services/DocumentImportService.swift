import Foundation
import UniformTypeIdentifiers

enum DocumentImportError: LocalizedError {
    case unreadable
    case unsupported

    var errorDescription: String? {
        switch self {
        case .unreadable:
            return NSLocalizedString("error_unreadable", comment: "")
        case .unsupported:
            return NSLocalizedString("error_unsupported", comment: "")
        }
    }
}

struct DocumentImportService {
    static let supportedTypes: [UTType] = [.plainText, .utf8PlainText, .rtf, UTType(filenameExtension: "md") ?? .plainText, UTType(filenameExtension: "epub") ?? .data]

    func importDocument(from url: URL) throws -> ReaderDocument {
        let fileType = ReaderFileType(pathExtension: url.pathExtension)

        switch fileType {
        case .txt, .md:
            return try makeTextDocument(from: url, encoding: .utf8, fileType: fileType)
        case .rtf:
            return try makeRTFDocument(from: url)
        case .epub:
            return try makeEPUBDocument(from: url)
        case .unknown:
            throw DocumentImportError.unsupported
        }
    }

    private func makeTextDocument(from url: URL, encoding: String.Encoding, fileType: ReaderFileType) throws -> ReaderDocument {
        guard let content = try? String(contentsOf: url, encoding: encoding) else {
            throw DocumentImportError.unreadable
        }

        return ReaderDocument(
            fileName: url.lastPathComponent,
            fileURL: url,
            importedAt: .now,
            content: content,
            fileType: fileType
        )
    }

    private func makeRTFDocument(from url: URL) throws -> ReaderDocument {
        let data = try Data(contentsOf: url)
        guard
            let attributed = try? NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.rtf],
                documentAttributes: nil
            )
        else {
            throw DocumentImportError.unreadable
        }

        return ReaderDocument(
            fileName: url.lastPathComponent,
            fileURL: url,
            importedAt: .now,
            content: attributed.string,
            fileType: .rtf
        )
    }

    private func makeEPUBDocument(from url: URL) throws -> ReaderDocument {
        let archiveDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)

        try FileManager.default.createDirectory(at: archiveDirectory, withIntermediateDirectories: true)
        defer { try? FileManager.default.removeItem(at: archiveDirectory) }

        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/unzip")
        process.arguments = [url.path, "-d", archiveDirectory.path]
        try process.run()
        process.waitUntilExit()

        let enumerator = FileManager.default.enumerator(at: archiveDirectory, includingPropertiesForKeys: nil)
        let htmlFiles = (enumerator?.allObjects as? [URL] ?? []).filter { ["xhtml", "html", "htm"].contains($0.pathExtension.lowercased()) }
            .sorted { $0.path < $1.path }

        let merged = htmlFiles.compactMap { try? String(contentsOf: $0, encoding: .utf8) }.joined(separator: "\n\n")
        guard !merged.isEmpty else {
            throw DocumentImportError.unreadable
        }

        return ReaderDocument(
            fileName: url.lastPathComponent,
            fileURL: url,
            importedAt: .now,
            content: merged.replacingOccurrences(of: "<[^>]+>", with: " ", options: .regularExpression),
            fileType: .epub
        )
    }
}
