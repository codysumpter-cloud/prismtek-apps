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
    var pixelVariantID: String = "pixellab-classic"
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
            Section("Preview") {
                preview
            }

            Section("Look") {
                TextField("Look name", text: $draft.profileName)
                TextField("Accent label", text: $draft.accentLabel)
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

            Section("Body") {
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
                Section("ASCII") {
                    Picker("ASCII style", selection: $draft.asciiVariantID) {
                        ForEach(asciiVariantOptions, id: \.id) { option in
                            Text(option.label).tag(option.id)
                        }
                    }
                    Text("ASCII mode keeps Buddy lightweight, legible, and always available inside the native app.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
            } else {
                Section("Pixel") {
                    TextField("Pixel variant ID", text: $draft.pixelVariantID)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    Text(pixelLabLinked
                         ? "PixelLab is linked, so this look can track a richer pixel identity alongside the native Buddy shell."
                         : "You can keep using native pixel Buddy mode now, and link PixelLab when you want richer synced art workflows.")
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
                Text("Pixel looks can work without PixelLab, but linking it gives the Buddy a clearer path to richer synced pixel identity later.")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
        }
    }
}
