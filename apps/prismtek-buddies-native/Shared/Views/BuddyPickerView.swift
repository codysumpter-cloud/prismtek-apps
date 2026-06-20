import SwiftUI

struct BuddyPickerView: View {
    @AppStorage("buddy.selected.id") private var selectedID: String = BuddyCharacter.defaultID

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Choose Buddy")
                .font(.headline)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 92), spacing: 8)], spacing: 8) {
                ForEach(BuddyCharacter.registry) { buddy in
                    Button {
                        selectedID = buddy.id
                    } label: {
                        VStack(spacing: 6) {
                            BuddyPickerPreview(buddy: buddy)
                                .frame(width: 48, height: 52)
                            Text(buddy.name)
                                .font(.caption2)
                                .lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(
                            PixelPickerOutline(isSelected: selectedID == buddy.id)
                        )
                    }
                    .buttonStyle(.plain)
                    .help(buddy.blurb)
                }
            }
        }
        .padding()
    }
}

private struct BuddyPickerPreview: View {
    let buddy: BuddyCharacter

    var body: some View {
        switch buddy.kind {
        case .animatedAtlas:
            BitbudRenderer(state: .idle, frameDuration: 0.2, pixelScale: 0.46)
        case .staticImage:
            StaticBuddyRenderer(assetName: buddy.assetName ?? "buddy_classic", state: .idle, pixelScale: 0.46)
        }
    }
}

private struct PixelPickerOutline: View {
    let isSelected: Bool

    var body: some View {
        ZStack {
            Rectangle()
                .fill(isSelected ? Color.accentColor.opacity(0.18) : Color.clear)
            Rectangle()
                .strokeBorder(isSelected ? Color.accentColor : Color.secondary.opacity(0.25), lineWidth: isSelected ? 2 : 1)
        }
    }
}
