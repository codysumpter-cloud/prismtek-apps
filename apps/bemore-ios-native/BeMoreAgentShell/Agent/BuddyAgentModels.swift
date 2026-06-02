import SwiftUI

let buddyActionLoopSchemaVersion = "2026-06-02.buddy-action.v1"
let buddyAgentSessionSchemaVersion = "2026-06-02.buddy-agent-session.v1"

enum BuddyAgentRole: String, Codable, Equatable {
    case orchestrator
    case worker

    var displayName: String {
        switch self {
        case .orchestrator: return "Buddy"
        case .worker: return "Lil' Buddy"
        }
    }

    var color: Color {
        switch self {
        case .orchestrator: return BMOTheme.accent
        case .worker: return BMOTheme.success
        }
    }
}

enum BuddyAgentSessionStatus: String, Codable, Equatable {
    case open
    case waitingForHuman = "waiting-for-human"
    case running
    case completed
    case failed
    case cancelled

    var displayLabel: String {
        switch self {
        case .open: return "open"
        case .waitingForHuman: return "approval needed"
        case .running: return "running"
        case .completed: return "complete"
        case .failed: return "failed"
        case .cancelled: return "cancelled"
        }
    }

    var color: Color {
        switch self {
        case .open, .running: return BMOTheme.accent
        case .waitingForHuman: return BMOTheme.warning
        case .completed: return BMOTheme.success
        case .failed, .cancelled: return BMOTheme.error
        }
    }
}

enum BuddyDelegationStatus: String, Codable, Equatable {
    case queued
    case running
    case blocked
    case completed
    case cancelled
    case failed
}

enum BuddyWorkerReportStatus: String, Codable, Equatable {
    case stepCompleted = "step-completed"
    case needsNextStep = "needs-next-step"
    case blocked
    case needsApproval = "needs-approval"
    case failed
    case done

    var displayLabel: String {
        switch self {
        case .stepCompleted: return "reported step complete"
        case .needsNextStep: return "waiting for Buddy"
        case .blocked: return "blocked"
        case .needsApproval: return "needs approval"
        case .failed: return "failed"
        case .done: return "done"
        }
    }
}

enum BuddyRiskClass: String, Codable, CaseIterable, Equatable {
    case readOnly = "read-only"
    case draftOnly = "draft-only"
    case write
    case externalAction = "external-action"
    case destructive
    case money
    case identity
    case location
    case credential
    case repoMutation = "repo-mutation"

    var displayLabel: String {
        switch self {
        case .readOnly: return "read-only"
        case .draftOnly: return "draft"
        case .write, .externalAction, .location, .repoMutation: return "confirm"
        case .destructive, .money, .identity: return "deny by default"
        case .credential: return "denied"
        }
    }

    var requiresApproval: Bool {
        switch self {
        case .readOnly, .draftOnly:
            return false
        case .write, .externalAction, .destructive, .money, .identity, .location, .credential, .repoMutation:
            return true
        }
    }

    var systemImage: String {
        switch self {
        case .readOnly: return "checkmark.shield.fill"
        case .draftOnly: return "doc.badge.plus"
        case .write, .externalAction, .location, .repoMutation: return "exclamationmark.shield.fill"
        case .destructive, .money, .identity, .credential: return "lock.shield.fill"
        }
    }

    var color: Color {
        switch self {
        case .readOnly, .draftOnly: return BMOTheme.success
        case .write, .externalAction, .location, .repoMutation: return BMOTheme.warning
        case .destructive, .money, .identity, .credential: return BMOTheme.error
        }
    }
}

enum BuddyActionType: String, Codable, Equatable {
    case browserOpen = "browser.open"
    case browserSummarize = "browser.summarize"
    case memoryRemember = "memory.remember"
    case noteDraft = "note.draft"
    case calendarDraft = "calendar.draft"
    case calendarCreate = "calendar.create"
    case messageDraft = "message.draft"
    case emailDraft = "email.draft"

    var confirmationLabel: String {
        switch self {
        case .browserOpen: return "Open Page"
        case .browserSummarize: return "Lil' Buddy Complete Step"
        case .memoryRemember: return "Lil' Buddy Save Memory"
        case .noteDraft: return "Lil' Buddy Draft Note"
        case .calendarDraft: return "Lil' Buddy Draft Event"
        case .calendarCreate: return "Request Approval"
        case .messageDraft: return "Lil' Buddy Draft Message"
        case .emailDraft: return "Lil' Buddy Draft Email"
        }
    }

    var receiptSummary: String {
        switch self {
        case .browserOpen:
            return "Lil' Buddy opened a guarded browser page."
        case .browserSummarize:
            return "Lil' Buddy prepared a review-safe page summary draft."
        case .memoryRemember:
            return "Lil' Buddy staged a memory write for Buddy review."
        case .noteDraft:
            return "Lil' Buddy prepared a note draft."
        case .calendarDraft:
            return "Lil' Buddy prepared a calendar draft without creating an event."
        case .calendarCreate:
            return "Lil' Buddy requested calendar creation and Buddy routed it through approval."
        case .messageDraft:
            return "Lil' Buddy prepared a message draft without sending."
        case .emailDraft:
            return "Lil' Buddy prepared an email draft without sending."
        }
    }
}

enum BuddyActionStatus: String, Codable, Equatable {
    case draft
    case delegated
    case needsReview = "needs-review"
    case approved
    case running
    case completed
    case failed
    case cancelled
    case denied
}

enum BuddyWorldSurface: String, Codable, Equatable {
    case browser
    case memory
    case notes
    case calendar
    case email
    case messages
    case code
    case repository
}

struct BuddyAgentRuntimeProfile: Identifiable, Codable, Equatable {
    var id: String { agentId }
    var agentId: String
    var buddyId: String
    var role: BuddyAgentRole
    var displayName: String
    var canTalkToHuman: Bool
    var canDelegate: Bool
    var canExecuteTools: Bool

    static let buddy = BuddyAgentRuntimeProfile(
        agentId: "buddy-orchestrator-default",
        buddyId: "default",
        role: .orchestrator,
        displayName: "Buddy",
        canTalkToHuman: true,
        canDelegate: true,
        canExecuteTools: false
    )

    static let lilBuddy = BuddyAgentRuntimeProfile(
        agentId: "lil-buddy-worker-default",
        buddyId: "default",
        role: .worker,
        displayName: "Lil' Buddy",
        canTalkToHuman: false,
        canDelegate: false,
        canExecuteTools: true
    )
}

struct BuddyAgentSession: Identifiable, Codable, Equatable {
    var id: UUID
    var schemaVersion: String
    var originalHumanRequest: String
    var orchestrator: BuddyAgentRuntimeProfile
    var worker: BuddyAgentRuntimeProfile
    var status: BuddyAgentSessionStatus
    var createdAt: Date
}

struct BuddyDelegation: Identifiable, Codable, Equatable {
    var id: UUID
    var sessionId: UUID
    var orchestratorAgentId: String
    var workerAgentId: String
    var objective: String
    var nextInstruction: String
    var status: BuddyDelegationStatus
    var createdAt: Date
}

struct BuddyWorkerReport: Identifiable, Codable, Equatable {
    var id = UUID()
    var sessionId: UUID?
    var delegationId: UUID?
    var status: BuddyWorkerReportStatus
    var summary: String
    var completedActionIds: [UUID]
    var producedReceiptIds: [UUID]
    var proposedNextInstruction: String?
    var createdAt = Date()
}

struct BuddyAgentTimelineEvent: Identifiable, Codable, Equatable {
    var id = UUID()
    var speaker: String
    var role: BuddyAgentRole
    var summary: String
    var createdAt = Date()
}

struct BuddyActionInputRef: Identifiable, Codable, Equatable {
    var id = UUID()
    var kind: String
    var label: String
    var value: String
    var redacted: Bool = false
}

struct BuddyAction: Identifiable, Codable, Equatable {
    var id: UUID
    var schemaVersion: String
    var sessionId: UUID?
    var delegationId: UUID?
    var buddyId: String
    var title: String
    var intent: String
    var type: BuddyActionType
    var source: String
    var status: BuddyActionStatus
    var risk: BuddyRiskClass
    var requiresApproval: Bool
    var assignedAgentRole: BuddyAgentRole
    var createdAt: Date
    var updatedAt: Date?
    var inputRefs: [BuddyActionInputRef]
    var receiptId: String?

    static func draft(
        sessionId: UUID?,
        delegationId: UUID?,
        buddyId: String,
        title: String,
        intent: String,
        type: BuddyActionType,
        risk: BuddyRiskClass,
        currentURL: String
    ) -> BuddyAction {
        BuddyAction(
            id: UUID(),
            schemaVersion: buddyActionLoopSchemaVersion,
            sessionId: sessionId,
            delegationId: delegationId,
            buddyId: buddyId,
            title: title,
            intent: intent,
            type: type,
            source: "orchestrator",
            status: risk.requiresApproval ? .needsReview : .delegated,
            risk: risk,
            requiresApproval: risk.requiresApproval,
            assignedAgentRole: .worker,
            createdAt: Date(),
            updatedAt: nil,
            inputRefs: [
                BuddyActionInputRef(kind: "url", label: "current-page", value: currentURL)
            ],
            receiptId: nil
        )
    }
}

struct BuddyReceipt: Identifiable, Codable, Equatable {
    var id: UUID
    var actionId: UUID
    var sessionId: UUID?
    var delegationId: UUID?
    var agentRole: BuddyAgentRole
    var createdAt: Date
    var status: BuddyActionStatus
    var title: String
    var summary: String
    var risk: BuddyRiskClass
    var redactions: [String]

    static func from(action: BuddyAction, status: BuddyActionStatus, summary: String) -> BuddyReceipt {
        BuddyReceipt(
            id: UUID(),
            actionId: action.id,
            sessionId: action.sessionId,
            delegationId: action.delegationId,
            agentRole: action.assignedAgentRole,
            createdAt: Date(),
            status: status,
            title: action.title,
            summary: summary,
            risk: action.risk,
            redactions: ["raw prompts", "tokens", "cookies", "private keys", "OAuth material"]
        )
    }
}

struct BuddyWorldState: Codable, Equatable {
    var currentMission: String
    var activeSurface: BuddyWorldSurface
    var activeTool: String?
    var visibleArtifacts: [String]
    var recentReceiptIds: [UUID]
    var buddyStatus: String
    var lilBuddyStatus: String

    static let empty = BuddyWorldState(
        currentMission: "No active mission.",
        activeSurface: .browser,
        activeTool: nil,
        visibleArtifacts: [],
        recentReceiptIds: [],
        buddyStatus: "waiting for mission",
        lilBuddyStatus: "ready for safe work"
    )
}
