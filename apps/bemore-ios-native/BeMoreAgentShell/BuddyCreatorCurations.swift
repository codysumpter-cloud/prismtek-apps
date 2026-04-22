import Foundation

enum BuddyCreatorCurations {
    static let paletteFamilies: [String: String] = [
        "mint_cream": "Soft pastels",
        "rose_white": "Soft pastels",
        "lavender_sky": "Soft pastels",
        "sunset_pop": "Warm glow",
        "peach_brown": "Warm glow",
        "yellow_cocoa": "Warm glow",
        "sky_navy": "Cool signal",
        "aqua_teal": "Cool signal",
        "aurora_ice": "Cool signal",
        "forest_moss": "Nature",
        "moss_ember": "Nature",
        "petal_leaf": "Nature",
        "black_neon": "Arcade",
        "red_charcoal": "Arcade",
        "plasma_wave": "Arcade",
        "purple_gold": "Royal",
        "ember_lilac": "Royal",
        "midnight_gold": "Royal",
        "candy_burst": "Playful",
        "berry_soda": "Playful",
        "pixel_party": "Playful"
    ]

    static let featureOptions = ["tiny antenna", "soft scarf", "pocket glow", "leaf charm", "star clip", "mini cape", "cheek sparks", "satchel", "moon pin"]
    static let vibeOptions = ["Friendly", "Curious", "Focused", "Cozy", "Playful", "Bold"]
    static let asciiStyles = ["starter_a", "starter_b", "starter_c"]

    static func familyLabel(for paletteID: String) -> String {
        paletteFamilies[paletteID] ?? "Curated"
    }
}
