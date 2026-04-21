import SwiftUI

struct BuddyHeaderSectionView: View {
    let buddy: BuddyInstance
    let template: CouncilStarterBuddyTemplate?
    let mood: BuddyAnimationMood
    let ownedCount: Int
    let battleCount: Int
    let tradeCount: Int
    let trust: Int

    var body: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
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
                StatusBadge(label: "Phone-first", color: BMOTheme.success)
            }

            BuddyVisualView(buddy: buddy, template: template, mood: mood, compact: true)

            HStack(spacing: BMOTheme.spacingSM) {
                metricPill(title: "Owned", value: "\(ownedCount)")
                metricPill(title: "Battles", value: "\(battleCount)")
                metricPill(title: "Trades", value: "\(tradeCount)")
                metricPill(title: "Level", value: "\(buddy.progression.level)")
                metricPill(title: "Trust", value: "\(trust)")
            }
        }
        .bmoCard()
    }
}

struct BuddyOverviewSectionView: View {
    let buddy: BuddyInstance
    let template: CouncilStarterBuddyTemplate?
    let bondLabel: String
    let moodColor: Color
    let mood: BuddyAnimationMood
    let care: BuddyCareSnapshot
    let paletteLabel: String
    let asciiLabel: String
    let rarityLabel: String
    let lastActiveLabel: String
    let onPersonalize: () -> Void
    let onOpenAppearanceStudio: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
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
                    StatusBadge(label: buddy.state.mood.capitalized, color: moodColor)
                }
            }

            BuddyVisualView(buddy: buddy, template: template, mood: mood)

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
                profileRow(label: "Palette", value: paletteLabel)
                profileRow(label: "ASCII style", value: asciiLabel)
                profileRow(label: "Rarity", value: rarityLabel)
                profileRow(label: "Last active", value: lastActiveLabel)
                profileRow(label: "Top move", value: buddy.equippedMoves.sorted(by: { $0.slot < $1.slot }).first?.name ?? "None")
            }

            Button("Personalize Buddy", action: onPersonalize)
                .buttonStyle(BMOButtonStyle(isPrimary: false))

            Button("Open Appearance Studio", action: onOpenAppearanceStudio)
                .buttonStyle(BMOButtonStyle())
        }
        .bmoCard()
    }
}

struct BuddyAppearanceSectionView: View {
    let buddy: BuddyInstance
    let template: CouncilStarterBuddyTemplate?
    let previewBuddy: BuddyInstance
    let previewMood: BuddyAnimationMood
    let activeProfileLabel: String
    let archetypeLabel: String
    let paletteLabel: String
    let asciiLabel: String
    let profiles: [BuddyAppearanceProfile]
    let isPixelLabLinked: Bool
    let onEquip: (String) -> Void
    let onDesignNewLook: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Appearance Studio")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Buddy can now save named ASCII looks or switch into native pixel mode. PixelLab can layer on top when linked, but it no longer blocks pixel-style Buddy identity in the app.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: activeProfileLabel, color: isPixelLabLinked ? BMOTheme.success : BMOTheme.accent)
            }

            BuddyVisualView(buddy: previewBuddy, template: template, mood: previewMood, compact: true)

            VStack(alignment: .leading, spacing: 6) {
                profileRow(label: "Archetype", value: archetypeLabel)
                profileRow(label: "Palette", value: paletteLabel)
                profileRow(label: "ASCII style", value: asciiLabel)
                profileRow(label: "State", value: buddy.visual?.currentAnimationState ?? buddy.state.mood.capitalized)
                profileRow(label: "Saved looks", value: "\(profiles.count)")
                profileRow(label: "PixelLab", value: isPixelLabLinked ? "Linked" : "Not linked")
            }

            if profiles.isEmpty {
                Text("No saved looks yet. Create a first appearance profile to make Buddy feel more like yours.")
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
            } else {
                ForEach(profiles.prefix(3)) { profile in
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(profile.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundColor(BMOTheme.textPrimary)
                            Text("\(profile.archetype) • \(profile.palette) • \(profile.asciiVariantId)")
                                .font(.caption)
                                .foregroundColor(BMOTheme.textSecondary)
                            Text("Tone: \(profile.expressionTone.capitalized) • Accent: \(profile.accentLabel)")
                                .font(.caption)
                                .foregroundColor(BMOTheme.textTertiary)
                            if let pixelVariantId = profile.pixelVariantId, !pixelVariantId.isEmpty {
                                Text("Pixel: \(pixelVariantId)")
                                    .font(.caption2)
                                    .foregroundColor(BMOTheme.accent)
                            }
                        }
                        Spacer()
                        Button(profile.id == buddy.visual?.activeAppearanceProfileId ? "Active" : "Equip") {
                            onEquip(profile.id)
                        }
                        .buttonStyle(BMOButtonStyle(isPrimary: profile.id != buddy.visual?.activeAppearanceProfileId))
                        .disabled(profile.id == buddy.visual?.activeAppearanceProfileId)
                    }
                    .padding(BMOTheme.spacingMD)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                }
            }

            Button("Design New Look", action: onDesignNewLook)
                .buttonStyle(BMOButtonStyle())
        }
        .bmoCard()
    }
}

struct BuddyTeachingSectionView: View {
    let buddyName: String
    let latestPlan: BuddyDailyPlan?
    @Binding var preferenceTitle: String
    @Binding var preferenceDetail: String
    @Binding var topPriority: String
    @Binding var supportStyle: String
    @Binding var reminderDueAt: Date
    let isCreatingReminder: Bool
    let appleActionStatus: String?
    let onTeach: () -> Void
    let onCaptureJournal: () -> Void
    let onShareNote: () -> Void
    let onCreateReminder: () -> Void
    let onDraftMessage: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Teach Buddy")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Teach \(buddyName) how you like to plan, then use that lesson for a reminder, journal note, or follow-up draft.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "Planning loop", color: BMOTheme.success)
            }

            VStack(alignment: .leading, spacing: 10) {
                textFieldCard("What should Buddy learn?", text: $preferenceTitle)
                textFieldCard("Preference detail", text: $preferenceDetail, axis: .vertical)
                textFieldCard("Today's priority", text: $topPriority, axis: .vertical)
                textFieldCard("Support style", text: $supportStyle)
            }

            HStack {
                Button("Teach and Train", action: onTeach)
                    .buttonStyle(BMOButtonStyle())
                Button("Capture Journal", action: onCaptureJournal)
                    .buttonStyle(BMOButtonStyle(isPrimary: false))
                Button("Share Note", action: onShareNote)
                    .buttonStyle(BMOButtonStyle(isPrimary: false))
            }

            Divider().overlay(BMOTheme.divider)

            VStack(alignment: .leading, spacing: 10) {
                Text("Apple handoff")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)
                Text("Reminders are created after permission. Messages open the native composer when available. Notes use the iPhone share sheet because Apple does not expose a direct Notes write API.")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)

                DatePicker("Reminder time", selection: $reminderDueAt, displayedComponents: [.date, .hourAndMinute])
                    .foregroundColor(BMOTheme.textSecondary)

                HStack {
                    Button(isCreatingReminder ? "Creating..." : "Create Reminder", action: onCreateReminder)
                        .disabled(isCreatingReminder)
                        .buttonStyle(BMOButtonStyle(isPrimary: false))
                    Button("Draft Message", action: onDraftMessage)
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

private func textFieldCard(_ placeholder: String, text: Binding<String>, axis: Axis = .horizontal) -> some View {
    TextField(placeholder, text: text, axis: axis)
        .textFieldStyle(.plain)
        .foregroundColor(BMOTheme.textPrimary)
        .padding(BMOTheme.spacingMD)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
}
