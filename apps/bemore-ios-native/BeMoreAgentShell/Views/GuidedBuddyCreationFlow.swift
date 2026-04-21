import SwiftUI

struct GuidedBuddyCreationFlow: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep: CreationStep = .appearanceMode
    @State private var selectedMode: BuddyAppearanceMode = .ascii
    @State private var selectedTemplate: CouncilStarterBuddyTemplate?
    @State private var displayName: String = ""
    @State private var nickname: String = ""
    @State private var selectedPalette: String = "default"
    @State private var asciiVariant: String = "classic"
    @State private var pixelProjectRef: String?
    @State private var isCreating: Bool = false
    @State private var errorMessage: String?
    
    enum CreationStep: CaseIterable {
        case appearanceMode, chooseTemplate, nameBuddy, customize, confirm
        
        var title: String {
            switch self {
            case .appearanceMode: return "Choose Style"
            case .chooseTemplate: return "Select Buddy"
            case .nameBuddy: return "Name Your Buddy"
            case .customize: return "Customize"
            case .confirm: return "Ready?"
            }
        }
        
        var progress: Double {
            switch self {
            case .appearanceMode: return 0.2
            case .chooseTemplate: return 0.4
            case .nameBuddy: return 0.6
            case .customize: return 0.8
            case .confirm: return 1.0
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Progress bar
                ProgressView(value: currentStep.progress)
                    .tint(BMOTheme.accent)
                    .padding(.horizontal)
                
                // Step title
                Text(currentStep.title)
                    .font(.title2.weight(.bold))
                    .foregroundColor(BMOTheme.textPrimary)
                    .padding(.top, 8)
                
                // Step content
                ScrollView {
                    stepContent
                        .padding()
                }
                
                Spacer()
                
                // Navigation buttons
                HStack(spacing: 16) {
                    if currentStep != .appearanceMode {
                        Button("Back") {
                            previousStep()
                        }
                        .buttonStyle(BMOButtonStyle(isPrimary: false))
                    }
                    
                    Spacer()
                    
                    let isNextEnabled = validateCurrentStep()
                    
                    Button(action: nextStep) {
                        HStack(spacing: 8) {
                            if isCreating {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text(currentStep == .confirm ? "Create Buddy" : "Next")
                            }
                        }
                    }
                    .buttonStyle(BMOButtonStyle(isPrimary: true))
                    .disabled(!isNextEnabled || isCreating)
                }
                .padding()
            }
            .background(BMOTheme.backgroundPrimary)
        }
        .alert("Error", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }
    
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case .appearanceMode:
            AppearanceModeStep(
                selectedMode: $selectedMode,
                onSelect: { mode in
                    selectedMode = mode
                }
            )
        case .chooseTemplate:
            TemplateSelectionStep(
                templates: appState.buddyStore.contracts?.templates ?? [],
                selectedTemplate: $selectedTemplate
            )
        case .nameBuddy:
            NameBuddyStep(
                displayName: $displayName,
                nickname: $nickname
            )
        case .customize:
            CustomizeStep(
                mode: selectedMode,
                selectedPalette: $selectedPalette,
                asciiVariant: $asciiVariant,
                pixelProjectRef: $pixelProjectRef,
                template: selectedTemplate
            )
        case .confirm:
            ConfirmStep(
                name: displayName,
                nickname: nickname,
                mode: selectedMode,
                palette: selectedPalette,
                templateIcon: selectedTemplate?.ascii.baseSilhouette ?? ""
            )
        }
    }
    
    private func validateCurrentStep() -> Bool {
        switch currentStep {
        case .appearanceMode:
            return true
        case .chooseTemplate:
            return selectedTemplate != nil
        case .nameBuddy:
            return !displayName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .customize:
            return true
        case .confirm:
            return true
        }
    }
    
    private func previousStep() {
        if let index = CreationStep.allCases.firstIndex(of: currentStep),
           index > 0 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentStep = CreationStep.allCases[index - 1]
            }
        }
    }
    
    private func nextStep() {
        if let index = CreationStep.allCases.firstIndex(of: currentStep),
           index < CreationStep.allCases.count - 1 {
            withAnimation(.easeInOut(duration: 0.2)) {
                currentStep = CreationStep.allCases[index + 1]
            }
        } else {
            createBuddy()
        }
    }
    
    private func createBuddy() {
        isCreating = true
        errorMessage = nil
        
        Task { @MainActor in
            do {
                guard let template = selectedTemplate else {
                    errorMessage = "No template selected"
                    isCreating = false
                    return
                }
                
                // Install the Buddy
                let receipt = try await appState.buddyStore.installFromCatalog(
                    templateID: template.templateID,
                    displayName: displayName,
                    nickname: nickname.nilIfBlank
                )
                
                if receipt.status == .failed {
                    errorMessage = receipt.error ?? "Failed to create buddy"
                    isCreating = false
                    return
                }
                
                // Customize appearance
                if let instanceId = receipt.output["instanceId"] {
                    var instance = appState.buddyStore.instances.first { $0.instanceId == instanceId }
                    if var inst = instance {
                        inst.identity.palette = selectedPalette
                        if selectedMode == .ascii {
                            inst.visual?.asciiVariantId = asciiVariant
                        }
                        appState.buddyStore.upsert(inst)
                    }
                }
                
                isCreating = false
                dismiss()
                
            } catch {
                errorMessage = error.localizedDescription
                isCreating = false
            }
        }
    }
}

enum BuddyAppearanceMode: String, CaseIterable {
    case ascii = "ASCII"
    case pixel = "Pixel Art"
    
    var icon: String {
        switch self {
        case .ascii: return "textformat.alt"
        case .pixel: return "square.grid.2x2"
        }
    }
    
    var description: String {
        switch self {
        case .ascii: return "Retro text-based character with expressions"
        case .pixel: return "Animated pixel art from Pixel Studio"
        }
    }
}

struct AppearanceModeStep: View {
    @Binding var selectedMode: BuddyAppearanceMode
    let onSelect: (BuddyAppearanceMode) -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Text("How should your Buddy look?")
                .font(.headline)
                .foregroundColor(BMOTheme.textSecondary)
            
            ForEach(BuddyAppearanceMode.allCases, id: \.self) { mode in
                Button {
                    selectedMode = mode
                    onSelect(mode)
                } label: {
                    HStack(spacing: 16) {
                        Image(systemName: mode.icon)
                            .font(.system(size: 32))
                            .frame(width: 60)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(mode.rawValue)
                                .font(.title3.weight(.semibold))
                            Text(mode.description)
                                .font(.caption)
                                .foregroundColor(BMOTheme.textSecondary)
                        }
                        
                        Spacer()
                        
                        if selectedMode == mode {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(BMOTheme.accent)
                                .font(.title3)
                        }
                    }
                    .padding()
                    .background(selectedMode == mode ? BMOTheme.accent.opacity(0.1) : BMOTheme.backgroundCard)
                    .cornerRadius(BMOTheme.radiusMedium)
                    .overlay(
                        RoundedRectangle(cornerRadius: BMOTheme.radiusMedium)
                            .stroke(selectedMode == mode ? BMOTheme.accent : BMOTheme.divider, lineWidth: 2)
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

struct TemplateSelectionStep: View {
    let templates: [CouncilStarterBuddyTemplate]
    @Binding var selectedTemplate: CouncilStarterBuddyTemplate?
    
    var body: some View {
        VStack(spacing: 16) {
            Text("Choose your Buddy's archetype")
                .font(.headline)
                .foregroundColor(BMOTheme.textSecondary)
            
            LazyVStack(spacing: 12) {
                ForEach(templates) { template in
                    Button {
                        selectedTemplate = template
                    } label: {
                        BuddyTemplateCard(
                            template: template,
                            isSelected: selectedTemplate?.id == template.id
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}

struct BuddyTemplateCard: View {
    let template: CouncilStarterBuddyTemplate
    let isSelected: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // ASCII Preview
            Text(template.ascii.baseSilhouette)
                .font(.system(size: 24, design: .monospaced))
                .frame(width: 60, height: 60)
                .background(BMOTheme.backgroundSecondary)
                .cornerRadius(8)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(template.name)
                    .font(.headline)
                
                Text(template.onboardingTitle)
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
                    .lineLimit(2)
                
                HStack(spacing: 8) {
                    Text("Focus: \(template.stats.focus)")
                    Text("Creativity: \(template.stats.creativity)")
                    Text("Memory: \(template.stats.memory)")
                }
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
            }
            
            Spacer()
            
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(BMOTheme.accent)
            }
        }
        .padding()
        .background(isSelected ? BMOTheme.accent.opacity(0.05) : BMOTheme.backgroundCard)
        .cornerRadius(BMOTheme.radiusMedium)
        .overlay(
            RoundedRectangle(cornerRadius: BMOTheme.radiusMedium)
                .stroke(isSelected ? BMOTheme.accent : BMOTheme.divider, lineWidth: isSelected ? 2 : 1)
        )
    }
}

struct NameBuddyStep: View {
    @Binding var displayName: String
    @Binding var nickname: String
    
    var body: some View {
        VStack(spacing: 20) {
            Text("What should we call your Buddy?")
                .font(.headline)
                .foregroundColor(BMOTheme.textSecondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Display Name")
                    .font(.subheadline.weight(.semibold))
                
                TextField("e.g. Hermes", text: $displayName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Nickname (optional)")
                    .font(.subheadline.weight(.semibold))
                
                TextField("e.g. Herm", text: $nickname)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .font(.body)
            }
            
            if !displayName.isEmpty {
                HStack {
                    Image(systemName: "quote.opening")
                    Text("Hello, I'm \(displayName)!")
                        .font(.subheadline.italic())
                    Image(systemName: "quote.closing")
                }
                .foregroundColor(BMOTheme.textSecondary)
                .padding()
                .background(BMOTheme.backgroundSecondary)
                .cornerRadius(8)
            }
        }
    }
}

struct CustomizeStep: View {
    let mode: BuddyAppearanceMode
    @Binding var selectedPalette: String
    @Binding var asciiVariant: String
    @Binding var pixelProjectRef: String?
    let template: CouncilStarterBuddyTemplate?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Make your Buddy unique")
                .font(.headline)
                .foregroundColor(BMOTheme.textSecondary)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Color Palette")
                    .font(.subheadline.weight(.semibold))
                
                HStack(spacing: 12) {
                    PaletteButton(color: "default", name: "Default", isSelected: selectedPalette == "default") {
                        selectedPalette = "default"
                    }
                    PaletteButton(color: "warm", name: "Warm", isSelected: selectedPalette == "warm") {
                        selectedPalette = "warm"
                    }
                    PaletteButton(color: "cool", name: "Cool", isSelected: selectedPalette == "cool") {
                        selectedPalette = "cool"
                    }
                    PaletteButton(color: "mono", name: "Mono", isSelected: selectedPalette == "mono") {
                        selectedPalette = "mono"
                    }
                }
            }
            
            if mode == .ascii {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Style Variant")
                        .font(.subheadline.weight(.semibold))
                    
                    HStack(spacing: 12) {
                        VariantButton(name: "Classic", isSelected: asciiVariant == "classic") {
                            asciiVariant = "classic"
                        }
                        VariantButton(name: "Bold", isSelected: asciiVariant == "bold") {
                            asciiVariant = "bold"
                        }
                        VariantButton(name: "Minimal", isSelected: asciiVariant == "minimal") {
                            asciiVariant = "minimal"
                        }
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Pixel Studio Project")
                        .font(.subheadline.weight(.semibold))
                    
                    Button {
                        // Open Pixel Studio project picker
                    } label: {
                        HStack {
                            Image(systemName: "square.grid.2x2")
                            Text(pixelProjectRef != nil ? "Project linked" : "Link a project")
                            Spacer()
                            Image(systemName: "chevron.right")
                        }
                        .padding()
                        .background(BMOTheme.backgroundCard)
                        .cornerRadius(BMOTheme.radiusMedium)
                    }
                    .buttonStyle(.plain)
                }
            }
            
            // Preview
            if let template = template {
                VStack(spacing: 8) {
                    Text("Preview")
                        .font(.caption.weight(.semibold))
                    
                    Text(template.ascii.baseSilhouette)
                        .font(.system(size: 48, design: .monospaced))
                        .padding()
                        .background(BMOTheme.backgroundSecondary)
                        .cornerRadius(12)
                }
            }
        }
    }
}

struct PaletteButton: View {
    let color: String
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Circle()
                    .fill(paletteColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Circle()
                            .stroke(isSelected ? BMOTheme.accent : Color.clear, lineWidth: 3)
                    )
                
                Text(name)
                    .font(.caption)
            }
        }
        .buttonStyle(.plain)
    }
    
    var paletteColor: Color {
        switch color {
        case "default": return .blue
        case "warm": return .orange
        case "cool": return .cyan
        case "mono": return .gray
        default: return .blue
        }
    }
}

struct VariantButton: View {
    let name: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(name)
                .font(.caption.weight(.semibold))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? BMOTheme.accent : BMOTheme.backgroundCard)
                .foregroundColor(isSelected ? .white : BMOTheme.textPrimary)
                .cornerRadius(BMOTheme.radiusSmall)
        }
        .buttonStyle(.plain)
    }
}

struct ConfirmStep: View {
    let name: String
    let nickname: String
    let mode: BuddyAppearanceMode
    let palette: String
    let templateIcon: String
    
    var body: some View {
        VStack(spacing: 24) {
            Text("Ready to meet your Buddy?")
                .font(.title3.weight(.bold))
            
            VStack(spacing: 16) {
                Text(templateIcon)
                    .font(.system(size: 80, design: .monospaced))
                    .padding()
                    .background(BMOTheme.backgroundSecondary)
                    .cornerRadius(16)
                
                Text(name)
                    .font(.title2.weight(.bold))
                
                if !nickname.isEmpty {
                    Text("\"\(nickname)\"")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                
                HStack(spacing: 16) {
                    Label(mode.rawValue, systemImage: mode.icon)
                        .font(.caption)
                    Label(palette.capitalized, systemImage: "paintpalette")
                        .font(.caption)
                }
                .foregroundColor(BMOTheme.textSecondary)
            }
            .padding()
            .background(BMOTheme.backgroundCard)
            .cornerRadius(BMOTheme.radiusLarge)
            
            Text("You can customize \(name) more after creation in the Buddy settings.")
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
                .multilineTextAlignment(.center)
        }
    }
}
