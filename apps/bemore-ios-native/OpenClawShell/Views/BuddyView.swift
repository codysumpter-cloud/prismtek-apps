import Foundation
import SwiftUI
import UIKit

private struct BuddyPersonalizationDraft {
    var displayName: String = ""
    var nickname: String = ""
    var currentFocus: String = ""
    var palette: String = "mint_cream"
    var asciiVariantID: String = "starter_a"
}

private struct BuddyTeachingDraft {
    var preferenceTitle = "Daily planning style"
    var preferenceDetail = "Help me pick one calm, useful next step before I over-plan."
    var topPriority = "Plan today around one real priority"
    var supportStyle = "Calm, specific, and low-pressure"
}

struct BuddyView: View {
    @EnvironmentObject private var appState: AppState
    @ObservedObject var store: BuddyProfileStore
    @State private var checkInNote = ""
    @State private var trainingNote = ""
    @State private var personalizationDraft = BuddyPersonalizationDraft()
    @State private var teachingDraft = BuddyTeachingDraft()
    @State private var reminderDueAt = Calendar.current.date(byAdding: .hour, value: 2, to: Date()) ?? Date()
    @State private var appleActionStatus: String?
    @State private var isCreatingReminder = false
    @State private var isShowingMessageComposer = false
    @State private var messageDraft = ""
    @State private var isShowingPersonalizationSheet = false
    @State private var battleArenaName = "Pocket Garden Ring"
    @State private var selectedBattleModifier: BuddyBattleArenaModifier = .balanced
    @State private var tradeImportDraft = ""
    @State private var tradeLocalStatus: String?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
                    if let activeBuddy = store.activeBuddy {
                        myBuddyHeader(for: activeBuddy)
                        activeBuddyCard(for: activeBuddy)
                        teachBuddyPlanningCard(for: activeBuddy)
                        memoryAndSkillsCard(for: activeBuddy)
                        actionCard(for: activeBuddy)
                        battleCard(for: activeBuddy)
                        tradeOutpostCard(for: activeBuddy)
                        recentEventsCard(for: activeBuddy)
                    } else {
                        emptyStateCard
                    }

                    rosterCard
                    marketplaceCard

                    buddyTemplateLifecycleCard
                    sellReadyTemplateCard
                    trainingAndManagementCard

                    if let receipt = store.lastReceipt {
                        receiptCard(receipt)
                    }

                    if let loadError = store.loadError {
                        errorCard(loadError)
                    }
                }
                .padding(.horizontal, BMOTheme.spacingMD)
                .padding(.bottom, BMOTheme.spacingXL)
            }
            .background(BMOTheme.backgroundPrimary)
            .navigationTitle("Buddy")
            .toolbarBackground(BMOTheme.backgroundPrimary, for: .navigationBar)
        }
        .task {
            store.load(for: appState.stackConfig)
        }
        .sheet(isPresented: $isShowingPersonalizationSheet) {
            personalizationSheet
        }
        .sheet(isPresented: $isShowingMessageComposer) {
            BuddyMessageComposer(body: messageDraft)
        }
    }

    private func myBuddyHeader(for buddy: BuddyInstance) -> some View {
        let template = store.contracts?.templateForInstance(buddy)
        let care = careSnapshot(for: buddy, template: template)
        return VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Buddy")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(BMOTheme.textTertiary)
                    Text(buddy.displayName)
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(BMOTheme.textPrimary)
                    Text(template?.onboardingCopy ?? "\(buddy.displayName) helps with your day, your plans, your routines, and the identity you build together over time.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(
                    label: "Phone-first",
                    color: BMOTheme.success
                )
            }

            BuddyAsciiView(buddy: buddy, template: template, mood: buddyMood(for: buddy), compact: true)

            HStack(spacing: BMOTheme.spacingSM) {
                metricPill(title: "Owned", value: "\(store.installedBuddies.count)")
                metricPill(title: "Battles", value: "\(battleRecords(for: buddy).count)")
                metricPill(title: "Trades", value: "\(tradeRecords(for: buddy).count)")
                metricPill(title: "Level", value: "\(buddy.progression.level)")
                metricPill(title: "Trust", value: "\(care.trust)")
            }
        }
        .bmoCard()
    }

    private func teachBuddyPlanningCard(for buddy: BuddyInstance) -> some View {
        let latestPlan = buddy.dailyPlans?.sorted { $0.createdAt > $1.createdAt }.first

        return VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Teach Buddy")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Teach \(buddy.displayName) how you like to plan, then use that lesson for a reminder, journal note, or follow-up draft.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "Planning loop", color: BMOTheme.success)
            }

            VStack(alignment: .leading, spacing: 10) {
                TextField("What should Buddy learn?", text: $teachingDraft.preferenceTitle)
                    .textFieldStyle(.plain)
                    .foregroundColor(BMOTheme.textPrimary)
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))

                TextField("Preference detail", text: $teachingDraft.preferenceDetail, axis: .vertical)
                    .textFieldStyle(.plain)
                    .foregroundColor(BMOTheme.textPrimary)
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))

                TextField("Today's priority", text: $teachingDraft.topPriority, axis: .vertical)
                    .textFieldStyle(.plain)
                    .foregroundColor(BMOTheme.textPrimary)
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))

                TextField("Support style", text: $teachingDraft.supportStyle)
                    .textFieldStyle(.plain)
                    .foregroundColor(BMOTheme.textPrimary)
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
            }

            HStack {
                Button("Teach and Train") {
                    store.teachPlanningLoop(
                        preferenceTitle: teachingDraft.preferenceTitle,
                        preferenceDetail: teachingDraft.preferenceDetail,
                        topPriority: teachingDraft.topPriority,
                        supportStyle: teachingDraft.supportStyle,
                        using: appState
                    )
                    appleActionStatus = "\(buddy.displayName) learned this planning preference. Review or edit it below."
                }
                .buttonStyle(BMOButtonStyle())

                Button("Capture Journal") {
                    captureJournalArtifact(for: buddy)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }

            Divider().overlay(BMOTheme.divider)

            VStack(alignment: .leading, spacing: 10) {
                Text("Apple handoff")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)
                Text("Reminders are created after permission. Messages stay as drafts until you choose to send them.")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)

                DatePicker("Reminder time", selection: $reminderDueAt, displayedComponents: [.date, .hourAndMinute])
                    .foregroundColor(BMOTheme.textSecondary)

                HStack {
                    Button(isCreatingReminder ? "Creating..." : "Create Reminder") {
                        createReminder(from: latestPlan, fallbackBuddy: buddy)
                    }
                    .disabled(isCreatingReminder)
                    .buttonStyle(BMOButtonStyle(isPrimary: false))

                    Button("Draft Message") {
                        prepareMessageDraft(from: latestPlan, fallbackBuddy: buddy)
                    }
                    .buttonStyle(BMOButtonStyle(isPrimary: false))
                }
            }

            if let latestPlan {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Latest plan")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(BMOTheme.textTertiary)
                    Text(latestPlan.topPriority)
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text(latestPlan.journalPrompt)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                .padding(BMOTheme.spacingMD)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
            }

            if let appleActionStatus {
                Text(appleActionStatus)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
        }
        .bmoCard()
    }

    private func memoryAndSkillsCard(for buddy: BuddyInstance) -> some View {
        let preferences = (buddy.learnedPreferences ?? []).sorted { $0.updatedAt > $1.updatedAt }
        let skills = (buddy.learnedSkills ?? []).sorted { lhs, rhs in
            if lhs.isEquipped != rhs.isEquipped { return lhs.isEquipped && !rhs.isEquipped }
            if lhs.mastery != rhs.mastery { return lhs.mastery > rhs.mastery }
            return lhs.name < rhs.name
        }

        return VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("Memory and Skills")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)

            if preferences.isEmpty {
                Text("No taught preferences yet. Teach Buddy one thing you want remembered.")
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
            } else {
                ForEach(preferences.prefix(4)) { preference in
                    VStack(alignment: .leading, spacing: 4) {
                        Text(preference.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(BMOTheme.textPrimary)
                        Text(preference.detail)
                            .font(.caption)
                            .foregroundColor(BMOTheme.textSecondary)
                        Text("Learned from \(preference.source), reinforced \(preference.reinforcementCount)x")
                            .font(.caption2)
                            .foregroundColor(BMOTheme.textTertiary)
                    }
                    .padding(BMOTheme.spacingMD)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                }
            }

            Divider().overlay(BMOTheme.divider)

            if skills.isEmpty {
                Text("No learned skills are visible yet.")
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
            } else {
                ForEach(skills) { skill in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(skill.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(BMOTheme.textPrimary)
                            Text(skill.summary)
                                .font(.caption)
                                .foregroundColor(BMOTheme.textSecondary)
                            Text("Mastery \(skill.mastery)/5")
                                .font(.caption2)
                                .foregroundColor(BMOTheme.textTertiary)
                        }
                        Spacer()
                        StatusBadge(label: skill.isEquipped ? "Equipped" : "Unlocked", color: skill.isEquipped ? BMOTheme.success : BMOTheme.accent)
                    }
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                }
            }
        }
        .bmoCard()
    }

    private func activeBuddyCard(for buddy: BuddyInstance) -> some View {
        let template = store.contracts?.templateForInstance(buddy)
        let bondLabel = store.contracts.map { BuddyMarkdownRenderer.bondLabel(for: buddy.progression.bond, contracts: $0) } ?? "Bond"
        let care = careSnapshot(for: buddy, template: template)

        return VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack(alignment: .top, spacing: BMOTheme.spacingMD) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Active Buddy")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(BMOTheme.textTertiary)
                    Text(buddy.displayName)
                        .font(.title2.bold())
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("\(buddy.identity.class) • \(buddy.identity.role)")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 8) {
                    StatusBadge(label: bondLabel, color: BMOTheme.accent)
                    StatusBadge(label: buddy.state.mood.capitalized, color: moodColor(buddy.state.mood))
                }
            }

            BuddyAsciiView(buddy: buddy, template: template, mood: buddyMood(for: buddy))

            Text("Buddy is already useful right here on iPhone: care, training, sparring, roster building, and trade package sharing all work without Mac or repo access.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BMOTheme.spacingSM) {
                metricPill(title: "Vitality", value: "\(care.vitality)")
                metricPill(title: "Focus", value: "\(care.focus)")
                metricPill(title: "Trust", value: "\(care.trust)")
                metricPill(title: "Confidence", value: "\(care.confidence)")
                metricPill(title: "Curiosity", value: "\(care.curiosity)")
                metricPill(title: "Tier", value: "\(buddy.progression.evolutionTier)")
            }

            VStack(alignment: .leading, spacing: 6) {
                profileRow(label: "Template", value: template?.name ?? "Legacy Buddy")
                profileRow(label: "Focus", value: buddy.state.currentFocus ?? "No active focus")
                profileRow(label: "Palette", value: paletteLabel(for: buddy.identity.palette))
                profileRow(label: "ASCII style", value: asciiVariantLabel(for: buddy.visual?.asciiVariantId))
                profileRow(label: "Rarity", value: rarityLabel(for: buddy))
                profileRow(label: "Last active", value: BuddyMarkdownRenderer.iso8601(buddy.state.lastActiveAt))
                profileRow(label: "Top move", value: buddy.equippedMoves.sorted(by: { $0.slot < $1.slot }).first?.name ?? "None")
            }

            Button("Personalize Buddy") {
                personalizationDraft = BuddyPersonalizationDraft(
                    displayName: buddy.displayName,
                    nickname: buddy.nickname ?? "",
                    currentFocus: buddy.state.currentFocus ?? "",
                    palette: buddy.identity.palette,
                    asciiVariantID: buddy.visual?.asciiVariantId ?? defaultASCIIVariantID
                )
                isShowingPersonalizationSheet = true
            }
            .buttonStyle(BMOButtonStyle(isPrimary: false))
        }
        .bmoCard()
    }

    private func actionCard(for buddy: BuddyInstance) -> some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("Care and Training")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)

            Text("Buddy should invite return, not anxiety. Missing a day does not punish the bond. Come back, care, and keep growing.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(BuddyCareAction.allCases) { action in
                    Button(action.title) {
                        store.performCare(action, using: appState)
                    }
                    .buttonStyle(BMOButtonStyle(isPrimary: action == .encourage))
                }
            }

            VStack(alignment: .leading, spacing: 10) {
                Text("Check-in")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)
                TextField("What changed or what matters now?", text: $checkInNote, axis: .vertical)
                    .textFieldStyle(.plain)
                    .foregroundColor(BMOTheme.textPrimary)
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))

                Button("Record Check-in") {
                    store.recordCheckIn(note: checkInNote, using: appState)
                    checkInNote = ""
                }
                .buttonStyle(BMOButtonStyle())
            }

            Divider().overlay(BMOTheme.divider)

            VStack(alignment: .leading, spacing: 10) {
                Text("Training")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)

                Picker("Training category", selection: $store.selectedTrainingCategory) {
                    ForEach(store.contracts?.progression.trainingCategories ?? [], id: \.self) { category in
                        Text(category).tag(category)
                    }
                }
                .pickerStyle(.menu)
                .tint(BMOTheme.accent)

                TextField("What did you train or improve?", text: $trainingNote, axis: .vertical)
                    .textFieldStyle(.plain)
                    .foregroundColor(BMOTheme.textPrimary)
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))

                Button("Record Training for \(buddy.displayName)") {
                    store.recordTraining(note: trainingNote, using: appState)
                    trainingNote = ""
                }
                .buttonStyle(BMOButtonStyle())
            }
        }
        .bmoCard()
    }

    private func battleCard(for buddy: BuddyInstance) -> some View {
        let records = battleRecords(for: buddy)
        return VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Sparring Ring")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Use local sparring to express training, moves, and Buddy identity in a real repeatable loop.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: records.first?.result.capitalized ?? "Ready", color: records.first?.result == "victory" ? BMOTheme.success : BMOTheme.accent)
            }

            TextField("Arena name", text: $battleArenaName)
                .textFieldStyle(.plain)
                .foregroundColor(BMOTheme.textPrimary)
                .padding(BMOTheme.spacingMD)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))

            Picker("Battle intensity", selection: $selectedBattleModifier) {
                ForEach(BuddyBattleArenaModifier.allCases) { modifier in
                    Text(modifier.title).tag(modifier)
                }
            }
            .pickerStyle(.segmented)

            Text(selectedBattleModifier.summary)
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)

            Button("Start Spar") {
                store.startSparring(arenaName: battleArenaName, modifier: selectedBattleModifier, using: appState)
            }
            .buttonStyle(BMOButtonStyle())

            if records.isEmpty {
                Text("No sparring record yet. Your Buddy's training, bond, energy, and move loadout will all affect the result.")
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
            } else {
                ForEach(records.prefix(3)) { record in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(record.opponentName)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(BMOTheme.textPrimary)
                            Spacer()
                            StatusBadge(label: record.result.capitalized, color: record.result == "victory" ? BMOTheme.success : BMOTheme.warning)
                        }
                        Text(record.summary)
                            .font(.subheadline)
                            .foregroundColor(BMOTheme.textSecondary)
                        Text("Score: \(record.scoreline)")
                            .font(.caption)
                            .foregroundColor(BMOTheme.textTertiary)
                        Text("Next training: \(record.recommendedTraining.joined(separator: ", "))")
                            .font(.caption)
                            .foregroundColor(BMOTheme.textTertiary)
                    }
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
                }
            }
        }
        .bmoCard()
    }

    private func tradeOutpostCard(for buddy: BuddyInstance) -> some View {
        return VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Trade Outpost")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Export a sanitized Buddy package, copy the token, or import one from someone else. This is the real trade-ready wedge for iPhone.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: rarityLabel(for: buddy), color: BMOTheme.accent)
            }

            HStack {
                Button("Export Trade Package") {
                    store.exportActiveTradePackage(using: appState)
                    tradeLocalStatus = "Exported \(buddy.displayName)."
                }
                .buttonStyle(BMOButtonStyle())

                if let code = store.lastTradeExportCode, code.isEmpty == false {
                    Button("Copy Token") {
                        UIPasteboard.general.string = code
                        tradeLocalStatus = "Trade token copied. Share it directly or keep it as a backup."
                    }
                    .buttonStyle(BMOButtonStyle(isPrimary: false))
                }
            }

            if let code = store.lastTradeExportCode, code.isEmpty == false {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Latest export token")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(BMOTheme.textTertiary)
                    Text(code)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundColor(BMOTheme.textPrimary)
                        .padding(BMOTheme.spacingMD)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(BMOTheme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                }
            }

            Divider().overlay(BMOTheme.divider)

            TextField("Paste Buddy trade token or JSON package", text: $tradeImportDraft, axis: .vertical)
                .textFieldStyle(.plain)
                .foregroundColor(BMOTheme.textPrimary)
                .padding(BMOTheme.spacingMD)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))

            Button("Import Trade Package") {
                store.importTradePackage(tradeImportDraft, using: appState)
                tradeImportDraft = ""
            }
            .buttonStyle(BMOButtonStyle(isPrimary: false))

            if let tradeStatus = tradeLocalStatus ?? store.tradeStatusMessage {
                Text(tradeStatus)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }

            if tradeHistoryRows.isEmpty == false {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Recent trade history")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(BMOTheme.textTertiary)
                    ForEach(tradeHistoryRows.prefix(3)) { trade in
                        Text("\(trade.type.capitalized): \(trade.summary)")
                            .font(.caption)
                            .foregroundColor(BMOTheme.textSecondary)
                    }
                }
            }
        }
        .bmoCard()
    }

    private func recentEventsCard(for buddy: BuddyInstance) -> some View {
        let events = store.recentEvents(for: buddy)
        return VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("Recent Buddy Events")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)

            if events.isEmpty {
                Text("No activity yet. Install, personalize, check in, or train Buddy to start building useful history.")
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
            } else {
                ForEach(events) { event in
                    VStack(alignment: .leading, spacing: 6) {
                        HStack {
                            Text(event.type)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(BMOTheme.accent)
                            Spacer()
                            Text(BuddyMarkdownRenderer.iso8601(event.occurredAt))
                                .font(.caption)
                                .foregroundColor(BMOTheme.textTertiary)
                        }
                        Text(event.summary)
                            .font(.subheadline)
                            .foregroundColor(BMOTheme.textPrimary)
                    }
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
                }
            }
        }
        .bmoCard()
    }

    private var marketplaceCard: some View {
        let installedTemplateIDs = Set(store.installedBuddies.map(\.templateId))

        return VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Discover Buddies")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Grow a collectible roster of starter Buddies with distinct roles, moves, palettes, and future battle paths.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "Collection", color: BMOTheme.accent)
            }

            ForEach(store.templates) { template in
                VStack(alignment: .leading, spacing: 10) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.headline)
                                .foregroundColor(BMOTheme.textPrimary)
                            Text(template.starterRole)
                                .font(.subheadline)
                                .foregroundColor(BMOTheme.textSecondary)
                        }
                        Spacer()
                        if installedTemplateIDs.contains(template.templateID) {
                            StatusBadge(label: store.activeBuddy?.templateId == template.templateID ? "Active" : "Owned", color: BMOTheme.success)
                        } else {
                            Button("Install") {
                                store.install(template: template, using: appState)
                            }
                            .buttonStyle(BMOButtonStyle(isPrimary: false))
                        }
                    }

                    Text(template.onboardingCopy)
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)

                    HStack(spacing: BMOTheme.spacingSM) {
                        metricPill(title: "Power", value: "\(template.total)")
                        metricPill(title: "Signature", value: template.moveSet.first?.name ?? "None")
                    }

                    Text(template.ascii.baseSilhouette)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundColor(BMOTheme.accent)

                    Text("Moves: \(template.moveSet.map(\.name).joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                }
                .padding(BMOTheme.spacingMD)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
            }
        }
        .bmoCard()
    }

    private var rosterCard: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("My Buddy Roster")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Keep a small roster of Buddies with different strengths. Equip the one you want helping right now.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "\(store.installedBuddies.count) owned", color: BMOTheme.accent)
            }

            if store.installedBuddies.isEmpty {
                Text("Install your first Buddy from Discover to start a roster.")
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
            } else {
                ForEach(store.installedBuddies) { buddy in
                    let isActive = store.activeBuddy?.instanceId == buddy.instanceId
                    let template = store.contracts?.templateForInstance(buddy)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack(alignment: .top) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(buddy.displayName)
                                    .font(.headline)
                                    .foregroundColor(BMOTheme.textPrimary)
                                Text(template?.name ?? buddy.identity.role)
                                    .font(.subheadline)
                                    .foregroundColor(BMOTheme.textSecondary)
                            }
                            Spacer()
                            if isActive {
                                StatusBadge(label: "Active", color: BMOTheme.accent)
                            } else {
                                Button("Equip") {
                                    store.makeActive(buddy, using: appState)
                                }
                                .buttonStyle(BMOButtonStyle(isPrimary: false))
                            }
                        }

                        Text("Focus: \(buddy.state.currentFocus ?? "No active focus")")
                            .font(.subheadline)
                            .foregroundColor(BMOTheme.textSecondary)

                        HStack(spacing: BMOTheme.spacingSM) {
                            metricPill(title: "Level", value: "\(buddy.progression.level)")
                            metricPill(title: "Bond", value: "\(buddy.progression.bond)")
                            metricPill(title: "Mood", value: buddy.state.mood.capitalized)
                        }
                    }
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
                }
            }
        }
        .bmoCard()
    }

    private var trainingAndManagementCard: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("What Buddy Can Do Here")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("Buddy can already help you care, train, customize, collect, spar, and trade on iPhone. Repo/runtime power stays optional and secondary.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
            HStack {
                Button("Open Chat") {
                    appState.openChat(from: .buddy)
                }
                .buttonStyle(BMOButtonStyle())
                Button("Go Home") {
                    appState.route(to: .missionControl)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
        .bmoCard()
    }

    private var buddyTemplateLifecycleCard: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Care, Train, Spar, Trade")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("The strongest phone-first loop is simple: care for Buddy, train useful strengths, spar to express that growth, and share a safe package when you want to trade.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "Standalone loop", color: BMOTheme.accent)
            }

            lifecycleStep(
                number: "1",
                title: "Care",
                body: "Check in, encourage, play, rest, and explore. The loop is return-friendly and never punishes you for missing a day."
            )
            lifecycleStep(
                number: "2",
                title: "Train",
                body: "Use check-ins, taught preferences, and training sessions to strengthen identity, focus, and skill proficiencies."
            )
            lifecycleStep(
                number: "3",
                title: "Spar",
                body: "Run lightweight local battles where growth, energy, bond, and trained proficiencies change the outcome."
            )
            lifecycleStep(
                number: "4",
                title: "Trade",
                body: "Export or import a sanitized Buddy package today. Live marketplace selling stays optional future work."
            )
        }
        .bmoCard()
    }

    private var sellReadyTemplateCard: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Template Workshop")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Template packaging is still here for creator workflows, but trading and sharing now come first on iPhone.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: store.activeBuddy == nil ? "Needs Buddy" : "Ready", color: store.activeBuddy == nil ? BMOTheme.warning : BMOTheme.success)
            }

            VStack(alignment: .leading, spacing: 8) {
                templateBoundaryRow(title: "Included", body: "Identity, role, moves, public progression, public training category scores, recommended uses, and seller guide.")
                templateBoundaryRow(title: "Stripped", body: "Private memories, chat transcripts, raw check-ins, raw training notes, and personal workspace context.")
                templateBoundaryRow(title: "Not live yet", body: "Payment processing, public marketplace publishing, moderation queue, refunds, and buyer install analytics.")
            }

            HStack {
                Button("Package Active Buddy") {
                    store.packageActiveBuddyTemplate(using: appState)
                }
                .disabled(store.activeBuddy == nil)
                .buttonStyle(BMOButtonStyle())

                Button("Open Artifacts") {
                    appState.route(to: .artifacts)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
        .bmoCard()
    }

    private var emptyStateCard: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("No Buddy Installed Yet")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("Install a starter Buddy to begin with a companion you can name, teach, train, and rely on for everyday follow-through.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .bmoCard()
    }

    private func receiptCard(_ receipt: OpenClawReceipt) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Latest Buddy Receipt")
                    .font(.headline)
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                StatusBadge(label: receipt.status.label, color: receipt.status.color)
            }

            Text(receipt.summary)
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)

            if receipt.artifacts.isEmpty == false {
                Text("Artifacts: \(receipt.artifacts.joined(separator: ", "))")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textTertiary)
            }
        }
        .bmoCard()
    }

    private func errorCard(_ message: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Buddy Load Error")
                .font(.headline)
                .foregroundColor(BMOTheme.error)
            Text(message)
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .bmoCard()
    }

    private var personalizationSheet: some View {
        NavigationStack {
            Form {
                Section("Identity") {
                    TextField("Display name", text: $personalizationDraft.displayName)
                    TextField("Nickname", text: $personalizationDraft.nickname)
                }

                Section("Current Focus") {
                    TextField("Focus", text: $personalizationDraft.currentFocus, axis: .vertical)
                }

                Section("Appearance") {
                    Picker("Palette", selection: $personalizationDraft.palette) {
                        ForEach(availablePalettes, id: \.id) { palette in
                            Text(palette.label).tag(palette.id)
                        }
                    }

                    Picker("ASCII style", selection: $personalizationDraft.asciiVariantID) {
                        ForEach(asciiVariantOptions, id: \.id) { option in
                            Text(option.label).tag(option.id)
                        }
                    }
                }
            }
            .navigationTitle("Personalize Buddy")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isShowingPersonalizationSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        store.personalizeActive(
                            displayName: personalizationDraft.displayName,
                            nickname: personalizationDraft.nickname,
                            currentFocus: personalizationDraft.currentFocus,
                            palette: personalizationDraft.palette,
                            asciiVariantID: personalizationDraft.asciiVariantID,
                            using: appState
                        )
                        isShowingPersonalizationSheet = false
                    }
                }
            }
        }
    }

    private func asciiArt(for buddy: BuddyInstance, template: CouncilStarterBuddyTemplate?) -> String {
        guard let template else {
            return buddy.visual?.currentAnimationState ?? buddy.displayName
        }
        let state = buddy.visual?.currentAnimationState ?? buddy.state.mood
        return template.ascii.expressions[state] ?? template.ascii.baseSilhouette
    }

    private func metricPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
            Text(value)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(BMOTheme.textPrimary)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
    }

    private func profileRow(label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(BMOTheme.textTertiary)
                .frame(width: 84, alignment: .leading)
            Text(value)
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
            Spacer(minLength: 0)
        }
    }

    private func lifecycleStep(number: String, title: String, body: String) -> some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.caption.weight(.bold))
                .foregroundColor(BMOTheme.backgroundPrimary)
                .frame(width: 24, height: 24)
                .background(BMOTheme.accent)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)
                Text(body)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
        }
    }

    private func templateBoundaryRow(title: String, body: String) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption.weight(.semibold))
                .foregroundColor(BMOTheme.accent)
            Text(body)
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
    }

    private func moodColor(_ mood: String) -> Color {
        switch mood.lowercased() {
        case "happy", "excited":
            return BMOTheme.success
        case "working", "thinking":
            return BMOTheme.accent
        case "stressed":
            return BMOTheme.warning
        default:
            return BMOTheme.textSecondary
        }
    }

    private var availablePalettes: [BuddyPaletteOption] {
        store.contracts?.creationOptions.options.palettes ?? []
    }

    private var asciiVariantOptions: [BuddyChoiceOption] {
        [
            BuddyChoiceOption(id: "starter_a", label: "Classic", description: "Default Buddy shell look."),
            BuddyChoiceOption(id: "starter_b", label: "Soft", description: "Rounded expression and antenna accent."),
            BuddyChoiceOption(id: "starter_c", label: "Bold", description: "Sharper framing for a stronger look.")
        ]
    }

    private var defaultASCIIVariantID: String {
        store.contracts?.creationOptions.defaults.asciiVariant ?? "starter_a"
    }

    private func paletteLabel(for paletteID: String) -> String {
        availablePalettes.first(where: { $0.id == paletteID })?.label ?? paletteID
    }

    private func asciiVariantLabel(for asciiVariantID: String?) -> String {
        let variantID = asciiVariantID ?? defaultASCIIVariantID
        return asciiVariantOptions.first(where: { $0.id == variantID })?.label ?? variantID
    }

    private func buddyMood(for buddy: BuddyInstance) -> BuddyAnimationMood {
        switch buddy.state.mood.lowercased() {
        case "happy", "excited":
            return .happy
        case "working":
            return .working
        case "thinking":
            return .thinking
        case "sleepy", "tired":
            return .sleepy
        case "needsattention", "needs attention", "stressed":
            return .needsAttention
        default:
            return .idle
        }
    }

    private var tradeHistoryRows: [BuddyTradeRecord] {
        store.tradeHistory.sorted { $0.createdAt > $1.createdAt }
    }

    private func battleRecords(for buddy: BuddyInstance) -> [BuddyBattleRecord] {
        store.battleHistory
            .filter { $0.buddyInstanceId == buddy.instanceId }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private func tradeRecords(for buddy: BuddyInstance) -> [BuddyTradeRecord] {
        store.tradeHistory
            .filter { $0.buddyDisplayName == buddy.displayName }
            .sorted { $0.createdAt > $1.createdAt }
    }

    private func careSnapshot(for buddy: BuddyInstance, template: CouncilStarterBuddyTemplate?) -> BuddyCareSnapshot {
        BuddyCareCalculator.snapshot(
            for: buddy,
            template: template,
            battles: battleRecords(for: buddy)
        )
    }

    private func rarityLabel(for buddy: BuddyInstance) -> String {
        switch (buddy.progression.evolutionTier, buddy.progression.level) {
        case (3, _):
            return "Ascendant"
        case (2, 7...):
            return "Elite"
        case (_, 5...):
            return "Seasoned"
        default:
            return "Starter"
        }
    }

    private func createReminder(from plan: BuddyDailyPlan?, fallbackBuddy buddy: BuddyInstance) {
        let title = plan?.reminderTitle ?? "Check in with \(buddy.displayName): \(teachingDraft.topPriority)"
        let notes = plan?.journalPrompt ?? "\(buddy.displayName) learned: \(teachingDraft.preferenceDetail)"
        isCreatingReminder = true
        appleActionStatus = nil
        Task {
            do {
                _ = try await BuddyAppleIntegrationService().createReminder(title: title, notes: notes, dueDate: reminderDueAt)
                await MainActor.run {
                    appleActionStatus = "Reminder created. Buddy can help you follow through from the saved plan."
                    isCreatingReminder = false
                }
            } catch {
                await MainActor.run {
                    appleActionStatus = error.localizedDescription
                    isCreatingReminder = false
                }
            }
        }
    }

    private func captureJournalArtifact(for buddy: BuddyInstance) {
        let latestPlan = buddy.dailyPlans?.sorted { $0.createdAt > $1.createdAt }.first
        let slug = BuddyMarkdownRenderer.iso8601(Date()).prefix(10)
        let content = """
        # Buddy Daily Note

        - Buddy: \(buddy.displayName)
        - Created: \(BuddyMarkdownRenderer.iso8601(Date()))
        - Priority: \(latestPlan?.topPriority ?? teachingDraft.topPriority)
        - Support style: \(latestPlan?.supportStyle ?? teachingDraft.supportStyle)

        ## What Buddy learned
        \(latestPlan?.journalPrompt ?? teachingDraft.preferenceDetail)

        ## Next check-in
        \(latestPlan?.reminderTitle ?? "Check in with \(buddy.displayName)")
        """
        let receipt = appState.writeWorkspaceArtifact(path: "journal/buddy-daily-\(slug).md", content: content)
        appleActionStatus = receipt.status == .persisted ? "Journal note captured in workspace artifacts." : receipt.summary
    }

    private func prepareMessageDraft(from plan: BuddyDailyPlan?, fallbackBuddy buddy: BuddyInstance) {
        messageDraft = plan?.messageDraft ?? "Quick check-in: I am focusing on \(teachingDraft.topPriority). Can you help keep me honest today?"
        if BuddyMessageComposer.canSendText {
            isShowingMessageComposer = true
        } else {
            UIPasteboard.general.string = messageDraft
            appleActionStatus = "This device cannot present Messages compose. Draft copied instead."
        }
    }
}
