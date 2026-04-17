import SwiftUI

struct BeMoreMacRootView: View {
    @EnvironmentObject private var state: BeMoreMacState

    var body: some View {
        if state.hasCompletedOnboarding {
            appShell
        } else {
            MacOnboardingView()
        }
    }

    private var appShell: some View {
        NavigationSplitView {
            List(BeMoreMacSection.allCases, selection: $state.selectedSection) { section in
                Label(section.rawValue, systemImage: section.symbol)
                    .tag(section)
            }
            .navigationTitle("BeMore")
            .safeAreaInset(edge: .bottom) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(state.activeBuddyName)
                        .font(.headline)
                    Text(state.activeBuddyRole)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    HStack(alignment: .top, spacing: 18) {
                        content
                            .frame(maxWidth: .infinity, alignment: .leading)
                        companionRail
                            .frame(width: 260)
                    }
                }
                .padding(28)
                .frame(maxWidth: 1180, alignment: .leading)
            }
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.98, blue: 0.94),
                        Color(red: 0.88, green: 0.94, blue: 0.98)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(state.selectedSection.rawValue)
                    .font(.system(size: 34, weight: .bold))
                Text("BeMore Mac keeps Buddy useful on the desktop: plan work, train skills, review results, and open deeper operator tools when you need them.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Check Runtime") {
                state.checkRuntime()
            }
            .buttonStyle(.bordered)
            Button("Open Runtime") {
                state.openRuntime()
            }
            .buttonStyle(.borderedProminent)
        }
    }

    @ViewBuilder
    private var content: some View {
        switch state.selectedSection {
        case .home:
            homeContent
        case .chat:
            chatContent
        case .work:
            workContent
        case .skills:
            skillsContent
        case .results:
            resultsContent
        case .templates:
            templatesContent
        case .settings:
            settingsContent
        }
    }

    private var companionRail: some View {
        VStack(alignment: .leading, spacing: 14) {
            BuddyAsciiView(buddyName: state.activeBuddyName, mood: state.buddyMood)
            Text(state.latestReceipt)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                statPill("Energy", value: state.energy)
                statPill("Bond", value: state.bond)
                statPill("Focus", value: state.focus)
                statPill("Care", value: state.care)
            }
            HStack {
                Button("Check In") { state.checkIn() }
                Button("Train") { state.train() }
                Button("Rest") { state.rest() }
            }
            .buttonStyle(.bordered)
        }
        .panel()
    }

    private var homeContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Today With \(state.activeBuddyName)")
                .font(.title2.bold())
            Text(state.activeBuddyFocus)
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                actionTile("Start a task", icon: "plus.circle.fill", body: "Create focused work for your Buddy.") {
                    state.selectedSection = .work
                }
                actionTile("Run a skill", icon: "wand.and.stars", body: "Train or use a practical Buddy capability.") {
                    state.selectedSection = .skills
                }
                actionTile("Package a template", icon: "shippingbox.fill", body: "Prepare a sell-ready Buddy draft.") {
                    state.selectedSection = .templates
                }
            }

            latestReceipts(limit: 3)
        }
        .panel()
    }

    private var chatContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Chat With \(state.activeBuddyName)")
                .font(.title2.bold())
            Text("Ask for planning, follow-through, teaching, or technical help. Buddy will keep the next step visible and avoid pretending work happened invisibly.")
                .foregroundStyle(.secondary)

            ForEach(state.chatMessages) { message in
                VStack(alignment: .leading, spacing: 4) {
                    Text(message.speaker)
                        .font(.caption.bold())
                        .foregroundStyle(message.speaker == "You" ? .blue : .green)
                    Text(message.body)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }

            HStack {
                TextField("Ask Buddy what to do next...", text: $state.chatDraft)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { state.sendChat() }
                Button("Send") { state.sendChat() }
                    .buttonStyle(.borderedProminent)
            }
        }
        .panel()
    }

    private var workContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Workbench")
                .font(.title2.bold())
            Text("Create tasks, mark progress, and keep the next step clear before moving into deeper operator work.")
                .foregroundStyle(.secondary)

            HStack {
                TextField("New task...", text: $state.taskDraft)
                    .textFieldStyle(.roundedBorder)
                    .onSubmit { state.addTask() }
                Button("Add Task") { state.addTask() }
                    .buttonStyle(.borderedProminent)
            }

            ForEach(state.tasks) { task in
                Button {
                    state.toggleTask(task)
                } label: {
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(task.isDone ? .green : .secondary)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(task.title)
                                .font(.headline)
                            Text(task.detail)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .padding(12)
                .background(Color.white.opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .panel()
    }

    private var skillsContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Skills")
                .font(.title2.bold())
            Text("Skills are practical abilities Buddy can learn, equip, and use for planning, review, templates, or deeper technical work.")
                .foregroundStyle(.secondary)

            ForEach(state.skills) { skill in
                HStack(alignment: .top, spacing: 12) {
                    Image(systemName: "wand.and.stars")
                        .foregroundStyle(.blue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(skill.name)
                            .font(.headline)
                        Text(skill.summary)
                            .foregroundStyle(.secondary)
                        Text(skill.status)
                            .font(.caption.bold())
                            .foregroundStyle(.green)
                    }
                    Spacer()
                    Button("Run") {
                        state.runSkill(skill)
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(12)
                .background(Color.white.opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .panel()
    }

    private var resultsContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Results and Receipts")
                .font(.title2.bold())
            Text("Results show what Buddy actually did: tasks, skills, template work, and saved outputs.")
                .foregroundStyle(.secondary)
            latestReceipts(limit: 20)
        }
        .panel()
    }

    private var templatesContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Buddy Templates")
                .font(.title2.bold())
            Text("Create, train, and package Buddies without leaking private memory. Selling still needs billing and moderation; this build prepares clean shareable drafts.")
                .foregroundStyle(.secondary)

            HStack(spacing: 12) {
                templateStep("Create", "Install or personalize a Buddy with a clear role and use case.")
                templateStep("Train", "Use check-ins, tasks, and skills to show what the Buddy is good at.")
                templateStep("Package", "Create a clean guide and template without private history.")
                templateStep("Sell", "Submit when marketplace billing and moderation are enabled.")
            }

            Button("Prepare Seller-Ready Draft") {
                state.packageTemplate()
            }
            .buttonStyle(.borderedProminent)

            Text("Discoverable Buddies")
                .font(.headline)
            ForEach(state.marketplaceBuddies, id: \.self) { buddy in
                HStack {
                    VStack(alignment: .leading) {
                        Text(buddy)
                            .font(.headline)
                        Text(state.ownedBuddies.contains(buddy) ? "Owned" : "Installable starter template")
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Button(state.ownedBuddies.contains(buddy) ? "Owned" : "Install") {
                        state.installBuddy(buddy)
                    }
                    .disabled(state.ownedBuddies.contains(buddy))
                }
                .padding(12)
                .background(Color.white.opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
        .panel()
    }

    private var settingsContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Settings")
                .font(.title2.bold())
            Text("Runtime URL: \(state.runtimeURL.absoluteString)")
                .foregroundStyle(.secondary)
            Text("Runtime status: \(state.runtimeStatus)")
                .foregroundStyle(.secondary)
            Button("Check Runtime Boundary") { state.checkRuntime() }
                .buttonStyle(.borderedProminent)
            Button("Run Onboarding Again") { state.resetOnboarding() }
                .buttonStyle(.bordered)
        }
        .panel()
    }

    private func latestReceipts(limit: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Latest Receipts")
                .font(.headline)
            ForEach(Array(state.receipts.prefix(limit))) { receipt in
                VStack(alignment: .leading, spacing: 4) {
                    Text(receipt.title)
                        .font(.headline)
                    Text(receipt.summary)
                        .foregroundStyle(.secondary)
                    Text(receipt.artifact)
                        .font(.caption.monospaced())
                        .foregroundStyle(.blue)
                }
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white.opacity(0.86))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            }
        }
    }

    private func actionTile(_ title: String, icon: String, body: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.headline)
                Text(body)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity, minHeight: 130, alignment: .leading)
            .background(Color.white.opacity(0.9))
            .clipShape(RoundedRectangle(cornerRadius: 14))
        }
        .buttonStyle(.plain)
    }

    private func templateStep(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 120, alignment: .topLeading)
        .background(Color.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func statPill(_ title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.headline)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.86))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}

private struct MacOnboardingView: View {
    @EnvironmentObject private var state: BeMoreMacState
    @State private var buddyName = "Prism"
    @State private var buddyRole = "Builder companion"
    @State private var buddyFocus = "Help me plan the day, follow through, and learn what useful support looks like."
    @State private var runtimeURL = "http://127.0.0.1:4319"

    var body: some View {
        VStack(spacing: 24) {
            Text("Set Up BeMore Mac")
                .font(.system(size: 42, weight: .bold))
            Text("Create your first Buddy, choose what they help with, and add deeper operator setup only when you need it.")
                .font(.title3)
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 14) {
                TextField("Buddy name", text: $buddyName)
                TextField("Buddy role", text: $buddyRole)
                TextField("Current focus", text: $buddyFocus)
                TextField("Runtime URL", text: $runtimeURL)
            }
            .textFieldStyle(.roundedBorder)
            .frame(width: 520)

            HStack(spacing: 12) {
                onboardingPill("Create", "Name a Buddy and role.")
                onboardingPill("Train", "Use tasks, chat, and skills.")
                onboardingPill("Sell", "Package sanitized templates.")
            }
            .frame(width: 720)

            Button("Start BeMore") {
                state.completeOnboarding(name: buddyName, role: buddyRole, focus: buddyFocus, runtime: runtimeURL)
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
        .padding(48)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.94, green: 0.98, blue: 0.91),
                    Color(red: 0.84, green: 0.92, blue: 0.98)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private func onboardingPill(_ title: String, _ body: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.headline)
            Text(body)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white.opacity(0.82))
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }
}

private extension View {
    func panel() -> some View {
        padding()
            .background(Color.white.opacity(0.72))
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: .black.opacity(0.06), radius: 18, y: 8)
    }
}
