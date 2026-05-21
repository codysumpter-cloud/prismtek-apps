import SwiftUI

struct BuddyMonView: View {
    @StateObject private var store = BuddyMonStore()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
                    heroCard
                    careGrid
                    battleCard
                    collectionCard
                    evolutionLogCard

                    if let receipt = store.state.lastReceipt {
                        receiptCard(receipt)
                    }

                    if let saveError = store.saveError {
                        errorCard(saveError)
                    }
                }
                .padding(.horizontal, BMOTheme.spacingMD)
                .padding(.bottom, BMOTheme.spacingXL)
            }
            .background(BMOTheme.backgroundPrimary)
            .navigationTitle("BuddyMon")
            .toolbarBackground(BMOTheme.backgroundPrimary, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        store.reset()
                    }
                    .foregroundColor(BMOTheme.warning)
                }
            }
        }
        .onAppear { store.refresh() }
    }

    private var heroCard: some View {
        let pet = store.activePet
        let form = store.activeForm
        return VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Pocket Companions")
                        .font(.caption.weight(.semibold))
                        .textCase(.uppercase)
                        .foregroundColor(BMOTheme.accent)
                    Text(form.name)
                        .font(.largeTitle.weight(.black))
                        .foregroundColor(BMOTheme.textPrimary)
                    Text(form.tagline)
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: pet.mood.label, color: moodColor(pet.mood))
            }

            VStack(spacing: 4) {
                ForEach(form.asciiArt, id: \.self) { line in
                    Text(line)
                        .font(.system(.title3, design: .monospaced).weight(.bold))
                        .foregroundColor(BMOTheme.accent)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(BMOTheme.spacingLG)
            .background(BMOTheme.accentGlow)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusLarge, style: .continuous))

            Text(store.attentionSummary)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(BMOTheme.textPrimary)
                .padding(BMOTheme.spacingMD)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BMOTheme.spacingSM) {
                statBar("Hunger", value: pet.stats.hunger)
                statBar("Happy", value: pet.stats.happiness)
                statBar("Clean", value: pet.stats.hygiene)
                statBar("Energy", value: pet.stats.energy)
                statBar("Strength", value: pet.stats.strength)
                statBar("Bond", value: pet.stats.bond)
                statBar("Discipline", value: pet.stats.discipline)
                statBar("Stress", value: pet.stats.stress, isWarning: true)
            }

            HStack(spacing: BMOTheme.spacingSM) {
                metricPill("Stage", form.stage.displayName)
                metricPill("Wins", "\(pet.stats.battlesWon)")
                metricPill("Care misses", "\(pet.stats.careMistakes)")
            }
        }
        .bmoCard()
    }

    private var careGrid: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("Care Loop")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("Feed, clean, play, rest, train, and recover. Offline time changes the pet when the app reopens.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: BMOTheme.spacingSM) {
                ForEach(BuddyMonCareAction.allCases) { action in
                    Button {
                        store.perform(action)
                    } label: {
                        Label(action.title, systemImage: action.systemImage)
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(BMOButtonStyle(isPrimary: action == .feed || action == .play || action == .train))
                }
            }
        }
        .bmoCard()
    }

    private var battleCard: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pocket Spar")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Safe NPC battle prototype. No PvP, no betting, no live-service economy.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                Button("Battle") {
                    store.runBattle()
                }
                .buttonStyle(BMOButtonStyle())
                .disabled(store.activeForm.moves.isEmpty)
            }

            if store.activeForm.moves.isEmpty {
                Text("Hatch first to unlock starter moves.")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textTertiary)
            } else {
                ForEach(store.activeForm.moves) { move in
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(move.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(BMOTheme.textPrimary)
                            Text("\(move.type.capitalized) • Power \(move.power) • Accuracy \(move.accuracy)%")
                                .font(.caption)
                                .foregroundColor(BMOTheme.textSecondary)
                        }
                        Spacer()
                        Text("-\(move.energyCost) EN")
                            .font(.caption.weight(.bold))
                            .foregroundColor(BMOTheme.warning)
                    }
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                }
            }

            if let latest = store.state.battleLog.first {
                Divider().overlay(BMOTheme.divider)
                Text(latest.summary)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
        }
        .bmoCard()
    }

    private var collectionCard: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("Collection")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("This v1 keeps one original starter line and proves the loop before adding a full roster.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)

            ForEach(store.state.collection) { pet in
                let form = BuddyMonEngine.form(for: pet.formID)
                HStack(spacing: BMOTheme.spacingMD) {
                    Text(form.idleGlyph)
                        .font(.system(.title, design: .monospaced).weight(.bold))
                        .foregroundColor(BMOTheme.accent)
                        .frame(width: 42, height: 42)
                        .background(BMOTheme.accentGlow)
                        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                    VStack(alignment: .leading, spacing: 3) {
                        Text(pet.nickname)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(BMOTheme.textPrimary)
                        Text("\(form.name) • \(form.stage.displayName) • Bond \(Int(pet.stats.bond))")
                            .font(.caption)
                            .foregroundColor(BMOTheme.textSecondary)
                    }
                    Spacer()
                }
                .padding(BMOTheme.spacingMD)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
            }
        }
        .bmoCard()
    }

    private var evolutionLogCard: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("Growth Log")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)

            ForEach(store.activePet.evolutionLog.reversed(), id: \.self) { entry in
                Text(entry)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
                    .padding(.vertical, 2)
            }
        }
        .bmoCard()
    }

    private func receiptCard(_ receipt: String) -> some View {
        Label(receipt, systemImage: "checkmark.seal.fill")
            .font(.subheadline)
            .foregroundColor(BMOTheme.success)
            .frame(maxWidth: .infinity, alignment: .leading)
            .bmoCard()
    }

    private func errorCard(_ error: String) -> some View {
        Label(error, systemImage: "exclamationmark.triangle.fill")
            .font(.subheadline)
            .foregroundColor(BMOTheme.error)
            .frame(maxWidth: .infinity, alignment: .leading)
            .bmoCard()
    }

    private func statBar(_ label: String, value: Double, isWarning: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(BMOTheme.textSecondary)
                Spacer()
                Text("\(Int(value))")
                    .font(.caption.monospacedDigit())
                    .foregroundColor(isWarning && value > 65 ? BMOTheme.warning : BMOTheme.textPrimary)
            }
            GeometryReader { proxy in
                ZStack(alignment: .leading) {
                    Capsule().fill(BMOTheme.backgroundPrimary)
                    Capsule()
                        .fill(isWarning ? BMOTheme.warning.opacity(0.85) : BMOTheme.accent.opacity(0.85))
                        .frame(width: max(8, proxy.size.width * min(max(value, 0), 100) / 100))
                }
            }
            .frame(height: 8)
        }
        .padding(BMOTheme.spacingMD)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
    }

    private func metricPill(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2.weight(.bold))
                .foregroundColor(BMOTheme.textTertiary)
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundColor(BMOTheme.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(BMOTheme.spacingSM)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
    }

    private func moodColor(_ mood: BuddyMonMood) -> Color {
        switch mood {
        case .happy, .battle: return BMOTheme.success
        case .hungry, .dirty, .sleepy, .stressed: return BMOTheme.warning
        case .evolving, .training: return BMOTheme.accent
        case .idle: return BMOTheme.textSecondary
        }
    }
}

#Preview {
    BuddyMonView()
}
