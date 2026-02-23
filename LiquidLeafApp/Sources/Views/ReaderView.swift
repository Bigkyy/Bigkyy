import SwiftUI

struct ReaderView: View {
    let book: Book

    @EnvironmentObject private var libraryStore: LibraryStore
    @EnvironmentObject private var readingTracker: ReadingTracker
    @StateObject private var viewModel = ReaderViewModel()

    var body: some View {
        ZStack(alignment: .bottom) {
            viewModel.selectedTheme.background
                .ignoresSafeArea()

            ScrollView {
                Text(viewModel.content)
                    .foregroundStyle(viewModel.selectedTheme.foreground)
                    .font(.system(size: 19))
                    .lineSpacing(8)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 28)
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
                    viewModel.toggleToolbar()
                }
            }

            if viewModel.isToolbarVisible {
                VStack(spacing: 12) {
                    HStack {
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.simulatePageTurn(next: false)
                            }
                        } label: {
                            Label("prev_page", systemImage: "chevron.left")
                        }

                        Spacer()

                        Text("\(Int(viewModel.progress * 100))%")
                            .font(.caption)
                            .monospacedDigit()

                        Spacer()

                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                viewModel.simulatePageTurn(next: true)
                            }
                        } label: {
                            Label("next_page", systemImage: "chevron.right")
                        }
                    }

                    Picker("theme_picker", selection: $viewModel.selectedTheme) {
                        ForEach(ReaderTheme.allCases) { theme in
                            Text(theme.displayName).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                .padding(12)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                .padding(.horizontal, 12)
                .padding(.bottom, 6)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            let initial = readingTracker.state(for: book.id).progress
            viewModel.load(book: book, url: libraryStore.url(for: book), initialProgress: initial)
        }
        .onDisappear {
            readingTracker.update(
                bookID: book.id,
                title: book.title,
                progress: viewModel.progress,
                locator: "\(viewModel.currentPage)",
                sessionSeconds: viewModel.sessionSeconds()
            )
        }
    }
}
