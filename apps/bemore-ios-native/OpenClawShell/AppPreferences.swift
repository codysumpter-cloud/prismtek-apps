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
        case .editor: return "Studio"
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
        case .editor: return "paintpalette.fill"
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

    var isInternalDraft: Bool {
        false
    }
}

// MARK: - Preferences

struct ShellPreferences: Codable, Hashable {
    var orderedTabs: [AppTab]
    var hiddenTabs: Set<AppTab>
    var selectedTab: AppTab

    static let `default` = ShellPreferences(
        orderedTabs: [.missionControl, .buddy, .chat, .editor, .skills, .models, .artifacts, .files, .settings, .pairing, .pricing],
        hiddenTabs: [.pairing, .pricing],
        selectedTab: .missionControl
    )

    func normalized() -> ShellPreferences {
        var order = orderedTabs
        for tab in AppTab.allCases where !order.contains(tab) {
            order.append(tab)
        }
        order = order.reduce(into: [AppTab]()) { result, tab in
            guard AppTab.allCases.contains(tab), !result.contains(tab) else { return }
            result.append(tab)
        }

        if let modelsIndex = order.firstIndex(of: .models), let skillsIndex = order.firstIndex(of: .skills), modelsIndex > skillsIndex + 1 {
            order.remove(at: modelsIndex)
            order.insert(.models, at: skillsIndex + 1)
        }

        var hidden = hiddenTabs.filter { ($0.allowsHiding || $0.isInternalDraft) && AppTab.allCases.contains($0) }
        hidden.subtract([.buddy, .chat, .editor, .skills, .models, .artifacts, .files, .settings])
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
