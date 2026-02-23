import SwiftUI

@main
struct LiquidLeafApp: App {
    @StateObject private var libraryStore = LibraryStore()
    @StateObject private var readingTracker = ReadingTracker()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(libraryStore)
                .environmentObject(readingTracker)
                .task {
                    libraryStore.loadLibrary()
                    readingTracker.load()
                }
        }
    }
}
