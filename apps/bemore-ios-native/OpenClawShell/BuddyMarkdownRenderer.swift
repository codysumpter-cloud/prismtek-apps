import Foundation

enum BuddyMarkdownRenderer {
    static func renderActiveBuddy(
        instance: BuddyInstance,
        template: CouncilStarterBuddyTemplate?,
        contracts: BuddyCanonicalResources,
        events: [BuddyRuntimeEvent],
        battleHistory: [BuddyBattleRecord],
        tradeHistory: [BuddyTradeRecord],
        now: Date = .now
    ) -> String {
        let bondLabel = bondLabel(for: instance.progression.bond, contracts: contracts)
        let nextLevel = nextLevelProgress(for: instance, contracts: contracts)
        let roleProfile = template.flatMap { contracts.progression.roleProfiles[$0.id] }
        let recent = recentEvents(for: instance, events: events, limit: 4)
        let topProficiencies = topProficiencyLabels(for: instance)
        let care = BuddyCareCalculator.snapshot(
            for: instance,
            template: template,
            battles: battleHistory.filter { $0.buddyInstanceId == instance.instanceId }
        )

        return """
        # buddy.md

        - Active buddy: \(instance.displayName)
        - Template: \(template?.name ?? "Legacy Buddy")
        - Role: \(instance.identity.class) / \(instance.identity.role)
        - Level: \(instance.progression.level)
        - XP: \(instance.progression.xp)
        - Bond: \(instance.progression.bond)/\(contracts.progression.maxBond) (\(bondLabel))
        - Evolution tier: \(instance.progression.evolutionTier)
        - Mood: \(instance.state.mood.capitalized)
        - Activity mode: \(instance.state.activityMode.capitalized)
        - Current focus: \(instance.state.currentFocus ?? "No active focus")
        - Last active: \(iso8601(instance.state.lastActiveAt))
        - Vitality: \(care.vitality)
        - Focus: \(care.focus)
        - Trust: \(care.trust)
        - Confidence: \(care.confidence)
        - Curiosity: \(care.curiosity)

        ## What changed recently
        \(bulletList(recent.isEmpty ? ["No Buddy events recorded yet."] : recent))

        ## What matters now
        \(bulletList(matterNowLines(instance: instance, roleProfile: roleProfile, nextLevel: nextLevel, topProficiencies: topProficiencies)))

        ## What Buddy learned from you
        \(bulletList(learnedPreferenceLines(for: instance)))

        ## Equipped skills
        \(bulletList(skillLines(for: instance)))

        ## Latest daily plan
        \(bulletList(dailyPlanLines(for: instance)))

        ## Recent sparring
        \(bulletList(battleLines(for: instance, battleHistory: battleHistory)))

        ## Trade status
        \(bulletList(tradeLines(for: instance, tradeHistory: tradeHistory)))

        ## What is stale
        \(bulletList(staleLines(for: instance, now: now)))

        ## Equipped moves
        \(bulletList(instance.equippedMoves.sorted(by: { $0.slot < $1.slot }).map { "Slot \($0.slot): \($0.name) (\($0.category), mastery \($0.mastery))" }))
        """
    }

    static func renderRoster(
        instances: [BuddyInstance],
        activeBuddyInstanceId: String?,
        contracts: BuddyCanonicalResources,
        events: [BuddyRuntimeEvent],
        battleHistory: [BuddyBattleRecord],
        tradeHistory: [BuddyTradeRecord],
        now: Date = .now
    ) -> String {
        let sections = instances.map { instance -> String in
            let template = contracts.templateForInstance(instance)
            let recent = recentEvents(for: instance, events: events, limit: 2)
            let status = instance.instanceId == activeBuddyInstanceId ? "Active" : (isStale(instance, now: now) ? "Needs attention" : "Installed")
            let bond = bondLabel(for: instance.progression.bond, contracts: contracts)
            let battles = battleHistory.filter { $0.buddyInstanceId == instance.instanceId }
            let trades = tradeHistory.filter { $0.buddyDisplayName == instance.displayName }
            let care = BuddyCareCalculator.snapshot(for: instance, template: template, battles: battles)

            return """
            ## \(instance.displayName)

            - Status: \(status)
            - Template: \(template?.name ?? "Legacy Buddy")
            - Role: \(instance.identity.role)
            - Level: \(instance.progression.level)
            - Bond: \(instance.progression.bond)/\(contracts.progression.maxBond) (\(bond))
            - Mood: \(instance.state.mood.capitalized)
            - Focus: \(instance.state.currentFocus ?? "No active focus")
            - Learned preferences: \(instance.learnedPreferences?.count ?? 0)
            - Equipped skills: \((instance.learnedSkills ?? []).filter(\.isEquipped).count)
            - Vitality / trust / confidence: \(care.vitality) / \(care.trust) / \(care.confidence)
            - Battles logged: \(battles.count)
            - Trade history: \(trades.count)
            - Last active: \(iso8601(instance.state.lastActiveAt))
            \(recent.isEmpty ? "- Recent note: No Buddy events recorded yet." : recent.map { "- Recent note: \($0)" }.joined(separator: "\n"))
            """
        }

        return """
        # buddies.md

        - Installed buddies: \(instances.count)
        - Active buddy ID: \(activeBuddyInstanceId ?? "None")
        - Updated: \(iso8601(now))

        \(sections.joined(separator: "\n\n"))
        """
    }

    static func bondLabel(for bond: Int, contracts: BuddyCanonicalResources) -> String {
        let labels = contracts.progression.bondLabels
        let safeIndex = max(0, min(bond, labels.count - 1))
        return labels[safeIndex]
    }

    static func iso8601(_ date: Date) -> String {
        ISO8601DateFormatter().string(from: date)
    }

    private static func recentEvents(for instance: BuddyInstance, events: [BuddyRuntimeEvent], limit: Int) -> [String] {
        events
            .filter { $0.buddyInstanceId == instance.instanceId }
            .sorted { $0.occurredAt > $1.occurredAt }
            .prefix(limit)
            .map { "\(iso8601($0.occurredAt)): \($0.summary)" }
    }

    private static func matterNowLines(
        instance: BuddyInstance,
        roleProfile: BuddyRoleProfile?,
        nextLevel: (level: Int?, remainingXP: Int?),
        topProficiencies: [String]
    ) -> [String] {
        var lines: [String] = []
        if let level = nextLevel.level, let remainingXP = nextLevel.remainingXP {
            lines.append("Next level: \(level) in \(remainingXP) XP.")
        } else {
            lines.append("Level cap reached for the current BeMore companion wedge.")
        }

        if let challenge = roleProfile?.dailyChallengeHook {
            lines.append("Recommended daily challenge: \(challenge.name) — \(challenge.description)")
        }

        if topProficiencies.isEmpty {
            lines.append("Training profile is still fresh. One guided training session will establish a specialty.")
        } else {
            lines.append("Current strongest proficiencies: \(topProficiencies.joined(separator: ", ")).")
        }

        return lines
    }

    private static func learnedPreferenceLines(for instance: BuddyInstance) -> [String] {
        let preferences = (instance.learnedPreferences ?? [])
            .sorted { $0.updatedAt > $1.updatedAt }
            .prefix(5)
        guard preferences.isEmpty == false else {
            return ["No explicit taught preferences yet. Use Teach Buddy to make memory inspectable."]
        }
        return preferences.map { "\($0.title): \($0.detail) (reinforced \($0.reinforcementCount)x)" }
    }

    private static func skillLines(for instance: BuddyInstance) -> [String] {
        let skills = (instance.learnedSkills ?? [])
            .filter(\.isEquipped)
            .sorted { lhs, rhs in
                if lhs.mastery == rhs.mastery { return lhs.name < rhs.name }
                return lhs.mastery > rhs.mastery
            }
        guard skills.isEmpty == false else {
            return ["No equipped learned skills yet."]
        }
        return skills.map { "\($0.name): \($0.summary) Mastery \($0.mastery)/5" }
    }

    private static func dailyPlanLines(for instance: BuddyInstance) -> [String] {
        guard let plan = instance.dailyPlans?.sorted(by: { $0.createdAt > $1.createdAt }).first else {
            return ["No daily plan captured yet."]
        }
        return [
            "Date: \(plan.dateLabel)",
            "Top priority: \(plan.topPriority)",
            "Support style: \(plan.supportStyle)",
            "Reminder: \(plan.reminderTitle)",
            "Journal: \(plan.journalPrompt)"
        ]
    }

    private static func battleLines(for instance: BuddyInstance, battleHistory: [BuddyBattleRecord]) -> [String] {
        let recent = battleHistory
            .filter { $0.buddyInstanceId == instance.instanceId }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(3)
        guard recent.isEmpty == false else {
            return ["No sparring record yet. Start a local battle to test training and loadout."]
        }
        return recent.map {
            "\($0.result.capitalized) vs \($0.opponentName) in \($0.arenaName) (\($0.scoreline)). Recommended next training: \($0.recommendedTraining.joined(separator: ", "))."
        }
    }

    private static func tradeLines(for instance: BuddyInstance, tradeHistory: [BuddyTradeRecord]) -> [String] {
        let recent = tradeHistory
            .filter { $0.buddyDisplayName == instance.displayName }
            .sorted { $0.createdAt > $1.createdAt }
            .prefix(3)
        guard recent.isEmpty == false else {
            return ["No trade packages imported for this Buddy yet. Export a package to share or keep as a backup."]
        }
        return recent.map { "\($0.type.capitalized): \($0.summary)" }
    }

    private static func staleLines(for instance: BuddyInstance, now: Date) -> [String] {
        guard isStale(instance, now: now) else {
            return ["No stale Buddy warnings right now."]
        }

        let days = max(1, Calendar.current.dateComponents([.day], from: instance.state.lastActiveAt, to: now).day ?? 1)
        return [
            "Buddy has not been active for \(days) day\(days == 1 ? "" : "s").",
            "Run a check-in or training session before trusting this Buddy as your current primary."
        ]
    }

    private static func isStale(_ instance: BuddyInstance, now: Date) -> Bool {
        let days = Calendar.current.dateComponents([.day], from: instance.state.lastActiveAt, to: now).day ?? 0
        return days >= 3
    }

    private static func nextLevelProgress(
        for instance: BuddyInstance,
        contracts: BuddyCanonicalResources
    ) -> (level: Int?, remainingXP: Int?) {
        let thresholds = contracts.progression.xpThresholds.sorted { $0.level < $1.level }
        guard let next = thresholds.first(where: { $0.level > instance.progression.level }) else {
            return (nil, nil)
        }
        return (next.level, max(0, next.xpRequired - instance.progression.xp))
    }

    private static func topProficiencyLabels(for instance: BuddyInstance) -> [String] {
        let values: [(String, Int)] = [
            ("Planning", instance.proficiencies.planning),
            ("Building", instance.proficiencies.building),
            ("Research", instance.proficiencies.research),
            ("Writing", instance.proficiencies.writing),
            ("Memory", instance.proficiencies.memory),
            ("Organization", instance.proficiencies.organization),
            ("Safety", instance.proficiencies.safety),
            ("Verification", instance.proficiencies.verification),
            ("Optimization", instance.proficiencies.optimization),
            ("Creativity", instance.proficiencies.creativity),
            ("Coordination", instance.proficiencies.coordination),
            ("Emotional Support", instance.proficiencies.emotionalSupport)
        ]

        return values
            .filter { $0.1 > 0 }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0 < rhs.0
                }
                return lhs.1 > rhs.1
            }
            .prefix(3)
            .map { "\($0.0) \($0.1)/5" }
    }

    private static func bulletList(_ items: [String]) -> String {
        items.map { "- \($0)" }.joined(separator: "\n")
    }
}
