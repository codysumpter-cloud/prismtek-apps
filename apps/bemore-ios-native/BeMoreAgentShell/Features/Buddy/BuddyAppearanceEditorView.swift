import SwiftUI

enum BuddyAppearanceRenderStyle: String, Codable, CaseIterable, Identifiable {
    case ascii
    case pixel

    var id: String { rawValue }

    var title: String {
        switch self {
        case .ascii: return "ASCII"
        case .pixel: return "Pixel"
        }
    }
}

struct BuddyAppearanceEditorDraft: Hashable {
    var profileName: String = "Everyday Look"
    var archetype: String = "console_pet"
    var palette: String = "mint_cream"
    var asciiVariantID: String = "starter_a"
    var expressionTone: String = "friendly"
    var accentLabel: String = "pocket glow"
    var customization: BuddyAppearanceCustomization = BuddyAppearanceRenderContract.defaultCustomization(for: "console_pet")
    var renderStyle: BuddyAppearanceRenderStyle = .ascii
    var pixelVariantID: String = ""
    var pixelAssetPath: String? = nil

    func previewSpec(buddyName: String) -> BuddyAppearancePreviewSpec {
        BuddyAppearanceRenderContract.makePreviewSpec(
            buddyName: buddyName,
            archetypeID: archetype,
            paletteID: palette,
            asciiVariantID: asciiVariantID,
            expressionTone: expressionTone,
            accentLabel: accentLabel,
            renderStyle: renderStyle,
            customization: customization,
            pixelRequestKey: pixelVariantID.isEmpty ? nil : pixelVariantID,
            pixelAssetPath: pixelAssetPath
        )
    }
}

struct BuddyAppearanceEditorView<Preview: View>: View {
    @Binding var draft: BuddyAppearanceEditorDraft
    let availablePalettes: [BuddyPaletteOption]
    let availableArchetypes: [BuddyArchetypeOption]
    let asciiVariantOptions: [BuddyChoiceOption]
    let expressionToneOptions: [BuddyChoiceOption]
    let pixelLabLinked: Bool
    let buddyDisplayName: String
    let onPixelLabLink: () -> Void
    let preview: Preview

    init(
        draft: Binding<BuddyAppearanceEditorDraft>,
        availablePalettes: [BuddyPaletteOption],
        availableArchetypes: [BuddyArchetypeOption],
        asciiVariantOptions: [BuddyChoiceOption],
        expressionToneOptions: [BuddyChoiceOption],
        pixelLabLinked: Bool,
        buddyDisplayName: String = "Buddy",
        onPixelLabLink: @escaping () -> Void,
        @ViewBuilder preview: () -> Preview
    ) {
        _draft = draft
        self.availablePalettes = availablePalettes
        self.availableArchetypes = availableArchetypes
        self.asciiVariantOptions = asciiVariantOptions
        self.expressionToneOptions = expressionToneOptions
        self.pixelLabLinked = pixelLabLinked
        self.buddyDisplayName = buddyDisplayName
        self.onPixelLabLink = onPixelLabLink
        self.preview = preview()
    }

    var body: some View {
        Form {
            Section("Preview") {
                preview
                Text(previewSummary)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }

            Section("Identity") {
                TextField("Look name", text: $draft.profileName)
                Picker("Archetype", selection: $draft.archetype) {
                    ForEach(availableArchetypes, id: \.id) { archetype in
                        Text(archetype.label).tag(archetype.id)
                    }
                }
                if subtypeOptions.isEmpty == false {
                    Picker("Subtype / Species", selection: $draft.customization.subtype) {
                        ForEach(subtypeOptions) { option in
                            Text(option.label).tag(option.id)
                        }
                    }
                    Text(selectedSubtypeDetail)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
            }

            Section("Style") {
                Picker("Render style", selection: $draft.renderStyle) {
                    ForEach(BuddyAppearanceRenderStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
                Picker("Palette", selection: $draft.palette) {
                    ForEach(availablePalettes, id: \.id) { palette in
                        Text(palette.label).tag(palette.id)
                    }
                }
                Picker("Expression tone", selection: $draft.expressionTone) {
                    ForEach(expressionToneOptions, id: \.id) { option in
                        Text(option.label).tag(option.id)
                    }
                }
                Picker("Body style", selection: $draft.customization.bodyStyle) {
                    ForEach(bodyStyleOptions) { option in
                        Text(option.label).tag(option.id)
                    }
                }
                Picker("Pose / Stance", selection: $draft.customization.pose) {
                    ForEach(poseOptions) { option in
                        Text(option.label).tag(option.id)
                    }
                }
                if draft.renderStyle == .ascii {
                    Picker("ASCII style", selection: $draft.asciiVariantID) {
                        ForEach(asciiVariantOptions, id: \.id) { option in
                            Text(option.label).tag(option.id)
                        }
                    }
                }
            }

            Section("Details") {
                Picker("Accessory", selection: $draft.customization.accessory) {
                    ForEach(accessoryOptions) { option in
                        Text(option.label).tag(option.id)
                    }
                }
                Picker("Accent", selection: $draft.customization.accentDetail) {
                    ForEach(accentOptions) { option in
                        Text(option.label).tag(option.id)
                    }
                }
                Picker("Personality vibe", selection: $draft.customization.personalityVibe) {
                    ForEach(vibeOptions) { option in
                        Text(option.label).tag(option.id)
                    }
                }
                Picker("Animation flavor", selection: $draft.customization.animationFlavor) {
                    ForEach(animationOptions) { option in
                        Text(option.label).tag(option.id)
                    }
                }
                TextField("Prompt modifier", text: $draft.customization.promptModifiers, prompt: Text("cute retro green sprite buddy"))
                TextField("Preview label", text: $draft.accentLabel, prompt: Text("leaf scarf, cheek glow, horn trim"))
            }

            Section("Save") {
                TextField("Look name", text: $draft.profileName)
                Text(currentPixelVariantLabel)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
                Text(pixelLabLinked
                     ? "Pixel rendering uses a deterministic direct PixelLab request key derived from this exact look."
                     : "Pixel rendering stays optional. Link PixelLab for live pixel generation, otherwise ASCII remains the local-first fallback.")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }

            Section("PixelLab") {
                HStack {
                    Text(pixelLabLinked ? "Linked" : "Not linked")
                        .foregroundColor(pixelLabLinked ? BMOTheme.success : BMOTheme.warning)
                    Spacer()
                    Button(pixelLabLinked ? "Manage Link" : "Link PixelLab") {
                        onPixelLabLink()
                    }
                    .foregroundColor(BMOTheme.accent)
                }
                Text("PixelLab stays optional. The beginner flow should still work without it.")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
        }
        .task(id: pixelKeySignature) {
            syncPixelVariantIDIfNeeded()
        }
        .task(id: draft.archetype) {
            resetCustomizationForArchetype()
        }
    }

    private var pixelKeySignature: String {
        [
            draft.renderStyle.rawValue,
            buddyDisplayName,
            draft.archetype,
            draft.palette,
            draft.expressionTone,
            draft.accentLabel,
            draft.customization.subtype,
            draft.customization.bodyStyle,
            draft.customization.accessory,
            draft.customization.accentDetail,
            draft.customization.pose,
            draft.customization.personalityVibe,
            draft.customization.animationFlavor,
            draft.customization.promptModifiers
        ]
        .joined(separator: "|")
    }

    private var currentPixelVariantLabel: String {
        let value = draft.pixelVariantID.isEmpty ? derivedPixelVariantID : draft.pixelVariantID
        return "Pixel render key: \(value)"
    }

    private var subtypeOptions: [BuddyAppearanceOption] {
        BuddyAppearanceRenderContract.subtypeOptions(for: draft.archetype)
    }

    private var bodyStyleOptions: [BuddyAppearanceOption] {
        BuddyAppearanceRenderContract.options(for: \.bodyStyle, archetypeID: draft.archetype)
    }

    private var accessoryOptions: [BuddyAppearanceOption] {
        BuddyAppearanceRenderContract.options(for: \.accessory, archetypeID: draft.archetype)
    }

    private var accentOptions: [BuddyAppearanceOption] {
        BuddyAppearanceRenderContract.options(for: \.accentDetail, archetypeID: draft.archetype)
    }

    private var poseOptions: [BuddyAppearanceOption] {
        BuddyAppearanceRenderContract.options(for: \.pose, archetypeID: draft.archetype)
    }

    private var vibeOptions: [BuddyAppearanceOption] {
        BuddyAppearanceRenderContract.options(for: \.personalityVibe, archetypeID: draft.archetype)
    }

    private var animationOptions: [BuddyAppearanceOption] {
        BuddyAppearanceRenderContract.options(for: \.animationFlavor, archetypeID: draft.archetype)
    }

    private var selectedSubtypeDetail: String {
        subtypeOptions.first(where: { $0.id == draft.customization.subtype })?.detail ?? "Subtype affects both ASCII silhouette and pixel generation."
    }

    private var previewSummary: String {
        "\(draft.archetype.replacingOccurrences(of: "_", with: " ").capitalized) • \(draft.customization.subtype.replacingOccurrences(of: "_", with: " ").capitalized) • \(draft.customization.personalityVibe.capitalized)"
    }

    private var derivedPixelVariantID: String {
        BuddyAppearanceRenderContract.pixelRequestKey(
            buddyName: buddyDisplayName,
            archetypeID: draft.archetype,
            paletteID: draft.palette,
            expressionTone: draft.expressionTone,
            accentLabel: draft.accentLabel,
            customization: draft.customization
        )
    }

    private func syncPixelVariantIDIfNeeded() {
        if draft.renderStyle == .pixel {
            draft.pixelVariantID = derivedPixelVariantID
        } else if draft.pixelVariantID.hasPrefix("pixellab:") {
            draft.pixelVariantID = ""
            draft.pixelAssetPath = nil
        }
    }

    private func resetCustomizationForArchetype() {
        let defaults = BuddyAppearanceRenderContract.defaultCustomization(for: draft.archetype)
        if subtypeOptions.contains(where: { $0.id == draft.customization.subtype }) == false {
            draft.customization = defaults
            return
        }
        draft.customization = BuddyAppearanceRenderContract.normalizedCustomization(draft.customization, archetypeID: draft.archetype)
    }
}
