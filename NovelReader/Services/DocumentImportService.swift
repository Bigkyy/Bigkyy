import Foundation
import UniformTypeIdentifiers
import ZIPFoundation

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

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
        do {
            let archive = try Archive(url: url, accessMode: .read)
            let htmlEntries = archive.filter {
                $0.type == .file && ["xhtml", "html", "htm"].contains(
                    ($0.path as NSString).pathExtension.lowercased()
                )
            }.sorted { $0.path < $1.path }

            // Consume only chapter data in memory; never materialize archive paths
            // or symlinks on disk. Preserve the MVP's path order and UTF-8 handling.
            let chapters = try htmlEntries.compactMap { entry -> String? in
                var data = Data()
                let checksum = try archive.extract(entry) { data.append($0) }
                guard checksum == entry.checksum else {
                    throw DocumentImportError.unreadable
                }
                return String(data: data, encoding: .utf8)
            }
            let merged = chapters.joined(separator: "\n\n")
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
        } catch {
            throw DocumentImportError.unreadable
        }
    }
}
