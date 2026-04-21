import SwiftUI

private enum StudioSurface: String, CaseIterable, Identifiable {
    case pixelStudio
    case builderStudio
    case missionControl
    case profiles
    case workspaceFile

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pixelStudio: return "Pixel"
        case .builderStudio: return "Builder"
        case .missionControl: return "Mission"
        case .profiles: return "Profiles"
        case .workspaceFile: return "Files"
        }
    }

    var route: BeMoreWebFeatureRoute? {
        switch self {
        case .pixelStudio: return .pixelStudio
        case .builderStudio: return .builderStudio
        case .missionControl: return .missionControl
        case .profiles: return .myAccount
        case .workspaceFile: return nil
        }
    }
}

struct EditorTabView: View {
    @EnvironmentObject private var appState: AppState
    @ObservedObject private var studioStore = PixelStudioStore.shared
    @State private var selectedSurface: StudioSurface = .pixelStudio
    @State private var lastReceipt: OpenClawReceipt?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
                    heroCard
                    projectBriefCard
                    buddyAssistCard
                    if let lastReceipt {
                        ActionReceiptCard(receipt: lastReceipt)
                    }
                    surfacesCard
                }
                .padding(.horizontal, BMOTheme.spacingMD)
                .padding(.bottom, BMOTheme.spacingXL)
            }
            .background(BMOTheme.backgroundPrimary)
            .navigationTitle("Studio")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private var heroCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Buddy Studio")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Pixel Studio, Builder Studio, admin Mission Control, and profile surfaces now live inside the iPhone app shell.")
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "Phone-first", color: BMOTheme.success)
            }

            Text("Ask Buddy in chat things like “finish this pixel art”, “improve this sprite”, or “animate this sprite”. Buddy will save a real project brief and a finish/improvement/animation artifact into Results.")
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .bmoCard()
    }

    private var projectBriefCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Active Pixel Project")
                    .font(.headline)
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                StatusBadge(label: "\(studioStore.project.canvasSize)x\(studioStore.project.canvasSize)", color: BMOTheme.accent)
            }

            labeledField("Project title", text: binding(\.title), placeholder: "Buddy Sprite")
            labeledField("Author", text: binding(\.author), placeholder: appState.operatorDisplayName)
            labeledField("Concept", text: binding(\.concept), placeholder: "A premium rival sprite with one readable accent")
            labeledField("Palette", text: binding(\.palette), placeholder: "#9EF0D0, #2B7A78, #17252A")
            labeledField("Polish goal", text: binding(\.polishGoal), placeholder: "Clean silhouette and make the accent more readable")
            labeledField("Animation goal", text: binding(\.animationGoal), placeholder: "Smooth idle loop with one anticipation beat")

            HStack(spacing: 12) {
                numberField(label: "Canvas", value: bindingInt(\.canvasSize), allowed: [16, 24, 32, 48, 64])
                numberField(label: "Frames", value: bindingInt(\.frameCount), allowed: [1, 2, 4, 6, 8])
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Notes")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textTertiary)
                TextEditor(text: binding(\.notes))
                    .frame(minHeight: 110)
                    .padding(8)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
            }

            if let summary = studioStore.project.lastBuddySummary {
                Text(summary)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
            if let artifact = studioStore.project.lastBuddyArtifact {
                Text("Latest Buddy artifact: \(artifact)")
                    .font(.caption2)
                    .foregroundColor(BMOTheme.accent)
            }
        }
        .bmoCard()
    }

    private var buddyAssistCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Buddy Pixel Copilot")
                    .font(.headline)
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                StatusBadge(label: appState.buddyStore.activeBuddy?.displayName ?? "Buddy", color: BMOTheme.success)
            }

            Text("These buttons use the same local Buddy artifact flow that chat now uses for pixel-art help.")
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)

            HStack(spacing: 8) {
                actionButton(.finish)
                actionButton(.improve)
                actionButton(.animate)
            }

            Button("Open Chat with Buddy") {
                appState.openChat(from: .editor)
            }
            .buttonStyle(BMOButtonStyle(isPrimary: false))
        }
        .bmoCard()
    }

    private var surfacesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Website Surfaces in App")
                    .font(.headline)
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                StatusBadge(label: selectedSurface.title, color: BMOTheme.accent)
            }

            Picker("Surface", selection: $selectedSurface) {
                ForEach(StudioSurface.allCases) { surface in
                    Text(surface.title).tag(surface)
                }
            }
            .pickerStyle(.segmented)

            Text(surfaceSummary)
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)

            Group {
                switch selectedSurface {
                case .workspaceFile:
                    workspaceFileSurface
                default:
                    webSurface
                }
            }
            .frame(minHeight: 520)
            .background(BMOTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
        }
        .bmoCard()
    }

    private var webSurface: some View {
        Group {
            if let route = selectedSurface.route,
               let url = route.resolvedURL(stackConfig: appState.stackConfig) {
                BeMoreWebShellView(url: url)
            } else {
                ContentUnavailableView("Surface unavailable", systemImage: "globe")
            }
        }
    }

    private var workspaceFileSurface: some View {
        Group {
            if let file = appState.workspaceStore.selectedFile {
                if file.isTextLike {
                    EditorWebView(file: file)
                        .environmentObject(appState)
                } else {
                    ContentUnavailableView("Not a text file", systemImage: "doc", description: Text("Pick a text-like file from Workspace to edit it here."))
                }
            } else {
                ContentUnavailableView("No workspace file selected", systemImage: "chevron.left.forwardslash.chevron.right", description: Text("Pick a file in Workspace first, or stay on Pixel / Builder / Mission / Profiles."))
            }
        }
    }

    private var surfaceSummary: String {
        switch selectedSurface {
        case .workspaceFile:
            return "Local file editing still lives here too, so Studio remains the place for both the native pixel-art workflow and workspace drafting."
        default:
            return selectedSurface.route?.summary ?? "Studio surface"
        }
    }

    private func actionButton(_ action: PixelBuddyAction) -> some View {
        Button {
            lastReceipt = appState.runPixelStudioBuddyAction(action)
        } label: {
            HStack {
                Image(systemName: action.systemImage)
                Text(action.title)
            }
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(BMOButtonStyle(isPrimary: action == .finish))
    }

    private func binding(_ keyPath: WritableKeyPath<PixelStudioProject, String>) -> Binding<String> {
        Binding(
            get: { studioStore.project[keyPath: keyPath] },
            set: { newValue in
                studioStore.update { $0[keyPath: keyPath] = newValue }
            }
        )
    }

    private func bindingInt(_ keyPath: WritableKeyPath<PixelStudioProject, Int>) -> Binding<Int> {
        Binding(
            get: { studioStore.project[keyPath: keyPath] },
            set: { newValue in
                studioStore.update { $0[keyPath: keyPath] = newValue }
            }
        )
    }

    private func labeledField(_ label: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .foregroundColor(BMOTheme.textPrimary)
                .padding(12)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
        }
    }

    private func numberField(label: String, value: Binding<Int>, allowed: [Int]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
            Picker(label, selection: value) {
                ForEach(allowed, id: \.self) { item in
                    Text("\(item)").tag(item)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}
