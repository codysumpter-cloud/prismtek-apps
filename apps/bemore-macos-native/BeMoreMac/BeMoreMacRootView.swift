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
                    BuddyAsciiView(mood: state.buddyMood)
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
        case .buddy:
            buddyContent
        case .chat:
            chatContent
        case .workspace:
            productPanel(title: "Workspace", summary: "Browse and edit files in the local runtime shell at \(state.runtimeURL.absoluteString).")
        case .tasks:
            productPanel(title: "Tasks", summary: "Create Buddy tasks, delegate subtasks, retry bounded failures, and inspect status through the runtime.")
        case .skills:
            productPanel(title: "Skills", summary: "Skills are Buddy-linked actions that create artifacts and receipts instead of empty shortcuts.")
        case .results:
            productPanel(title: "Results", summary: "Command output, diffs, patches, artifacts, and receipts are the proof trail for every run.")
        case .marketplace:
            marketplaceContent
        case .pricing:
            pricingContent
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
                Button("Check Runtime") {
                    state.markWorking()
                    state.openRuntime()
                }
                .buttonStyle(.borderedProminent)
                Button("Queue \(state.activeBuddyName) Task") {
                    state.markHappy()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.white.opacity(0.78))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    private var buddyContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("My Buddy")
                .font(.title2.bold())
            Text("\(state.activeBuddyName) is equipped as the active Buddy. Owned Buddies stay separate from marketplace discovery.")
                .foregroundStyle(.secondary)
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 180), spacing: 12)], spacing: 12) {
                ForEach(state.ownedBuddies, id: \.self) { buddy in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(buddy)
                            .font(.headline)
                        Text(buddy == state.activeBuddyName ? "Active" : "Owned")
                            .foregroundStyle(buddy == state.activeBuddyName ? .green : .secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            Button("Train \(state.activeBuddyName)") {
                state.markHappy()
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

    private var marketplaceContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Buddy Marketplace")
                .font(.title2.bold())
            Text("Curated starter Buddies are available now. Premium creator Buddies and council packs can attach to billing later.")
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
}
