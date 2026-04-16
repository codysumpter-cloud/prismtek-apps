import Foundation
import SwiftUI

// MARK: - App Tabs

enum AppTab: String, Codable, CaseIterable, Hashable, Identifiable {
    case missionControl
    case editor
    case buddy
    case files
    case skills
    case artifacts
    case pairing
    case models
    case chat
    case pricing
    case settings

    var id: String { rawValue }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)
        switch rawValue {
        case "home":
            self = .missionControl
        default:
            guard let tab = AppTab(rawValue: rawValue) else {
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Unknown app tab: \(rawValue)"
                )
            }
            self = tab
        }
    }

    var title: String {
        switch self {
        case .missionControl: return "Home"
        case .editor: return "Editor"
        case .buddy: return "Buddy"
        case .files: return "Workspace"
        case .skills: return "Skills"
        case .artifacts: return "Results"
        case .pairing: return "Mac"
        case .models: return "Models"
        case .chat: return "Chat"
        case .pricing: return "Pricing"
        case .settings: return "Settings"
        }
    }

    var systemImage: String {
        switch self {
        case .missionControl: return "heart.text.square.fill"
        case .editor: return "doc.text.fill"
        case .buddy: return "person.crop.circle.badge.checkmark"
        case .files: return "folder.fill"
        case .skills: return "sparkles.rectangle.stack.fill"
        case .artifacts: return "checklist.checked"
        case .pairing: return "macbook.and.iphone"
        case .models: return "cpu"
        case .chat: return "message.fill"
        case .pricing: return "creditcard.fill"
        case .settings: return "gearshape.fill"
        }
    }

    var allowsHiding: Bool {
        self != .missionControl
    }
}

// MARK: - Preferences

struct ShellPreferences: Codable, Hashable {
    var orderedTabs: [AppTab]
    var hiddenTabs: Set<AppTab>
    var selectedTab: AppTab

    static let `default` = ShellPreferences(
        orderedTabs: [.missionControl, .buddy, .chat, .skills, .models, .artifacts, .files, .settings, .pairing, .pricing, .editor],
        hiddenTabs: [.pairing, .pricing, .editor],
        selectedTab: .missionControl
    )

    func normalized() -> ShellPreferences {
        var order = orderedTabs
        for tab in AppTab.allCases where !order.contains(tab) {
            order.append(tab)
        }
        order = order.filter { AppTab.allCases.contains($0) }

        var hidden = hiddenTabs.filter { $0.allowsHiding && AppTab.allCases.contains($0) }
        if order.filter({ !hidden.contains($0) }).isEmpty {
            hidden.removeAll()
        }

        let selected = hidden.contains(selectedTab) ? order.first(where: { !hidden.contains($0) }) ?? .missionControl : selectedTab
        return ShellPreferences(orderedTabs: order, hiddenTabs: hidden, selectedTab: selected)
    }

    var visibleTabs: [AppTab] {
        let normalized = normalized()
        return normalized.orderedTabs.filter { !normalized.hiddenTabs.contains($0) }
    }
}

enum AppColorTheme: String, Codable, Hashable, CaseIterable, Identifiable {
    case system
    case dark

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .system: return "System"
        case .dark: return "Dark"
        }
    }

    var preferredColorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .dark: return .dark
        }
    }
}

struct UserPreferences: Codable, Hashable {
    var preferredName: String
    var theme: AppColorTheme
    var userProfileMarkdown: String
    var soulProfileMarkdown: String

    static let `default` = UserPreferences(
        preferredName: "",
        theme: .dark,
        userProfileMarkdown: "",
        soulProfileMarkdown: ""
    )
}
