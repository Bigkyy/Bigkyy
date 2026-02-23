import SwiftUI

struct RootTabView: View {
    var body: some View {
        TabView {
            NavigationStack {
                LibraryView()
            }
            .tabItem {
                Label("library_tab", systemImage: "books.vertical")
            }

            NavigationStack {
                ContinueReadingView()
            }
            .tabItem {
                Label("continue_tab", systemImage: "clock.arrow.circlepath")
            }

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("settings_tab", systemImage: "gear")
            }
        }
    }
}
