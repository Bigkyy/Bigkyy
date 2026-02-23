import SwiftUI
import UniformTypeIdentifiers

struct LibraryView: View {
    @EnvironmentObject private var libraryStore: LibraryStore
    @EnvironmentObject private var readingTracker: ReadingTracker

    @State private var showingImporter = false
    @State private var importError: String?

    var body: some View {
        List {
            Section {
                Button {
                    showingImporter = true
                } label: {
                    Label("import_book", systemImage: "square.and.arrow.down")
                }
            }

            if libraryStore.books.isEmpty {
                ContentUnavailableView(
                    NSLocalizedString("empty_library_title", comment: ""),
                    systemImage: "book.closed",
                    description: Text("empty_library_subtitle")
                )
            } else {
                ForEach(libraryStore.books) { book in
                    NavigationLink {
                        ReaderView(book: book)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title).font(.headline)
                            Text(book.author).font(.subheadline).foregroundStyle(.secondary)
                            Text(book.format.rawValue.uppercased()).font(.caption).foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("library_tab")
        .alert("import_failed", isPresented: Binding(get: { importError != nil }, set: { _ in importError = nil })) {
            Button("ok", role: .cancel) { }
        } message: {
            Text(importError ?? "")
        }
        .fileImporter(
            isPresented: $showingImporter,
            allowedContentTypes: [.epub, .plainText, .pdf],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case let .success(urls):
                guard let url = urls.first else { return }
                do {
                    try libraryStore.importBook(from: url)
                } catch {
                    importError = error.localizedDescription
                }
            case let .failure(error):
                importError = error.localizedDescription
            }
        }
    }
}

private extension UTType {
    static let epub = UTType(filenameExtension: "epub") ?? .data
}
