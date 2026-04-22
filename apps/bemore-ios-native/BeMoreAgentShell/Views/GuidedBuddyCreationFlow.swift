import SwiftUI

private struct BuddyCreatorDraft {
    var templateID: String = ""
    var displayName: String = ""
    var paletteID: String = "mint_cream"
    var asciiVariantID: String = "starter_a"
    var expressionTone: String = "friendly"
    var accentLabel: String = "pocket glow"
    var renderStyle: BuddyAppearanceRenderStyle = .ascii

    mutating func reset(using template: CouncilStarterBuddyTemplate?, palettes: [BuddyPaletteOption]) {
        paletteID = palettes.first?.id ?? "mint_cream"
        asciiVariantID = BuddyCreatorCurations.asciiStyles.first ?? "starter_a"
        expressionTone = "friendly"
        accentLabel = "pocket glow"
        renderStyle = .ascii
        if displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            displayName = template?.name ?? "Buddy"
        }
    }
}

struct GuidedBuddyCreationFlow: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var draft = BuddyCreatorDraft()
    @State private var currentStep = 0
    @State private var isSaving = false
    @State private var errorMessage: String?

    private let stepTitles = ["Starter", "Colors", "Features", "Save Buddy"]

    private var templates: [CouncilStarterBuddyTemplate] {
        appState.buddyStore.templates
    }

    private var palettes: [BuddyPaletteOption] {
        appState.buddyStore.contracts?.creationOptions.options.palettes ?? []
    }

    private var selectedTemplate: CouncilStarterBuddyTemplate? {
        templates.first(where: { $0.id == draft.templateID || $0.templateID == draft.templateID }) ?? templates.first
    }

    private var previewBuddy: BuddyInstance? {
        guard var preview = appState.buddyStore.activeBuddy else { return nil }
        preview.displayName = draft.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? preview.displayName : draft.displayName
        preview.identity.palette = draft.paletteID
        var visual = preview.visual ?? BuddyVisualState(
            asciiVariantId: nil,
            pixelVariantId: nil,
            activeAppearanceProfileId: nil,
            currentAnimationState: nil,
            evolutionCosmetics: []
        )
        visual.asciiVariantId = draft.asciiVariantID
        visual.pixelVariantId = draft.renderStyle == .pixel ? "creator-\(draft.expressionTone)" : nil
        visual.currentAnimationState = draft.expressionTone == "focused" ? "working" : (draft.expressionTone == "curious" ? "thinking" : "happy")
        preview.visual = visual
        return preview
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Create Buddy")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Pick a starter, choose colors from a real palette, tweak a few obvious features, and save. Deeper editing stays in Customize More.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)

                    HStack(spacing: 8) {
                        ForEach(Array(stepTitles.enumerated()), id: \.offset) { index, title in
                            Text(title)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(index <= currentStep ? BMOTheme.backgroundPrimary : BMOTheme.textSecondary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 8)
                                .background(index <= currentStep ? BMOTheme.accent : BMOTheme.backgroundSecondary)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(BMOTheme.spacingLG)
                .frame(maxWidth: .infinity, alignment: .leading)

                ScrollView {
                    VStack(spacing: BMOTheme.spacingLG) {
                        previewCard
                        stepContent
                    }
                    .padding(BMOTheme.spacingLG)
                }

                HStack(spacing: 12) {
                    if currentStep > 0 {
                        Button("Back") {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentStep -= 1
                            }
                        }
                        .buttonStyle(BMOButtonStyle(isPrimary: false))
                    }

                    Button("Randomize") {
                        randomizeDraft()
                    }
                    .buttonStyle(BMOButtonStyle(isPrimary: false))

                    Spacer()

                    Button(currentStep == stepTitles.count - 1 ? "Save Buddy" : "Next") {
                        if currentStep == stepTitles.count - 1 {
                            saveBuddy()
                        } else {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                currentStep += 1
                            }
                        }
                    }
                    .buttonStyle(BMOButtonStyle())
                    .disabled(isSaving || !canAdvance)
                }
                .padding(BMOTheme.spacingLG)
            }
            .background(BMOTheme.backgroundPrimary)
            .onAppear {
                if draft.templateID.isEmpty {
                    draft.templateID = selectedTemplate?.id ?? templates.first?.id ?? ""
                }
                draft.reset(using: selectedTemplate, palettes: palettes)
                if let activeBuddy = appState.buddyStore.activeBuddy {
                    draft.displayName = activeBuddy.displayName
                    draft.paletteID = activeBuddy.identity.palette
                    draft.asciiVariantID = activeBuddy.visual?.asciiVariantId ?? "starter_a"
                }
            }
            .alert("Buddy creator", isPresented: Binding(
                get: { errorMessage != nil },
                set: { if !$0 { errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(errorMessage ?? "Unknown error")
            }
        }
    }

    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 0:
            starterStep
        case 1:
            colorsStep
        case 2:
            featuresStep
        default:
            saveStep
        }
    }

    private var previewCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Live preview")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Every major choice updates here immediately.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                if let palette = palettes.first(where: { $0.id == draft.paletteID }) {
                    Text(BuddyCreatorCurations.familyLabel(for: palette.id))
                        .font(.caption.weight(.semibold))
                        .foregroundColor(BMOTheme.accent)
                }
            }

            if let previewBuddy, let template = selectedTemplate {
                BuddyVisualView(
                    buddy: previewBuddy,
                    template: template,
                    mood: draft.expressionTone == "focused" ? .working : (draft.expressionTone == "curious" ? .thinking : .happy),
                    compact: true
                )
            } else {
                Text(selectedTemplate?.ascii.baseSilhouette ?? "Pick a starter to see the preview.")
                    .font(.system(size: 24, design: .monospaced))
                    .foregroundColor(BMOTheme.accent)
                    .frame(maxWidth: .infinity)
                    .padding(BMOTheme.spacingLG)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
            }

            if let palette = palettes.first(where: { $0.id == draft.paletteID }) {
                HStack(spacing: 8) {
                    ForEach(palette.colors, id: \.self) { hex in
                        Circle()
                            .fill(Color(pixelStudioHex: hex) ?? BMOTheme.backgroundSecondary)
                            .frame(width: 20, height: 20)
                    }
                    Text(palette.label)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
            }
        }
        .bmoCard()
    }

    private var starterStep: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("Choose a starter")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("Start with a strong default instead of building from scratch.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)

            ForEach(templates) { template in
                Button {
                    draft.templateID = template.id
                    if draft.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || draft.displayName == selectedTemplate?.name {
                        draft.displayName = template.name
                    }
                } label: {
                    HStack(spacing: 14) {
                        Text(template.ascii.baseSilhouette)
                            .font(.system(size: 20, design: .monospaced))
                            .foregroundColor(BMOTheme.accent)
                            .frame(width: 72, height: 72)
                            .background(BMOTheme.backgroundSecondary)
                            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))

                        VStack(alignment: .leading, spacing: 4) {
                            Text(template.name)
                                .font(.headline)
                                .foregroundColor(BMOTheme.textPrimary)
                            Text(template.onboardingTitle)
                                .font(.subheadline)
                                .foregroundColor(BMOTheme.textSecondary)
                            Text(template.onboardingCopy)
                                .font(.caption)
                                .foregroundColor(BMOTheme.textTertiary)
                                .lineLimit(2)
                        }
                        Spacer()
                    }
                    .padding(BMOTheme.spacingMD)
                    .background(draft.templateID == template.id ? BMOTheme.accent.opacity(0.12) : BMOTheme.backgroundCard)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous)
                            .stroke(draft.templateID == template.id ? BMOTheme.accent : BMOTheme.divider, lineWidth: draft.templateID == template.id ? 2 : 1)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var colorsStep: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Pick colors")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Use richer curated themes instead of a tiny fixed palette.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                Button("Reset to starter") {
                    draft.reset(using: selectedTemplate, palettes: palettes)
                }
                .font(.caption.weight(.semibold))
                .foregroundColor(BMOTheme.accent)
            }

            ForEach(Dictionary(grouping: palettes, by: { BuddyCreatorCurations.familyLabel(for: $0.id) }).keys.sorted(), id: \.self) { family in
                VStack(alignment: .leading, spacing: 10) {
                    Text(family)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(BMOTheme.textPrimary)

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(palettes.filter { BuddyCreatorCurations.familyLabel(for: $0.id) == family }, id: \.id) { palette in
                            Button {
                                draft.paletteID = palette.id
                            } label: {
                                VStack(alignment: .leading, spacing: 10) {
                                    HStack(spacing: 6) {
                                        ForEach(palette.colors, id: \.self) { hex in
                                            Circle()
                                                .fill(Color(pixelStudioHex: hex) ?? BMOTheme.backgroundSecondary)
                                                .frame(width: 18, height: 18)
                                        }
                                    }
                                    Text(palette.label)
                                        .font(.subheadline.weight(.semibold))
                                        .foregroundColor(BMOTheme.textPrimary)
                                }
                                .padding(BMOTheme.spacingMD)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(draft.paletteID == palette.id ? BMOTheme.accent.opacity(0.12) : BMOTheme.backgroundCard)
                                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
                                .overlay(
                                    RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous)
                                        .stroke(draft.paletteID == palette.id ? BMOTheme.accent : BMOTheme.divider, lineWidth: draft.paletteID == palette.id ? 2 : 1)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
        }
    }

    private var featuresStep: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("Shape the vibe")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("Keep decisions obvious: look, mood, and one standout detail.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)

            Picker("Look", selection: $draft.renderStyle) {
                Text("ASCII").tag(BuddyAppearanceRenderStyle.ascii)
                Text("Pixel").tag(BuddyAppearanceRenderStyle.pixel)
            }
            .pickerStyle(.segmented)

            Picker("Style", selection: $draft.asciiVariantID) {
                Text("Classic").tag("starter_a")
                Text("Soft").tag("starter_b")
                Text("Bold").tag("starter_c")
            }
            .pickerStyle(.segmented)

            Picker("Vibe", selection: $draft.expressionTone) {
                Text("Friendly").tag("friendly")
                Text("Curious").tag("curious")
                Text("Focused").tag("focused")
            }
            .pickerStyle(.segmented)

            VStack(alignment: .leading, spacing: 8) {
                Text("Feature")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
                    ForEach(BuddyCreatorCurations.featureOptions, id: \.self) { feature in
                        Button(feature.capitalized) {
                            draft.accentLabel = feature
                        }
                        .buttonStyle(BMOButtonStyle(isPrimary: draft.accentLabel == feature))
                    }
                }
            }

            HStack {
                Button("Remix current") {
                    randomizeDraft()
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))

                Button("Customize More") {
                    currentStep = stepTitles.count - 1
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
    }

    private var saveStep: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            Text("Name and save")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("A usable Buddy should exist before any advanced editing.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)

            TextField("Buddy name", text: $draft.displayName)
                .textFieldStyle(.plain)
                .foregroundColor(BMOTheme.textPrimary)
                .padding(BMOTheme.spacingMD)
                .background(BMOTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                summaryRow("Starter", selectedTemplate?.name ?? "None")
                summaryRow("Colors", palettes.first(where: { $0.id == draft.paletteID })?.label ?? draft.paletteID)
                summaryRow("Style", draft.renderStyle == .pixel ? "Pixel preview" : "ASCII preview")
                summaryRow("Feature", draft.accentLabel.capitalized)
                summaryRow("Vibe", draft.expressionTone.capitalized)
            }
            .bmoCard()
        }
    }

    private var canAdvance: Bool {
        switch currentStep {
        case 0:
            return selectedTemplate != nil
        case 3:
            return draft.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false
        default:
            return true
        }
    }

    private func randomizeDraft() {
        if let template = templates.randomElement() {
            draft.templateID = template.id
            if draft.displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                draft.displayName = template.name
            }
        }
        if let palette = palettes.randomElement() {
            draft.paletteID = palette.id
        }
        draft.asciiVariantID = BuddyCreatorCurations.asciiStyles.randomElement() ?? "starter_a"
        draft.expressionTone = ["friendly", "curious", "focused"].randomElement() ?? "friendly"
        draft.accentLabel = BuddyCreatorCurations.featureOptions.randomElement() ?? "pocket glow"
        draft.renderStyle = Bool.random() ? .ascii : .pixel
    }

    private func saveBuddy() {
        guard let template = selectedTemplate else {
            errorMessage = "Choose a starter Buddy first."
            return
        }

        let cleanedName = draft.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard cleanedName.isEmpty == false else {
            errorMessage = "Add a Buddy name before saving."
            return
        }

        isSaving = true
        appState.buddyStore.install(template: template, using: appState)
        appState.buddyStore.personalizeActive(
            displayName: cleanedName,
            nickname: nil,
            currentFocus: nil,
            palette: draft.paletteID,
            asciiVariantID: draft.asciiVariantID,
            using: appState
        )
        appState.buddyStore.saveAppearanceProfile(
            profileName: "Starter Look",
            archetype: CouncilBuddyIdentityCatalog.identity(for: template).archetype,
            palette: draft.paletteID,
            asciiVariantID: draft.asciiVariantID,
            pixelVariantID: draft.renderStyle == .pixel ? "creator-\(draft.expressionTone)" : nil,
            expressionTone: draft.expressionTone,
            accentLabel: draft.accentLabel,
            setActive: true,
            using: appState
        )
        isSaving = false
        dismiss()
    }

    private func summaryRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption.weight(.semibold))
                .foregroundColor(BMOTheme.textTertiary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .foregroundColor(BMOTheme.textPrimary)
        }
    }
}
