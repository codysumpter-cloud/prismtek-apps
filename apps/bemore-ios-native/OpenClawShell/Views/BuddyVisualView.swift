import SwiftUI

struct BuddyVisualView: View {
    var buddy: BuddyInstance?
    var template: CouncilStarterBuddyTemplate?
    let mood: BuddyAnimationMood
    var compact: Bool = false

    var body: some View {
        let isPixel = buddy?.visual?.pixelVariantId != nil
        
        Group {
            if !isPixel {
                BuddyAsciiView(buddy: buddy, template: template, mood: mood, compact: compact)
            } else {
                BuddyPixelView(buddy: buddy, template: template, mood: mood, compact: compact)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
