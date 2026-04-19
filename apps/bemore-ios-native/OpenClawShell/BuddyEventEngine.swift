import Foundation

struct BuddyPersistenceBundle {
    var libraryState: BuddyLibraryState
    var eventLog: BuddyRuntimeEventLog
    var activeBuddyMarkdown: String?
    var rosterMarkdown: String
    var actionTitle: String
    var summary: String
}

enum BuddyEventEngineError: LocalizedError {
    case templateNotFound(String)
    case instanceNotFound(String)
    case invalidName

    var errorDescription: String? {
        switch self {
        case .templateNotFound(let id):
            return "Could not find Buddy template \(id)."
        case .instanceNotFound(let id):
            return "Could not find Buddy instance \(id)."
        case .invalidName:
            return "Buddy display names must contain at least one non-space character."
        }
    }
}

struct BuddyEventEngine {
    let contracts: BuddyCanonicalResources

    func install(
        templateID: String,
        currentState: BuddyLibraryState,
        currentEvents: BuddyRuntimeEventLog,
        now: Date = .now
    ) throws -> BuddyPersistenceBundle {
        guard let template = contracts.templates.first(where: { $0.id == templateID || $0.templateID == templateID }) else {
            throw BuddyEventEngineError.templateNotFound(templateID)
        }

        var nextState = currentState
        var nextEvents = currentEvents
        let instance = buildInstance(from: template, now: now)
        nextState.upsert(instance)
        nextState.activeBuddyInstanceId = instance.instanceId
        nextState.lastUpdatedAt = now

        let installEvent = makeEvent(
            type: "buddy.template.installed",
            instance: instance,
            actor: "user",
            summary: "Installed \(instance.displayName) from the Council Starter Pack.",
            payload: [
                "templateId": instance.templateId,
                "installFlowState": "installed_clean"
            ],
            effects: BuddyRuntimeEventEffects(
                xpDelta: nil,
                bondDelta: 1,
                proficiencyDeltas: nil,
                moodTarget: "happy",
                stateTransition: "installed_clean",
                memoryPromotion: nil,
                badgeGrant: nil,
                passiveUnlock: nil,
                signatureUpgrade: nil,
                receiptRef: nil,
                sanitationReport: nil
            ),
            occurredAt: now
        )

        nextEvents.events.append(installEvent)
        return finalize(
            state: nextState,
            eventLog: nextEvents,
            summary: "Installed \(instance.displayName) from the Council Starter Pack.",
            actionTitle: "Install \(instance.displayName)",
            activeInstanceID: instance.instanceId,
            now: now
        )
    }

    func personalize(
        instanceID: String,
        displayName: String,
        nickname: String?,
        currentFocus: String?,
        palette: String?,
        asciiVariantID: String?,
        currentState: BuddyLibraryState,
        currentEvents: BuddyRuntimeEventLog,
        now: Date = .now
    ) throws -> BuddyPersistenceBundle {
        let cleanedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanedName.isEmpty else {
            throw BuddyEventEngineError.invalidName
        }

        guard var instance = currentState.instances.first(where: { $0.instanceId == instanceID }) else {
            throw BuddyEventEngineError.instanceNotFound(instanceID)
        }

        let previous = instance.displayName
        instance.displayName = cleanedName
        instance.nickname = nickname?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank
        instance.state.currentFocus = currentFocus?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank ?? instance.state.currentFocus
        if let palette = palette?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank {
            instance.identity.palette = palette
        }
        var visual = instance.visual ?? BuddyVisualState(
            asciiVariantId: nil,
            pixelVariantId: nil,
            currentAnimationState: nil,
            evolutionCosmetics: []
        )
        if let asciiVariantID = asciiVariantID?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank {
            visual.asciiVariantId = asciiVariantID
        }
        instance.visual = visual
        instance.state.mood = nextMood(from: instance.state.mood, preferred: "happy")
        instance.state.lastActiveAt = now
        let actualBondDelta = cappedBondDelta(currentEvents, on: now, requested: 1)
        instance.progression.bond = min(contracts.progression.maxBond, instance.progression.bond + actualBondDelta)

        let updated = recalculateProgression(for: instance, template: contracts.templateForInstance(instance), now: now)
        var nextState = currentState
        nextState.upsert(updated)
        nextState.lastUpdatedAt = now

        var nextEvents = currentEvents
        nextEvents.events.append(
            makeEvent(
                type: "buddy.personalized",
                instance: updated,
                actor: "user",
                summary: previous == cleanedName
                    ? "Updated \(cleanedName)'s nickname and focus."
                    : "Renamed \(previous) to \(cleanedName).",
                payload: [
                    "displayName": cleanedName,
                    "nickname": updated.nickname ?? "",
                    "currentFocus": updated.state.currentFocus ?? "",
                    "palette": updated.identity.palette,
                    "asciiVariantId": updated.visual?.asciiVariantId ?? ""
                ],
                effects: BuddyRuntimeEventEffects(
                    xpDelta: nil,
                    bondDelta: actualBondDelta > 0 ? actualBondDelta : nil,
                    proficiencyDeltas: nil,
                    moodTarget: updated.state.mood,
                    stateTransition: "personalized",
                    memoryPromotion: nil,
                    badgeGrant: nil,
                    passiveUnlock: nil,
                    signatureUpgrade: nil,
                    receiptRef: nil,
                    sanitationReport: nil
                ),
                occurredAt: now
            )
        )

        return finalize(
            state: nextState,
            eventLog: nextEvents,
            summary: "Personalized \(updated.displayName).",
            actionTitle: "Personalize \(updated.displayName)",
            activeInstanceID: updated.instanceId,
            now: now
        )
    }

    func recordCheckIn(
        instanceID: String,
        note: String?,
        currentState: BuddyLibraryState,
        currentEvents: BuddyRuntimeEventLog,
        now: Date = .now
    ) throws -> BuddyPersistenceBundle {
        guard var instance = currentState.instances.first(where: { $0.instanceId == instanceID }) else {
            throw BuddyEventEngineError.instanceNotFound(instanceID)
        }

        let previousLastActive = instance.state.lastActiveAt
        let awardedXP = cappedXP(currentEvents, on: now, requested: contracts.progression.xpRewards.realTask.small ?? 10)
        let bondDelta = cappedBondDelta(currentEvents, on: now, requested: 1)
        instance.state.currentFocus = note?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank ?? instance.state.currentFocus
        instance.state.mood = nextMood(from: instance.state.mood, preferred: "happy")
        instance.state.lastActiveAt = now
        instance.state.energy = min(100, instance.state.energy + 6)
        instance.progression.xp += awardedXP
        instance.progression.bond = min(contracts.progression.maxBond, instance.progression.bond + bondDelta)
        instance.progression.streakDays = nextStreakDays(current: instance.progression.streakDays, lastActiveAt: previousLastActive, now: now)

        let updated = recalculateProgression(for: instance, template: contracts.templateForInstance(instance), now: now)
        var nextState = currentState
        nextState.upsert(updated)
        nextState.activeBuddyInstanceId = updated.instanceId
        nextState.lastUpdatedAt = now

        var nextEvents = currentEvents
        nextEvents.events.append(
            makeEvent(
                type: "buddy.checkin.completed",
                instance: updated,
                actor: "user",
                summary: "Completed a Buddy check-in with \(updated.displayName).",
                payload: [
                    "note": note?.nilIfBlank ?? "",
                    "xpAwarded": String(awardedXP)
                ],
                effects: BuddyRuntimeEventEffects(
                    xpDelta: awardedXP,
                    bondDelta: bondDelta,
                    proficiencyDeltas: nil,
                    moodTarget: updated.state.mood,
                    stateTransition: "active",
                    memoryPromotion: nil,
                    badgeGrant: nil,
                    passiveUnlock: nil,
                    signatureUpgrade: nil,
                    receiptRef: nil,
                    sanitationReport: nil
                ),
                occurredAt: now
            )
        )

        return finalize(
            state: nextState,
            eventLog: nextEvents,
            summary: "Recorded a check-in for \(updated.displayName).",
            actionTitle: "Check in with \(updated.displayName)",
            activeInstanceID: updated.instanceId,
            now: now
        )
    }

    func recordTraining(
        instanceID: String,
        category: String,
        note: String?,
        currentState: BuddyLibraryState,
        currentEvents: BuddyRuntimeEventLog,
        now: Date = .now
    ) throws -> BuddyPersistenceBundle {
        guard var instance = currentState.instances.first(where: { $0.instanceId == instanceID }) else {
            throw BuddyEventEngineError.instanceNotFound(instanceID)
        }

        let previousLastActive = instance.state.lastActiveAt
        let awardedXP = cappedXP(currentEvents, on: now, requested: contracts.progression.xpRewards.training.basic ?? 15)
        let bondDelta = cappedBondDelta(currentEvents, on: now, requested: 1)
        instance.proficiencies.increment(category: category, cap: contracts.progression.maxSkillProficiency)
        instance.trainingHistory.append(
            BuddyTrainingRecord(
                id: "train_\(UUID().uuidString.lowercased())",
                category: category,
                xpAwarded: awardedXP,
                bondDelta: bondDelta,
                completedAt: now,
                source: "training_drill"
            )
        )
        instance.state.currentFocus = note?.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank ?? "Training \(category)"
        instance.state.mood = nextMood(from: instance.state.mood, preferred: "working")
        instance.state.lastActiveAt = now
        instance.state.energy = max(0, instance.state.energy - 8)
        instance.progression.xp += awardedXP
        instance.progression.bond = min(contracts.progression.maxBond, instance.progression.bond + bondDelta)
        instance.progression.streakDays = nextStreakDays(current: instance.progression.streakDays, lastActiveAt: previousLastActive, now: now)

        let updated = recalculateProgression(for: instance, template: contracts.templateForInstance(instance), now: now)
        var nextState = currentState
        nextState.upsert(updated)
        nextState.activeBuddyInstanceId = updated.instanceId
        nextState.lastUpdatedAt = now

        var nextEvents = currentEvents
        nextEvents.events.append(
            makeEvent(
                type: "buddy.training.completed",
                instance: updated,
                actor: "user",
                summary: "Completed \(category) training for \(updated.displayName).",
                payload: [
                    "category": category,
                    "note": note?.nilIfBlank ?? "",
                    "xpAwarded": String(awardedXP)
                ],
                effects: BuddyRuntimeEventEffects(
                    xpDelta: awardedXP,
                    bondDelta: bondDelta,
                    proficiencyDeltas: [category: 1],
                    moodTarget: updated.state.mood,
                    stateTransition: "training",
                    memoryPromotion: nil,
                    badgeGrant: nil,
                    passiveUnlock: updated.progression.passiveUnlocked ? "tier2-passive" : nil,
                    signatureUpgrade: updated.progression.signatureUpgradeUnlocked ? "tier3-signature" : nil,
                    receiptRef: nil,
                    sanitationReport: nil
                ),
                occurredAt: now
            )
        )

        return finalize(
            state: nextState,
            eventLog: nextEvents,
            summary: "Recorded \(category) training for \(updated.displayName).",
            actionTitle: "Train \(updated.displayName)",
            activeInstanceID: updated.instanceId,
            now: now
        )
    }

    func teachPlanningLoop(
        instanceID: String,
        preferenceTitle: String,
        preferenceDetail: String,
        topPriority: String,
        supportStyle: String,
        currentState: BuddyLibraryState,
        currentEvents: BuddyRuntimeEventLog,
        now: Date = .now
    ) throws -> BuddyPersistenceBundle {
        guard var instance = currentState.instances.first(where: { $0.instanceId == instanceID }) else {
            throw BuddyEventEngineError.instanceNotFound(instanceID)
        }

        let cleanedTitle = preferenceTitle.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank ?? "Daily planning style"
        let cleanedDetail = preferenceDetail.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank ?? "Help me plan calmly around one useful next step."
        let cleanedPriority = topPriority.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank ?? "Pick one useful next step"
        let cleanedStyle = supportStyle.trimmingCharacters(in: .whitespacesAndNewlines).nilIfBlank ?? "Calm, specific, and low-pressure"
        let previousLastActive = instance.state.lastActiveAt
        let awardedXP = cappedXP(currentEvents, on: now, requested: contracts.progression.xpRewards.training.basic ?? 15)
        let bondDelta = cappedBondDelta(currentEvents, on: now, requested: 1)
        let preference = upsertPreference(
            in: instance.learnedPreferences ?? [],
            category: "planning",
            title: cleanedTitle,
            detail: cleanedDetail,
            source: "teach_buddy",
            now: now
        )
        instance.learnedPreferences = preference
        instance.learnedSkills = upsertSkill(
            in: instance.learnedSkills ?? Self.defaultStarterSkills(now: now),
            id: "daily-planning",
            trainedCategory: "Planning",
            now: now,
            cap: contracts.progression.maxSkillProficiency
        )
        instance.proficiencies.increment(category: "Planning", cap: contracts.progression.maxSkillProficiency)
        instance.trainingHistory.append(
            BuddyTrainingRecord(
                id: "train_\(UUID().uuidString.lowercased())",
                category: "Planning",
                xpAwarded: awardedXP,
                bondDelta: bondDelta,
                completedAt: now,
                source: "teaching_loop"
            )
        )
        instance.state.currentFocus = cleanedPriority
        instance.state.favoriteTasks = Array(([cleanedPriority] + instance.state.favoriteTasks).uniqued().prefix(5))
        instance.state.mood = nextMood(from: instance.state.mood, preferred: "thinking")
        instance.state.energy = min(100, max(0, instance.state.energy + 4))
        instance.state.lastActiveAt = now
        instance.progression.xp += awardedXP
        instance.progression.bond = min(contracts.progression.maxBond, instance.progression.bond + bondDelta)
        instance.progression.streakDays = nextStreakDays(current: instance.progression.streakDays, lastActiveAt: previousLastActive, now: now)
        if instance.progression.badges.contains("planning-student") == false {
            instance.progression.badges.append("planning-student")
        }

        let dailyPlan = BuddyDailyPlan(
            id: "plan_\(UUID().uuidString.lowercased())",
            createdAt: now,
            dateLabel: Self.dayFormatter.string(from: now),
            topPriority: cleanedPriority,
            supportStyle: cleanedStyle,
            reminderTitle: "Check in with \(instance.displayName): \(cleanedPriority)",
            journalPrompt: "\(instance.displayName) learned: \(cleanedDetail)",
            messageDraft: "Quick check-in: I am focusing on \(cleanedPriority). Can you help keep me honest today?"
        )
        instance.dailyPlans = Array(([dailyPlan] + (instance.dailyPlans ?? [])).prefix(20))

        let updated = recalculateProgression(for: instance, template: contracts.templateForInstance(instance), now: now)
        var nextState = currentState
        nextState.upsert(updated)
        nextState.activeBuddyInstanceId = updated.instanceId
        nextState.lastUpdatedAt = now

        var nextEvents = currentEvents
        nextEvents.events.append(
            makeEvent(
                type: "buddy.training.completed",
                instance: updated,
                actor: "user",
                summary: "\(updated.displayName) learned a daily planning preference and trained Planning.",
                payload: [
                    "category": "Planning",
                    "preferenceTitle": cleanedTitle,
                    "preferenceDetail": cleanedDetail,
                    "topPriority": cleanedPriority,
                    "supportStyle": cleanedStyle,
                    "reminderTitle": dailyPlan.reminderTitle,
                    "journalPrompt": dailyPlan.journalPrompt
                ],
                effects: BuddyRuntimeEventEffects(
                    xpDelta: awardedXP,
                    bondDelta: bondDelta,
                    proficiencyDeltas: ["Planning": 1],
                    moodTarget: updated.state.mood,
                    stateTransition: "training",
                    memoryPromotion: "Saved an inspectable Buddy planning preference.",
                    badgeGrant: "planning-student",
                    passiveUnlock: updated.progression.passiveUnlocked ? "tier2-passive" : nil,
                    signatureUpgrade: updated.progression.signatureUpgradeUnlocked ? "tier3-signature" : nil,
                    receiptRef: nil,
                    sanitationReport: nil
                ),
                occurredAt: now
            )
        )

        return finalize(
            state: nextState,
            eventLog: nextEvents,
            summary: "\(updated.displayName) learned your planning style and prepared today's loop.",
            actionTitle: "Teach \(updated.displayName) planning",
            activeInstanceID: updated.instanceId,
            now: now
        )
    }

    func performCare(
        instanceID: String,
        action: BuddyCareAction,
        currentState: BuddyLibraryState,
        currentEvents: BuddyRuntimeEventLog,
        now: Date = .now
    ) throws -> BuddyPersistenceBundle {
        guard var instance = currentState.instances.first(where: { $0.instanceId == instanceID }) else {
            throw BuddyEventEngineError.instanceNotFound(instanceID)
        }

        let previousLastActive = instance.state.lastActiveAt
        let awardedXP = cappedXP(currentEvents, on: now, requested: 6)
        let bondDelta = cappedBondDelta(currentEvents, on: now, requested: 1)
        var rewardLines: [String] = []
        var summary = ""

        switch action {
        case .encourage:
            instance.state.mood = nextMood(from: instance.state.mood, preferred: "happy")
            instance.state.energy = min(100, instance.state.energy + 4)
            summary = "Spent a quick supportive moment with \(instance.displayName)."
            rewardLines = ["Trust feels steadier.", "Confidence nudged upward."]
        case .play:
            instance.state.mood = nextMood(from: instance.state.mood, preferred: "happy")
            instance.state.energy = max(0, instance.state.energy - 3)
            instance.progression.badges = Array((instance.progression.badges + ["playful-checkin"]).uniqued()).prefix(12).map { $0 }
            summary = "Played with \(instance.displayName) to keep the bond warm."
            rewardLines = ["Bond increased without pressure.", "Buddy feels more playful."]
        case .rest:
            instance.state.mood = nextMood(from: instance.state.mood, preferred: "sleepy")
            instance.state.energy = min(100, instance.state.energy + 14)
            summary = "Let \(instance.displayName) recharge and reset."
            rewardLines = ["Vitality recovered.", "No missed-day penalty applied."]
        case .explore:
            instance.state.mood = nextMood(from: instance.state.mood, preferred: "thinking")
            instance.state.energy = max(0, instance.state.energy - 5)
            instance.proficiencies.increment(category: "Research", cap: contracts.progression.maxSkillProficiency)
            instance.proficiencies.increment(category: "Creativity", cap: contracts.progression.maxSkillProficiency)
            summary = "\(instance.displayName) explored something new and brought back ideas."
            rewardLines = ["Curiosity increased.", "Research and creativity both improved."]
        }

        instance.progression.xp += awardedXP
        instance.progression.bond = min(contracts.progression.maxBond, instance.progression.bond + bondDelta)
        instance.progression.streakDays = nextStreakDays(current: instance.progression.streakDays, lastActiveAt: previousLastActive, now: now)
        instance.state.lastActiveAt = now

        let updated = recalculateProgression(for: instance, template: contracts.templateForInstance(instance), now: now)
        var nextState = currentState
        nextState.upsert(updated)
        nextState.activeBuddyInstanceId = updated.instanceId
        nextState.lastUpdatedAt = now

        var nextEvents = currentEvents
        nextEvents.events.append(
            makeEvent(
                type: "buddy.care.completed",
                instance: updated,
                actor: "user",
                summary: summary,
                payload: [
                    "careAction": action.rawValue,
                    "rewardNotes": rewardLines.joined(separator: " | "),
                    "xpAwarded": String(awardedXP)
                ],
                effects: BuddyRuntimeEventEffects(
                    xpDelta: awardedXP,
                    bondDelta: bondDelta,
                    proficiencyDeltas: action == .explore ? ["Research": 1, "Creativity": 1] : nil,
                    moodTarget: updated.state.mood,
                    stateTransition: "care",
                    memoryPromotion: nil,
                    badgeGrant: action == .play ? "playful-checkin" : nil,
                    passiveUnlock: nil,
                    signatureUpgrade: nil,
                    receiptRef: nil,
                    sanitationReport: nil
                ),
                occurredAt: now
            )
        )

        return finalize(
            state: nextState,
            eventLog: nextEvents,
            summary: summary,
            actionTitle: "\(action.title) \(updated.displayName)",
            activeInstanceID: updated.instanceId,
            now: now
        )
    }

    func startBattle(
        instanceID: String,
        arenaName: String,
        modifier: BuddyBattleArenaModifier,
        currentState: BuddyLibraryState,
        currentEvents: BuddyRuntimeEventLog,
        now: Date = .now
    ) throws -> BuddyPersistenceBundle {
        guard var instance = currentState.instances.first(where: { $0.instanceId == instanceID }) else {
            throw BuddyEventEngineError.instanceNotFound(instanceID)
        }

        let template = contracts.templateForInstance(instance)
        let existingBattles = currentState.battleHistory ?? []
        let battleIndex = existingBattles.filter { $0.buddyInstanceId == instance.instanceId }.count
        let previousLastActive = instance.state.lastActiveAt
        let opponent = battleOpponent(for: instance, template: template, battleIndex: battleIndex)
        let playerPower = battlePower(for: instance, template: template, modifier: modifier)
        let rivalPower = opponent.basePower + modifier.challengeBonus + battleIndex * 2
        let victory = playerPower >= rivalPower
        let xpAwarded = cappedXP(currentEvents, on: now, requested: (victory ? 18 : 10) + modifier.rewardBonus)
        let bondDelta = cappedBondDelta(currentEvents, on: now, requested: victory ? 1 : 0)
        let recommendations = battleRecommendations(for: instance)

        instance.state.energy = max(0, instance.state.energy - (modifier == .charged ? 16 : 11))
        instance.state.lastActiveAt = now
        instance.state.mood = nextMood(from: instance.state.mood, preferred: victory ? "levelUp" : "working")
        instance.progression.xp += xpAwarded
        instance.progression.bond = min(contracts.progression.maxBond, instance.progression.bond + bondDelta)
        instance.progression.streakDays = nextStreakDays(current: instance.progression.streakDays, lastActiveAt: previousLastActive, now: now)
        if victory {
            instance.proficiencies.increment(category: recommendations.first ?? "Building", cap: contracts.progression.maxSkillProficiency)
        } else {
            instance.proficiencies.increment(category: recommendations.first ?? "Planning", cap: contracts.progression.maxSkillProficiency)
        }
        var visual = instance.visual ?? BuddyVisualState(
            asciiVariantId: nil,
            pixelVariantId: nil,
            currentAnimationState: nil,
            evolutionCosmetics: []
        )
        if victory {
            let cosmetic = opponent.rewardCosmetic
            visual.evolutionCosmetics = Array((visual.evolutionCosmetics + [cosmetic]).uniqued()).prefix(8).map { $0 }
        }
        instance.visual = visual

        let updated = recalculateProgression(for: instance, template: template, now: now)
        let result = victory ? "victory" : "setback"
        let scoreline = "\(playerPower) - \(rivalPower)"
        let record = BuddyBattleRecord(
            id: "battle_\(UUID().uuidString.lowercased())",
            buddyInstanceId: updated.instanceId,
            buddyDisplayName: updated.displayName,
            opponentName: opponent.name,
            opponentStyle: opponent.style,
            arenaName: arenaName.nilIfBlank ?? "Pocket Arena",
            modifier: modifier.rawValue,
            result: result,
            summary: victory
                ? "\(updated.displayName) won a \(modifier.title.lowercased()) spar against \(opponent.name)."
                : "\(updated.displayName) lost a \(modifier.title.lowercased()) spar to \(opponent.name), but learned something useful.",
            scoreline: scoreline,
            rewards: victory
                ? ["+\(xpAwarded) XP", "\(opponent.rewardCosmetic) unlocked", recommendations.first.map { "Training bonus: \($0)" }].compactMap { $0 }
                : ["+\(xpAwarded) XP", "Recovery path prepared", recommendations.first.map { "Train \($0) next" }].compactMap { $0 },
            recommendedTraining: recommendations,
            createdAt: now
        )

        var nextState = currentState
        nextState.upsert(updated)
        nextState.activeBuddyInstanceId = updated.instanceId
        nextState.battleHistory = [record] + Array(existingBattles.prefix(19))
        nextState.lastUpdatedAt = now

        var nextEvents = currentEvents
        nextEvents.events.append(
            makeEvent(
                type: "buddy.battle.completed",
                instance: updated,
                actor: "runtime",
                summary: record.summary,
                payload: [
                    "opponentName": opponent.name,
                    "arenaName": record.arenaName,
                    "modifier": modifier.rawValue,
                    "result": result,
                    "scoreline": scoreline
                ],
                effects: BuddyRuntimeEventEffects(
                    xpDelta: xpAwarded,
                    bondDelta: bondDelta == 0 ? nil : bondDelta,
                    proficiencyDeltas: [recommendations.first ?? "Planning": 1],
                    moodTarget: updated.state.mood,
                    stateTransition: "battle",
                    memoryPromotion: "Persisted a Buddy sparring record.",
                    badgeGrant: victory ? "sparring-win" : nil,
                    passiveUnlock: updated.progression.passiveUnlocked ? "tier2-passive" : nil,
                    signatureUpgrade: updated.progression.signatureUpgradeUnlocked ? "tier3-signature" : nil,
                    receiptRef: nil,
                    sanitationReport: nil
                ),
                occurredAt: now
            )
        )

        return finalize(
            state: nextState,
            eventLog: nextEvents,
            summary: record.summary,
            actionTitle: "Spar \(updated.displayName)",
            activeInstanceID: updated.instanceId,
            now: now
        )
    }

    func makeActive(
        instanceID: String,
        currentState: BuddyLibraryState,
        currentEvents: BuddyRuntimeEventLog,
        now: Date = .now
    ) throws -> BuddyPersistenceBundle {
        guard let instance = currentState.instances.first(where: { $0.instanceId == instanceID }) else {
            throw BuddyEventEngineError.instanceNotFound(instanceID)
        }

        var nextState = currentState
        nextState.activeBuddyInstanceId = instanceID
        nextState.lastUpdatedAt = now

        var nextEvents = currentEvents
        nextEvents.events.append(
            makeEvent(
                type: "buddy.receipt.recorded",
                instance: instance,
                actor: "runtime",
                summary: "Marked \(instance.displayName) as the active Buddy.",
                payload: ["activeBuddyInstanceId": instanceID],
                effects: BuddyRuntimeEventEffects(
                    xpDelta: nil,
                    bondDelta: nil,
                    proficiencyDeltas: nil,
                    moodTarget: nil,
                    stateTransition: "active",
                    memoryPromotion: nil,
                    badgeGrant: nil,
                    passiveUnlock: nil,
                    signatureUpgrade: nil,
                    receiptRef: nil,
                    sanitationReport: nil
                ),
                occurredAt: now
            )
        )

        return finalize(
            state: nextState,
            eventLog: nextEvents,
            summary: "Made \(instance.displayName) the active Buddy.",
            actionTitle: "Activate \(instance.displayName)",
            activeInstanceID: instanceID,
            now: now
        )
    }

    private func finalize(
        state: BuddyLibraryState,
        eventLog: BuddyRuntimeEventLog,
        summary: String,
        actionTitle: String,
        activeInstanceID: String?,
        now: Date
    ) -> BuddyPersistenceBundle {
        var nextState = state
        nextState.lastUpdatedAt = now
        var nextEvents = eventLog

        if let active = activeInstanceID.flatMap({ id in nextState.instances.first(where: { $0.instanceId == id }) }) {
            nextEvents.events.append(
                makeEvent(
                    type: "buddy.memory.promoted",
                    instance: active,
                    actor: "system",
                    summary: "Promoted Buddy continuity into buddy.md and buddies.md.",
                    payload: [
                        "buddyFile": ".openclaw/buddy.md",
                        "rosterFile": ".openclaw/buddies.md"
                    ],
                    effects: BuddyRuntimeEventEffects(
                        xpDelta: nil,
                        bondDelta: nil,
                        proficiencyDeltas: nil,
                        moodTarget: nil,
                        stateTransition: nil,
                        memoryPromotion: "Updated readable Buddy continuity files.",
                        badgeGrant: nil,
                        passiveUnlock: nil,
                        signatureUpgrade: nil,
                        receiptRef: nil,
                        sanitationReport: nil
                    ),
                    occurredAt: now
                )
            )
        }

        let activeBuddy = nextState.activeBuddy
        let activeMarkdown = activeBuddy.map {
            BuddyMarkdownRenderer.renderActiveBuddy(
                instance: $0,
                template: contracts.templateForInstance($0),
                contracts: contracts,
                events: nextEvents.events,
                battleHistory: nextState.battleHistory ?? [],
                tradeHistory: nextState.tradeHistory ?? [],
                now: now
            )
        }
        let rosterMarkdown = BuddyMarkdownRenderer.renderRoster(
            instances: nextState.instances,
            activeBuddyInstanceId: nextState.activeBuddyInstanceId,
            contracts: contracts,
            events: nextEvents.events,
            battleHistory: nextState.battleHistory ?? [],
            tradeHistory: nextState.tradeHistory ?? [],
            now: now
        )

        return BuddyPersistenceBundle(
            libraryState: nextState,
            eventLog: nextEvents,
            activeBuddyMarkdown: activeMarkdown,
            rosterMarkdown: rosterMarkdown,
            actionTitle: actionTitle,
            summary: summary
        )
    }

    private func buildInstance(from template: CouncilStarterBuddyTemplate, now: Date) -> BuddyInstance {
        let roleProfile = contracts.progression.roleProfiles[template.id]
        return BuddyInstance(
            instanceId: "buddy_inst_\(template.id)_\(UUID().uuidString.lowercased())",
            templateId: template.templateID,
            displayName: template.name,
            nickname: nil,
            identity: CouncilBuddyIdentityCatalog.identity(for: template),
            progression: BuddyProgressionState(
                level: 1,
                xp: 0,
                bond: 1,
                evolutionTier: 1,
                growthStageLabel: contracts.stateMachine.domains.progression.tiers["1"]?.label ?? "Starter",
                badges: [],
                streakDays: 0,
                passiveUnlocked: false,
                signatureUpgradeUnlocked: false
            ),
            state: BuddyStateSnapshot(
                mood: nextMood(from: contracts.stateMachine.domains.mood.initial, preferred: "happy"),
                energy: 82,
                activityMode: contracts.creationOptions.defaults.activityMode,
                lastActiveAt: now,
                currentFocus: roleProfile?.dailyChallengeHook.name ?? template.recommendedFor.first,
                favoriteTasks: template.recommendedFor.prefix(3).map { $0 }
            ),
            equippedMoves: template.moveSet.enumerated().map { offset, move in
                BuddyEquippedMove(
                    name: move.name,
                    category: move.category,
                    kind: move.kind,
                    slot: offset + 1,
                    mastery: move.kind == "signature" ? 1 : 0
                )
            },
            proficiencies: BuddyProficiencies.zero,
            provenance: BuddyProvenance(
                installedFrom: "official_library",
                derivedFromTemplate: true,
                sanitizedSource: true,
                creatorId: nil,
                installedAt: now
            ),
            memory: BuddyMemoryBindings(
                buddyFile: ".openclaw/buddy.md",
                userFile: ".openclaw/user.md",
                memoryFile: ".openclaw/memory.md",
                sessionFile: ".openclaw/session.md",
                skillsFile: ".openclaw/skills.md",
                lastStateSyncAt: now
            ),
            visual: BuddyVisualState(
                asciiVariantId: "\(template.id)_ascii_v1",
                pixelVariantId: nil,
                currentAnimationState: "happy",
                evolutionCosmetics: []
            ),
            trainingHistory: [],
            learnedPreferences: [],
            learnedSkills: Self.defaultStarterSkills(now: now),
            dailyPlans: []
        )
    }

    private func recalculateProgression(
        for instance: BuddyInstance,
        template: CouncilStarterBuddyTemplate?,
        now: Date
    ) -> BuddyInstance {
        var updated = instance
        updated.progression.level = level(for: updated.progression.xp)
        let tier = evolutionTier(for: updated, template: template)
        updated.progression.evolutionTier = tier
        updated.progression.growthStageLabel = contracts.stateMachine.domains.progression.tiers["\(tier)"]?.label ?? updated.progression.growthStageLabel
        updated.progression.passiveUnlocked = tier >= 2
        updated.progression.signatureUpgradeUnlocked = tier >= 3
        updated.memory.lastStateSyncAt = now
        return updated
    }

    private func evolutionTier(for instance: BuddyInstance, template: CouncilStarterBuddyTemplate?) -> Int {
        guard let template else { return 1 }
        let roleProfile = contracts.progression.roleProfiles[template.id]
        let primaryCategory = roleProfile?.primaryTrainingCategory ?? ""
        let normalizedPrimary = normalizeCategory(primaryCategory)
        let primaryTrainingSessions = instance.trainingHistory.filter {
            normalizeCategory($0.category) == normalizedPrimary
        }.count
        let dailyChallengesCompleted = instance.trainingHistory.filter { $0.source == "daily_challenge" }.count
        let realTasksCompleted = instance.trainingHistory.filter { $0.source == "real_task" }.count
        let primarySkill = instance.proficiencies.value(for: primaryCategory)

        if instance.progression.level >= 10,
           instance.progression.bond >= 7,
           primarySkill >= 2,
           instance.progression.streakDays >= 3,
           dailyChallengesCompleted >= 3 {
            return 3
        }

        if instance.progression.level >= 5,
           instance.progression.bond >= 3,
           primaryTrainingSessions >= 3,
           dailyChallengesCompleted >= 3,
           realTasksCompleted >= 7 {
            return 2
        }

        return 1
    }

    private func level(for xp: Int) -> Int {
        contracts.progression.xpThresholds
            .sorted { $0.level < $1.level }
            .last(where: { xp >= $0.xpRequired })?.level ?? 1
    }

    private func cappedXP(_ eventLog: BuddyRuntimeEventLog, on date: Date, requested: Int) -> Int {
        let usedToday = eventLog.events
            .filter { Calendar.current.isDate($0.occurredAt, inSameDayAs: date) }
            .compactMap(\.effects.xpDelta)
            .reduce(0, +)
        let remaining = max(0, contracts.progression.antiGrind.dailySoftCapXp - usedToday)
        return min(requested, remaining)
    }

    private func cappedBondDelta(_ eventLog: BuddyRuntimeEventLog, on date: Date, requested: Int) -> Int {
        let usedToday = eventLog.events
            .filter { Calendar.current.isDate($0.occurredAt, inSameDayAs: date) }
            .compactMap(\.effects.bondDelta)
            .reduce(0, +)
        let remaining = max(0, (contracts.stateMachine.domains.bond.rules.dailySoftCap) - usedToday)
        return min(requested, remaining)
    }

    private func nextMood(from current: String, preferred: String) -> String {
        let domain = contracts.stateMachine.domains.mood
        let currentState = domain.states[current] ?? domain.states[domain.initial]
        guard let currentState else { return preferred }
        return currentState.allowedTransitions.contains(preferred) ? preferred : domain.initial
    }

    private func nextStreakDays(current: Int, lastActiveAt: Date, now: Date) -> Int {
        let calendar = Calendar.current
        if calendar.isDate(lastActiveAt, inSameDayAs: now) {
            return max(current, 1)
        }
        guard let yesterday = calendar.date(byAdding: .day, value: -1, to: now),
              calendar.isDate(lastActiveAt, inSameDayAs: yesterday) else {
            return 1
        }
        return current + 1
    }

    private func battlePower(
        for instance: BuddyInstance,
        template: CouncilStarterBuddyTemplate?,
        modifier: BuddyBattleArenaModifier
    ) -> Int {
        let templateTotal = template?.total ?? 36
        let movePower = instance.equippedMoves.reduce(0) { partial, move in
            partial + move.mastery + (move.kind == "signature" ? 3 : 1)
        }
        return templateTotal
            + (instance.progression.level * 4)
            + (instance.progression.bond * 2)
            + (instance.state.energy / 5)
            + (instance.proficiencies.planning * 2)
            + (instance.proficiencies.building * 2)
            + (instance.proficiencies.verification * 2)
            + movePower
            + modifier.rewardBonus
    }

    private func battleOpponent(
        for instance: BuddyInstance,
        template: CouncilStarterBuddyTemplate?,
        battleIndex: Int
    ) -> (name: String, style: String, basePower: Int, rewardCosmetic: String) {
        let rivals = [
            ("Signal Fox", "fast pressure", 58, "signal-scarf"),
            ("Lantern Moth", "evasive tempo", 54, "lantern-wings"),
            ("Harbor Wisp", "curious trickster", 56, "harbor-glow"),
            ("Stone Pup", "steady defender", 60, "stone-band"),
            ("Circuit Sprout", "adaptive learner", 57, "circuit-bloom")
        ]
        let seed = instance.instanceId.unicodeScalars.map(\.value).reduce(0, +)
        let offset = Int(seed) + battleIndex + (template?.name.count ?? 0)
        let rival = rivals[offset % rivals.count]
        return rival
    }

    private func battleRecommendations(for instance: BuddyInstance) -> [String] {
        let ordered: [(String, Int)] = [
            ("Planning", instance.proficiencies.planning),
            ("Building", instance.proficiencies.building),
            ("Research", instance.proficiencies.research),
            ("Verification", instance.proficiencies.verification),
            ("Creativity", instance.proficiencies.creativity),
            ("Coordination", instance.proficiencies.coordination)
        ]
        return ordered
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 { return lhs.0 < rhs.0 }
                return lhs.1 < rhs.1
            }
            .prefix(2)
            .map(\.0)
    }

    private func makeEvent(
        type: String,
        instance: BuddyInstance,
        actor: String,
        summary: String,
        payload: [String: String],
        effects: BuddyRuntimeEventEffects,
        occurredAt: Date
    ) -> BuddyRuntimeEvent {
        BuddyRuntimeEvent(
            id: UUID().uuidString.lowercased(),
            type: type,
            buddyInstanceId: instance.instanceId,
            buddyDisplayName: instance.displayName,
            actor: actor,
            occurredAt: occurredAt,
            summary: summary,
            payload: payload,
            effects: effects
        )
    }

    private func normalizeCategory(_ value: String) -> String {
        value
            .lowercased()
            .replacingOccurrences(of: "_", with: "")
            .replacingOccurrences(of: " ", with: "")
    }

    private func upsertPreference(
        in preferences: [BuddyLearnedPreference],
        category: String,
        title: String,
        detail: String,
        source: String,
        now: Date
    ) -> [BuddyLearnedPreference] {
        var updated = preferences
        if let index = updated.firstIndex(where: { $0.category == category && $0.title.localizedCaseInsensitiveCompare(title) == .orderedSame }) {
            updated[index].detail = detail
            updated[index].updatedAt = now
            updated[index].reinforcementCount += 1
        } else {
            updated.insert(
                BuddyLearnedPreference(
                    id: "pref_\(UUID().uuidString.lowercased())",
                    category: category,
                    title: title,
                    detail: detail,
                    source: source,
                    createdAt: now,
                    updatedAt: now,
                    reinforcementCount: 1
                ),
                at: 0
            )
        }
        return Array(updated.prefix(40))
    }

    private func upsertSkill(
        in skills: [BuddySkillState],
        id: String,
        trainedCategory: String,
        now: Date,
        cap: Int
    ) -> [BuddySkillState] {
        var updated = skills
        if let index = updated.firstIndex(where: { $0.id == id }) {
            updated[index].isUnlocked = true
            updated[index].isEquipped = true
            updated[index].mastery = min(cap, updated[index].mastery + 1)
            updated[index].unlockedAt = updated[index].unlockedAt ?? now
            updated[index].lastTrainedAt = now
        } else {
            updated.insert(
                BuddySkillState(
                    id: id,
                    name: "Daily Planning",
                    summary: "Turns a taught planning preference into a reminder, journal prompt, and follow-up draft.",
                    category: trainedCategory,
                    isUnlocked: true,
                    isEquipped: true,
                    mastery: 1,
                    unlockedAt: now,
                    lastTrainedAt: now
                ),
                at: 0
            )
        }
        return updated
    }

    static func defaultStarterSkills(now: Date) -> [BuddySkillState] {
        [
            BuddySkillState(
                id: "daily-planning",
                name: "Daily Planning",
                summary: "Turns taught planning preferences into a daily plan, reminder, journal prompt, and follow-up draft.",
                category: "Planning",
                isUnlocked: true,
                isEquipped: true,
                mastery: 1,
                unlockedAt: now,
                lastTrainedAt: now
            ),
            BuddySkillState(
                id: "reflection-journal",
                name: "Reflection Journal",
                summary: "Captures what Buddy learned and what changed today as an editable local artifact.",
                category: "Memory",
                isUnlocked: true,
                isEquipped: false,
                mastery: 0,
                unlockedAt: now,
                lastTrainedAt: nil
            ),
            BuddySkillState(
                id: "message-drafting",
                name: "Message Drafting",
                summary: "Drafts check-ins or follow-ups for user-approved compose flows. It never sends silently.",
                category: "Writing",
                isUnlocked: true,
                isEquipped: false,
                mastery: 0,
                unlockedAt: now,
                lastTrainedAt: nil
            )
        ]
    }

    private static let dayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter
    }()
}

private extension BuddyLibraryState {
    mutating func upsert(_ instance: BuddyInstance) {
        if let existingIndex = instances.firstIndex(where: { $0.instanceId == instance.instanceId }) {
            instances[existingIndex] = instance
        } else {
            instances.append(instance)
        }
        instances.sort { $0.provenance.installedAt > $1.provenance.installedAt }
    }
}

private extension String {
    var nilIfBlank: String? {
        let value = trimmingCharacters(in: .whitespacesAndNewlines)
        return value.isEmpty ? nil : value
    }
}

private extension Array where Element == String {
    func uniqued() -> [String] {
        var seen = Set<String>()
        return filter { value in
            let normalized = value.lowercased()
            guard seen.contains(normalized) == false else { return false }
            seen.insert(normalized)
            return true
        }
    }
}
