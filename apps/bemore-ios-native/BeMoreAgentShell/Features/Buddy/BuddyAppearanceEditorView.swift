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
}

struct BuddyAppearanceEditorView<Preview: View>: View {
    @Binding var draft: BuddyAppearanceEditorDraft
    let availablePalettes: [BuddyPaletteOption]
    let availableArchetypes: [BuddyArchetypeOption]
    let asciiVariantOptions: [BuddyChoiceOption]
    let expressionToneOptions: [BuddyChoiceOption]
    let pixelLabLinked: Bool
    let onPixelLabLink: () -> Void
    let preview: Preview

    init(
        draft: Binding<BuddyAppearanceEditorDraft>,
        availablePalettes: [BuddyPaletteOption],
        availableArchetypes: [BuddyArchetypeOption],
        asciiVariantOptions: [BuddyChoiceOption],
        expressionToneOptions: [BuddyChoiceOption],
        pixelLabLinked: Bool,
        onPixelLabLink: @escaping () -> Void,
        @ViewBuilder preview: () -> Preview
    ) {
        _draft = draft
        self.availablePalettes = availablePalettes
        self.availableArchetypes = availableArchetypes
        self.asciiVariantOptions = asciiVariantOptions
        self.expressionToneOptions = expressionToneOptions
        self.pixelLabLinked = pixelLabLinked
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
                    Text(draft.pixelVariantID.isEmpty ? "Pixel render key will be assigned from the selected Buddy look." : draft.pixelVariantID)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                    Text(pixelLabLinked
                         ? "Pixel mode should use a real PixelLab-generated render instead of a fake local placeholder id."
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
    }
}
