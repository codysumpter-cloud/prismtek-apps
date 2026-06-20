import SwiftUI

/// Manual emote buttons + a "What can Buddy do?" panel.
/// The emote buttons drive Bitbud's state and the room action label directly
/// (independent of tapping furniture). The panel lists current actions and a
/// future roadmap.
struct BuddyActionsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhatCanBuddyDo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Buddy Actions")
                .font(.headline)

            // Manual emote buttons.
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 88), spacing: 8)], spacing: 8) {
                emoteButton("Wave", "hand.wave") { appState.emote(.wave) }
                emoteButton("Celebrate", "party.popper") { appState.emote(.celebrate) }
                emoteButton("Think", "brain.head.profile") { appState.emote(.inspect) }
                emoteButton("Work", "desktopcomputer") { appState.emote(.work) }
                emoteButton("Wait", "hourglass") { appState.emote(.wait) }
                emoteButton("Sit", "chair") { appState.emote(.sit) }
                emoteButton("Sad", "cloud.rain") { appState.emoteFailed() }
            }

            Button {
                showWhatCanBuddyDo = true
            } label: {
                Label("What can Buddy do?", systemImage: "questionmark.circle")
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .sheet(isPresented: $showWhatCanBuddyDo) {
            WhatCanBuddyDoPanel(isPresented: $showWhatCanBuddyDo)
        }
    }

    private func emoteButton(_ title: String, _ systemImage: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: systemImage)
                Text(title).font(.caption2)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(.bordered)
    }
}

/// Lists the current Buddy actions and a "Future" roadmap section.
struct WhatCanBuddyDoPanel: View {
    @Binding var isPresented: Bool

    private let current: [String] = [
        "Sit on chair",
        "Work at desk",
        "Review a task",
        "Wait for user",
        "Celebrate focus session",
        "Wave / greet",
        "React to a failed / deleted task",
        "Inspect shelf",
        "Water plant",
        "Listen to music (placeholder)",
        "Idle on rug"
    ]

    private let future: [String] = [
        "Apple Reminders tasks",
        "Apple Notes memo context",
        "GitHub PR / check reactions",
        "Codex / Claude build-phase reactions",
        "Gifts / unlocks after focus streaks",
        "Time-of-day room / theme changes",
        "Choose different Buddies",
        "Dedicated animations (sit / sleep / dance / eat / read / code / fish / garden)",
        "Room editor / furniture placement",
        "Mini Mode desktop companion controls"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("What can Buddy do?").font(.title3.bold())
                Spacer()
                Button("Done") { isPresented = false }
                    .buttonStyle(.borderless)
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    section("Right now", items: current, systemImage: "checkmark.circle.fill", tint: .green)
                    section("Future", items: future, systemImage: "sparkles", tint: .purple)
                }
                .padding()
            }
        }
        .frame(minWidth: 320, minHeight: 380)
    }

    private func section(_ title: String, items: [String], systemImage: String, tint: Color) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title).font(.headline)
            ForEach(items, id: \.self) { item in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: systemImage).foregroundStyle(tint)
                    Text(item)
                    Spacer()
                }
                .font(.callout)
            }
        }
    }
}
