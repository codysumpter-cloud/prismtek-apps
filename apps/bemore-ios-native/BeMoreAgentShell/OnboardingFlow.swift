import SwiftUI

enum OnboardingStep: Int, CaseIterable {
    case welcome
    case chooseBuddy
    case nameBuddy
    case focusBuddy
    case appearanceBuddy
    case powerMode
    case building
    case summary
}

struct OnboardingFlow: View {
    @EnvironmentObject private var appState: AppState
    @StateObject private var buddyStore = BuddyProfileStore()
    @State private var step: OnboardingStep = .welcome
    @State private var config = StackConfig.default
    @State private var selectedTemplateID = ""
    @State private var buddyName = ""
    @State private var buddyFocus = ""
    @State private var appearanceDraft = BuddyAppearanceEditorDraft()
    @State private var selectedPowerMode: BuddyPowerMode = .balanced
    @State private var showAdvancedSetup = false
    @State private var buildProgress: Double = 0
    @State private var buildMessages: [String] = []

    var body: some View {
        ZStack {
            BMOTheme.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                if step != .welcome && step != .building {
                    progressBar
                        .padding(.horizontal, BMOTheme.spacingLG)
                        .padding(.top, BMOTheme.spacingMD)
                }

                Group {
                    switch step {
                    case .welcome: welcomeScreen
                    case .chooseBuddy: chooseBuddyScreen
                    case .nameBuddy: nameBuddyScreen
                    case .focusBuddy: focusBuddyScreen
                    case .appearanceBuddy: appearanceBuddyScreen
                    case .powerMode: powerModeScreen
                    case .building: buildingScreen
                    case .summary: summaryScreen
                    }
                }
                .transition(.asymmetric(
                    insertion: .move(edge: .trailing).combined(with: .opacity),
                    removal: .move(edge: .leading).combined(with: .opacity)
                ))
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            config = appState.stackConfig
            buddyStore.load(for: appState.stackConfig)
            appState.buddyStore.load(for: appState.stackConfig)
            if selectedTemplateID.isEmpty {
                selectedTemplateID = config.onboardingBuddyTemplateID ?? buddyStore.templates.first?.templateID ?? ""
            }
            if buddyName.isEmpty {
                buddyName = config.onboardingBuddyName ?? "Buddy"
            }
            if buddyFocus.isEmpty {
                buddyFocus = config.onboardingBuddyFocus ?? "Help me decide what matters and finish the next useful step."
            }
            selectedPowerMode = config.onboardingPowerMode ?? .balanced
            configureAppearanceDraftFromState()
        }
        .onChange(of: selectedTemplateID) { _, _ in
            configureAppearanceDraftFromState(keepExistingIfCustomized: true)
        }
    }

    private var progressBar: some View {
        let total = OnboardingStep.allCases.count - 2
        let current = max(0, step.rawValue - 1)
        return GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(BMOTheme.divider)
                    .frame(height: 4)
                Capsule()
                    .fill(BMOTheme.accent)
                    .frame(width: geo.size.width * CGFloat(current) / CGFloat(max(1, total - 1)), height: 4)
            }
        }
        .frame(height: 4)
    }

    private var welcomeScreen: some View {
        VStack(spacing: BMOTheme.spacingLG) {
            Spacer()

            BuddyAsciiView(mood: .happy)
                .padding(.horizontal, BMOTheme.spacingXL)

            Text("Welcome to BeMore")
                .font(.system(size: 36, weight: .bold))
                .foregroundColor(BMOTheme.textPrimary)
                .multilineTextAlignment(.center)

            Text("Start with a Buddy you can name, customize, teach, and use for real daily help. Deeper setup can wait until you need it.")
                .font(.body)
                .foregroundColor(BMOTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, BMOTheme.spacingXL)

            VStack(alignment: .leading, spacing: 10) {
                featureRow("Choose the Buddy who will help with your day, follow-through, and routines")
                featureRow("Name them, set their first focus, and customize how they look before you land on Buddy Home")
                featureRow("Teach preferences, grow them through care and training, and add deeper operator power only when you want it")
            }
            .padding(.horizontal, BMOTheme.spacingXL)

            Spacer()

            Button("Create my Buddy") {
                withAnimation(.easeInOut(duration: 0.35)) {
                    step = .chooseBuddy
                }
            }
            .buttonStyle(BMOButtonStyle())

            Spacer().frame(height: BMOTheme.spacingXL)
        }
    }

    private var chooseBuddyScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BMOTheme.spacingLG) {
                Spacer().frame(height: BMOTheme.spacingXL)

                onboardingTitle("Choose your first Buddy", subtitle: "Pick a starter archetype. You can own more Buddies later, but this one becomes your active companion now.")

                if buddyStore.templates.isEmpty {
                    Text("Buddy templates are still loading. Continue and BeMore will use the default Buddy when it is ready.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                        .bmoCard()
                        .padding(.horizontal, BMOTheme.spacingLG)
                } else {
                    VStack(spacing: 12) {
                        ForEach(buddyStore.templates) { template in
                            buddyTemplateButton(template)
                        }
                    }
                    .padding(.horizontal, BMOTheme.spacingLG)
                }

                navButtons(back: .welcome, next: .nameBuddy, canProceed: !selectedTemplateID.isEmpty || buddyStore.templates.isEmpty)
                    .padding(.top, BMOTheme.spacingMD)
            }
        }
    }

    private var nameBuddyScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BMOTheme.spacingLG) {
                Spacer().frame(height: BMOTheme.spacingXL)
                onboardingTitle("Name your Buddy", subtitle: "Give your companion the name you want to see in plans, chats, tasks, and training.")
                labeledField(title: "Buddy name", text: $buddyName, placeholder: selectedTemplate?.name ?? "Buddy")
                selectedBuddyPreview
                navButtons(back: .chooseBuddy, next: .focusBuddy, canProceed: !trimmed(buddyName).isEmpty)
                    .padding(.top, BMOTheme.spacingMD)
            }
        }
    }

    private var focusBuddyScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BMOTheme.spacingLG) {
                Spacer().frame(height: BMOTheme.spacingXL)
                onboardingTitle("Pick your Buddy's first focus", subtitle: "Choose the first kind of help you want Buddy to practice. You can change it later.")
                labeledField(title: "First focus", text: $buddyFocus, placeholder: selectedTemplate?.canonicalRole ?? "Help me finish the next useful step")
                VStack(alignment: .leading, spacing: 10) {
                    Text("How this will show up")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("\(fallback(buddyName, defaultValue: selectedTemplate?.name ?? "Buddy")) will use this focus on Home, in Chat, and in the first check-ins so the experience starts personal.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                .bmoCard()
                .padding(.horizontal, BMOTheme.spacingLG)
                navButtons(back: .nameBuddy, next: .appearanceBuddy, canProceed: !trimmed(buddyFocus).isEmpty)
                    .padding(.top, BMOTheme.spacingMD)
            }
        }
    }

    private var appearanceBuddyScreen: some View {
        NavigationStack {
            BuddyAppearanceEditorView(
                draft: $appearanceDraft,
                availablePalettes: availablePalettes,
                availableArchetypes: availableArchetypes,
                asciiVariantOptions: asciiVariantOptions,
                expressionToneOptions: expressionToneOptions,
                pixelLabLinked: appState.linkedAccountStore.record(for: .pixelLab).isLinked,
                onPixelLabLink: {
                    appState.linkedAccountStore.markPending(.pixelLab)
                }
            ) {
                VStack(alignment: .leading, spacing: 12) {
                    onboardingTitle("Choose your Buddy's first look", subtitle: "This is part of onboarding now. Start with ASCII or pixel mode, then keep evolving the Buddy later.")
                    Group {
                        if appearanceDraft.renderStyle == .pixel {
                            BuddyPixelView(template: selectedTemplate, mood: .happy, compact: true)
                        } else {
                            BuddyAsciiView(template: selectedTemplate, mood: .happy, compact: true)
                        }
                    }
                    Text("Render style: \(appearanceDraft.renderStyle.title) • Palette: \(paletteLabel(for: appearanceDraft.palette))")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                        .padding(.horizontal, BMOTheme.spacingSM)
                }
            }
            .navigationTitle("Buddy Appearance")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    navButtons(back: .focusBuddy, next: .powerMode, canProceed: !trimmed(appearanceDraft.profileName).isEmpty)
                }
            }
        }
    }

    private var powerModeScreen: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BMOTheme.spacingLG) {
                Spacer().frame(height: BMOTheme.spacingXL)
                onboardingTitle("Mode choice is optional", subtitle: "Begin in companion mode on iPhone. Care, customization, training, collection, sparring, and trade packages work before any operator setup.")

                VStack(spacing: 12) {
                    ForEach(BuddyPowerMode.allCases) { mode in
                        Button {
                            selectedPowerMode = mode
                        } label: {
                            HStack(alignment: .top, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mode.title)
                                        .font(.headline)
                                    Text(mode.subtitle)
                                        .font(.subheadline)
                                        .foregroundColor(BMOTheme.textSecondary)
                                }
                                Spacer()
                                if selectedPowerMode == mode {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(BMOTheme.accent)
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .foregroundColor(BMOTheme.textPrimary)
                            .background(selectedPowerMode == mode ? BMOTheme.backgroundCardHover : BMOTheme.backgroundCard)
                            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
                        }
                    }
                }
                .padding(.horizontal, BMOTheme.spacingLG)

                toggleCard(icon: "macbook.and.iphone", title: "Pair with Mac later", subtitle: "Keep deeper operator tools available after you land on Buddy Home.", isOn: $config.installDesktopNode)
                    .padding(.horizontal, BMOTheme.spacingLG)
                toggleCard(icon: "bell.badge", title: "Buddy notifications", subtitle: "Allow BeMore to remind you about Buddy tasks, results, and check-ins when enabled.", isOn: $config.enableNotifications)
                    .padding(.horizontal, BMOTheme.spacingLG)

                DisclosureGroup(isExpanded: $showAdvancedSetup) {
                    VStack(spacing: BMOTheme.spacingMD) {
                        labeledField(title: "Runtime endpoint", text: $config.gatewayURL, placeholder: "https://bemore.example.com")
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        labeledField(title: "Public domain", text: $config.adminDomain, placeholder: "example.com")
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                        toggleCard(icon: "wrench.and.screwdriver", title: "Operator tools", subtitle: "Allow technical actions when the connected runtime supports and confirms them.", isOn: $config.toolsEnabled)
                        toggleCard(icon: "brain", title: "Memory", subtitle: "Let Buddy keep local preferences, routines, and useful context on this device.", isOn: $config.memoryEnabled)
                    }
                    .padding(.top, BMOTheme.spacingMD)
                } label: {
                    Text("Advanced operator setup")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                }
                .padding(BMOTheme.spacingMD)
                .background(BMOTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
                .padding(.horizontal, BMOTheme.spacingLG)

                navButtons(back: .appearanceBuddy, next: .building, canProceed: true)
                    .padding(.top, BMOTheme.spacingMD)
            }
        }
    }

    private var buildingScreen: some View {
        VStack(spacing: BMOTheme.spacingLG) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(BMOTheme.divider, lineWidth: 4)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: buildProgress)
                    .stroke(BMOTheme.accent, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                Image(systemName: "heart.text.square.fill")
                    .font(.system(size: 36))
                    .foregroundColor(BMOTheme.accent)
            }

            Text("Waking \(buddyName)")
                .font(.system(size: 24, weight: .bold))
                .foregroundColor(BMOTheme.textPrimary)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(buildMessages, id: \.self) { msg in
                    HStack(spacing: 8) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.caption)
                            .foregroundColor(BMOTheme.success)
                        Text(msg)
                            .font(.subheadline)
                            .foregroundColor(BMOTheme.textSecondary)
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, BMOTheme.spacingXL)

            Spacer()
        }
        .onAppear { runBuildSequence() }
    }

    private var summaryScreen: some View {
        ScrollView {
            VStack(spacing: BMOTheme.spacingLG) {
                Spacer().frame(height: BMOTheme.spacingXL)

                if appearanceDraft.renderStyle == .pixel {
                    BuddyPixelView(template: selectedTemplate, mood: .levelUp)
                        .padding(.horizontal, BMOTheme.spacingXL)
                } else {
                    BuddyAsciiView(mood: .levelUp)
                        .padding(.horizontal, BMOTheme.spacingXL)
                }

                Text("\(buddyName) is ready")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(BMOTheme.textPrimary)

                Text("You’ll land on Buddy Home with your chosen look already active. Chat, results, and optional operator power all point back to this active Buddy.")
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BMOTheme.spacingLG)

                VStack(spacing: 12) {
                    summaryRow(icon: "person.crop.circle.badge.checkmark", label: "Active Buddy", value: buddyName)
                    summaryRow(icon: "sparkles", label: "Starter", value: selectedTemplate?.name ?? "Default Buddy")
                    summaryRow(icon: "scope", label: "Focus", value: buddyFocus)
                    summaryRow(icon: "paintpalette", label: "Appearance", value: "\(appearanceDraft.renderStyle.title) • \(appearanceDraft.profileName)")
                    summaryRow(icon: "dial.high", label: "Power mode", value: selectedPowerMode.title)
                    summaryRow(icon: "macbook.and.iphone", label: "Mac power", value: config.installDesktopNode ? "Available later" : "Phone-first")
                }
                .bmoCard()
                .padding(.horizontal, BMOTheme.spacingLG)

                Button("Go to Buddy Home") {
                    finishOnboarding()
                }
                .buttonStyle(BMOButtonStyle())
                .padding(.top, BMOTheme.spacingMD)

                Spacer().frame(height: BMOTheme.spacingXL)
            }
        }
    }

    private func runBuildSequence() {
        buildProgress = 0
        buildMessages = []
        let name = fallback(buddyName, defaultValue: selectedTemplate?.name ?? "Buddy")
        let steps = [
            (0.25, "Creating \(name) as your active Buddy"),
            (0.50, "Applying the \(appearanceDraft.profileName) appearance"),
            (0.75, config.installDesktopNode ? "Keeping deeper Mac operator tools available for later" : "Starting in phone-first companion mode"),
            (1.0, "Preparing your Buddy-first BeMore shell")
        ]
        for (index, (progress, message)) in steps.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.5) {
                withAnimation(.easeOut(duration: 0.35)) {
                    buildProgress = progress
                    buildMessages.append(message)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps.count) * 0.5 + 0.4) {
            withAnimation(.easeInOut(duration: 0.35)) {
                step = .summary
            }
        }
    }

    private func finishOnboarding() {
        let cleanedBuddyName = fallback(buddyName, defaultValue: selectedTemplate?.name ?? "Buddy")
        let cleanedFocus = fallback(buddyFocus, defaultValue: selectedTemplate?.canonicalRole ?? "Finish the next useful step")
        let templateID = selectedTemplate?.templateID ?? selectedTemplateID

        config.stackName = fallback(config.stackName, defaultValue: "BeMore")
        config.goal = cleanedFocus
        config.role = selectedTemplate?.canonicalRole ?? "Buddy companion"
        config.operatorName = fallback(config.operatorName, defaultValue: "Builder")
        config.gatewayURL = fallback(config.gatewayURL, defaultValue: "https://prismtek.dev")
        config.adminDomain = fallback(config.adminDomain, defaultValue: "prismtek.dev")
        config.onboardingBuddyName = cleanedBuddyName
        config.onboardingBuddyTemplateID = templateID
        config.onboardingBuddyFocus = cleanedFocus
        config.onboardingPowerMode = selectedPowerMode
        config.onboardingAppearanceProfileName = appearanceDraft.profileName
        config.onboardingAppearanceArchetype = appearanceDraft.archetype
        config.onboardingAppearancePalette = appearanceDraft.palette
        config.onboardingAppearanceASCIIVariantID = appearanceDraft.asciiVariantID
        config.onboardingAppearanceExpressionTone = appearanceDraft.expressionTone
        config.onboardingAppearanceAccentLabel = appearanceDraft.accentLabel
        config.onboardingAppearanceRenderStyle = appearanceDraft.renderStyle
        config.onboardingAppearancePixelVariantID = appearanceDraft.renderStyle == .pixel ? appearanceDraft.pixelVariantID : nil
        config.optimizationMode = selectedPowerMode.optimizationMode
        config.setupChecklist = generatedChecklist
        config.isOnboardingComplete = true
        appState.completeOnboarding(config)
        appState.buddyStore.ensureStarterBuddy(templateID: templateID, displayName: cleanedBuddyName, focus: cleanedFocus, using: appState)
        appState.buddyStore.saveAppearanceProfile(
            profileName: appearanceDraft.profileName,
            archetype: appearanceDraft.archetype,
            palette: appearanceDraft.palette,
            asciiVariantID: appearanceDraft.asciiVariantID,
            pixelVariantID: appearanceDraft.renderStyle == .pixel ? appearanceDraft.pixelVariantID : nil,
            expressionTone: appearanceDraft.expressionTone,
            accentLabel: appearanceDraft.accentLabel,
            setActive: true,
            using: appState
        )
        appState.selectedTab = .missionControl
    }

    private var selectedTemplate: CouncilStarterBuddyTemplate? {
        buddyStore.templates.first(where: { $0.templateID == selectedTemplateID || $0.id == selectedTemplateID }) ?? buddyStore.templates.first
    }

    private var selectedBuddyPreview: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Your active Buddy")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text(selectedTemplate?.ascii.baseSilhouette ?? "    /\\\n  < o  o >\n  /|  v |\\\n /_|____|_\\")
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(BMOTheme.accent)
            Text("\(fallback(buddyName, defaultValue: selectedTemplate?.name ?? "Buddy")) will become the Buddy shown on Home and in Chat.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .bmoCard()
        .padding(.horizontal, BMOTheme.spacingLG)
    }

    private func buddyTemplateButton(_ template: CouncilStarterBuddyTemplate) -> some View {
        Button {
            selectedTemplateID = template.templateID
            if buddyName == "Buddy" || buddyName.isEmpty {
                buddyName = template.name
            }
            if buddyFocus.isEmpty {
                buddyFocus = template.canonicalRole
            }
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.name)
                            .font(.headline)
                        Text(template.starterRole)
                            .font(.subheadline)
                            .foregroundColor(BMOTheme.textSecondary)
                    }
                    Spacer()
                    if selectedTemplateID == template.templateID {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(BMOTheme.accent)
                    }
                }
                Text(template.onboardingCopy)
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
                Text(template.ascii.baseSilhouette)
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(BMOTheme.accent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .foregroundColor(BMOTheme.textPrimary)
            .background(selectedTemplateID == template.templateID ? BMOTheme.backgroundCardHover : BMOTheme.backgroundCard)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
        }
    }

    private func onboardingTitle(_ title: String, subtitle: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(BMOTheme.textPrimary)
            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .padding(.horizontal, BMOTheme.spacingLG)
    }

    @ViewBuilder
    private func labeledField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            TextField(placeholder, text: text, axis: title == "First focus" ? .vertical : .horizontal)
                .textFieldStyle(.plain)
                .padding()
                .background(BMOTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
                .foregroundColor(BMOTheme.textPrimary)
        }
        .padding(.horizontal, BMOTheme.spacingLG)
    }

    private func toggleCard(icon: String, title: String, subtitle: String, isOn: Binding<Bool>) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Image(systemName: icon)
                        .foregroundColor(BMOTheme.accent)
                    Text(title)
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                }
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
            Spacer()
            Toggle("", isOn: isOn)
                .tint(BMOTheme.accent)
                .labelsHidden()
        }
        .bmoCard()
    }

    private func navButtons(back: OnboardingStep?, next: OnboardingStep, canProceed: Bool) -> some View {
        HStack {
            if let back {
                Button {
                    withAnimation(.easeInOut(duration: 0.35)) { step = back }
                } label: {
                    Image(systemName: "arrow.left")
                        .foregroundColor(BMOTheme.textSecondary)
                        .frame(width: 48, height: 48)
                        .background(BMOTheme.backgroundCard)
                        .clipShape(Circle())
                }
            }

            Spacer()

            Button(next == .building ? "Start BeMore" : "Continue") {
                withAnimation(.easeInOut(duration: 0.35)) { step = next }
            }
            .buttonStyle(BMOButtonStyle())
            .disabled(!canProceed)
            .opacity(canProceed ? 1.0 : 0.4)
        }
        .padding(.horizontal, BMOTheme.spacingLG)
        .padding(.bottom, BMOTheme.spacingLG)
    }

    private func featureRow(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(BMOTheme.success)
                .padding(.top, 1)
            Text(text)
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
        }
    }

    private func summaryRow(icon: String, label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Image(systemName: icon)
                .frame(width: 24)
                .foregroundColor(BMOTheme.accent)
            Text(label)
                .foregroundColor(BMOTheme.textSecondary)
            Spacer()
            Text(value.isEmpty ? "Not set" : value)
                .fontWeight(.medium)
                .multilineTextAlignment(.trailing)
                .foregroundColor(BMOTheme.textPrimary)
        }
    }

    private var generatedChecklist: [String] {
        var items = ["Keep \(fallback(buddyName, defaultValue: selectedTemplate?.name ?? "Buddy")) active on Home, Chat, and Results."]
        items.append("Start in \(selectedPowerMode.title.lowercased()) so the first-run shell matches your comfort level.")
        items.append("Land with the \(appearanceDraft.profileName) look already active.")
        if config.installDesktopNode {
            items.append("Pair BeMore Mac when you want repo work, debugging, workspace actions, and deeper verification from your desktop.")
        }
        if config.toolsEnabled {
            items.append("Enable only the operator tools you want Buddy to use after the connected runtime confirms support.")
        }
        return items
    }

    private var availablePalettes: [BuddyPaletteOption] {
        buddyStore.contracts?.creationOptions.options.palettes ?? []
    }

    private var availableArchetypes: [BuddyArchetypeOption] {
        buddyStore.contracts?.creationOptions.options.archetypes ?? []
    }

    private var asciiVariantOptions: [BuddyChoiceOption] {
        [
            BuddyChoiceOption(id: "starter_a", label: "Classic", description: "Default Buddy shell look."),
            BuddyChoiceOption(id: "starter_b", label: "Soft", description: "Rounded expression and antenna accent."),
            BuddyChoiceOption(id: "starter_c", label: "Bold", description: "Sharper framing for a stronger look.")
        ]
    }

    private var expressionToneOptions: [BuddyChoiceOption] {
        [
            BuddyChoiceOption(id: "friendly", label: "Friendly", description: "Soft and welcoming"),
            BuddyChoiceOption(id: "curious", label: "Curious", description: "Question-forward and bright"),
            BuddyChoiceOption(id: "focused", label: "Focused", description: "Sharper and more task-ready")
        ]
    }

    private func paletteLabel(for paletteID: String) -> String {
        availablePalettes.first(where: { $0.id == paletteID })?.label ?? paletteID
    }

    private func configureAppearanceDraftFromState(keepExistingIfCustomized: Bool = false) {
        let defaultPalette = selectedTemplate.map { CouncilBuddyIdentityCatalog.identity(for: $0).palette } ?? config.onboardingAppearancePalette ?? "mint_cream"
        let defaultArchetype = selectedTemplate.map { CouncilBuddyIdentityCatalog.identity(for: $0).archetype } ?? config.onboardingAppearanceArchetype ?? "console_pet"
        let defaultASCII = config.onboardingAppearanceASCIIVariantID ?? buddyStore.contracts?.creationOptions.defaults.asciiVariant ?? "starter_a"

        if keepExistingIfCustomized, appearanceDraft.profileName != "Everyday Look" {
            return
        }

        appearanceDraft = BuddyAppearanceEditorDraft(
            profileName: config.onboardingAppearanceProfileName ?? "Everyday Look",
            archetype: defaultArchetype,
            palette: defaultPalette,
            asciiVariantID: defaultASCII,
            expressionTone: config.onboardingAppearanceExpressionTone ?? "friendly",
            accentLabel: config.onboardingAppearanceAccentLabel ?? "pocket glow",
            renderStyle: config.onboardingAppearanceRenderStyle ?? .ascii,
            pixelVariantID: config.onboardingAppearancePixelVariantID ?? "pixellab-classic"
        )
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private func fallback(_ value: String, defaultValue: String) -> String {
        let cleaned = trimmed(value)
        return cleaned.isEmpty ? defaultValue : cleaned
    }
}
