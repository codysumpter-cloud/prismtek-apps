import Foundation

struct BuddyAppearanceOption: Identifiable, Hashable {
    var id: String
    var label: String
    var detail: String
}

struct BuddyAppearancePreviewSpec: Hashable {
    var buddyName: String
    var archetypeID: String
    var paletteID: String
    var asciiVariantID: String
    var expressionTone: String
    var accentLabel: String
    var renderStyle: BuddyAppearanceRenderStyle
    var customization: BuddyAppearanceCustomization
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
            accentLabel: accentLabel,
            customization: customization
        )
    }
}

enum BuddyAppearanceRenderContract {
    static func cleanedName(_ value: String, fallback: String = "Buddy") -> String {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return cleaned.isEmpty ? fallback : cleaned
    }

    static func normalizedID(_ value: String, fallback: String) -> String {
        let cleaned = value.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        return cleaned.isEmpty ? fallback : cleaned
    }

    static func defaultCustomization(for archetypeID: String) -> BuddyAppearanceCustomization {
        switch archetypeID {
        case "dino":
            return .init(
                subtype: "trex",
                bodyStyle: "chunky",
                accessory: "none",
                accentDetail: "spike tail",
                pose: "proud stance",
                personalityVibe: "cute",
                animationFlavor: "tail swish",
                promptModifiers: "cute retro green sprite buddy"
            )
        case "pixel_pet":
            return .init(
                subtype: "pet",
                bodyStyle: "round",
                accessory: "bell collar",
                accentDetail: "cheek blush",
                pose: "idle bounce",
                personalityVibe: "friendly",
                animationFlavor: "tiny bounce",
                promptModifiers: "game-ready pet sprite"
            )
        case "cat_like":
            return .init(
                subtype: "cat",
                bodyStyle: "fluffy",
                accessory: "scarf",
                accentDetail: "soft whiskers",
                pose: "curled sit",
                personalityVibe: "sleepy",
                animationFlavor: "tail flick",
                promptModifiers: ""
            )
        case "fox_like":
            return .init(
                subtype: "fox",
                bodyStyle: "sleek",
                accessory: "leaf ribbon",
                accentDetail: "fluffy tail",
                pose: "alert stand",
                personalityVibe: "sly",
                animationFlavor: "ear twitch",
                promptModifiers: ""
            )
        case "robot":
            return .init(
                subtype: "utility bot",
                bodyStyle: "compact chassis",
                accessory: "antenna",
                accentDetail: "screen face",
                pose: "ready stance",
                personalityVibe: "focused",
                animationFlavor: "signal blink",
                promptModifiers: ""
            )
        case "slime":
            return .init(
                subtype: "goo buddy",
                bodyStyle: "round blob",
                accessory: "star clip",
                accentDetail: "sparkle goo",
                pose: "squish pose",
                personalityVibe: "playful",
                animationFlavor: "wobble",
                promptModifiers: ""
            )
        case "plant_creature":
            return .init(
                subtype: "sproutling",
                bodyStyle: "leafy",
                accessory: "vine charm",
                accentDetail: "bloom accent",
                pose: "gentle sway",
                personalityVibe: "gentle",
                animationFlavor: "leaf sway",
                promptModifiers: ""
            )
        case "mini_wizard":
            return .init(
                subtype: "apprentice",
                bodyStyle: "robe",
                accessory: "tiny staff",
                accentDetail: "moon trim",
                pose: "casting pose",
                personalityVibe: "wise",
                animationFlavor: "cloak flutter",
                promptModifiers: ""
            )
        case "spirit":
            return .init(
                subtype: "wisp",
                bodyStyle: "floaty",
                accessory: "rune halo",
                accentDetail: "aura trail",
                pose: "hover",
                personalityVibe: "calm",
                animationFlavor: "pulse shimmer",
                promptModifiers: ""
            )
        case "companion_orb":
            return .init(
                subtype: "orb",
                bodyStyle: "round",
                accessory: "orbit ring",
                accentDetail: "rune sparks",
                pose: "hover",
                personalityVibe: "smart",
                animationFlavor: "orbit pulse",
                promptModifiers: ""
            )
        case "tiny_monster":
            return .init(
                subtype: "goblin",
                bodyStyle: "spiky",
                accessory: "fang charm",
                accentDetail: "little horns",
                pose: "stomp",
                personalityVibe: "bold",
                animationFlavor: "bounce stomp",
                promptModifiers: ""
            )
        default:
            return .default
        }
    }

    static func normalizedCustomization(
        _ customization: BuddyAppearanceCustomization,
        archetypeID: String
    ) -> BuddyAppearanceCustomization {
        let defaults = defaultCustomization(for: archetypeID)
        return BuddyAppearanceCustomization(
            subtype: normalizedID(customization.subtype, fallback: defaults.subtype),
            bodyStyle: normalizedID(customization.bodyStyle, fallback: defaults.bodyStyle),
            accessory: normalizedID(customization.accessory, fallback: defaults.accessory),
            accentDetail: normalizedID(customization.accentDetail, fallback: defaults.accentDetail),
            pose: normalizedID(customization.pose, fallback: defaults.pose),
            personalityVibe: normalizedID(customization.personalityVibe, fallback: defaults.personalityVibe),
            animationFlavor: normalizedID(customization.animationFlavor, fallback: defaults.animationFlavor),
            promptModifiers: customization.promptModifiers.trimmingCharacters(in: .whitespacesAndNewlines)
        )
    }

    static func requestSignature(
        buddyName: String,
        archetypeID: String,
        paletteID: String,
        expressionTone: String,
        accentLabel: String,
        customization: BuddyAppearanceCustomization
    ) -> String {
        let details = normalizedCustomization(customization, archetypeID: archetypeID)
        return [
            cleanedName(buddyName).lowercased(),
            normalizedID(archetypeID, fallback: "console_pet"),
            normalizedID(paletteID, fallback: "mint_cream"),
            normalizedID(expressionTone, fallback: "friendly"),
            normalizedID(accentLabel, fallback: details.accentDetail),
            details.subtype,
            details.bodyStyle,
            details.accessory,
            details.accentDetail,
            details.pose,
            details.personalityVibe,
            details.animationFlavor,
            details.promptModifiers.lowercased()
        ]
        .joined(separator: "|")
    }

    static func pixelRequestKey(
        buddyName: String,
        archetypeID: String,
        paletteID: String,
        expressionTone: String,
        accentLabel: String,
        customization: BuddyAppearanceCustomization
    ) -> String {
        let normalized = requestSignature(
            buddyName: buddyName,
            archetypeID: archetypeID,
            paletteID: paletteID,
            expressionTone: expressionTone,
            accentLabel: accentLabel,
            customization: customization
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
        customization: BuddyAppearanceCustomization? = nil,
        pixelRequestKey: String? = nil,
        pixelAssetPath: String? = nil
    ) -> BuddyAppearancePreviewSpec {
        let name = cleanedName(buddyName)
        let details = normalizedCustomization(customization ?? defaultCustomization(for: archetypeID), archetypeID: archetypeID)
        let key = renderStyle == .pixel
            ? (pixelRequestKey ?? self.pixelRequestKey(
                buddyName: name,
                archetypeID: archetypeID,
                paletteID: paletteID,
                expressionTone: expressionTone,
                accentLabel: accentLabel,
                customization: details
            ))
            : nil
        return BuddyAppearancePreviewSpec(
            buddyName: name,
            archetypeID: archetypeID,
            paletteID: paletteID,
            asciiVariantID: asciiVariantID,
            expressionTone: expressionTone,
            accentLabel: normalizedID(accentLabel, fallback: details.accentDetail),
            renderStyle: renderStyle,
            customization: details,
            pixelRequestKey: key,
            pixelAssetPath: pixelAssetPath
        )
    }

    static func subtypeOptions(for archetypeID: String) -> [BuddyAppearanceOption] {
        switch archetypeID {
        case "dino":
            return [
                .init(id: "trex", label: "T-Rex", detail: "Big head, tiny arms, chunky biped"),
                .init(id: "raptor", label: "Raptor", detail: "Lean, agile, long tail"),
                .init(id: "triceratops", label: "Triceratops", detail: "Frill and horns"),
                .init(id: "stegosaurus", label: "Stegosaurus", detail: "Back plates and tail spikes"),
                .init(id: "longneck", label: "Long-neck", detail: "Gentle brontosaurus silhouette"),
                .init(id: "ankylosaurus", label: "Ankylosaurus", detail: "Armored back and club tail"),
                .init(id: "pterodactyl", label: "Pterodactyl", detail: "Winged flying reptile"),
                .init(id: "random_dino", label: "Random Dino", detail: "Shuffle a dino silhouette")
            ]
        case "cat_like":
            return [.init(id: "cat", label: "Cat", detail: "Classic cozy cat")]
        case "fox_like":
            return [.init(id: "fox", label: "Fox", detail: "Fluffy tailed fox")]
        case "robot":
            return [.init(id: "utility_bot", label: "Utility Bot", detail: "Compact helper robot")]
        case "slime":
            return [.init(id: "goo_buddy", label: "Goo Buddy", detail: "Bouncy slime pal")]
        case "plant_creature":
            return [.init(id: "sproutling", label: "Sproutling", detail: "Leafy creature")]
        case "mini_wizard":
            return [.init(id: "apprentice", label: "Apprentice", detail: "Tiny spellcaster")]
        case "spirit":
            return [.init(id: "wisp", label: "Wisp", detail: "Gentle floating spirit")]
        case "companion_orb":
            return [.init(id: "orb", label: "Orb", detail: "Rune-lit orb")]
        case "tiny_monster":
            return [.init(id: "goblin", label: "Goblin", detail: "Spiky pocket monster")]
        case "pixel_pet":
            return [.init(id: "pet", label: "Pixel Pet", detail: "Tiny retro pet")]
        default:
            return [.init(id: "classic", label: "Classic", detail: "Default shape")]
        }
    }

    static func options(
        for field: WritableKeyPath<BuddyAppearanceCustomization, String>,
        archetypeID: String
    ) -> [BuddyAppearanceOption] {
        switch field {
        case \.bodyStyle:
            switch archetypeID {
            case "dino":
                return [
                    .init(id: "chunky", label: "Chunky", detail: "Round cute proportions"),
                    .init(id: "lean", label: "Lean", detail: "Agile and quick"),
                    .init(id: "armored", label: "Armored", detail: "Extra plated"),
                    .init(id: "gentle", label: "Gentle", detail: "Soft rounded build")
                ]
            case "cat_like":
                return [.init(id: "fluffy", label: "Fluffy", detail: "Big soft fur"), .init(id: "sleek", label: "Sleek", detail: "Neat elegant body")]
            case "fox_like":
                return [.init(id: "sleek", label: "Sleek", detail: "Sharp and tidy"), .init(id: "fluffy", label: "Fluffy", detail: "Extra tail fluff")]
            case "robot":
                return [.init(id: "compact_chassis", label: "Compact", detail: "Small sturdy chassis"), .init(id: "screen_torso", label: "Screen Body", detail: "Panel-forward"), .init(id: "tower", label: "Tower", detail: "Tall silhouette")]
            case "slime":
                return [.init(id: "round_blob", label: "Round", detail: "Simple blob"), .init(id: "star_blob", label: "Star", detail: "Pointed edges"), .init(id: "droplet", label: "Droplet", detail: "Taller drip")]
            case "plant_creature":
                return [.init(id: "leafy", label: "Leafy", detail: "Leaf body"), .init(id: "bloom", label: "Bloom", detail: "Flower body"), .init(id: "viney", label: "Viney", detail: "Trailing vine shape")]
            case "mini_wizard":
                return [.init(id: "robe", label: "Robe", detail: "Classic robe"), .init(id: "cloak", label: "Cloak", detail: "Flowing cape")]
            default:
                return [.init(id: "compact", label: "Compact", detail: "Small readable body"), .init(id: "round", label: "Round", detail: "Soft silhouette")]
            }
        case \.accessory:
            switch archetypeID {
            case "dino":
                return [.init(id: "none", label: "None", detail: "No accessory"), .init(id: "leaf_bandana", label: "Leaf Bandana", detail: "Cute neck wrap"), .init(id: "satchel", label: "Satchel", detail: "Explorer buddy"), .init(id: "scarf", label: "Scarf", detail: "Soft cozy scarf")]
            case "cat_like":
                return [.init(id: "bell_collar", label: "Bell Collar", detail: "Classic pet bell"), .init(id: "ribbon", label: "Ribbon", detail: "Cute ribbon")]
            case "robot":
                return [.init(id: "antenna", label: "Antenna", detail: "Signal antenna"), .init(id: "tool_pack", label: "Tool Pack", detail: "Utility pack")]
            default:
                return [.init(id: "none", label: "None", detail: "Keep it simple"), .init(id: "scarf", label: "Scarf", detail: "Soft accessory"), .init(id: "star_clip", label: "Star Clip", detail: "Small accent")]
            }
        case \.accentDetail:
            switch archetypeID {
            case "dino":
                return [.init(id: "spike_tail", label: "Spike Tail", detail: "Sharper tail"), .init(id: "heart_cheeks", label: "Heart Cheeks", detail: "Extra cute face"), .init(id: "plate_ridges", label: "Plate Ridges", detail: "Back detail"), .init(id: "club_tail", label: "Club Tail", detail: "Heavy tail accent")]
            case "cat_like":
                return [.init(id: "soft_whiskers", label: "Soft Whiskers", detail: "Long whiskers"), .init(id: "sleepy_eyes", label: "Sleepy Eyes", detail: "Cozy eyes")]
            case "fox_like":
                return [.init(id: "tail_fluff", label: "Tail Fluff", detail: "Very fluffy tail"), .init(id: "ear_tips", label: "Ear Tips", detail: "Contrasting ear tips")]
            default:
                return [.init(id: "signature_glow", label: "Signature Glow", detail: "Simple highlight"), .init(id: "cheek_sparks", label: "Cheek Sparks", detail: "Tiny cheek mark"), .init(id: "leaf_charm", label: "Leaf Charm", detail: "Nature accent")]
            }
        case \.pose:
            return [
                .init(id: "idle", label: "Idle", detail: "Neutral display pose"),
                .init(id: "proud_stance", label: "Proud", detail: "Chest out"),
                .init(id: "bounce", label: "Bounce", detail: "Animated bounce"),
                .init(id: "peek", label: "Peek", detail: "Shy side pose")
            ]
        case \.personalityVibe:
            return [
                .init(id: "cute", label: "Cute", detail: "Softer features"),
                .init(id: "friendly", label: "Friendly", detail: "Welcoming expression"),
                .init(id: "playful", label: "Playful", detail: "Energetic body language"),
                .init(id: "fierce", label: "Fierce", detail: "Sharper silhouette"),
                .init(id: "sleepy", label: "Sleepy", detail: "Relaxed face"),
                .init(id: "focused", label: "Focused", detail: "Sharper eyes")
            ]
        case \.animationFlavor:
            return [
                .init(id: "gentle_bob", label: "Gentle Bob", detail: "Soft idle motion"),
                .init(id: "tail_swish", label: "Tail Swish", detail: "Tail-led motion"),
                .init(id: "blink_blink", label: "Blink", detail: "Face-led motion"),
                .init(id: "bounce_stomp", label: "Bounce Stomp", detail: "Chunkier movement")
            ]
        default:
            return []
        }
    }

    static func pixelDescription(for spec: BuddyAppearancePreviewSpec) -> String {
        let details = normalizedCustomization(spec.customization, archetypeID: spec.archetypeID)
        let subtypePrompt: String
        switch (spec.archetypeID, details.subtype) {
        case ("dino", "trex"):
            subtypePrompt = "cute retro green T-Rex buddy, chunky biped silhouette, big head, tiny arms, readable dinosaur sprite"
        case ("dino", "raptor"):
            subtypePrompt = "cute retro green raptor buddy, lean agile silhouette, longer tail, sprite-friendly posture"
        case ("dino", "triceratops"):
            subtypePrompt = "cute retro green triceratops buddy, frill and horns, compact quadruped silhouette"
        case ("dino", "stegosaurus"):
            subtypePrompt = "cute retro green stegosaurus buddy, readable back plates, chunky tail"
        case ("dino", "longneck"):
            subtypePrompt = "cute retro green long-neck dinosaur buddy, gentle long neck silhouette, soft friendly body"
        case ("dino", "ankylosaurus"):
            subtypePrompt = "cute retro green ankylosaurus buddy, armored back, club tail, sturdy silhouette"
        case ("dino", "pterodactyl"):
            subtypePrompt = "cute retro green pterodactyl buddy, winged flying reptile silhouette, compact sprite"
        case ("pixel_pet", _):
            subtypePrompt = "cute retro pixel pet buddy, compact mobile game pet silhouette, tamagotchi-like readability"
        case ("cat_like", _):
            subtypePrompt = "cute retro pixel cat buddy, readable ears and curled tail"
        case ("fox_like", _):
            subtypePrompt = "cute retro pixel fox buddy, pointed ears and fluffy tail"
        case ("robot", _):
            subtypePrompt = "cute retro pixel robot buddy, readable compact chassis and face screen"
        case ("slime", _):
            subtypePrompt = "cute retro pixel slime buddy, rounded goo silhouette"
        case ("plant_creature", _):
            subtypePrompt = "cute retro pixel plant creature buddy, leaf and bloom silhouette"
        case ("mini_wizard", _):
            subtypePrompt = "cute retro pixel wizard buddy, hat and robe silhouette"
        case ("spirit", _):
            subtypePrompt = "cute retro pixel spirit buddy, floaty readable aura silhouette"
        case ("companion_orb", _):
            subtypePrompt = "cute retro pixel orb buddy, clear orb body with rune accents"
        case ("tiny_monster", _):
            subtypePrompt = "cute retro pixel tiny monster buddy, pocket-monster silhouette"
        default:
            subtypePrompt = "cute retro pixel buddy, readable game sprite silhouette"
        }

        return [
            subtypePrompt,
            "palette \(spec.paletteID)",
            "expression \(spec.expressionTone)",
            "body style \(details.bodyStyle)",
            "accessory \(details.accessory)",
            "accent \(details.accentDetail)",
            "pose \(details.pose)",
            "personality vibe \(details.personalityVibe)",
            "animation flavor \(details.animationFlavor)",
            spec.accentLabel.isEmpty ? nil : "detail \(spec.accentLabel)",
            details.promptModifiers.isEmpty ? nil : details.promptModifiers,
            "transparent background",
            "single centered full-body character",
            "retro 2D sprite feel",
            "readable compact silhouette",
            "cute mobile-game pet presentation",
            "no text",
            "no scenery",
            "no watermark"
        ]
        .compactMap { $0 }
        .joined(separator: ", ")
    }
}
