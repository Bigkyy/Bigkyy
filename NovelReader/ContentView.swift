import SwiftUI

struct ContentView: View {
    @State private var documents: [ReaderDocument] = []
    @State private var selection: ReaderDocument?
    @State private var showingImporter = false
    @State private var fontSize: CGFloat = 20
    @State private var backgroundStyle: ReaderBackgroundStyle = .paper
    @State private var importError: String?

    private let importer = DocumentImportService()

    var body: some View {
        NavigationSplitView {
            List(documents, selection: $selection) { document in
                VStack(alignment: .leading, spacing: 4) {
                    Text(document.fileName)
                        .font(.headline)
                    Text(document.importedAt, style: .date)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(8)
                .glassCard()
            }
            .navigationTitle(String(localized: "library_title"))
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingImporter = true
                    } label: {
                        Label(String(localized: "import_button"), systemImage: "square.and.arrow.down")
                    }
                }
            }
            .fileImporter(
                isPresented: $showingImporter,
                allowedContentTypes: DocumentImportService.supportedTypes,
                allowsMultipleSelection: true
            ) { result in
                switch result {
                case let .success(urls):
                    importDocuments(urls)
                case let .failure(error):
                    importError = error.localizedDescription
                }
            }
        } detail: {
            if let selection {
                ReaderView(document: selection, fontSize: $fontSize, backgroundStyle: $backgroundStyle)
                    .safeAreaInset(edge: .bottom) {
                        controls
                    }
            } else {
                emptyState
            }
        }
        .alert(String(localized: "import_failed_title"), isPresented: Binding(
            get: { importError != nil },
            set: { if !$0 { importError = nil } }
        )) {
            Button(String(localized: "ok_button"), role: .cancel) { }
        } message: {
            Text(importError ?? "")
        }
    }

    private var controls: some View {
        VStack(spacing: 12) {
            HStack {
                Text(String(localized: "font_size_label"))
                Slider(value: $fontSize, in: 14...34, step: 1)
                Text("\(Int(fontSize))")
                    .font(.caption.monospacedDigit())
                    .frame(width: 32)
            }

            Picker(String(localized: "theme_label"), selection: $backgroundStyle) {
                Text(String(localized: "theme_paper")).tag(ReaderBackgroundStyle.paper)
                Text(String(localized: "theme_night")).tag(ReaderBackgroundStyle.night)
                Text(String(localized: "theme_mint")).tag(ReaderBackgroundStyle.mint)
                Text(String(localized: "theme_sky")).tag(ReaderBackgroundStyle.sky)
            }
            .pickerStyle(.segmented)
        }
        .padding(16)
        .glassCard()
        .padding(.horizontal)
        .padding(.bottom, 10)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "book.pages")
                .font(.system(size: 46))
                .foregroundStyle(.secondary)
            Text(String(localized: "empty_title"))
                .font(.title3.bold())
            Text(String(localized: "empty_subtitle"))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
            Button {
                showingImporter = true
            } label: {
                Label(String(localized: "import_button"), systemImage: "square.and.arrow.down")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(30)
        .glassCard()
        .padding()
    }

    private func importDocuments(_ urls: [URL]) {
        var added: [ReaderDocument] = []

        for url in urls {
            do {
                let document = try importer.importDocument(from: url)
                added.append(document)
            } catch {
                importError = error.localizedDescription
            }
        }

        documents.insert(contentsOf: added, at: 0)
        if selection == nil {
            selection = documents.first
        }
    }
}

private struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .stroke(.white.opacity(0.25), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 6)
    }
}

private extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}
