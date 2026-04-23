import SwiftUI

struct BuddyVisualView: View {
    var buddy: BuddyInstance?
    var template: CouncilStarterBuddyTemplate?
    var previewSpec: BuddyAppearancePreviewSpec?
    let mood: BuddyAnimationMood
    var compact: Bool = false

    var body: some View {
        let isPixel = previewSpec?.renderStyle == .pixel
            || previewSpec?.pixelRequestKey?.isEmpty == false
            || previewSpec?.pixelAssetPath?.isEmpty == false
            || buddy?.visual?.pixelVariantId?.isEmpty == false
            || buddy?.visual?.pixelAssetPath?.isEmpty == false

        Group {
            if !isPixel {
                BuddyAsciiView(buddy: buddy, template: template, previewSpec: previewSpec, mood: mood, compact: compact)
            } else {
                BuddyPixelView(buddy: buddy, template: template, previewSpec: previewSpec, mood: mood, compact: compact)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
