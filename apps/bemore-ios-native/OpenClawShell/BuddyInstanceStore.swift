import Foundation

struct BuddyInstanceStore {
    private let encoder: JSONEncoder = {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }()

    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return decoder
    }()

    // Tolerant decoder for legacy JSON that may use either ISO 8601 strings or
    // numeric timestamps (seconds since Apple reference date, the JSONEncoder default).
    private let legacyDecoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            if let str = try? container.decode(String.self) {
                let iso = ISO8601DateFormatter()
                if let date = iso.date(from: str) { return date }
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Cannot parse date string: \(str)"
                )
            }
            // JSONEncoder default: Double seconds since Jan 1 2001 (Apple reference date)
            let seconds = try container.decode(Double.self)
            return Date(timeIntervalSinceReferenceDate: seconds)
        }
        return decoder
    }()

    var libraryStateURL: URL {
        Paths.stateDirectory.appendingPathComponent("buddy-instances.json")
    }

    var eventLogURL: URL {
        Paths.openClawDirectory.appendingPathComponent("state/buddy-runtime-events.json")
    }

    private var legacyStateURL: URL {
        Paths.stateDirectory.appendingPathComponent("buddy-system.json")
    }

    func loadLibraryState() -> BuddyLibraryState? {
        guard let data = try? Data(contentsOf: libraryStateURL) else { return nil }
        return try? decoder.decode(BuddyLibraryState.self, from: data)
    }

    func loadEventLog() -> BuddyRuntimeEventLog? {
        guard let data = try? Data(contentsOf: eventLogURL) else { return nil }
        return try? decoder.decode(BuddyRuntimeEventLog.self, from: data)
    }

    func persistLibraryState(_ state: BuddyLibraryState) throws {
        let data = try encoder.encode(state)
        try FileManager.default.createDirectory(at: libraryStateURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try data.write(to: libraryStateURL, options: [.atomic])
    }

    func migrateLegacyState(contracts: BuddyCanonicalResources) -> BuddyLibraryState? {
        guard let data = try? Data(contentsOf: legacyStateURL),
              let legacy = try? legacyDecoder.decode(LegacyBuddySystemState.self, from: data) else {
            return nil
        }

        var instances: [BuddyInstance] = []
        instances.append(migrateLegacyBuddy(legacy.activeBuddy, contracts: contracts))

        for buddy in legacy.collection {
            let migrated = migrateLegacyBuddy(buddy, contracts: contracts)
            if instances.contains(where: { $0.displayName == migrated.displayName }) == false {
                instances.append(migrated)
            }
        }

        let activeID = instances.first?.instanceId
        return BuddyLibraryState(
            version: "1.0.0",
            activeBuddyInstanceId: activeID,
            instances: instances.sorted { $0.provenance.installedAt > $1.provenance.installedAt },
            lastUpdatedAt: instances.map { $0.provenance.installedAt }.max() ?? .now
        )
    }

    private func migrateLegacyBuddy(_ legacy: LegacyGeneratedBuddy, contracts: BuddyCanonicalResources) -> BuddyInstance {
        let fallbackTemplate = contracts.templates.first(where: { $0.id == "bmo" }) ?? contracts.templates.first
        let identity = fallbackTemplate.map { CouncilBuddyIdentityCatalog.identity(for: $0) } ?? BuddyIdentity(
            class: "Legacy",
            role: legacy.title,
            personalityPrimary: "Cheerful",
            personalitySecondary: nil,
            voicePrimary: "Friendly",
            voiceSecondary: nil,
            archetype: "console_pet",
            bodyStyle: "compact",
            palette: "mint_cream"
        )
        let installedAt = legacy.createdAt
        let bond = max(1, min(contracts.progression.maxBond, legacy.stats.bond / 10))

        return BuddyInstance(
            instanceId: "legacy_\(legacy.id.uuidString.lowercased())",
            templateId: "legacy.generated.v1",
            displayName: legacy.name,
            nickname: nil,
            identity: BuddyIdentity(
                class: identity.class,
                role: legacy.title,
                personalityPrimary: identity.personalityPrimary,
                personalitySecondary: identity.personalitySecondary,
                voicePrimary: identity.voicePrimary,
                voiceSecondary: identity.voiceSecondary,
                archetype: legacy.archetype,
                bodyStyle: identity.bodyStyle,
                palette: identity.palette
            ),
            progression: BuddyProgressionState(
                level: 1,
                xp: 0,
                bond: bond,
                evolutionTier: 1,
                growthStageLabel: "Legacy",
                badges: ["legacy_migrated"],
                streakDays: 0,
                passiveUnlocked: false,
                signatureUpgradeUnlocked: false
            ),
            state: BuddyStateSnapshot(
                mood: "neutral",
                energy: 75,
                activityMode: "balanced",
                lastActiveAt: installedAt,
                currentFocus: legacy.specialty,
                favoriteTasks: []
            ),
            equippedMoves: [
                BuddyEquippedMove(name: "Carry Forward", category: "Recovery", kind: "signature", slot: 1, mastery: 1),
                BuddyEquippedMove(name: "Fresh Start", category: "Support", kind: "utility", slot: 2, mastery: 0),
                BuddyEquippedMove(name: "Keep Signal", category: "Utility", kind: "utility", slot: 3, mastery: 0),
                BuddyEquippedMove(name: "Open Claw", category: "Attack", kind: "universal", slot: 4, mastery: 0)
            ],
            proficiencies: .zero,
            provenance: BuddyProvenance(
                installedFrom: "custom_creation",
                derivedFromTemplate: false,
                sanitizedSource: true,
                creatorId: nil,
                installedAt: installedAt
            ),
            memory: BuddyMemoryBindings(
                buddyFile: ".openclaw/buddy.md",
                userFile: ".openclaw/user.md",
                memoryFile: ".openclaw/memory.md",
                sessionFile: ".openclaw/session.md",
                skillsFile: ".openclaw/skills.md",
                lastStateSyncAt: installedAt
            ),
            visual: BuddyVisualState(
                asciiVariantId: nil,
                pixelVariantId: nil,
                activeAppearanceProfileId: nil,
                currentAnimationState: "neutral",
                evolutionCosmetics: []
            ),
            appearanceProfiles: [],
            trainingHistory: [],
            learnedPreferences: [],
            learnedSkills: BuddyEventEngine.defaultStarterSkills(now: installedAt),
            dailyPlans: []
        )
    }
}

@MainActor
final class BuddyProfileStore: ObservableObject {
    @Published private(set) var contracts: BuddyCanonicalResources?
    @Published private(set) var libraryState = BuddyLibraryState()
    @Published private(set) var eventLog = BuddyRuntimeEventLog()
    @Published private(set) var lastReceipt: OpenClawReceipt?
    @Published private(set) var loadError: String?
    @Published private(set) var lastTradeExportCode: String?
    @Published private(set) var lastTradeExportJSON: String?
    @Published private(set) var tradeStatusMessage: String?
    @Published var selectedTrainingCategory: String = "Planning"

    private let store = BuddyInstanceStore()

    var templates: [CouncilStarterBuddyTemplate] {
        contracts?.templates ?? []
    }

    var activeBuddy: BuddyInstance? {
        libraryState.activeBuddy
    }

    var installedBuddies: [BuddyInstance] {
        libraryState.instances
    }

    var battleHistory: [BuddyBattleRecord] {
        libraryState.battleHistory ?? []
    }

    var tradeHistory: [BuddyTradeRecord] {
        libraryState.tradeHistory ?? []
    }

    func recentEvents(for instance: BuddyInstance?, limit: Int = 6) -> [BuddyRuntimeEvent] {
        guard let instance else { return [] }
        return eventLog.events
            .filter { $0.buddyInstanceId == instance.instanceId }
            .sorted { $0.occurredAt > $1.occurredAt }
            .prefix(limit)
            .map { $0 }
    }

    func load(for _: StackConfig) {
        do {
            let contracts = try BuddyContractLoader.loadCanonicalResources()
            self.contracts = contracts
            if let existing = store.loadLibraryState() {
                libraryState = normalizedLibraryState(existing, contracts: contracts)
            } else if let migrated = store.migrateLegacyState(contracts: contracts) {
                libraryState = normalizedLibraryState(migrated, contracts: contracts)
                // Persist immediately so migration doesn't re-run on every launch.
                try store.persistLibraryState(libraryState)
            } else {
                libraryState = BuddyLibraryState()
            }
            eventLog = store.loadEventLog() ?? BuddyRuntimeEventLog()
            if libraryState.activeBuddyInstanceId == nil {
                libraryState.activeBuddyInstanceId = libraryState.instances.first?.instanceId
            }
            selectedTrainingCategory = contracts.progression.trainingCategories.first ?? "Planning"
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func normalizedLibraryState(_ state: BuddyLibraryState, contracts: BuddyCanonicalResources) -> BuddyLibraryState {
        var normalized = state
        normalized.instances = state.instances.map { buddy in
            var updated = buddy
            if updated.appearanceProfiles?.isEmpty != false {
                let defaultProfile = BuddyAppearanceProfile(
                    id: "appearance_\(updated.instanceId)_starter",
                    name: "Starter Look",
                    archetype: updated.identity.archetype,
                    palette: updated.identity.palette,
                    asciiVariantId: updated.visual?.asciiVariantId ?? contracts.creationOptions.defaults.asciiVariant,
                    expressionTone: "friendly",
                    accentLabel: updated.visual?.evolutionCosmetics.first ?? "starter glow",
                    source: "hermes_ascii",
                    createdAt: updated.provenance.installedAt,
                    updatedAt: updated.memory.lastStateSyncAt ?? updated.provenance.installedAt
                )
                updated.appearanceProfiles = [defaultProfile]
                if updated.visual == nil {
                    updated.visual = BuddyVisualState(
                        asciiVariantId: defaultProfile.asciiVariantId,
                        pixelVariantId: nil,
                        activeAppearanceProfileId: defaultProfile.id,
                        currentAnimationState: updated.state.mood,
                        evolutionCosmetics: []
                    )
                } else {
                    updated.visual?.activeAppearanceProfileId = defaultProfile.id
                }
            } else if updated.visual?.activeAppearanceProfileId == nil {
                updated.visual?.activeAppearanceProfileId = updated.appearanceProfiles?.first?.id
            }
            return updated
        }
        return normalized
    }

    func install(template: CouncilStarterBuddyTemplate, using appState: AppState) {
        mutate(using: appState) { contracts in
            try BuddyEventEngine(contracts: contracts).install(
                templateID: template.id,
                currentState: libraryState,
                currentEvents: eventLog
            )
        }
    }

    func personalizeActive(
        displayName: String,
        nickname: String?,
        currentFocus: String?,
        palette: String?,
        asciiVariantID: String?,
        using appState: AppState
    ) {
        guard let activeBuddy else { return }
        mutate(using: appState) { contracts in
            try BuddyEventEngine(contracts: contracts).personalize(
                instanceID: activeBuddy.instanceId,
                displayName: displayName,
                nickname: nickname,
                currentFocus: currentFocus,
                palette: palette,
                asciiVariantID: asciiVariantID,
                currentState: libraryState,
                currentEvents: eventLog
            )
        }
    }

    func saveAppearanceProfile(
        profileName: String,
        archetype: String,
        palette: String,
        asciiVariantID: String,
        expressionTone: String,
        accentLabel: String,
        setActive: Bool,
        using appState: AppState
    ) {
        guard let activeBuddy else { return }
        mutate(using: appState) { contracts in
            try BuddyEventEngine(contracts: contracts).saveAppearanceProfile(
                instanceID: activeBuddy.instanceId,
                profileName: profileName,
                archetype: archetype,
                palette: palette,
                asciiVariantID: asciiVariantID,
                expressionTone: expressionTone,
                accentLabel: accentLabel,
                setActive: setActive,
                currentState: libraryState,
                currentEvents: eventLog
            )
        }
    }

    func activateAppearanceProfile(_ profileID: String, using appState: AppState) {
        guard let activeBuddy else { return }
        mutate(using: appState) { contracts in
            try BuddyEventEngine(contracts: contracts).activateAppearanceProfile(
                instanceID: activeBuddy.instanceId,
                profileID: profileID,
                currentState: libraryState,
                currentEvents: eventLog
            )
        }
    }

    func makeActive(_ instance: BuddyInstance, using appState: AppState) {
        mutate(using: appState) { contracts in
            try BuddyEventEngine(contracts: contracts).makeActive(
                instanceID: instance.instanceId,
                currentState: libraryState,
                currentEvents: eventLog
            )
        }
    }

    func recordCheckIn(note: String?, using appState: AppState) {
        guard let activeBuddy else { return }
        mutate(using: appState) { contracts in
            try BuddyEventEngine(contracts: contracts).recordCheckIn(
                instanceID: activeBuddy.instanceId,
                note: note,
                currentState: libraryState,
                currentEvents: eventLog
            )
        }
    }

    func recordTraining(note: String?, using appState: AppState) {
        guard let activeBuddy else { return }
        mutate(using: appState) { contracts in
            try BuddyEventEngine(contracts: contracts).recordTraining(
                instanceID: activeBuddy.instanceId,
                category: selectedTrainingCategory,
                note: note,
                currentState: libraryState,
                currentEvents: eventLog
            )
        }
    }

    func performCare(_ action: BuddyCareAction, using appState: AppState) {
        guard let activeBuddy else { return }
        mutate(using: appState) { contracts in
            try BuddyEventEngine(contracts: contracts).performCare(
                instanceID: activeBuddy.instanceId,
                action: action,
                currentState: libraryState,
                currentEvents: eventLog
            )
        }
    }

    func startSparring(arenaName: String, modifier: BuddyBattleArenaModifier, using appState: AppState) {
        guard let activeBuddy else { return }
        mutate(using: appState) { contracts in
            try BuddyEventEngine(contracts: contracts).startBattle(
                instanceID: activeBuddy.instanceId,
                arenaName: arenaName,
                modifier: modifier,
                currentState: libraryState,
                currentEvents: eventLog
            )
        }
    }

    func teachPlanningLoop(
        preferenceTitle: String,
        preferenceDetail: String,
        topPriority: String,
        supportStyle: String,
        using appState: AppState
    ) {
        guard let activeBuddy else { return }
        mutate(using: appState) { contracts in
            try BuddyEventEngine(contracts: contracts).teachPlanningLoop(
                instanceID: activeBuddy.instanceId,
                preferenceTitle: preferenceTitle,
                preferenceDetail: preferenceDetail,
                topPriority: topPriority,
                supportStyle: supportStyle,
                currentState: libraryState,
                currentEvents: eventLog
            )
        }
    }

    func packageActiveBuddyTemplate(using appState: AppState) {
        guard let activeBuddy else {
            loadError = "Install or equip a Buddy before packaging a template."
            return
        }
        guard let contracts else {
            loadError = "Buddy contracts are not loaded yet."
            return
        }

        let template = contracts.templateForInstance(activeBuddy)
        let slug = safeTemplateSlug(activeBuddy.displayName.isEmpty ? activeBuddy.identity.role : activeBuddy.displayName)
        let jsonPath = "buddies/templates/\(slug)-template-package.json"
        let guidePath = "buddies/templates/\(slug)-seller-guide.md"
        let trainedCategories = activeBuddy.proficiencies.templateDictionary
            .filter { $0.value > 0 }
            .sorted { lhs, rhs in lhs.value == rhs.value ? lhs.key < rhs.key : lhs.value > rhs.value }
        let package: [String: Any] = [
            "schemaVersion": "buddy-template-package.v1",
            "packageId": "buddy.template.\(slug).v1",
            "displayName": activeBuddy.displayName,
            "sourceTemplateId": activeBuddy.templateId,
            "sourceTemplateName": template?.name ?? "Custom Buddy",
            "status": "sell-ready-draft",
            "marketplaceAvailability": "packaged locally; paid marketplace submission is gated by billing and moderation",
            "creatorNotes": [
                "This package is sanitized for template review.",
                "Private Buddy memory files, chat transcripts, check-in notes, and raw training notes are not included."
            ],
            "identity": [
                "class": activeBuddy.identity.class,
                "role": activeBuddy.identity.role,
                "personalityPrimary": activeBuddy.identity.personalityPrimary,
                "personalitySecondary": activeBuddy.identity.personalitySecondary ?? "",
                "voicePrimary": activeBuddy.identity.voicePrimary,
                "archetype": activeBuddy.identity.archetype,
                "bodyStyle": activeBuddy.identity.bodyStyle,
                "palette": activeBuddy.identity.palette
            ],
            "progressionSnapshot": [
                "level": activeBuddy.progression.level,
                "bond": activeBuddy.progression.bond,
                "evolutionTier": activeBuddy.progression.evolutionTier,
                "growthStageLabel": activeBuddy.progression.growthStageLabel,
                "badges": activeBuddy.progression.badges
            ],
            "publicTrainingSummary": [
                "trainingEventCount": activeBuddy.trainingHistory.count,
                "trainedCategories": trainedCategories.map { ["category": $0.key, "score": $0.value] },
                "favoriteTasks": activeBuddy.state.favoriteTasks
            ],
            "moves": activeBuddy.equippedMoves
                .sorted { $0.slot < $1.slot }
                .map { ["slot": $0.slot, "name": $0.name, "category": $0.category, "kind": $0.kind, "mastery": $0.mastery] },
            "recommendedFor": template?.recommendedFor ?? [],
            "sanitation": [
                "privateMemoryIncluded": false,
                "chatTranscriptsIncluded": false,
                "rawCheckInsIncluded": false,
                "rawTrainingNotesIncluded": false,
                "artifactPaths": [jsonPath, guidePath]
            ]
        ]

        do {
            let json = try prettyJSON(package)
            let guide = templateSellerGuide(
                buddy: activeBuddy,
                templateName: template?.name ?? "Custom Buddy",
                trainedCategories: trainedCategories,
                jsonPath: jsonPath
            )
            _ = appState.writeWorkspaceArtifact(path: jsonPath, content: json)
            lastReceipt = appState.writeWorkspaceArtifact(path: guidePath, content: guide)
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    func exportActiveTradePackage(using appState: AppState) {
        guard let activeBuddy else {
            loadError = "Install or equip a Buddy before exporting a trade package."
            return
        }
        guard let contracts else {
            loadError = "Buddy contracts are not loaded yet."
            return
        }

        do {
            let package = makeTradePackage(for: activeBuddy, contracts: contracts)
            let encoder = JSONEncoder()
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(package)
            let json = String(decoding: data, as: UTF8.self)
            let token = data
                .base64EncodedString()
                .replacingOccurrences(of: "+", with: "-")
                .replacingOccurrences(of: "/", with: "_")
                .replacingOccurrences(of: "=", with: "")

            let slug = safeTemplateSlug(activeBuddy.displayName)
            let jsonPath = "buddies/trades/\(slug)-trade-package.json"
            let tokenPath = "buddies/trades/\(slug)-trade-token.txt"
            _ = appState.writeWorkspaceArtifact(path: jsonPath, content: json)
            lastReceipt = appState.writeWorkspaceArtifact(path: tokenPath, content: token)
            lastTradeExportJSON = json
            lastTradeExportCode = token
            tradeStatusMessage = "Exported a trade-ready package for \(activeBuddy.displayName)."
            loadError = nil
        } catch {
            loadError = error.localizedDescription
        }
    }

    func importTradePackage(_ rawValue: String, using appState: AppState) {
        guard let contracts else {
            loadError = "Buddy contracts are not loaded yet."
            return
        }

        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            loadError = "Paste a Buddy trade token or JSON package first."
            return
        }

        do {
            let package = try decodeTradePackage(trimmed)
            try validateTradePackage(package)
            if tradeHistory.contains(where: { $0.packageId == package.packageId && $0.type == "import" }) {
                throw NSError(domain: "BuddyTrade", code: 1, userInfo: [NSLocalizedDescriptionKey: "This Buddy trade package was already imported on this device."])
            }

            let now = Date()
            let imported = importedBuddy(from: package, now: now)
            var nextState = libraryState
            nextState.upsertImported(imported)
            nextState.activeBuddyInstanceId = imported.instanceId
            nextState.tradeHistory = [
                BuddyTradeRecord(
                    id: "trade_\(UUID().uuidString.lowercased())",
                    packageId: package.packageId,
                    type: "import",
                    buddyDisplayName: imported.displayName,
                    summary: "Imported \(imported.displayName) from a trade package.",
                    createdAt: now
                )
            ] + Array(tradeHistory.prefix(19))
            nextState.lastUpdatedAt = now

            var nextEvents = eventLog
            nextEvents.events.append(
                BuddyRuntimeEvent(
                    id: UUID().uuidString.lowercased(),
                    type: "buddy.trade.imported",
                    buddyInstanceId: imported.instanceId,
                    buddyDisplayName: imported.displayName,
                    actor: "user",
                    occurredAt: now,
                    summary: "Imported \(imported.displayName) from a trade package.",
                    payload: [
                        "packageId": package.packageId,
                        "sourceApp": package.sourceApp,
                        "rarity": package.buddy.rarityLabel
                    ],
                    effects: BuddyRuntimeEventEffects(
                        xpDelta: nil,
                        bondDelta: nil,
                        proficiencyDeltas: nil,
                        moodTarget: imported.state.mood,
                        stateTransition: "trade_import",
                        memoryPromotion: "Installed a trade-imported Buddy package.",
                        badgeGrant: nil,
                        passiveUnlock: imported.progression.passiveUnlocked ? "tier2-passive" : nil,
                        signatureUpgrade: imported.progression.signatureUpgradeUnlocked ? "tier3-signature" : nil,
                        receiptRef: nil,
                        sanitationReport: "Imported only the sanitized trade payload."
                    )
                )
            )

            let bundle = BuddyPersistenceBundle(
                libraryState: nextState,
                eventLog: nextEvents,
                activeBuddyMarkdown: BuddyMarkdownRenderer.renderActiveBuddy(
                    instance: imported,
                    template: contracts.templateForInstance(imported),
                    contracts: contracts,
                    events: nextEvents.events,
                    battleHistory: nextState.battleHistory ?? [],
                    tradeHistory: nextState.tradeHistory ?? [],
                    now: now
                ),
                rosterMarkdown: BuddyMarkdownRenderer.renderRoster(
                    instances: nextState.instances,
                    activeBuddyInstanceId: nextState.activeBuddyInstanceId,
                    contracts: contracts,
                    events: nextEvents.events,
                    battleHistory: nextState.battleHistory ?? [],
                    tradeHistory: nextState.tradeHistory ?? [],
                    now: now
                ),
                actionTitle: "Import \(imported.displayName)",
                summary: "Imported \(imported.displayName) from a Buddy trade package."
            )

            let receipt = appState.persistBuddyBundle(bundle)
            lastReceipt = receipt
            if receipt.status == .persisted {
                libraryState = bundle.libraryState
                eventLog = bundle.eventLog
                tradeStatusMessage = "Imported \(imported.displayName) and made them your active Buddy."
                loadError = nil
            } else {
                loadError = receipt.error ?? receipt.summary
            }
        } catch {
            loadError = error.localizedDescription
        }
    }

    func ensureStarterBuddy(templateID: String, displayName: String, focus: String, using appState: AppState) {
        if contracts == nil {
            load(for: appState.stackConfig)
        }
        guard let template = templates.first(where: { $0.templateID == templateID || $0.id == templateID }) ?? templates.first else {
            loadError = "No starter Buddy templates are available."
            return
        }

        if let existing = installedBuddies.first(where: { $0.templateId == template.templateID || $0.templateId == template.id }) {
            makeActive(existing, using: appState)
        } else {
            install(template: template, using: appState)
        }

        let cleanedName = displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedFocus = focus.trimmingCharacters(in: .whitespacesAndNewlines)
        personalizeActive(
            displayName: cleanedName.isEmpty ? template.name : cleanedName,
            nickname: nil,
            currentFocus: cleanedFocus.isEmpty ? template.canonicalRole : cleanedFocus,
            palette: CouncilBuddyIdentityCatalog.identity(for: template).palette,
            asciiVariantID: contracts?.creationOptions.defaults.asciiVariant,
            using: appState
        )
    }

    private func mutate(using appState: AppState, operation: (BuddyCanonicalResources) throws -> BuddyPersistenceBundle) {
        guard let contracts else {
            loadError = "Buddy contracts are not loaded yet."
            return
        }

        do {
            let bundle = try operation(contracts)
            let receipt = appState.persistBuddyBundle(bundle)
            lastReceipt = receipt
            if receipt.status == .persisted {
                libraryState = bundle.libraryState
                eventLog = bundle.eventLog
                tradeStatusMessage = nil
                loadError = nil
            } else {
                loadError = receipt.error ?? receipt.summary
            }
        } catch {
            loadError = error.localizedDescription
        }
    }

    private func makeTradePackage(for buddy: BuddyInstance, contracts: BuddyCanonicalResources) -> BuddyTradePackage {
        let rarity = tradeRarity(for: buddy)
        return BuddyTradePackage(
            schemaVersion: "buddy-trade-package.v1",
            packageId: "trade.\(safeTemplateSlug(buddy.displayName)).\(UUID().uuidString.lowercased())",
            exportedAt: .now,
            sourceApp: "BeMore iPhone",
            buddy: BuddyTradeSnapshot(
                templateId: buddy.templateId,
                displayName: buddy.displayName,
                nickname: buddy.nickname,
                identity: buddy.identity,
                progression: buddy.progression,
                state: buddy.state,
                equippedMoves: buddy.equippedMoves.sorted { $0.slot < $1.slot },
                proficiencies: buddy.proficiencies,
                visual: buddy.visual,
                appearanceProfiles: buddy.appearanceProfiles,
                publicBadges: buddy.progression.badges,
                publicNotes: [
                    "Sanitized Buddy trade package exported from iPhone.",
                    "Private memory, raw notes, and chat transcripts are excluded.",
                    "Rarity: \(rarity)"
                ],
                rarityLabel: rarity
            )
        )
    }

    private func importedBuddy(from package: BuddyTradePackage, now: Date) -> BuddyInstance {
        let snapshot = package.buddy
        let clampedProgress = BuddyProgressionState(
            level: min(10, max(1, snapshot.progression.level)),
            xp: max(0, snapshot.progression.xp),
            bond: min(10, max(0, snapshot.progression.bond)),
            evolutionTier: min(3, max(1, snapshot.progression.evolutionTier)),
            growthStageLabel: snapshot.progression.growthStageLabel,
            badges: Array(snapshot.publicBadges.prefix(12)),
            streakDays: max(0, snapshot.progression.streakDays),
            passiveUnlocked: snapshot.progression.passiveUnlocked,
            signatureUpgradeUnlocked: snapshot.progression.signatureUpgradeUnlocked
        )
        return BuddyInstance(
            instanceId: "buddy_trade_\(UUID().uuidString.lowercased())",
            templateId: snapshot.templateId,
            displayName: snapshot.displayName,
            nickname: snapshot.nickname,
            identity: snapshot.identity,
            progression: clampedProgress,
            state: BuddyStateSnapshot(
                mood: snapshot.state.mood,
                energy: min(100, max(20, snapshot.state.energy)),
                activityMode: snapshot.state.activityMode,
                lastActiveAt: now,
                currentFocus: snapshot.state.currentFocus,
                favoriteTasks: Array(snapshot.state.favoriteTasks.prefix(5))
            ),
            equippedMoves: Array(snapshot.equippedMoves.sorted { $0.slot < $1.slot }.prefix(4)),
            proficiencies: snapshot.proficiencies,
            provenance: BuddyProvenance(
                installedFrom: "trade_import",
                derivedFromTemplate: snapshot.templateId.hasPrefix("starter."),
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
            visual: snapshot.visual ?? BuddyVisualState(
                asciiVariantId: nil,
                pixelVariantId: nil,
                activeAppearanceProfileId: nil,
                currentAnimationState: "happy",
                evolutionCosmetics: []
            ),
            appearanceProfiles: snapshot.appearanceProfiles ?? [],
            trainingHistory: [],
            learnedPreferences: [],
            learnedSkills: BuddyEventEngine.defaultStarterSkills(now: now),
            dailyPlans: []
        )
    }

    private func validateTradePackage(_ package: BuddyTradePackage) throws {
        guard package.schemaVersion == "buddy-trade-package.v1" else {
            throw NSError(domain: "BuddyTrade", code: 2, userInfo: [NSLocalizedDescriptionKey: "Unsupported Buddy trade package version."])
        }
        guard package.buddy.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw NSError(domain: "BuddyTrade", code: 3, userInfo: [NSLocalizedDescriptionKey: "Buddy trade package is missing a display name."])
        }
        guard package.buddy.equippedMoves.isEmpty == false else {
            throw NSError(domain: "BuddyTrade", code: 4, userInfo: [NSLocalizedDescriptionKey: "Buddy trade package is missing move data."])
        }
    }

    private func decodeTradePackage(_ rawValue: String) throws -> BuddyTradePackage {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601

        if let jsonData = rawValue.data(using: .utf8),
           let decoded = try? decoder.decode(BuddyTradePackage.self, from: jsonData) {
            return decoded
        }

        let normalized = rawValue
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let paddedLength = ((normalized.count + 3) / 4) * 4
        let padded = normalized.padding(toLength: paddedLength, withPad: "=", startingAt: 0)
        guard let data = Data(base64Encoded: padded) else {
            throw NSError(domain: "BuddyTrade", code: 5, userInfo: [NSLocalizedDescriptionKey: "Trade token is not valid JSON or base64."])
        }
        return try decoder.decode(BuddyTradePackage.self, from: data)
    }

    private func tradeRarity(for buddy: BuddyInstance) -> String {
        switch (buddy.progression.evolutionTier, buddy.progression.level) {
        case (3, _): return "Ascendant"
        case (2, 7...): return "Elite"
        case (_, 5...): return "Seasoned"
        default: return "Starter"
        }
    }

    private func prettyJSON(_ object: [String: Any]) throws -> String {
        let data = try JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted, .sortedKeys])
        return String(data: data, encoding: .utf8) ?? "{}"
    }

    private func safeTemplateSlug(_ value: String) -> String {
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        let slug = value
            .lowercased()
            .replacingOccurrences(of: " ", with: "-")
            .unicodeScalars
            .map { allowed.contains($0) ? Character($0) : "-" }
            .reduce(into: "") { $0.append($1) }
            .replacingOccurrences(of: "--", with: "-")
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return slug.isEmpty ? "buddy" : slug
    }

    private func templateSellerGuide(
        buddy: BuddyInstance,
        templateName: String,
        trainedCategories: [(key: String, value: Int)],
        jsonPath: String
    ) -> String {
        let moves = buddy.equippedMoves
            .sorted { $0.slot < $1.slot }
            .map { "- Slot \($0.slot): \($0.name) (\($0.category), mastery \($0.mastery))" }
            .joined(separator: "\n")
        let training = trainedCategories.isEmpty
            ? "- No scored training categories yet. Record training before marketplace submission."
            : trainedCategories.map { "- \($0.key): \($0.value)" }.joined(separator: "\n")

        return """
        # \(buddy.displayName) Template Seller Guide

        - Status: sell-ready draft
        - Source template: \(templateName)
        - Package artifact: \(jsonPath)
        - Marketplace note: paid selling is not live in this build. This package is ready for review once billing, moderation, and listing submission are enabled.

        ## What Users Are Creating
        A Buddy template is a reusable blueprint: identity, role, moves, starter guidance, public training summary, and recommended use cases. It is not a clone of your private Buddy.

        ## How To Create A Template
        1. Install or personalize a Buddy.
        2. Give the Buddy a clear role and focus.
        3. Use the Buddy on real tasks so receipts and artifacts prove what it can do.
        4. Package the active Buddy from the Buddy tab.

        ## How To Train A Template
        Training comes from check-ins, training entries, and receipt-backed work. Keep the notes specific: what improved, what category was trained, and which skill or artifact proved the improvement.

        ## How To Sell A Template
        Selling requires a sanitized package, a clear listing, pricing, moderation approval, and billing support. This build creates the sanitized package and seller guide; it does not publish paid listings yet.

        ## Public Capabilities
        - Class: \(buddy.identity.class)
        - Role: \(buddy.identity.role)
        - Level: \(buddy.progression.level)
        - Bond: \(buddy.progression.bond)
        - Evolution tier: \(buddy.progression.evolutionTier)

        ## Moves
        \(moves)

        ## Training Summary
        \(training)

        ## Privacy Boundary
        Private memory, chat transcripts, raw check-ins, and raw training notes are stripped. Buyers receive the template blueprint and public capability summary, not your personal history.
        """
    }
}

private extension BuddyProficiencies {
    var templateDictionary: [String: Int] {
        [
            "planning": planning,
            "building": building,
            "research": research,
            "writing": writing,
            "memory": memory,
            "organization": organization,
            "safety": safety,
            "verification": verification,
            "optimization": optimization,
            "creativity": creativity,
            "coordination": coordination,
            "emotionalSupport": emotionalSupport
        ]
    }
}

private struct LegacyBuddyStats: Codable {
    var bond: Int
    var power: Int
    var focus: Int
    var curiosity: Int
    var care: Int
}

private struct LegacyGeneratedBuddy: Codable {
    var id: UUID
    var seed: Int
    var profileSignature: String
    var name: String
    var archetype: String
    var title: String
    var originSummary: String
    var specialty: String
    var personalitySummary: String
    var asciiArt: String
    var stats: LegacyBuddyStats
    var createdAt: Date
}

private struct LegacyBuddyBattleRecord: Codable {
    var id: UUID
    var title: String
    var summary: String
    var isVictory: Bool
    var createdAt: Date
}

private struct LegacyBuddySystemState: Codable {
    var profileSignature: String
    var activeBuddy: LegacyGeneratedBuddy
    var collection: [LegacyGeneratedBuddy]
    var tradeOffers: [LegacyGeneratedBuddy]
    var battleHistory: [LegacyBuddyBattleRecord]
}

private extension BuddyLibraryState {
    mutating func upsertImported(_ instance: BuddyInstance) {
        if let existingIndex = instances.firstIndex(where: { $0.instanceId == instance.instanceId }) {
            instances[existingIndex] = instance
        } else {
            instances.append(instance)
        }
        instances.sort { $0.provenance.installedAt > $1.provenance.installedAt }
    }
}
