import Foundation
import SwiftUI

// MARK: - App Tabs
enum AppTab: String, CaseIterable, Codable, Identifiable, Hashable {
    case home
    case chat
    case files
    case models
    case pricing
    case buddy
    case settings

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home: return "Home"
        case .chat: return "Chat"
        case .files: return "Files"
        case .models: return "Models"
        case .pricing: return "Pricing"
        case .buddy: return "Buddy"
        case .settings: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .home: return "house.fill"
        case .chat: return "message.fill"
        case .files: return "folder.fill"
        case .models: return "cpu"
        case .pricing: return "creditcard.fill"
        case .buddy: return "person.fill"
        case .settings: return "gearshape.fill"
        }
    }
}

// MARK: - Preferences

struct UserPreferences: Codable, Hashable {
    var theme: AppColorTheme = .dark
    var notificationsEnabled: Bool = true
    var autoUpdateEnabled: Bool = true

    static let `default` = UserPreferences()
}

struct ShellPreferences: Codable, Hashable {
    var fontSize: CGFloat = 14
    var showLineNumbers: Bool = true
    var cursorStyle: String = "block"

    static let `default` = ShellPreferences()
}

enum AppColorTheme: String, Codable, CaseIterable {
    case light
    case dark
    case system

    static let `default`: AppColorTheme = .dark
}
