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
                Text("Buddy is the center. Workspace, tasks, skills, results, and receipts stay connected to the local BeMore runtime.")
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
        case .workspace:
            productPanel(title: "Workspace", summary: "Browse and edit files in the local runtime shell at \(state.runtimeURL.absoluteString).")
        case .tasks:
            productPanel(title: "Tasks", summary: "Create Buddy tasks, delegate subtasks, retry bounded failures, and inspect status through the runtime.")
        case .skills:
            productPanel(title: "Skills", summary: "Skills are Buddy-linked actions that create artifacts and receipts instead of empty shortcuts.")
        case .results:
            productPanel(title: "Results", summary: "Command output, diffs, patches, artifacts, and receipts are the proof trail for every run.")
        case .settings:
            productPanel(title: "Runtime Boundary", summary: "The macOS TestFlight app is the native shell. The local Node runtime remains explicit at \(state.runtimeURL.absoluteString).")
        }
    }

    private var homeContent: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Start with Buddy")
                .font(.title2.bold())
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
                Button("Queue Buddy Task") {
                    state.markHappy()
                }
                .buttonStyle(.bordered)
            }
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
