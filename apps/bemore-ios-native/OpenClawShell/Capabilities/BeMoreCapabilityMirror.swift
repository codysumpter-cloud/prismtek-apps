import Foundation
import SwiftUI

enum BeMoreCapabilityRouteMode: String, Hashable {
    case native
    case nativePlusWebShell = "native+web-shell"
    case linkedAccount = "linked-account"
    case linkedRuntime = "linked-runtime"
    case webShell = "web-shell"
}

enum BeMoreTrustBoundary: String, Hashable {
    case nativeApp = "native_app"
    case linkedAccount = "linked_account"
    case linkedRuntime = "linked_runtime"
    case webShell = "web_shell"

    var title: String {
        switch self {
        case .nativeApp: return "Native app"
        case .linkedAccount: return "Linked account"
        case .linkedRuntime: return "Linked runtime"
        case .webShell: return "Web shell"
        }
    }
}

struct BeMoreCapabilityGroup: Identifiable, Hashable {
    let id: String
    let title: String
    let description: String
}

struct BeMoreCapabilityDescriptor: Identifiable, Hashable {
    let id: String
    let title: String
    let groupID: String
    let permissions: [String]
    let routeMode: BeMoreCapabilityRouteMode
    let trustBoundary: BeMoreTrustBoundary
    let appSurface: String
    let notes: String
}

enum BeMoreCapabilityAvailability: Hashable {
    case available
    case availableViaWebSurface
    case partial
    case requiresLinkedAccount
    case requiresLinkedRuntime
    case unavailable

    var label: String {
        switch self {
        case .available: return "Available"
        case .availableViaWebSurface: return "Web surface"
        case .partial: return "Partial"
        case .requiresLinkedAccount: return "Needs account link"
        case .requiresLinkedRuntime: return "Needs linked runtime"
        case .unavailable: return "Unavailable"
        }
    }

    var color: Color {
        switch self {
        case .available: return BMOTheme.success
        case .availableViaWebSurface: return BMOTheme.accent
        case .partial: return BMOTheme.warning
        case .requiresLinkedAccount, .requiresLinkedRuntime: return BMOTheme.warning
        case .unavailable: return BMOTheme.error
        }
    }
}

struct BeMoreCapabilityStatus: Identifiable, Hashable {
    var id: String { capability.id }
    let capability: BeMoreCapabilityDescriptor
    let availability: BeMoreCapabilityAvailability
    let reason: String
}

enum BeMoreCapabilityMirror {
    static let groups: [BeMoreCapabilityGroup] = [
        .init(id: "companion", title: "Companion", description: "Day planning, follow-through, teaching, memory shaping, and Buddy care/training."),
        .init(id: "workspace", title: "Workspace", description: "Reading, writing, supervising, and exporting workspace artifacts."),
        .init(id: "research", title: "Research", description: "Web, docs, and repository discovery."),
        .init(id: "repo", title: "Repo", description: "GitHub/private repo access and git mutation through approved routes."),
        .init(id: "skills", title: "Skills", description: "Skill authoring, validation, install, equip, run, and supervision."),
        .init(id: "studio", title: "Studio", description: "Pixel Studio, animation planning, Builder Studio, and creator surfaces."),
        .init(id: "admin", title: "Admin", description: "Mission Control, builder/admin tools, profile management, and operator settings."),
        .init(id: "runtime", title: "Runtime", description: "Terminal/process execution, safe command routing, runtime resume, and deep operator actions.")
    ]

    static let capabilities: [BeMoreCapabilityDescriptor] = [
        .init(id: "buddy.chat", title: "Buddy Chat", groupID: "companion", permissions: ["event.emit"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Chat", notes: "Core Buddy conversation and everyday help."),
        .init(id: "buddy.train", title: "Buddy Training", groupID: "companion", permissions: ["workspace.write", "artifact.write"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Buddy", notes: "Tamagotchi-style care, growth, memory shaping, and training loops."),
        .init(id: "buddy.memory", title: "Buddy Memory", groupID: "companion", permissions: ["workspace.read", "workspace.write", "artifact.write"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Buddy / Results", notes: "Facts, preferences, session state, and durable memory artifacts."),
        .init(id: "workspace.read", title: "Workspace Read", groupID: "workspace", permissions: ["workspace.read"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Workspace / Results", notes: "Read app-owned BeMore workspace files and runtime-owned artifacts."),
        .init(id: "workspace.write", title: "Workspace Write", groupID: "workspace", permissions: ["workspace.write", "artifact.write"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Workspace / Results", notes: "Persist workspace edits and Buddy-created artifacts with receipts."),
        .init(id: "artifact.supervise", title: "Artifact Supervision", groupID: "workspace", permissions: ["workspace.read", "event.emit"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Results", notes: "Preview, inspect, and export generated artifacts."),
        .init(id: "web.read", title: "Web Research", groupID: "research", permissions: ["network.read", "event.emit"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Chat / Studio", notes: "Web browsing and documentation lookup."),
        .init(id: "github.read.public", title: "GitHub Public Read", groupID: "repo", permissions: ["network.read", "event.emit"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Chat / Studio", notes: "Search public repositories, issues, and code metadata."),
        .init(id: "github.read.private", title: "GitHub Private Read", groupID: "repo", permissions: ["network.read", "approval.request"], routeMode: .linkedAccount, trustBoundary: .linkedAccount, appSurface: "Settings / Chat", notes: "Requires linked GitHub account or approved runtime credentials."),
        .init(id: "git.mutate", title: "Git Mutate", groupID: "repo", permissions: ["workspace.write", "approval.request"], routeMode: .linkedRuntime, trustBoundary: .linkedRuntime, appSurface: "Mission Control / Chat", notes: "Requires paired runtime for real repo mutation and patch application."),
        .init(id: "skill.author", title: "Skill Authoring", groupID: "skills", permissions: ["workspace.write", "artifact.write", "approval.request"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Chat / Results", notes: "Teach, review, refine, validate, and approve reusable Buddy skills."),
        .init(id: "skill.run", title: "Skill Run", groupID: "skills", permissions: ["workspace.read", "workspace.write", "artifact.write"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Skills / Results", notes: "Run approved manifest-backed skills and persist their outputs."),
        .init(id: "pokemon.team-builder", title: "Pokemon Team Builder", groupID: "skills", permissions: ["workspace.read", "workspace.write", "artifact.write"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Skills / Results", notes: "Flagship real skill backed by receipts and saved artifacts."),
        .init(id: "studio.pixel", title: "Pixel Studio", groupID: "studio", permissions: ["workspace.write", "artifact.write"], routeMode: .nativePlusWebShell, trustBoundary: .nativeApp, appSurface: "Studio", notes: "Pixel project brief, Buddy finish/improve/animate artifacts, and web Pixel Studio surface."),
        .init(id: "studio.pixel.animate", title: "Pixel Animation Assist", groupID: "studio", permissions: ["workspace.write", "artifact.write"], routeMode: .native, trustBoundary: .nativeApp, appSurface: "Studio / Chat", notes: "Buddy animation plans and finish passes for pixel projects."),
        .init(id: "admin.builder", title: "Builder Studio", groupID: "admin", permissions: ["admin.access"], routeMode: .webShell, trustBoundary: .webShell, appSurface: "Studio", notes: "Website builder/admin tool surfaced inside the app shell."),
        .init(id: "admin.mission-control", title: "Admin Mission Control", groupID: "admin", permissions: ["admin.access"], routeMode: .webShell, trustBoundary: .webShell, appSurface: "Studio", notes: "Website admin Mission Control surfaced inside the app shell."),
        .init(id: "profile.manage", title: "Profile Management", groupID: "admin", permissions: ["profile.manage"], routeMode: .webShell, trustBoundary: .webShell, appSurface: "Studio / Settings", notes: "User-created profiles and account surfaces."),
        .init(id: "runtime.exec.safe", title: "Safe Runtime Exec", groupID: "runtime", permissions: ["approval.request", "event.emit"], routeMode: .linkedRuntime, trustBoundary: .linkedRuntime, appSurface: "Mission Control / Chat", notes: "Controlled command execution routed through paired runtime."),
        .init(id: "runtime.exec.full", title: "Full Runtime Exec", groupID: "runtime", permissions: ["approval.request", "event.emit"], routeMode: .linkedRuntime, trustBoundary: .linkedRuntime, appSurface: "Mission Control", notes: "Deep operator execution only through paired runtime, never hidden in the app."),
        .init(id: "runtime.resume", title: "Runtime Resume", groupID: "runtime", permissions: ["workspace.read", "event.emit"], routeMode: .linkedRuntime, trustBoundary: .linkedRuntime, appSurface: "Mission Control / Results", notes: "Resume sessions, task/results, and open approvals from paired runtime."),
        .init(id: "account.chatgpt-link", title: "ChatGPT/OpenAI Account Link", groupID: "runtime", permissions: ["approval.request"], routeMode: .linkedAccount, trustBoundary: .linkedAccount, appSurface: "Settings", notes: "Requires a real OAuth client flow; contract present even if the app has not shipped it yet.")
    ]

    static func groupTitle(for id: String) -> String {
        groups.first(where: { $0.id == id })?.title ?? id
    }
}

@MainActor
extension AppState {
    var beMoreCapabilityStatuses: [BeMoreCapabilityStatus] {
        BeMoreCapabilityMirror.capabilities.map { capability in
            let availability: BeMoreCapabilityAvailability
            let reason: String
            switch capability.routeMode {
            case .native:
                availability = .available
                reason = "Buddy can use this directly on iPhone today."
            case .nativePlusWebShell:
                availability = .partial
                reason = "Buddy has native artifact/project help plus a linked web Studio surface in the app."
            case .webShell:
                availability = .availableViaWebSurface
                reason = "Available in-app through the embedded prismtek.dev web shell surface."
            case .linkedAccount:
                availability = .requiresLinkedAccount
                reason = "The contract is mirrored, but real account linking still needs a shipped OAuth flow."
            case .linkedRuntime:
                if macRuntimeSnapshot != nil {
                    availability = .available
                    reason = "A paired runtime is active, so Buddy can route this capability through the linked runtime surface."
                } else {
                    availability = .requiresLinkedRuntime
                    reason = "This capability is Hermes-parity only when a linked runtime is active."
                }
            }
            return BeMoreCapabilityStatus(capability: capability, availability: availability, reason: reason)
        }
    }

    var availableCapabilityCount: Int {
        beMoreCapabilityStatuses.filter { [.available, .availableViaWebSurface].contains($0.availability) }.count
    }

    var linkedRuntimeCapabilityCount: Int {
        beMoreCapabilityStatuses.filter { $0.availability == .requiresLinkedRuntime }.count
    }

    var linkedAccountCapabilityCount: Int {
        beMoreCapabilityStatuses.filter { $0.availability == .requiresLinkedAccount }.count
    }

    func capabilityStatuses(in groupID: String) -> [BeMoreCapabilityStatus] {
        beMoreCapabilityStatuses.filter { $0.capability.groupID == groupID }
    }
}
