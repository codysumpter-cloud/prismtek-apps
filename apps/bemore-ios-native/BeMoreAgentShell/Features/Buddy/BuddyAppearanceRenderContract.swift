import Foundation

struct BuddyAppearancePreviewSpec: Hashable {
    var buddyName: String
    var archetypeID: String
    var paletteID: String
    var asciiVariantID: String
    var expressionTone: String
    var accentLabel: String
    var renderStyle: BuddyAppearanceRenderStyle
    var pixelRequestKey: String?
    var pixelAssetPath: String?

    var animationState: String {
        BuddyAppearanceRenderContract.animationState(for: expressionTone)
    }

    var requestSignature: String {
        BuddyAppearanceRenderContract.requestSignature(
            buddyName: buddyName,
            archetypeID: archetypeID,
            paletteID: paletteID,
            expressionTone: expressionTone,
            accentLabel: accentLabel
        )
    }
}

enum BuddyAppearanceRenderContract {
    static func cleanedName(_ value: String, fallback: String = "Buddy") -> String {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? fallback : cleaned
    }

    static func requestSignature(
        buddyName: String,
        archetypeID: String,
        paletteID: String,
        expressionTone: String,
        accentLabel: String
    ) -> String {
        [
            cleanedName(buddyName).lowercased(),
            archetypeID.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            paletteID.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            expressionTone.trimmingCharacters(in: .whitespacesAndNewlines).lowercased(),
            accentLabel.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        ]
        .joined(separator: "|")
    }

    static func pixelRequestKey(
        buddyName: String,
        archetypeID: String,
        paletteID: String,
        expressionTone: String,
        accentLabel: String
    ) -> String {
        let normalized = requestSignature(
            buddyName: buddyName,
            archetypeID: archetypeID,
            paletteID: paletteID,
            expressionTone: expressionTone,
            accentLabel: accentLabel
        ).replacingOccurrences(of: " ", with: "-")
        return "pixellab:\(normalized)"
    }

    static func animationState(for expressionTone: String) -> String {
        switch expressionTone {
        case "curious":
            return "thinking"
        case "focused":
            return "working"
        default:
            return "happy"
        }
    }

    static func makePreviewSpec(
        buddyName: String,
        archetypeID: String,
        paletteID: String,
        asciiVariantID: String,
        expressionTone: String,
        accentLabel: String,
        renderStyle: BuddyAppearanceRenderStyle,
        pixelRequestKey: String? = nil,
        pixelAssetPath: String? = nil
    ) -> BuddyAppearancePreviewSpec {
        let name = cleanedName(buddyName)
        let key = renderStyle == .pixel
            ? (pixelRequestKey ?? self.pixelRequestKey(
                buddyName: name,
                archetypeID: archetypeID,
                paletteID: paletteID,
                expressionTone: expressionTone,
                accentLabel: accentLabel
            ))
            : nil
        return BuddyAppearancePreviewSpec(
            buddyName: name,
            archetypeID: archetypeID,
            paletteID: paletteID,
            asciiVariantID: asciiVariantID,
            expressionTone: expressionTone,
            accentLabel: accentLabel,
            renderStyle: renderStyle,
            pixelRequestKey: key,
            pixelAssetPath: pixelAssetPath
        )
    }

    static func pixelDescription(for spec: BuddyAppearancePreviewSpec) -> String {
        let archetypePrompt: String
        switch spec.archetypeID {
        case "dino":
            archetypePrompt = "small pixel dinosaur buddy with short arms, tail, and chunky head"
        case "pixel_pet":
            archetypePrompt = "tamagotchi-style pixel pet buddy with a readable pet silhouette"
        case "cat_like":
            archetypePrompt = "pixel cat buddy with ears, whiskers, and curled tail"
        case "fox_like":
            archetypePrompt = "pixel fox buddy with pointed ears and fluffy tail"
        case "robot":
            archetypePrompt = "pixel robot buddy with antenna, panel face, and tidy limbs"
        case "slime":
            archetypePrompt = "pixel slime buddy with a gooey rounded body"
        case "plant_creature":
            archetypePrompt = "pixel plant creature buddy with leaf sprout details"
        case "mini_wizard":
            archetypePrompt = "pixel mini wizard buddy with hat and robe"
        case "spirit":
            archetypePrompt = "pixel spirit buddy with floating wispy form"
        case "companion_orb":
            archetypePrompt = "pixel companion orb buddy with orbiting accents"
        case "tiny_monster":
            archetypePrompt = "pixel tiny monster buddy with horns or claws"
        default:
            archetypePrompt = "pixel buddy with a clean readable silhouette"
        }

        return "\(archetypePrompt), palette \(spec.paletteID), mood \(spec.expressionTone), accent \(spec.accentLabel), transparent background, one centered full-body character, sprite-friendly silhouette, no text, no scenery"
    }
}
