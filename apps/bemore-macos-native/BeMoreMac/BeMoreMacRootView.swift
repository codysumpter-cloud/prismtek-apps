import SwiftUI

struct BeMoreMacRootView: View {
    @EnvironmentObject private var state: BeMoreMacState

    var body: some View {
        NavigationSplitView {
            List(BeMoreMacSection.allCases, selection: $state.selectedSection) { section in
                Label(section.rawValue, systemImage: section.symbol)
                    .tag(section)
            }
            .navigationTitle("BeMore")
        } detail: {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    header
                    BuddyAsciiView(buddyName: state.activeBuddyName, mood: state.buddyMood)
                    content
                }
                .padding(28)
                .frame(maxWidth: 980, alignment: .leading)
            }
            .background(Color(red: 0.96, green: 0.98, blue: 0.95))
        }
    }

    private var header: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 6) {
                Text(state.selectedSection.rawValue)
                    .font(.system(size: 34, weight: .bold))
                Text("\(state.activeBuddyName) is the active Buddy across chat, tasks, skills, marketplace ownership, and receipts. Runtime power stays available without owning the first screen.")
                    .foregroundStyle(.secondary)
            }
            Spacer()
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
        case .results:
            productPanel(title: "Results", summary: "Command output, diffs, patches, artifacts, and receipts are the proof trail for every run.")
        case .discover:
            discoverContent
        case .settings:
            productPanel(title: "Runtime Boundary", summary: "The macOS TestFlight app is the native shell. The local Node runtime remains explicit at \(state.runtimeURL.absoluteString).")
        }
    }

    private var homeContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Start with Buddy")
                .font(.title2.bold())
            Text("\(state.activeBuddyName) • \(state.activeBuddyRole)")
                .font(.headline)
            Text(state.activeBuddyFocus)
                .foregroundStyle(.secondary)
            Text(state.latestReceipt)
                .foregroundStyle(.secondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 120), spacing: 10)], spacing: 10) {
                statPill("Energy", value: state.energy)
                statPill("Bond", value: state.bond)
                statPill("Focus", value: state.focus)
                statPill("Care", value: state.care)
            }
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                ForEach(state.quickActions, id: \.self) { action in
                    Text(action)
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            HStack {
                Button("Check In") {
                    state.checkIn()
                }
                .buttonStyle(.borderedProminent)
                Button("Train") {
                    state.train()
                }
                .buttonStyle(.bordered)
                Button("Rest") {
                    state.rest()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var workContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("\(state.activeBuddyName)'s Work")
                .font(.title2.bold())
            Text("Workspace, missions, skills, and Mac power mode stay grouped here so the main menu feels companion-first.")
                .foregroundStyle(.secondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                ForEach(["Workspace", "Missions", "Skills", "Mac power"], id: \.self) { surface in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(surface)
                            .font(.headline)
                        Text(surface == "Workspace" ? "Browse files and run bounded commands." : "Receipt-backed actions for \(state.activeBuddyName).")
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            Button("Open Local Runtime") {
                state.markWorking()
                state.openRuntime()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var chatContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Chat with \(state.activeBuddyName)")
                .font(.title2.bold())
            Text("Chat uses the active Buddy identity instead of a detached assistant label. The full runtime still lives behind the local endpoint.")
                .foregroundStyle(.secondary)
            Text("\(state.activeBuddyName): I’m watching tasks, skills, receipts, and Mac power mode with you.")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            Button("Open Runtime Chat Route") {
                state.markWorking()
                state.openRuntime()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var discoverContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Discover Buddies and Plans")
                .font(.title2.bold())
            Text("Owned Buddies, marketplace discovery, and plan previews live here after \(state.activeBuddyName) is established as your companion.")
                .foregroundStyle(.secondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 200), spacing: 12)], spacing: 12) {
                ForEach(state.marketplaceBuddies, id: \.self) { buddy in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(buddy)
                            .font(.headline)
                        Text(state.ownedBuddies.contains(buddy) ? "Owned" : "Installable")
                            .foregroundStyle(state.ownedBuddies.contains(buddy) ? .green : .secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            pricingContent
        }
        .padding()
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var pricingContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Pricing")
                .font(.title2.bold())
            Text("Free keeps one active Buddy and starter marketplace access. Plus unlocks more Buddy slots and runtime capacity. Council unlocks premium/creator Buddies and team-style rosters.")
                .foregroundStyle(.secondary)
            ForEach(["Free — $0", "Plus — $12/mo preview", "Council — $29/mo preview"], id: \.self) { plan in
                Text(plan)
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
            }
            Text("Checkout is not enabled in this build; the pricing structure is visible so the product no longer hides monetization.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func productPanel(title: String, summary: String) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
            Text(summary)
                .foregroundStyle(.secondary)
            Button("Open Local Runtime") {
                state.markWorking()
                state.openRuntime()
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private func statPill(_ title: String, value: Int) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text("\(value)")
                .font(.headline)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}
