import SwiftUI

enum ReaderTheme: String, CaseIterable, Identifiable {
    case paper
    case sepia
    case darkGray
    case pureBlack
    case softGreen

    var id: String { rawValue }

    var displayName: String {
        NSLocalizedString("theme_\(rawValue)", comment: "")
    }

    var background: Color {
        switch self {
        case .paper: return Color(red: 0.98, green: 0.96, blue: 0.91)
        case .sepia: return Color(red: 0.93, green: 0.86, blue: 0.72)
        case .darkGray: return Color(red: 0.16, green: 0.16, blue: 0.18)
        case .pureBlack: return .black
        case .softGreen: return Color(red: 0.85, green: 0.92, blue: 0.84)
        }
    }

    var foreground: Color {
        switch self {
        case .darkGray, .pureBlack:
            return .white
        default:
            return .black
        }
    }
}
