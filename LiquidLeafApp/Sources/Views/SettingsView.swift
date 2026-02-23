import SwiftUI

struct SettingsView: View {
    var body: some View {
        List {
            Section("language_title") {
                Text("language_hint")
            }

            Section("about_title") {
                Text("about_body")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("settings_tab")
    }
}
