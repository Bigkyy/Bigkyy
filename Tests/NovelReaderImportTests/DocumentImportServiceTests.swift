import Foundation
import XCTest
import ZIPFoundation
@testable import NovelReaderImport

final class DocumentImportServiceTests: XCTestCase {
    private var directory: URL!
    private let importer = DocumentImportService()

    override func setUpWithError() throws {
        directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    override func tearDownWithError() throws {
        try FileManager.default.removeItem(at: directory)
    }

    func testUTF8TextAndMarkdownKeepContentAndMetadata() throws {
        for (ext, fileType) in [("txt", ReaderFileType.txt), ("md", .md)] {
            let url = directory.appendingPathComponent("book.\(ext)")
            let content = "# Chapter one\nHello, 世界!\n"
            try Data(content.utf8).write(to: url)

            let document = try importer.importDocument(from: url)

            XCTAssertEqual(document.content, content)
            XCTAssertEqual(document.fileName, url.lastPathComponent)
            XCTAssertEqual(document.fileURL, url)
            XCTAssertEqual(document.fileType, fileType)
        }
    }

    func testRTFStillImportsPlainText() throws {
        let url = directory.appendingPathComponent("book.rtf")
        try Data(#"{\rtf1\ansi Hello \b reader\b0.}"#.utf8).write(to: url)

        let document = try importer.importDocument(from: url)

        XCTAssertEqual(document.content.trimmingCharacters(in: .whitespacesAndNewlines), "Hello reader.")
        XCTAssertEqual(document.fileType, .rtf)
        XCTAssertEqual(document.fileURL, url)
    }

    func testStoredAndDeflatedEPUBChaptersKeepPathOrderAndStripTags() throws {
        for compression in [CompressionMethod.none, .deflate] {
            let url = try makeEPUB([
                ("OEBPS/03.htm", Data("<p>Third</p>".utf8)),
                ("OEBPS/01.XHTML", Data("<p>First 世界</p>".utf8)),
                ("OEBPS/02.html", Data("<p>Second</p>".utf8)),
                ("OEBPS/style.css", Data("ignored".utf8))
            ], compression: compression)

            let document = try importer.importDocument(from: url)

            XCTAssertEqual(document.content, " First 世界 \n\n Second \n\n Third ")
            XCTAssertEqual(document.fileType, .epub)
            XCTAssertEqual(document.fileURL, url)
            XCTAssertEqual(document.fileName, url.lastPathComponent)
        }
    }

    func testEPUBAccumulatesMultipleExtractionChunks() throws {
        let text = String(repeating: "Hello 世界! ", count: 10_000)
        let url = try makeEPUB([("chapter.xhtml", Data("<p>\(text)</p>".utf8))])

        XCTAssertEqual(try importer.importDocument(from: url).content, " \(text) ")
    }

    func testEPUBSkipsNonUTF8ChaptersAsBefore() throws {
        let url = try makeEPUB([
            ("01.xhtml", Data([0xFF, 0xFE, 0xFF])),
            ("02.xhtml", Data("<p>Readable</p>".utf8))
        ])

        XCTAssertEqual(try importer.importDocument(from: url).content, " Readable ")
    }

    func testEPUBIgnoresSymlinkChapters() throws {
        let url = try makeEPUB([("chapter.xhtml", Data("<p>Readable</p>".utf8))])
        do {
            let archive = try Archive(url: url, accessMode: .update)
            try addEntry("link.xhtml", data: Data("chapter.xhtml".utf8), type: .symlink, to: archive)
        }

        XCTAssertEqual(try importer.importDocument(from: url).content, " Readable ")
    }

    func testEPUBWithoutReadableHTMLIsUnreadable() throws {
        for entries in [
            [("style.css", Data("body {}".utf8))],
            [("chapter.xhtml", Data([0xFF]))],
            [("chapter.xhtml", Data())]
        ] {
            let url = try makeEPUB(entries)
            assertUnreadable(url)
        }
    }

    func testMalformedAndTruncatedEPUBAreUnreadable() throws {
        let malformed = directory.appendingPathComponent("malformed.epub")
        try Data("not a ZIP archive".utf8).write(to: malformed)
        assertUnreadable(malformed)

        let truncated = try makeEPUB([("chapter.xhtml", Data("<p>Text</p>".utf8))])
        let bytes = try Data(contentsOf: truncated)
        try Data(bytes.prefix(bytes.count / 2)).write(to: truncated)
        assertUnreadable(truncated)
    }

    func testCorruptedChapterChecksumIsUnreadable() throws {
        let original = Data("<p>Original</p>".utf8)
        let url = try makeEPUB([("chapter.xhtml", original)], compression: .none)
        var bytes = try Data(contentsOf: url)
        let range = try XCTUnwrap(bytes.range(of: original))
        bytes[range.lowerBound + 3] = 0x58
        try bytes.write(to: url)

        assertUnreadable(url)
    }

    func testMissingEPUBIsUnreadableAndUnknownFormatIsUnsupported() {
        assertUnreadable(directory.appendingPathComponent("missing.epub"))
        XCTAssertThrowsError(try importer.importDocument(from: directory.appendingPathComponent("book.pdf"))) {
            guard case DocumentImportError.unsupported = $0 else {
                return XCTFail("Expected unsupported, got \($0)")
            }
        }
    }

    private func assertUnreadable(_ url: URL, file: StaticString = #filePath, line: UInt = #line) {
        XCTAssertThrowsError(try importer.importDocument(from: url), file: file, line: line) {
            guard case DocumentImportError.unreadable = $0 else {
                return XCTFail("Expected unreadable, got \($0)", file: file, line: line)
            }
        }
    }

    private func makeEPUB(
        _ entries: [(String, Data)],
        compression: CompressionMethod = .deflate
    ) throws -> URL {
        let url = directory.appendingPathComponent("\(UUID().uuidString).epub")
        let archive = try Archive(url: url, accessMode: .create)
        try addEntry("mimetype", data: Data("application/epub+zip".utf8), to: archive)
        for (path, data) in entries {
            try addEntry(path, data: data, compression: compression, to: archive)
        }
        return url
    }

    private func addEntry(
        _ path: String,
        data: Data,
        type: Entry.EntryType = .file,
        compression: CompressionMethod = .none,
        to archive: Archive
    ) throws {
        try archive.addEntry(
            with: path,
            type: type,
            uncompressedSize: Int64(data.count),
            compressionMethod: compression
        ) { position, size in
            let start = Int(position)
            return data.subdata(in: start..<(start + size))
        }
    }
}
