import Foundation

// MARK: - Skill Teaching Models

/// Represents a skill being taught via natural conversation
struct SkillTeachingDraft: Codable {
 let id: String
 let triggerPhrase: String          // e.g., "remind me to water plants"
 let actionType: SkillActionType
 let toolName: String                 // generated tool ID
 let parameters: [SkillParameter]
 let createdAt: Date
 var isActive: Bool = false
 var practiceCount: Int = 0
 var lastPracticed: Date?
}

enum SkillActionType: String, Codable {
 case reminder
 case note
 case webSearch
 case calculation
 case customFunction
 case apiCall
}

struct SkillParameter: Codable {
 let name: String
 let type: ParameterType
 let required: Bool
 let description: String
 let exampleValue: String?
}

enum ParameterType: String, Codable {
 case string
 case number
 case date
 case boolean
 case list
}

/// Recognition patterns for teaching intent
struct TeachingPatterns {
 static let teachPrefixes = [
 "teach you to", "teach you how to", "show you how to",
 "learn to", "remember to", "create a skill for",
 "can you learn", "teach me", "help me remember"
 ]

 static let actionVerbs = [
 "remind", "notify", "alert", "remember",
 "search", "look up", "find",
 "calculate", "compute", "figure out",
 "track", "monitor", "log", "note"
 ]
}

// MARK: - Teaching Engine

@MainActor
class BuddySkillTeachingEngine {
 static let shared = BuddySkillTeachingEngine()

 private let storageKey = "BuddySkillTeachingDrafts"
 private init() {}

 // MARK: - Intent Recognition

 /// Analyzes user message for teaching intent
 func analyzeTeachingIntent(_ message: String) -> TeachingAnalysis {
 let lower = message.lowercased()

 // Check for teaching prefixes
 let hasTeachIntent = TeachingPatterns.teachPrefixes.contains { lower.contains($0) }

 // Check for action verbs
 let detectedAction = TeachingPatterns.actionVerbs.first { lower.contains($0) }

 // Check for "when X then Y" structure
 let hasCondition = lower.contains("when") || lower.contains("if") || lower.contains("every")
 let hasAction = lower.contains("then") || lower.contains("do") || lower.contains("should")

 // Calculate confidence
 var confidence = 0
 if hasTeachIntent { confidence += 50 }
 if detectedAction != nil { confidence += 25 }
 if hasCondition && hasAction { confidence += 25 }

 return TeachingAnalysis(
 isTeachingIntent: confidence >= 50,
 confidence: confidence,
 detectedAction: detectedAction,
 suggestedSkillName: generateSkillName(from: message),
 suggestedParameters: extractParameters(from: message)
 )
 }

 // MARK: - Skill Generation

 /// Creates a skill draft from teaching conversation
 func createSkillDraft(
 from analysis: TeachingAnalysis,
 originalMessage: String
 ) -> SkillTeachingDraft {
 let toolId = "user-teaching-\(UUID().uuidString.prefix(8))"

 return SkillTeachingDraft(
 id: toolId,
 triggerPhrase: analysis.suggestedSkillName,
 actionType: inferActionType(from: analysis.detectedAction),
 toolName: toolId,
 parameters: analysis.suggestedParameters,
 createdAt: .now
 )
 }

 /// Creates a "trained skill" from completed teaching
 func completeTeaching(_ draft: SkillTeachingDraft) -> BuddySkillState {
 return BuddySkillState(
 id: draft.id,
 name: draft.triggerPhrase,
 summary: "User-taught skill: \(draft.triggerPhrase)",
 category: "User Taught",
 isEquipped: true,
 mastery: 1,
 xp: 10,
 maxXp: 100,
 learnedAt: .now,
 uses: 0,
 lastUsed: nil
 )
 }

 // MARK: - Persistence

 func saveDraft(_ draft: SkillTeachingDraft) {
 var drafts = loadAllDrafts()
 drafts.removeAll { $0.id == draft.id }
 drafts.append(draft)

 if let data = try? JSONEncoder().encode(drafts) {
 UserDefaults.standard.set(data, forKey: storageKey)
 }
 }

 func loadAllDrafts() -> [SkillTeachingDraft] {
 guard let data = UserDefaults.standard.data(forKey: storageKey),
 let drafts = try? JSONDecoder().decode([SkillTeachingDraft].self, from: data) else {
 return []
 }
 return drafts
 }

 func deleteDraft(id: String) {
 var drafts = loadAllDrafts()
 drafts.removeAll { $0.id == id }

 if let data = try? JSONEncoder().encode(drafts) {
 UserDefaults.standard.set(data, forKey: storageKey)
 }
 }

 // MARK: - Private Helpers

 private func generateSkillName(from message: String) -> String {
 // Extract the core action from the message
 let patterns = [
 (pattern: #"remind me (?:to|about|that) (.+)"#, group: 1),
 (pattern: #"when (.+) then (.+)"#, group: 2),
 (pattern: #"teach you (?:to|how to) (.+)"#, group: 1),
 ]

 for (pattern, group) in patterns {
 if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive),
 let match = regex.firstMatch(in: message, range: NSRange(message.startIndex..., in: message)),
 let range = Range(match.range(at: group), in: message) {
 let extracted = String(message[range]).trimmingCharacters(in: .whitespacesAndNewlines)
 return extracted.prefix(50).map { String($0) }.joined()
 }
 }

 // Fallback: first 5 significant words
 let words = message.split(separator: " ")
 let significant = words.prefix(5).joined(separator: " ")
 return String(significant)
 }

 private func extractParameters(from message: String) -> [SkillParameter] {
 var parameters: [SkillParameter] = []

 // Look for time/date references
 if message.contains("at ") || message.contains("every ") {
 parameters.append(SkillParameter(
 name: "time",
 type: .date,
 required: true,
 description: "When to perform this action",
 exampleValue: "9:00 AM"
 ))
 }

 // Look for target/subject
 if message.contains(" me ") || message.contains(" my ") {
 parameters.append(SkillParameter(
 name: "recipient",
 type: .string,
 required: false,
 description: "Who to notify",
 exampleValue: "me"
 ))
 }

 // Look for content/message
 if message.contains("about") || message.contains("that") {
 parameters.append(SkillParameter(
 name: "content",
 type: .string,
 required: true,
 description: "What to remember or say",
 exampleValue: "Text"
 ))
 }

 return parameters
 }

 private func inferActionType(from action: String?) -> SkillActionType {
 guard let action = action?.lowercased() else { return .customFunction }

 switch action {
 case let a where a.contains("remind") || a.contains("notify") || a.contains("alert"):
 return .reminder
 case let a where a.contains("search") || a.contains("look") || a.contains("find"):
 return .webSearch
 case let a where a.contains("calculate") || a.contains("compute") || a.contains("figure"):
 return .calculation
 case let a where a.contains("track") || a.contains("log") || a.contains("note"):
 return .note
 default:
 return .customFunction
 }
 }
}

// MARK: - Teaching Analysis Result

struct TeachingAnalysis {
 let isTeachingIntent: Bool
 let confidence: Int // 0-100
 let detectedAction: String?
 let suggestedSkillName: String
 let suggestedParameters: [SkillParameter]
}

// MARK: - SwiftUI Integration

import SwiftUI

extension BeMoreChatDispatch {
 /// Check if a message is a teaching attempt and handle it
 func handlePotentialTeaching(
 _ message: String,
 buddy: BuddyInstance,
 completion: @escaping (SkillTeachingDraft?) -> Void
 ) {
 let analysis = BuddySkillTeachingEngine.shared.analyzeTeachingIntent(message)

 guard analysis.isTeachingIntent else {
 completion(nil)
 return
 }

 let draft = BuddySkillTeachingEngine.shared.createSkillDraft(
 from: analysis,
 originalMessage: message
 )

 BuddySkillTeachingEngine.shared.saveDraft(draft)
 completion(draft)
 }
}
