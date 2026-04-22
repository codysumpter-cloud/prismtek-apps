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
            Section("Live Preview") {
                preview
            }

            Section("Save Look") {
                TextField("Look name", text: $draft.profileName)
                TextField("Feature", text: $draft.accentLabel)
                Picker("Expression tone", selection: $draft.expressionTone) {
                    ForEach(expressionToneOptions, id: \.id) { option in
                        Text(option.label).tag(option.id)
                    }
                }
                Picker("Render style", selection: $draft.renderStyle) {
                    ForEach(BuddyAppearanceRenderStyle.allCases) { style in
                        Text(style.title).tag(style)
                    }
                }
            }

            Section("Colors and Shape") {
                Picker("Archetype", selection: $draft.archetype) {
                    ForEach(availableArchetypes, id: \.id) { archetype in
                        Text(archetype.label).tag(archetype.id)
                    }
                }

                Picker("Palette", selection: $draft.palette) {
                    ForEach(availablePalettes, id: \.id) { palette in
                        Text(palette.label).tag(palette.id)
                    }
                }
            }

            if draft.renderStyle == .ascii {
                Section("Style") {
                    Picker("ASCII style", selection: $draft.asciiVariantID) {
                        ForEach(asciiVariantOptions, id: \.id) { option in
                            Text(option.label).tag(option.id)
                        }
                    }
                    Text("ASCII keeps Buddy readable and fast everywhere in the app.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
            } else {
                Section("Pixel Look") {
                    Text(currentPixelVariantLabel)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                    Text(pixelLabLinked
                         ? "Pixel mode now uses a deterministic PixelLab render key derived from the current Buddy look."
                         : "Link PixelLab to generate a real pixel Buddy render from this look.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
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
    }

    private var pixelKeySignature: String {
        [draft.renderStyle.rawValue, buddyDisplayName, draft.archetype, draft.palette, draft.expressionTone, draft.accentLabel].joined(separator: "|")
    }

    private var currentPixelVariantLabel: String {
        let value = draft.pixelVariantID.isEmpty ? derivedPixelVariantID : draft.pixelVariantID
        return "Pixel render key: \(value)"
    }

    private var derivedPixelVariantID: String {
        BuddyAppearanceRenderContract.pixelRequestKey(
            buddyName: buddyDisplayName,
            archetypeID: draft.archetype,
            paletteID: draft.palette,
            expressionTone: draft.expressionTone,
            accentLabel: draft.accentLabel
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
}
