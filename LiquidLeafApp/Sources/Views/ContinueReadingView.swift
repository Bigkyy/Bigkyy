import SwiftUI

struct ContinueReadingView: View {
    @EnvironmentObject private var libraryStore: LibraryStore
    @EnvironmentObject private var tracker: ReadingTracker

    var body: some View {
        List {
            Section("continue_reading") {
                ForEach(libraryStore.books.filter { (tracker.state(for: $0.id).progress > 0) && (tracker.state(for: $0.id).progress < 1) }) { book in
                    let state = tracker.state(for: book.id)
                    NavigationLink {
                        ReaderView(book: book)
                    } label: {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(book.title).font(.headline)
                            ProgressView(value: state.progress)
                            Text(String(format: NSLocalizedString("progress_percent", comment: ""), Int(state.progress * 100)))
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section("recent_history") {
                ForEach(tracker.recents.prefix(10)) { entry in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(entry.title)
                        Text(entry.openedAt, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("continue_tab")
    }
}
