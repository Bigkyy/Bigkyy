import SwiftUI

struct ReaderView: View {
    let document: ReaderDocument
    @Binding var fontSize: CGFloat
    @Binding var backgroundStyle: ReaderBackgroundStyle

    var body: some View {
        ScrollView {
            Text(document.content)
                .font(.system(size: fontSize, weight: .regular, design: .serif))
                .foregroundStyle(textColor)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(24)
        }
        .background(backgroundGradient)
        .navigationTitle(document.fileName)
        .navigationBarTitleDisplayMode(.inline)
    }

    private var textColor: Color {
        switch backgroundStyle {
        case .night: return .white.opacity(0.9)
        default: return .primary
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(colors: styleColors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .ignoresSafeArea()
    }

    private var styleColors: [Color] {
        switch backgroundStyle {
        case .paper: return [Color(red: 0.98, green: 0.95, blue: 0.86), Color(red: 0.96, green: 0.93, blue: 0.84)]
        case .night: return [Color.black, Color(red: 0.08, green: 0.09, blue: 0.14)]
        case .mint: return [Color(red: 0.88, green: 0.98, blue: 0.95), Color(red: 0.79, green: 0.94, blue: 0.9)]
        case .sky: return [Color(red: 0.88, green: 0.94, blue: 1.0), Color(red: 0.76, green: 0.87, blue: 0.99)]
        }
    }
}
