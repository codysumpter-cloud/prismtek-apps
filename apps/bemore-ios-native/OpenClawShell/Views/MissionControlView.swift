import SwiftUI

struct MissionControlView: View {
    @EnvironmentObject private var appState: AppState
    @ObservedObject var store: BuddyProfileStore
    @State private var selectedSurface: RepoSurface?
    @State private var lastReceipt: OpenClawReceipt?
    @State private var sandboxCommand = "ls"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BMOTheme.spacingMD) {
                    buddyHomeCard
                    primaryFlowCard
                    if let lastReceipt {
                        ActionReceiptCard(receipt: lastReceipt)
                    }
                    taskAndResultsCard
                    skillsCard
                    macPowerCard
                }
                .padding(.horizontal, BMOTheme.spacingMD)
                .padding(.bottom, BMOTheme.spacingXL)
            }
            .background(BMOTheme.backgroundPrimary)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Buddy Home")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                }
            }
            .toolbarBackground(BMOTheme.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .sheet(item: $selectedSurface) { surface in
                RepoSurfaceDetailView(surface: surface)
            }
            .onAppear {
                appState.workspaceRuntime.refreshMetadata()
                store.load(for: appState.stackConfig)
            }
        }
    }

    private var buddyHomeCard: some View {
        let buddy = store.activeBuddy
        return VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("My Buddy")
                        .font(.caption.weight(.semibold))
                        .foregroundColor(BMOTheme.textTertiary)
                    Text(buddy?.displayName ?? "Choose your Buddy")
                        .font(.system(size: 30, weight: .bold))
                        .foregroundColor(BMOTheme.textPrimary)
                    Text(homeSubtitle(for: buddy))
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: buddy == nil ? "Needs Buddy" : "Phone-first", color: buddy == nil ? BMOTheme.warning : BMOTheme.success)
            }

            BuddyAsciiView(
                buddy: buddy,
                template: buddy.flatMap { store.contracts?.templateForInstance($0) },
                mood: buddyMood(for: appState.buddyRuntimeStatus, buddy: buddy)
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                dashboardMetric("Owned", value: "\(store.installedBuddies.count)", icon: "person.2.fill")
                dashboardMetric("Battles", value: "\(store.battleHistory.count)", icon: "shield.lefthalf.filled")
                dashboardMetric("Trades", value: "\(store.tradeHistory.count)", icon: "arrow.triangle.swap")
                dashboardMetric("Bond", value: "\(buddy?.progression.bond ?? 0)", icon: "heart.fill")
            }
        }
        .bmoCard()
    }

    private var primaryFlowCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Start with what works here")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("Care for Buddy, train them, grow a roster, spar, trade packages, and open Studio/Admin surfaces on iPhone. Runtime setup stays secondary until you explicitly want more power.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)

            HStack(spacing: 8) {
                Button("Care & Train") {
                    appState.route(to: .buddy)
                }
                .buttonStyle(BMOButtonStyle())

                Button("Chat with \(store.activeBuddy?.displayName ?? "Buddy")") {
                    appState.openChat(from: .missionControl)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }

            HStack(spacing: 8) {
                Button("Battle & Trade") {
                    appState.route(to: .buddy)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))

                Button("Collect") {
                    appState.route(to: .buddy)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }

            HStack(spacing: 8) {
                Button("Open Studio") {
                    appState.route(to: .editor)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))

                Button("Admin & Profiles") {
                    appState.route(to: .editor)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
        .bmoCard()
    }

    private var taskAndResultsCard: some View {
        let status = appState.buddyRuntimeStatus
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Operator depth")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Repo, runtime, and sandbox controls still exist, but they are no longer the reason the app matters.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "\(status.failedActions.count) blocked", color: status.failedActions.isEmpty ? BMOTheme.success : BMOTheme.warning)
            }

            HStack(spacing: 8) {
                TextField("Sandbox command", text: $sandboxCommand)
                    .textFieldStyle(.plain)
                    .foregroundColor(BMOTheme.textPrimary)
                    .padding(10)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                Button("Run") {
                    lastReceipt = appState.runSandbox(command: sandboxCommand)
                }
                .buttonStyle(BMOButtonStyle())
            }

            if status.recentChanges.isEmpty {
                Text("No recent operator actions. Buddy care, training, battles, Studio work, and trade packages work entirely without them.")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textTertiary)
            } else {
                ForEach(Array(status.recentChanges.prefix(3)), id: \.id) { event in
                    detailRow(event.type, value: event.message)
                }
            }
        }
        .bmoCard()
    }

    private var skillsCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Optional skill power")
                    .font(.headline)
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                StatusBadge(label: "\(appState.workspaceRuntime.skills.count) registered", color: BMOTheme.accent)
            }
            Text("Skills can deepen the app later, but Buddy already has a strong self-contained loop before any runtime-backed skill run.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
            Button("Open Skills") {
                appState.route(to: .skills)
            }
            .buttonStyle(BMOButtonStyle(isPrimary: false))
        }
        .bmoCard()
    }

    private var macPowerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Mac power mode later")
                    .font(.headline)
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                StatusBadge(label: appState.macRuntimeSnapshot == nil ? "Not paired" : "Paired", color: appState.macRuntimeSnapshot == nil ? BMOTheme.warning : BMOTheme.success)
            }
            Text("Pairing with a Mac adds operator depth, but it is optional. The iPhone app should already be worth checking even with no external connection.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
            Button("Inspect Mac runtime") {
                Task { await appState.refreshMacRuntimeSnapshot() }
            }
            .buttonStyle(BMOButtonStyle(isPrimary: false))
        }
        .bmoCard()
    }

    private var stackSurfacesCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reference surfaces")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text("Repo briefs stay available as supporting context, but Buddy Home is now the product center.")
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)

            ForEach(RepoSurface.allCases) { surface in
                Button {
                    selectedSurface = surface
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(surface.title)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(BMOTheme.textPrimary)
                            Text(surface.summary)
                                .font(.caption)
                                .multilineTextAlignment(.leading)
                                .foregroundColor(BMOTheme.textSecondary)
                        }

                        Spacer()

                        VStack(alignment: .trailing, spacing: 8) {
                            StatusBadge(label: surface.statusLabel, color: surface.statusColor)
                            Text("Open brief")
                                .font(.caption2)
                                .foregroundColor(BMOTheme.accent)
                        }
                    }
                    .padding(12)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                }
                .buttonStyle(.plain)
            }
        }
        .bmoCard()
    }

    private func buddyMood(for status: BuddyRuntimeStatus, buddy: BuddyInstance?) -> BuddyAnimationMood {
        if let buddy {
            switch buddy.state.mood.lowercased() {
            case "happy", "excited":
                return .happy
            case "working":
                return .working
            case "thinking":
                return .thinking
            case "sleepy", "tired":
                return .sleepy
            case "needsattention", "needs attention", "stressed":
                return .needsAttention
            default:
                break
            }
        }
        if !status.failedActions.isEmpty { return .needsAttention }
        if appState.macRuntimeSnapshot?.processes.contains(where: { $0.status == "running" }) == true { return .working }
        if status.recentChanges.isEmpty && appState.workspaceStore.files.isEmpty { return .sleepy }
        if !status.recentChanges.isEmpty { return .happy }
        return status.runtimeAvailable ? .idle : .thinking
    }

    private func homeSubtitle(for buddy: BuddyInstance?) -> String {
        guard let buddy else {
            return "Create or install a Buddy before setup details take over the product."
        }
        let focus = buddy.state.currentFocus ?? "ready for the next useful step"
        return "\(buddy.identity.role) • \(focus)"
    }

    private func detailRow(_ label: String, value: String) -> some View {
        HStack(alignment: .top) {
            Text(label)
                .foregroundColor(BMOTheme.textTertiary)
            Spacer()
            Text(value)
                .multilineTextAlignment(.trailing)
                .foregroundColor(BMOTheme.textPrimary)
        }
        .font(.caption)
    }

    private func dashboardMetric(_ label: String, value: String, icon: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(BMOTheme.accent)
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(BMOTheme.textTertiary)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BMOTheme.textPrimary)
            }
            Spacer()
        }
        .padding(10)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
    }
}
