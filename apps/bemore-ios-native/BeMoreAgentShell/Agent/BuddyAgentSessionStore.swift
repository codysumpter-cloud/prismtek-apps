import Foundation

@MainActor
final class BuddyAgentSessionStore: ObservableObject {
    @Published private(set) var activeSession: BuddyAgentSession?
    @Published private(set) var activeDelegation: BuddyDelegation?
    @Published private(set) var workerReports: [BuddyWorkerReport] = []
    @Published private(set) var timeline: [BuddyAgentTimelineEvent] = []
    @Published private(set) var receipts: [BuddyReceipt] = []
    @Published private(set) var worldState: BuddyWorldState = .empty

    var latestWorkerStatus: String {
        workerReports.first?.status.displayLabel ?? worldState.lilBuddyStatus
    }

    func startSession(originalHumanRequest: String) {
        let request = sanitizedMission(originalHumanRequest)
        let session = BuddyAgentSession(
            id: UUID(),
            schemaVersion: buddyAgentSessionSchemaVersion,
            originalHumanRequest: request,
            orchestrator: BuddyAgentRuntimeProfile.buddy,
            worker: BuddyAgentRuntimeProfile.lilBuddy,
            status: .running,
            createdAt: Date()
        )
        activeSession = session
        activeDelegation = nil
        workerReports = []
        receipts = []
        timeline = [
            BuddyAgentTimelineEvent(
                speaker: "Buddy",
                role: .orchestrator,
                summary: "Mission received: \"\(request)\". Buddy owns the conversation and delegates bounded steps."
            ),
            BuddyAgentTimelineEvent(
                speaker: "Lil' Buddy",
                role: .worker,
                summary: "Ready. Lil' Buddy works delegated steps and reports back to Buddy."
            )
        ]
        updateWorldState(
            mission: request,
            surface: .browser,
            activeTool: nil,
            artifact: "Session started",
            buddyStatus: "owning the mission",
            lilBuddyStatus: "ready for delegated work"
        )
    }

    func createDelegatedAction(
        title: String,
        intent: String,
        type: BuddyActionType,
        risk: BuddyRiskClass,
        currentURL: String
    ) -> BuddyAction {
        ensureSession()
        guard let session = activeSession else {
            return BuddyAction.draft(
                sessionId: nil,
                delegationId: nil,
                buddyId: "default",
                title: title,
                intent: intent,
                type: type,
                risk: risk,
                currentURL: currentURL
            )
        }

        let delegation = BuddyDelegation(
            id: UUID(),
            sessionId: session.id,
            orchestratorAgentId: session.orchestrator.agentId,
            workerAgentId: session.worker.agentId,
            objective: title,
            nextInstruction: intent,
            status: risk.requiresApproval ? .blocked : .running,
            createdAt: Date()
        )
        activeDelegation = delegation

        appendTimeline(
            speaker: "Buddy",
            role: .orchestrator,
            summary: risk.requiresApproval
                ? "Lil' Buddy requested a step that needs approval. Buddy paused the loop."
                : "Delegated to Lil' Buddy: \(title)."
        )
        updateWorldState(
            surface: surface(for: type),
            activeTool: type.rawValue,
            artifact: risk.requiresApproval ? "Approval needed: \(title)" : "Delegated: \(title)",
            buddyStatus: risk.requiresApproval ? "approval needed" : "delegating",
            lilBuddyStatus: risk.requiresApproval ? "paused" : "working"
        )

        return BuddyAction.draft(
            sessionId: session.id,
            delegationId: delegation.id,
            buddyId: "default",
            title: title,
            intent: intent,
            type: type,
            risk: risk,
            currentURL: currentURL
        )
    }

    @discardableResult
    func completeWorkerStep(_ action: BuddyAction) -> BuddyReceipt {
        let receipt = BuddyReceipt.from(action: action, status: .completed, summary: action.type.receiptSummary)
        receipts.insert(receipt, at: 0)
        let report = BuddyWorkerReport(
            sessionId: action.sessionId,
            delegationId: action.delegationId,
            status: .stepCompleted,
            summary: "Completed \(action.title) and produced receipt \(receipt.id.uuidString.prefix(8)).",
            completedActionIds: [action.id],
            producedReceiptIds: [receipt.id],
            proposedNextInstruction: "Buddy can choose the next step from the original mission."
        )
        workerReports.insert(report, at: 0)
        activeSession?.status = .running
        activeDelegation?.status = .completed
        appendTimeline(speaker: "Lil' Buddy", role: .worker, summary: report.summary)
        appendTimeline(speaker: "Buddy", role: .orchestrator, summary: "Report received. Buddy can continue the mission.")
        updateWorldState(
            surface: surface(for: action.type),
            activeTool: nil,
            artifact: "Receipt: \(receipt.title)",
            receiptId: receipt.id,
            buddyStatus: "continuing mission",
            lilBuddyStatus: "reported step complete"
        )
        return receipt
    }

    @discardableResult
    func cancelWorkerStep(_ action: BuddyAction) -> BuddyReceipt {
        let receipt = BuddyReceipt.from(
            action: action,
            status: .cancelled,
            summary: "The delegated worker step was cancelled before completion."
        )
        receipts.insert(receipt, at: 0)
        let report = BuddyWorkerReport(
            sessionId: action.sessionId,
            delegationId: action.delegationId,
            status: .blocked,
            summary: "The delegated step was cancelled before completion.",
            completedActionIds: [],
            producedReceiptIds: [receipt.id],
            proposedNextInstruction: "Buddy should choose a clearer next step."
        )
        workerReports.insert(report, at: 0)
        activeDelegation?.status = .cancelled
        appendTimeline(speaker: "Lil' Buddy", role: .worker, summary: report.summary)
        updateWorldState(
            activeTool: nil,
            artifact: "Cancelled: \(action.title)",
            receiptId: receipt.id,
            buddyStatus: "needs replan",
            lilBuddyStatus: "blocked"
        )
        return receipt
    }

    @discardableResult
    func approveGatedAction(_ action: BuddyAction) -> BuddyReceipt {
        let receipt = BuddyReceipt.from(
            action: action,
            status: .completed,
            summary: "Human approval came through Buddy. Lil' Buddy may resume with a bounded next step."
        )
        receipts.insert(receipt, at: 0)
        let report = BuddyWorkerReport(
            sessionId: action.sessionId,
            delegationId: action.delegationId,
            status: .stepCompleted,
            summary: "Approval received through Buddy. The gated step is recorded and the loop may continue.",
            completedActionIds: [action.id],
            producedReceiptIds: [receipt.id],
            proposedNextInstruction: "Resume with the next bounded step."
        )
        workerReports.insert(report, at: 0)
        activeSession?.status = .running
        activeDelegation?.status = .completed
        appendTimeline(speaker: "Buddy", role: .orchestrator, summary: "Approval received. Buddy is resuming Lil' Buddy with a bounded step.")
        appendTimeline(speaker: "Lil' Buddy", role: .worker, summary: report.summary)
        updateWorldState(
            surface: surface(for: action.type),
            activeTool: nil,
            artifact: "Approved: \(action.title)",
            receiptId: receipt.id,
            buddyStatus: "resuming mission",
            lilBuddyStatus: "resumed"
        )
        return receipt
    }

    @discardableResult
    func denyGatedAction(_ action: BuddyAction) -> BuddyReceipt {
        let receipt = BuddyReceipt.from(
            action: action,
            status: .denied,
            summary: "Buddy denied the gated worker request. Lil' Buddy stopped and needs a safer plan."
        )
        receipts.insert(receipt, at: 0)
        let report = BuddyWorkerReport(
            sessionId: action.sessionId,
            delegationId: action.delegationId,
            status: .needsApproval,
            summary: "The gated step was denied. Lil' Buddy stopped and reported back to Buddy.",
            completedActionIds: [],
            producedReceiptIds: [receipt.id],
            proposedNextInstruction: "Buddy should replan without that step."
        )
        workerReports.insert(report, at: 0)
        activeSession?.status = .waitingForHuman
        activeDelegation?.status = .blocked
        appendTimeline(speaker: "Buddy", role: .orchestrator, summary: "Denied. Buddy will replan instead of continuing that path.")
        appendTimeline(speaker: "Lil' Buddy", role: .worker, summary: report.summary)
        updateWorldState(
            activeTool: nil,
            artifact: "Denied: \(action.title)",
            receiptId: receipt.id,
            buddyStatus: "replanning",
            lilBuddyStatus: "paused"
        )
        return receipt
    }

    @discardableResult
    func runSafeDemo(originalHumanRequest: String, currentURL: String) -> [BuddyReceipt] {
        startSession(originalHumanRequest: originalHumanRequest)
        let steps: [(String, String, BuddyActionType, BuddyRiskClass)] = [
            ("Summarize Page", "Lil' Buddy should inspect the current page and prepare a concise summary.", .browserSummarize, .readOnly),
            ("Save Memory", "Lil' Buddy should stage the useful takeaway as a Buddy memory.", .memoryRemember, .draftOnly),
            ("Note Draft", "Lil' Buddy should prepare a note draft from the result.", .noteDraft, .draftOnly),
        ]
        var generatedReceipts: [BuddyReceipt] = []
        for step in steps {
            let action = createDelegatedAction(
                title: step.0,
                intent: step.1,
                type: step.2,
                risk: step.3,
                currentURL: currentURL
            )
            generatedReceipts.append(completeWorkerStep(action))
        }
        activeSession?.status = .completed
        appendTimeline(speaker: "Buddy", role: .orchestrator, summary: "Demo loop complete. Buddy stayed human-facing; Lil' Buddy did the worker steps.")
        updateWorldState(activeTool: nil, artifact: "Mission demo completed", buddyStatus: "mission complete", lilBuddyStatus: "done")
        return generatedReceipts
    }

    private func ensureSession() {
        if activeSession == nil {
            startSession(originalHumanRequest: "Continue from the current Agent Browser context.")
        }
    }

    private func sanitizedMission(_ mission: String) -> String {
        let trimmed = mission.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Continue from the current Agent Browser context." : trimmed
    }

    private func appendTimeline(speaker: String, role: BuddyAgentRole, summary: String) {
        timeline.insert(BuddyAgentTimelineEvent(speaker: speaker, role: role, summary: summary), at: 0)
    }

    private func surface(for actionType: BuddyActionType) -> BuddyWorldSurface {
        switch actionType {
        case .browserOpen, .browserSummarize:
            return .browser
        case .memoryRemember:
            return .memory
        case .noteDraft:
            return .notes
        case .calendarDraft, .calendarCreate:
            return .calendar
        case .messageDraft:
            return .messages
        case .emailDraft:
            return .email
        }
    }

    private func updateWorldState(
        mission: String? = nil,
        surface: BuddyWorldSurface? = nil,
        activeTool: String? = nil,
        artifact: String? = nil,
        receiptId: UUID? = nil,
        buddyStatus: String? = nil,
        lilBuddyStatus: String? = nil
    ) {
        var artifacts = worldState.visibleArtifacts
        if let artifact {
            artifacts.insert(artifact, at: 0)
            artifacts = Array(artifacts.prefix(12))
        }
        var receiptIds = worldState.recentReceiptIds
        if let receiptId {
            receiptIds.insert(receiptId, at: 0)
            receiptIds = Array(receiptIds.prefix(12))
        }
        worldState = BuddyWorldState(
            currentMission: mission ?? activeSession?.originalHumanRequest ?? worldState.currentMission,
            activeSurface: surface ?? worldState.activeSurface,
            activeTool: activeTool,
            visibleArtifacts: artifacts,
            recentReceiptIds: receiptIds,
            buddyStatus: buddyStatus ?? worldState.buddyStatus,
            lilBuddyStatus: lilBuddyStatus ?? worldState.lilBuddyStatus
        )
    }
}
