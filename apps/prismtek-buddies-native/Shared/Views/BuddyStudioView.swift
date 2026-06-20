import SwiftUI
#if os(macOS)
import AppKit
#endif

struct BuddyStudioView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("buddy.selected.id") private var selectedID: String = BuddyCharacter.defaultID

    private var selectedBuddy: BuddyCharacter { BuddyCharacter.buddy(for: selectedID) }
    private let targetPath = "~/Library/Application Support/Prismtek Buddies/Buddies/"
    private let libreSpritePath = "/Applications/LibreSprite.app"
    private let pluginPath = "~/Library/Application Support/LibreSprite/scripts/PixelLab.js"

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text("Buddy Studio").font(.title3.bold())
                Spacer()
                Button("Done") { dismiss() }
                    .buttonStyle(.borderless)
            }
            .padding()

            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    currentBuddyCard
                    workflowCard
                    actionsCard
                    notesCard
                }
                .padding()
            }
        }
        .frame(minWidth: 380, minHeight: 520)
    }

    private var currentBuddyCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Current Buddy").font(.headline)
            HStack(spacing: 12) {
                BuddyStudioPreview(buddy: selectedBuddy)
                    .frame(width: 72, height: 78)
                VStack(alignment: .leading, spacing: 4) {
                    Text(selectedBuddy.name).font(.callout.bold())
                    Text(selectedBuddy.blurb)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }
        }
        .padding(12)
        .background(pixelPanel)
    }

    private var workflowCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("LibreSprite Workflow").font(.headline)
            studioRow("1", "Import a 64x64 PNG or future Codex pet package.")
            studioRow("2", "Open the sprite in LibreSprite and keep hard pixel edges.")
            studioRow("3", "Use PixelLab only after approval; generation can spend credits.")
            studioRow("4", "Later save imported buddies to \(targetPath)")
        }
        .padding(12)
        .background(pixelPanel)
    }

    private var actionsCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Actions").font(.headline)
            HStack {
                Button {
                    openLibreSprite()
                } label: {
                    Label("Open in LibreSprite", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.bordered)

                Button {
                    revealBuddyFolderPlaceholder()
                } label: {
                    Label("Import Buddy Image", systemImage: "photo")
                }
                .buttonStyle(.bordered)
            }
            Button {
                revealBuddyFolderPlaceholder()
            } label: {
                Label("Import Codex Pet Package", systemImage: "shippingbox")
            }
            .buttonStyle(.bordered)

            Button("Generate with LibreSprite / PixelLab plugin") {}
                .buttonStyle(.bordered)
                .disabled(true)
            Text("Generation is intentionally disabled in v0. It must go through the approved LibreSprite + PixelLab plugin workflow before any external service or credits are used.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(12)
        .background(pixelPanel)
    }

    private var notesCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Paths").font(.headline)
            Text("LibreSprite: \(libreSpritePath)")
            Text("PixelLab script: \(pluginPath)")
            Text("Future Buddy storage: \(targetPath)")
        }
        .font(.caption)
        .padding(12)
        .background(pixelPanel)
    }

    private var pixelPanel: some View {
        ZStack {
            Rectangle().fill(Color.secondary.opacity(0.08))
            Rectangle().strokeBorder(Color.secondary.opacity(0.25), lineWidth: 1)
        }
    }

    private func studioRow(_ number: String, _ text: String) -> some View {
        HStack(alignment: .top, spacing: 8) {
            Text(number)
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .frame(width: 18, height: 18)
                .background(Rectangle().fill(Color.accentColor))
            Text(text).font(.callout)
            Spacer()
        }
    }

    private func openLibreSprite() {
        #if os(macOS)
        NSWorkspace.shared.open(URL(fileURLWithPath: libreSpritePath))
        #endif
    }

    private func revealBuddyFolderPlaceholder() {
        #if os(macOS)
        let expanded = NSString(string: "~/Library/Application Support/Prismtek Buddies/Buddies/").expandingTildeInPath
        let url = URL(fileURLWithPath: expanded)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        NSWorkspace.shared.activateFileViewerSelecting([url])
        #endif
    }
}

private struct BuddyStudioPreview: View {
    let buddy: BuddyCharacter

    var body: some View {
        switch buddy.kind {
        case .animatedAtlas:
            BitbudRenderer(state: .idle, frameDuration: 0.2, pixelScale: 0.7)
        case .staticImage:
            StaticBuddyRenderer(assetName: buddy.assetName ?? "buddy_classic", state: .idle, pixelScale: 0.7)
        }
    }
}
