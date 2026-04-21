import Foundation

enum BeMoreChatCommandParser {
    enum LocalCommand: Equatable {
        case teach(String)
        case review(String)
        case refine(id: String, instruction: String)
        case validate(String)
        case approve(String)
        case pixelAssist(PixelBuddyAction, String)
    }

    static func parse(_ prompt: String) -> LocalCommand? {
        if let request = teachRequest(from: prompt) {
            return .teach(request)
        }
        if let refinement = refinement(from: prompt) {
            return .refine(id: refinement.id, instruction: refinement.instruction)
        }
        if let id = commandID(prefixes: ["review skill ", "inspect skill "], from: prompt) {
            return .review(id)
        }
        if let id = commandID(prefixes: ["validate skill ", "check skill "], from: prompt) {
            return .validate(id)
        }
        if let id = commandID(prefixes: ["approve skill "], from: prompt) {
            return .approve(id)
        }
        if let pixel = pixelCommand(from: prompt) {
            return pixel
        }
        return nil
    }

    static func isLocalCommand(_ prompt: String) -> Bool {
        parse(prompt) != nil
    }

    static func teachRequest(from prompt: String) -> String? {
        let trimmedPrompt = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        let lowered = trimmedPrompt.lowercased()
        let prefixes = [
            "teach yourself how to",
            "teach yourself to",
            "create a skill to",
            "make a reusable skill for",
            "build a skill to"
        ]
        for prefix in prefixes where lowered.hasPrefix(prefix) {
            let request = String(trimmedPrompt.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            if !request.isEmpty { return request }
        }
        return nil
    }

    static func refinement(from prompt: String) -> (id: String, instruction: String)? {
        let lowered = prompt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let prefixes = ["refine skill ", "correct skill ", "update skill "]
        for prefix in prefixes where lowered.hasPrefix(prefix) {
            let remainder = String(prompt.dropFirst(prefix.count))
            let separators = [":", "—", "- "]
            for separator in separators {
                if let range = remainder.range(of: separator) {
                    let id = remainder[..<range.lowerBound].trimmingCharacters(in: .whitespacesAndNewlines)
                    let instruction = remainder[range.upperBound...].trimmingCharacters(in: .whitespacesAndNewlines)
                    if !id.isEmpty && !instruction.isEmpty {
                        return (id, instruction)
                    }
                }
            }
            let chunks = remainder.split(separator: " ", maxSplits: 1, omittingEmptySubsequences: true)
            if chunks.count == 2 {
                let id = String(chunks[0]).trimmingCharacters(in: .whitespacesAndNewlines)
                let instruction = String(chunks[1]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !id.isEmpty && !instruction.isEmpty {
                    return (id, instruction)
                }
            }
        }
        return nil
    }

    private static func pixelCommand(from prompt: String) -> LocalCommand? {
        let lowered = prompt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        let finishPrefixes = [
            "finish this pixel art",
            "help finish this pixel art",
            "polish this pixel art",
            "finish this sprite"
        ]
        let improvePrefixes = [
            "improve this pixel art",
            "help improve this pixel art",
            "improve this sprite",
            "help improve this sprite"
        ]
        let animatePrefixes = [
            "animate this pixel art",
            "animate this sprite",
            "make an animation plan for this sprite",
            "help animate this sprite"
        ]

        if let request = requestAfter(prefixes: finishPrefixes, lowered: lowered, original: prompt) {
            return .pixelAssist(.finish, request)
        }
        if let request = requestAfter(prefixes: improvePrefixes, lowered: lowered, original: prompt) {
            return .pixelAssist(.improve, request)
        }
        if let request = requestAfter(prefixes: animatePrefixes, lowered: lowered, original: prompt) {
            return .pixelAssist(.animate, request)
        }
        return nil
    }

    private static func requestAfter(prefixes: [String], lowered: String, original: String) -> String? {
        for prefix in prefixes where lowered.hasPrefix(prefix) {
            let request = String(original.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            return request
        }
        return nil
    }

    private static func commandID(prefixes: [String], from prompt: String) -> String? {
        let lowered = prompt.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        for prefix in prefixes where lowered.hasPrefix(prefix) {
            let id = String(prompt.dropFirst(prefix.count)).trimmingCharacters(in: .whitespacesAndNewlines)
            if !id.isEmpty { return id }
        }
        return nil
    }
}

enum BeMoreResponseGuard {
    static func userVisibleAnswer(from raw: String) -> String {
        var text = AgentReplySanitizer.userVisibleAnswer(from: raw)
        text = removeDelimited("<analysis>", "</analysis>", from: text)
        text = removeDelimited("<plan>", "</plan>", from: text)
        text = removeDelimited("```analysis", "```", from: text)
        text = removeDelimited("```plan", "```", from: text)

        let lines = text.components(separatedBy: .newlines)
        let cleanedLines = lines.filter { line in
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { return true }
            let lower = trimmed.lowercased()
            let bannedStarts = [
                "the user is asking",
                "i should",
                "i need to",
                "plan:",
                "analysis:",
                "reasoning:",
                "how to answer",
                "developer instruction",
                "system prompt",
                "internal note",
                "assistant plan",
                "working notes"
            ]
            let bannedContains = [
                "hidden reasoning",
                "private chain of thought",
                "scratchpad",
                "deliberation",
                "step-by-step reasoning",
                "my reasoning is",
                "i will now",
                "specifics:"
            ]
            if bannedStarts.contains(where: { lower.hasPrefix($0) }) { return false }
            if bannedContains.contains(where: { lower.contains($0) }) { return false }
            if lower.hasPrefix("- i should") || lower.hasPrefix("- i need to") || lower.hasPrefix("* i should") || lower.hasPrefix("* i need to") {
                return false
            }
            return true
        }

        text = cleanedLines.joined(separator: "\n")
        text = collapseBlankLines(in: text)

        if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            return "Buddy is ready. I can help with planning, follow-through, practical Buddy tasks, and reusable skill workflows right now."
        }

        if looksLikeMeta(text) {
            return "Buddy is ready. I can help with planning, follow-through, practical Buddy tasks, and reusable skill workflows right now."
        }

        return text.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func removeDelimited(_ start: String, _ end: String, from value: String) -> String {
        var result = value
        while let startRange = result.range(of: start, options: [.caseInsensitive]) {
            guard let endRange = result.range(of: end, options: [.caseInsensitive], range: startRange.upperBound..<result.endIndex) else {
                result.removeSubrange(startRange.lowerBound..<result.endIndex)
                break
            }
            result.removeSubrange(startRange.lowerBound..<endRange.upperBound)
        }
        return result
    }

    private static func collapseBlankLines(in value: String) -> String {
        var output: [String] = []
        var lastWasBlank = false
        for line in value.components(separatedBy: .newlines) {
            let blank = line.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
            if blank {
                if lastWasBlank { continue }
                lastWasBlank = true
            } else {
                lastWasBlank = false
            }
            output.append(line)
        }
        return output.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func looksLikeMeta(_ value: String) -> Bool {
        let lower = value.lowercased()
        let markers = [
            "the user is asking",
            "i should",
            "i need to",
            "analysis section",
            "chain of thought",
            "system prompt",
            "developer instruction"
        ]
        return markers.contains(where: { lower.contains($0) })
    }
}

private enum BeMoreSkillDraftStore {
    static let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()
}

extension BeMoreWorkspaceRuntime {
    func reviewChatSkillDraft(id: String) -> OpenClawReceipt {
        let drafts = loadSkillDraftWorkflowState()
        guard let draft = drafts.first(where: { $0.id == id }) else {
            return OpenClawReceipt(actionId: UUID(), status: .failed, title: "Review drafted skill", summary: "Draft not found", output: [:], artifacts: [], logs: [], error: "No drafted skill exists for \(id).")
        }

        let readmePath = "skills/\(id)/README.md"
        let previewPath = "skills/\(id)/draft-manifest.json"
        let validationPath = "skills/\(id)/validation.json"
        var artifacts = [readmePath]
        if (try? readFile(previewPath)) != nil { artifacts.append(previewPath) }
        if (try? readFile(validationPath)) != nil { artifacts.append(validationPath) }

        let reviewSummary = [
            "Purpose: \(draft.purpose)",
            draft.reviewNotes,
            "Use `refine skill \(id): ...` to add corrections or examples.",
            "Use `validate skill \(id)` before approval."
        ].joined(separator: " ")

        return OpenClawReceipt(
            actionId: UUID(),
            status: .completed,
            title: "Review drafted skill",
            summary: "Reviewed \(draft.name)",
            output: [
                "skillId": id,
                "name": draft.name,
                "purpose": draft.purpose,
                "review": reviewSummary
            ],
            artifacts: artifacts,
            logs: [],
            error: nil
        )
    }

    func refineChatSkillDraft(id: String, instruction: String) -> OpenClawReceipt {
        let cleanedInstruction = instruction.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedInstruction.isEmpty else {
            return OpenClawReceipt(actionId: UUID(), status: .failed, title: "Refine drafted skill", summary: "No refinement provided", output: [:], artifacts: [], logs: [], error: "Add a correction, example, or refinement note.")
        }

        var drafts = loadSkillDraftWorkflowState()
        guard let index = drafts.firstIndex(where: { $0.id == id }) else {
            return OpenClawReceipt(actionId: UUID(), status: .failed, title: "Refine drafted skill", summary: "Draft not found", output: [:], artifacts: [], logs: [], error: "No drafted skill exists for \(id).")
        }

        let draft = drafts[index]
        let notePrefix = draft.reviewNotes.trimmingCharacters(in: .whitespacesAndNewlines)
        drafts[index].reviewNotes = notePrefix.isEmpty
            ? cleanedInstruction
            : notePrefix + "\n- " + cleanedInstruction

        let manifest = draftManifestPreview(for: drafts[index])
        let manifestJSON = (try? String(data: BeMoreSkillDraftStore.encoder.encode(manifest), encoding: .utf8)) ?? "{}"
        let readmePath = "skills/\(id)/README.md"
        let previewPath = "skills/\(id)/draft-manifest.json"

        do {
            let readme = draftReadme(for: drafts[index], extraWorkflowNotes: ["Correction/example: \(cleanedInstruction)"])
            _ = try writeFile(readmePath, content: readme, source: "chat.skill-refine")
            _ = try writeFile(previewPath, content: manifestJSON, source: "chat.skill-refine")
            try persistSkillDraftWorkflowState(drafts)
            return OpenClawReceipt(
                actionId: UUID(),
                status: .persisted,
                title: "Refine drafted skill",
                summary: "Refined \(draft.name)",
                output: [
                    "skillId": id,
                    "instruction": cleanedInstruction,
                    "next": "Review again, then validate before approval."
                ],
                artifacts: ["state/skill-drafts.json", readmePath, previewPath],
                logs: [],
                error: nil
            )
        } catch {
            return OpenClawReceipt(actionId: UUID(), status: .failed, title: "Refine drafted skill", summary: "Could not refine \(draft.name)", output: [:], artifacts: [], logs: [], error: error.localizedDescription)
        }
    }

    func validateChatSkillDraft(id: String) -> OpenClawReceipt {
        let drafts = loadSkillDraftWorkflowState()
        guard let draft = drafts.first(where: { $0.id == id }) else {
            return OpenClawReceipt(actionId: UUID(), status: .failed, title: "Validate drafted skill", summary: "Draft not found", output: [:], artifacts: [], logs: [], error: "No drafted skill exists for \(id).")
        }

        let readmePath = "skills/\(id)/README.md"
        let previewPath = "skills/\(id)/draft-manifest.json"
        let validationPath = "skills/\(id)/validation.json"
        let readmeExists = (try? readFile(readmePath)) != nil
        let manifest = draftManifestPreview(for: draft)
        let checks: [[String: String]] = [
            ["name": "name-present", "status": draft.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "failed" : "passed"],
            ["name": "purpose-present", "status": draft.purpose.trimmingCharacters(in: .whitespacesAndNewlines).count >= 8 ? "passed" : "failed"],
            ["name": "requested-by-present", "status": draft.requestedBy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "failed" : "passed"],
            ["name": "readme-present", "status": readmeExists ? "passed" : "failed"],
            ["name": "permissions-declared", "status": manifest.permissions.isEmpty ? "failed" : "passed"],
            ["name": "entrypoint-declared", "status": manifest.entrypoint.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? "failed" : "passed"]
        ]
        let failedChecks = checks.filter { $0["status"] == "failed" }
        let validationPayload: [String: Any] = [
            "skillId": id,
            "validatedAt": ISO8601DateFormatter().string(from: .now),
            "status": failedChecks.isEmpty ? "passed" : "failed",
            "checks": checks,
            "note": failedChecks.isEmpty ? "Draft is ready for approval." : "Fix the failed checks, then validate again."
        ]

        do {
            let previewJSON = (try? String(data: BeMoreSkillDraftStore.encoder.encode(manifest), encoding: .utf8)) ?? "{}"
            let validationJSON = try jsonString(validationPayload)
            _ = try writeFile(previewPath, content: previewJSON, source: "chat.skill-validate")
            _ = try writeFile(validationPath, content: validationJSON, source: "chat.skill-validate")

            if failedChecks.isEmpty {
                return OpenClawReceipt(
                    actionId: UUID(),
                    status: .persisted,
                    title: "Validate drafted skill",
                    summary: "Validated \(draft.name)",
                    output: [
                        "skillId": id,
                        "status": "passed",
                        "next": "Approve with approve skill \(id)"
                    ],
                    artifacts: [previewPath, validationPath],
                    logs: [],
                    error: nil
                )
            }

            let failureSummary = failedChecks.compactMap { $0["name"] }.joined(separator: ", ")
            return OpenClawReceipt(
                actionId: UUID(),
                status: .failed,
                title: "Validate drafted skill",
                summary: "Validation failed for \(draft.name)",
                output: ["skillId": id, "status": "failed"],
                artifacts: [previewPath, validationPath],
                logs: [],
                error: "Failed checks: \(failureSummary)"
            )
        } catch {
            return OpenClawReceipt(actionId: UUID(), status: .failed, title: "Validate drafted skill", summary: "Could not validate \(draft.name)", output: [:], artifacts: [], logs: [], error: error.localizedDescription)
        }
    }

    private func loadSkillDraftWorkflowState() -> [ChatSkillDraft] {
        let url = rootURL.appendingPathComponent("state/skill-drafts.json")
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? BeMoreSkillDraftStore.decoder.decode([ChatSkillDraft].self, from: data)) ?? []
    }

    private func persistSkillDraftWorkflowState(_ drafts: [ChatSkillDraft]) throws {
        let data = try BeMoreSkillDraftStore.encoder.encode(drafts)
        let content = String(data: data, encoding: .utf8) ?? "[]"
        _ = try writeFile("state/skill-drafts.json", content: content, source: "chat.skill-workflow")
    }

    private func draftManifestPreview(for draft: ChatSkillDraft) -> SkillManifest {
        SkillManifest(
            id: draft.id,
            name: draft.name,
            description: "User-taught Buddy skill draft. \(draft.purpose)",
            version: "0.1.0",
            category: "User Taught",
            tags: ["user-taught", "chat-to-skill", "draft"],
            permissions: ["workspace.read", "workspace.write", "actions.write"],
            inputSchema: ["request": "string", "example": "string optional"],
            outputSchema: ["summary": "string", "artifactPath": "string", "nextSteps": "string"],
            ui: .init(route: "/skills/\(draft.id)", systemImage: "bolt.badge.checkmark", accent: "accent"),
            entrypoint: "buddyskill.\(draft.id)",
            enabled: true,
            source: draft.source,
            isEquipped: false,
            config: [
                "requestedBy": draft.requestedBy,
                "approvalState": draft.approvedAt == nil ? "draft" : "approved"
            ]
        )
    }

    private func draftReadme(for draft: ChatSkillDraft, extraWorkflowNotes: [String]) -> String {
        let notes = ([draft.reviewNotes] + extraWorkflowNotes)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
            .map { "- \($0)" }
            .joined(separator: "\n")

        return """
        # \(draft.name)

        Source: Chat-to-skill draft
        Requested by: \(draft.requestedBy)
        Requested capability: \(draft.purpose)

        ## Purpose
        \(draft.purpose)

        ## Safety boundary
        - Runs inside the iPhone BeMore workspace scope.
        - No arbitrary shell or process execution.
        - Ask for confirmation before destructive actions.

        ## Inputs
        - request (string)
        - example (string, optional)

        ## Outputs
        - summary (string)
        - nextSteps (string)
        - artifactPath (string)

        ## Review and refinement notes
        \(notes.isEmpty ? "- Add corrections or examples with `refine skill \(draft.id): ...`." : notes)

        ## Workflow
        - Review with: `review skill \(draft.id)`
        - Refine with: `refine skill \(draft.id): add a correction or example`
        - Validate with: `validate skill \(draft.id)`
        - Approve with: `approve skill \(draft.id)`
        """
    }

    private func jsonString(_ value: Any) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: value, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "{}"
    }
}

@MainActor
extension AppState {
    func sendValueFirst(prompt: String) async {
        let cleaned = prompt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleaned.isEmpty else { return }

        switch BeMoreChatCommandParser.parse(cleaned) {
        case .teach(let request):
            let requestedBy = buddyStore.activeBuddy?.displayName ?? "Buddy Operator"
            let receipt = workspaceRuntime.draftSkillFromChat(request: request, requestedBy: requestedBy)
            chatStore.messages.append(ChatMessage(role: .user, content: cleaned))
            let skillID = receipt.output["skillId"] ?? ""
            let assistant = (receipt.status == .persisted || receipt.status == .completed)
                ? "Drafted reusable skill \(skillID). Next: review skill \(skillID), refine it with examples or corrections, validate it, then approve it to install and equip it."
                : "Could not draft skill: \(receipt.error ?? receipt.summary)"
            chatStore.messages.append(ChatMessage(role: .assistant, content: assistant))
            chatStore.messages.append(ChatMessage(role: .system, content: ReceiptFormatter.confirmedSummary(for: receipt)))
            chatStore.persist()
            return

        case .review(let id):
            let receipt = workspaceRuntime.reviewChatSkillDraft(id: id)
            chatStore.messages.append(ChatMessage(role: .user, content: cleaned))
            let assistant = receipt.status == .failed
                ? "Could not review skill: \(receipt.error ?? receipt.summary)"
                : "Reviewed \(receipt.output["name"] ?? id). Purpose: \(receipt.output["purpose"] ?? "not available"). Refine it if needed, then validate before approval."
            chatStore.messages.append(ChatMessage(role: .assistant, content: assistant))
            chatStore.messages.append(ChatMessage(role: .system, content: ReceiptFormatter.confirmedSummary(for: receipt)))
            chatStore.persist()
            return

        case .refine(let id, let instruction):
            let receipt = workspaceRuntime.refineChatSkillDraft(id: id, instruction: instruction)
            chatStore.messages.append(ChatMessage(role: .user, content: cleaned))
            let assistant = receipt.status == .failed
                ? "Could not refine skill: \(receipt.error ?? receipt.summary)"
                : "Updated \(id) with your correction/example. Review it again or validate it when the draft looks right."
            chatStore.messages.append(ChatMessage(role: .assistant, content: assistant))
            chatStore.messages.append(ChatMessage(role: .system, content: ReceiptFormatter.confirmedSummary(for: receipt)))
            chatStore.persist()
            return

        case .validate(let id):
            let receipt = workspaceRuntime.validateChatSkillDraft(id: id)
            chatStore.messages.append(ChatMessage(role: .user, content: cleaned))
            let assistant = receipt.status == .failed
                ? "Validation failed for \(id): \(receipt.error ?? receipt.summary)"
                : "Validation passed for \(id). It is ready to approve, install, and equip."
            chatStore.messages.append(ChatMessage(role: .assistant, content: assistant))
            chatStore.messages.append(ChatMessage(role: .system, content: ReceiptFormatter.confirmedSummary(for: receipt)))
            chatStore.persist()
            return

        case .approve(let id):
            chatStore.messages.append(ChatMessage(role: .user, content: cleaned))
            let validationReceipt = workspaceRuntime.validateChatSkillDraft(id: id)
            if validationReceipt.status == .failed {
                chatStore.messages.append(ChatMessage(role: .assistant, content: "Approval stopped because validation failed for \(id): \(validationReceipt.error ?? validationReceipt.summary)"))
                chatStore.messages.append(ChatMessage(role: .system, content: ReceiptFormatter.confirmedSummary(for: validationReceipt)))
                chatStore.persist()
                return
            }
            let receipt = workspaceRuntime.approveChatSkillDraft(id: id)
            let assistant = (receipt.status == .persisted || receipt.status == .completed)
                ? "Approved and installed \(receipt.output["skillId"] ?? id). Buddy can run it later from Skills, and future runs will leave visible history."
                : "Could not approve skill: \(receipt.error ?? receipt.summary)"
            chatStore.messages.append(ChatMessage(role: .assistant, content: assistant))
            chatStore.messages.append(ChatMessage(role: .system, content: ReceiptFormatter.confirmedSummary(for: receipt)))
            chatStore.persist()
            return

        case .pixelAssist(let action, let request):
            chatStore.messages.append(ChatMessage(role: .user, content: cleaned))
            let receipt = runPixelStudioBuddyAction(action, request: request.isEmpty ? nil : request)
            let assistant = receipt.status == .failed
                ? "Could not prepare the Buddy \(action.title.lowercased()): \(receipt.error ?? receipt.summary)"
                : "Prepared a Buddy \(action.title.lowercased()) for \(receipt.output["project"] ?? "your project"). Open Studio or Results to use it."
            chatStore.messages.append(ChatMessage(role: .assistant, content: assistant))
            chatStore.persist()
            return

        case .none:
            break
        }

        chatStore.errorMessage = nil
        let previousAssistantMessageID = chatStore.messages.last(where: { $0.role == .assistant })?.id
        await send(prompt: cleaned)
        scrubAssistantReply(after: previousAssistantMessageID)
        softenChatErrorIfNeeded()
    }

    private func scrubAssistantReply(after previousAssistantMessageID: UUID?) {
        guard let index = chatStore.messages.indices.reversed().first(where: { chatStore.messages[$0].role == .assistant }) else {
            return
        }
        if chatStore.messages[index].id == previousAssistantMessageID {
            return
        }
        let message = chatStore.messages[index]
        let cleaned = BeMoreResponseGuard.userVisibleAnswer(from: message.content)
        guard cleaned != message.content else { return }
        chatStore.messages[index] = ChatMessage(id: message.id, role: message.role, content: cleaned, createdAt: message.createdAt)
        chatStore.persist()
    }

    private func softenChatErrorIfNeeded() {
        guard let error = chatStore.errorMessage else { return }
        let lower = error.lowercased()
        if lower.contains("on-device runtime") || lower.contains("route not configured") || lower.contains("local runtime unavailable") {
            chatStore.errorMessage = "Live model chat is not connected right now. Buddy still works for local skill drafting, review, validation, approval, and the iPhone-first Buddy flows. Link a provider only when you want open-ended live model chat."
        }
    }
}
