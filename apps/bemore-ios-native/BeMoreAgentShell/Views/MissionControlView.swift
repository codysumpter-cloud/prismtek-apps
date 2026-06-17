import SwiftUI

struct MissionControlView: View {
    @EnvironmentObject private var appState: AppState
    @ObservedObject var store: BuddyProfileStore
    @State private var selectedSurface: RepoSurface?
    @State private var lastReceipt: BeMoreReceipt?
    @State private var sandboxCommand = "ls"

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BMOTheme.spacingMD) {
                    buddyHomeCard
                    primaryFlowCard
                    buddySymphonyCard
                    if let lastReceipt {
                        ActionReceiptCard(receipt: lastReceipt)
                    }
                    optionalPowerCard
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

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                primaryActionCard(
                    title: "Care & Train",
                    subtitle: "Feed, check in, teach, and keep Buddy growing.",
                    systemImage: "heart.fill",
                    isPrimary: true
                ) {
                    appState.route(to: .buddy)
                }

                primaryActionCard(
                    title: "Chat",
                    subtitle: "Talk with \(store.activeBuddy?.displayName ?? "Buddy") and keep the loop moving.",
                    systemImage: "message.fill"
                ) {
                    appState.openChat(from: .missionControl, resetConversation: true)
                }

                primaryActionCard(
                    title: "Studio",
                    subtitle: "Draw sprites, use Buddy copilot, and keep pixel work native.",
                    systemImage: "paintpalette.fill"
                ) {
                    appState.route(to: .editor)
                }

                primaryActionCard(
                    title: "Results",
                    subtitle: "Open artifacts, receipts, and generated output.",
                    systemImage: "checklist.checked"
                ) {
                    appState.route(to: .artifacts)
                }
            }
        }
        .bmoCard()
    }

    private var buddySymphonyCard: some View {
        let mission = BuddySymphonyMission.preview(for: store.activeBuddy)
        return VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Buddy Symphony")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Queued work becomes isolated Buddy missions. This phone view is status-only until a Mac/runtime relay accepts the run.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "Read-only", color: BMOTheme.accent)
            }

            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: mission.state.systemImage)
                        .font(.title3)
                        .foregroundColor(mission.state.color)
                        .frame(width: 28)

                    VStack(alignment: .leading, spacing: 4) {
                        Text(mission.title)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(BMOTheme.textPrimary)
                        Text(mission.summary)
                            .font(.caption)
                            .foregroundColor(BMOTheme.textSecondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }

                    Spacer()

                    StatusBadge(label: mission.state.title, color: mission.state.color)
                }

                VStack(spacing: 6) {
                    detailRow("Buddy", value: mission.buddyName)
                    detailRow("Workspace", value: mission.workspaceSummary)
                    detailRow("Policy", value: mission.policySummary)
                }
            }
            .padding(12)
            .background(BMOTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))

            VStack(alignment: .leading, spacing: 8) {
                Text("Proofs required before growth")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)

                ForEach(mission.proofs) { proof in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: proof.systemImage)
                            .foregroundColor(proof.isSatisfied ? BMOTheme.success : BMOTheme.warning)
                            .frame(width: 18)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(proof.title)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(BMOTheme.textPrimary)
                            Text(proof.summary)
                                .font(.caption2)
                                .foregroundColor(BMOTheme.textTertiary)
                        }
                        Spacer()
                    }
                }
            }

            HStack(spacing: 8) {
                Button("Open Results") {
                    appState.route(to: .artifacts)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))

                Button("Check Mac Relay") {
                    Task { await appState.refreshMacRuntimeSnapshot() }
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }

            Text("Growth recommendation only: BMO must convert accepted Symphony proofs into receipts before XP, bond, memory, unlocks, or evolution can change.")
                .font(.caption2)
                .foregroundColor(BMOTheme.textTertiary)
        }
        .bmoCard()
    }

    private var optionalPowerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Optional power")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Repo/runtime tools are still here, but they are secondary to the Buddy loop on iPhone.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: appState.macRuntimeSnapshot == nil ? "Phone only" : "Mac paired", color: appState.macRuntimeSnapshot == nil ? BMOTheme.accent : BMOTheme.success)
            }

            HStack(spacing: 8) {
                Button("Mac Runtime") {
                    Task { await appState.refreshMacRuntimeSnapshot() }
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }

            Text(appState.macPowerModeSummary)
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
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
            // Skill routing removed as part of 'natural skills' shift
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

    private func primaryActionCard(
        title: String,
        subtitle: String,
        systemImage: String,
        isPrimary: Bool = false,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: systemImage)
                    .font(.title3)
                Text(title)
                    .font(.headline)
                Text(subtitle)
                    .font(.caption)
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
            }
            .foregroundColor(isPrimary ? BMOTheme.backgroundPrimary : BMOTheme.textPrimary)
            .frame(maxWidth: .infinity, minHeight: 112, alignment: .leading)
            .padding(BMOTheme.spacingMD)
            .background(isPrimary ? BMOTheme.accent : BMOTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
            .contentShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

private struct BuddySymphonyMission: Identifiable {
    let id: String
    let title: String
    let summary: String
    let buddyName: String
    let workspaceSummary: String
    let policySummary: String
    let state: BuddySymphonyMissionState
    let proofs: [BuddySymphonyProof]

    static func preview(for buddy: BuddyInstance?) -> BuddySymphonyMission {
        let buddyName = buddy?.displayName ?? "Unassigned Buddy"
        let role = buddy?.identity.role ?? "mission-ready companion"
        let workspaceName = buddy.map { ".buddy-symphony/\($0.instanceId.prefix(8))" } ?? ".buddy-symphony/pending"

        return BuddySymphonyMission(
            id: "preview-buddy-symphony",
            title: "Prepare isolated work run",
            summary: "\(buddyName) can supervise implementation work as a mission, but execution stays behind Mac relay and BMO receipts.",
            buddyName: "\(buddyName) • \(role)",
            workspaceSummary: "\(workspaceName) • relay required",
            policySummary: "Receipts first, growth later",
            state: buddy == nil ? .needsBuddy : .waitingRelay,
            proofs: [
                BuddySymphonyProof(
                    title: "Reviewable diff or PR",
                    summary: "Source changes must produce a diff, PR, or artifact reference before acceptance.",
                    systemImage: "doc.text.magnifyingglass",
                    isSatisfied: false
                ),
                BuddySymphonyProof(
                    title: "Validation receipt",
                    summary: "CI, build, or local validation must be attached before Buddy growth is considered.",
                    systemImage: "checkmark.seal",
                    isSatisfied: false
                ),
                BuddySymphonyProof(
                    title: "BMO approval gate",
                    summary: "XP, bond, memory, unlocks, and evolution only change after BMO accepts receipts.",
                    systemImage: "lock.shield",
                    isSatisfied: true
                )
            ]
        )
    }
}

private struct BuddySymphonyProof: Identifiable {
    let id = UUID()
    let title: String
    let summary: String
    let systemImage: String
    let isSatisfied: Bool
}

private enum BuddySymphonyMissionState {
    case needsBuddy
    case waitingRelay
    case running
    case waitingReview
    case accepted

    var title: String {
        switch self {
        case .needsBuddy:
            return "Needs Buddy"
        case .waitingRelay:
            return "Waiting Relay"
        case .running:
            return "Running"
        case .waitingReview:
            return "Review"
        case .accepted:
            return "Accepted"
        }
    }

    var systemImage: String {
        switch self {
        case .needsBuddy:
            return "person.crop.circle.badge.questionmark"
        case .waitingRelay:
            return "antenna.radiowaves.left.and.right"
        case .running:
            return "play.circle.fill"
        case .waitingReview:
            return "eye.fill"
        case .accepted:
            return "checkmark.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .needsBuddy:
            return BMOTheme.warning
        case .waitingRelay:
            return BMOTheme.accent
        case .running:
            return BMOTheme.accent
        case .waitingReview:
            return BMOTheme.warning
        case .accepted:
            return BMOTheme.success
        }
    }
}
