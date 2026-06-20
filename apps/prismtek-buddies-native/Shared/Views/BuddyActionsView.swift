import SwiftUI

/// Manual emote buttons + a "What can Buddy do?" panel.
struct BuddyActionsView: View {
    @EnvironmentObject var appState: AppState
    @State private var showWhatCanBuddyDo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Buddy Actions")
                .font(.headline)

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

struct WhatCanBuddyDoPanel: View {
    @Binding var isPresented: Bool

    private let current: [String] = [
        "Sit on chair",
        "Work at desk/computer",
        "Review task",
        "Wait for user",
        "Celebrate focus session",
        "Wave/greet",
        "React to failed/deleted task",
        "Inspect shelf",
        "Water/check plant",
        "Listen to music placeholder",
        "Idle/play on rug",
        "Switch buddies",
        "Open Buddy Studio"
    ]

    private let future: [String] = [
        "Apple Reminders tasks",
        "Apple Notes context",
        "GitHub PR/check status",
        "Codex/Claude build phases",
        "Obsidian context",
        "Focus streak gifts/unlocks",
        "Time-of-day room changes",
        "More Buddy variants",
        "Dedicated animations: sit, sleep, dance, eat, read, code, fish, garden, listen",
        "Room editor / furniture placement",
        "Mini Mode desktop companion controls",
        "Live pet generation/import through LibreSprite + PixelLab plugin"
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
        .frame(minWidth: 320, minHeight: 420)
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
