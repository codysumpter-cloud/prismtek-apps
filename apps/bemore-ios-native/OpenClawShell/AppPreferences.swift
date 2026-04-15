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
    case missionControl = "home"
    case editor = "files"
    case pairing = "settings"
    case skills = "models"

    var id: String { rawValue }

    var title: String {
        switch self {
        case .home, .missionControl: return "Home"
        case .chat: return "Chat"
        case .files, .editor: return "Files"
        case .models, .skills: return "Models"
        case .pricing: return "Pricing"
        case .buddy: return "Buddy"
        case .settings, .pairing: return "Settings"
        }
    }

    var iconName: String {
        switch self {
        case .home, .missionControl: return "house.fill"
        case .chat: return "message.fill"
        case .files, .editor: return "folder.fill"
        case .models, .skills: return "cpu"
        case .pricing: return "creditcard.fill"
        case .buddy: return "person.fill"
        case .settings, .pairing: return "gearshape.fill"
        }
    }

    var systemImage: String { iconName }
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

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .light: return .light
        case .dark: return .dark
        case .system: return nil
        }
    }

    static let `default`: AppColorTheme = .dark
}
