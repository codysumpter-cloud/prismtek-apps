// Generated/seeded Pixel Fruit Arena asset catalog.
// Run `npm run catalog:assets` from games/pixel-fruit-arena to refresh from files on disk.

const approved = { status: "approved", runtimeReady: true, usable: true, styleFamily: "pixel-fruit-arena", compatibility: ["pixel-fruit-arena-runtime"] };

export const GENERATED_ASSET_CATALOG = {
  schemaVersion: 2,
  generatedBy: "tools/build_asset_catalog.mjs",
  generatedAt: null,
  source: "repo-seed-curated",
  root: "assets",
  policy: {
    defaultStatus: "discovered",
    runtimeRule: "Only assets with status=approved and runtimeReady=true are surfaced in game selectors.",
    reason: "The repo can contain multiple art styles, animation formats, source files, and game types. Discovery is not approval."
  },
  categories: {
    bodies: [
      { id: "male_basic", label: "Basic Male", path: "assets/characters/prismtek-custom/male-basic.svg", kind: "character_body", slot: "body", customizable: true, frameWidth: 32, frameHeight: 32, frames: 4, tags: ["player", "customizable", "male"], ...approved },
      { id: "female_basic", label: "Basic Female", path: "assets/characters/prismtek-custom/female-basic.svg", kind: "character_body", slot: "body", customizable: true, frameWidth: 32, frameHeight: 32, frames: 4, tags: ["player", "customizable", "female"], ...approved },
      { id: "prismcade_buddy", label: "Buddy", path: "assets/characters/prismcade-pixellab/prismcade_buddy/idle_4.png", kind: "character_body", slot: "body", customizable: false, frameWidth: 64, frameHeight: 64, frames: 4, tags: ["player", "pixellab", "prismcade", "buddy"], ...approved },
      { id: "prismcade_prismtek", label: "Prismtek", path: "assets/characters/prismcade-pixellab/prismcade_prismtek/idle_4.png", kind: "character_body", slot: "body", customizable: false, frameWidth: 64, frameHeight: 64, frames: 4, tags: ["player", "pixellab", "prismcade", "humanoid"], ...approved },
      { id: "prismcade_prismtek_jones", label: "Prismtek Jones", path: "assets/characters/prismcade-pixellab/prismcade_prismtek_jones/idle_4.png", kind: "character_body", slot: "body", customizable: false, frameWidth: 64, frameHeight: 64, frames: 4, tags: ["player", "pixellab", "prismcade", "humanoid"], ...approved },
      { id: "prismcade_female_blue_hoodie", label: "Female Blue Hoodie", path: "assets/characters/prismcade-pixellab/prismcade_female_blue_hoodie/idle_4.png", kind: "character_body", slot: "body", customizable: false, frameWidth: 64, frameHeight: 64, frames: 4, tags: ["player", "pixellab", "prismcade", "humanoid"], ...approved },
      { id: "prismcade_ponytail_guy", label: "Ponytail Guy", path: "assets/characters/prismcade-pixellab/prismcade_ponytail_guy/idle_4.png", kind: "character_body", slot: "body", customizable: false, frameWidth: 64, frameHeight: 64, frames: 4, tags: ["player", "pixellab", "prismcade", "humanoid"], ...approved },
      { id: "prismcade_prismtek_pixel_god", label: "Prismtek Pixel God", path: "assets/characters/prismcade-pixellab/prismcade_prismtek_pixel_god/idle_4.png", kind: "character_body", slot: "body", customizable: false, frameWidth: 64, frameHeight: 64, frames: 4, tags: ["player", "pixellab", "prismcade", "humanoid"], ...approved },
      { id: "prismcade_prismbot_pixel_god", label: "PrismBot Pixel God", path: "assets/characters/prismcade-pixellab/prismcade_prismbot_pixel_god/idle_4.png", kind: "character_body", slot: "body", customizable: false, frameWidth: 64, frameHeight: 64, frames: 4, tags: ["player", "pixellab", "prismcade", "humanoid"], ...approved },
      { id: "pink", label: "Prism Imp", path: "assets/characters/tiny-hero/pink/idle_4.png", kind: "character_body", slot: "body", customizable: false, frameWidth: 32, frameHeight: 32, tags: ["player", "tiny-hero"], ...approved },
      { id: "owlet", label: "Prism Owlet", path: "assets/characters/tiny-hero/owlet/idle_4.png", kind: "character_body", slot: "body", customizable: false, frameWidth: 32, frameHeight: 32, tags: ["player", "tiny-hero"], ...approved },
      { id: "dude", label: "Prism Dude", path: "assets/characters/tiny-hero/dude/idle_4.png", kind: "character_body", slot: "body", customizable: false, frameWidth: 32, frameHeight: 32, tags: ["player", "tiny-hero"], ...approved }
    ],
    hair: [
      { id: "crest", label: "Crest", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay"], ...approved },
      { id: "bob", label: "Bob", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay"], ...approved },
      { id: "spikes", label: "Spikes", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay"], ...approved },
      { id: "cap", label: "Cap", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay", "headwear"], ...approved },
      { id: "long", label: "Long", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay"], ...approved },
      { id: "ponytail", label: "Ponytail", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay"], ...approved },
      { id: "mohawk", label: "Mohawk", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay"], ...approved },
      { id: "hood", label: "Hood", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay", "clothing"], ...approved },
      { id: "normal_hair", label: "Normal Hair", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay", "prismcade"], ...approved },
      { id: "low_taper", label: "Low Taper", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay", "prismcade"], ...approved },
      { id: "antenna_nubs", label: "Antenna Nubs", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay", "prismcade", "buddy"], ...approved },
      { id: "pixel_crown", label: "Pixel Crown", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay", "prismcade"], ...approved },
      { id: "robot_glow", label: "Robot Glow", kind: "cosmetic_overlay", slot: "hair", tags: ["drawn-overlay", "prismcade"], ...approved }
    ],
    clothing: [
      { id: "runner", label: "Runner", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay"], ...approved },
      { id: "jacket", label: "Jacket", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay"], ...approved },
      { id: "hoodie", label: "Hoodie", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay"], ...approved },
      { id: "armor", label: "Armor", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay"], ...approved },
      { id: "robe", label: "Robe", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay"], ...approved },
      { id: "skirt", label: "Skirt", kind: "cosmetic_overlay", slot: "bottom", tags: ["drawn-overlay"], ...approved },
      { id: "gi", label: "Gi", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay"], ...approved },
      { id: "coat", label: "Coat", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay"], ...approved },
      { id: "blue_hoodie", label: "Blue Hoodie", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay", "prismcade"], ...approved },
      { id: "arcade_jacket", label: "Arcade Jacket", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay", "prismcade"], ...approved },
      { id: "buddy_shell", label: "Buddy Shell", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay", "prismcade", "buddy"], ...approved },
      { id: "pixel_god", label: "Pixel God", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay", "prismcade"], ...approved },
      { id: "prismbot_armor", label: "PrismBot Armor", kind: "cosmetic_overlay", slot: "top", tags: ["drawn-overlay", "prismcade"], ...approved }
    ],
    vfx: [
      { id: "firebolt", label: "Firebolt", path: "assets/effects/elemental-vfx/firebolt.png", kind: "vfx_sheet", family: "fire", tags: ["fire", "projectile"], ...approved },
      { id: "ice_hit", label: "Ice Hit", path: "assets/effects/elemental-vfx/ice-hit.png", kind: "vfx_sheet", family: "ice", tags: ["ice", "hit"], ...approved },
      { id: "thunder_beam", label: "Thunder Beam", path: "assets/effects/elemental-vfx/thunder-beam.png", kind: "vfx_sheet", family: "lightning", tags: ["lightning", "beam"], ...approved },
      { id: "dark_column", label: "Dark Column", path: "assets/effects/elemental-vfx/dark-column.png", kind: "vfx_sheet", family: "dark", tags: ["dark", "burst"], ...approved },
      { id: "earth_impact", label: "Earth Impact", path: "assets/effects/elemental-vfx/earth-impact.png", kind: "vfx_sheet", family: "earth", tags: ["earth", "impact"], ...approved },
      { id: "acid_splash", label: "Acid Splash", path: "assets/effects/elemental-vfx/acid-splash.png", kind: "vfx_sheet", family: "poison", tags: ["poison", "hazard"], ...approved },
      { id: "holy_column", label: "Holy Column", path: "assets/effects/elemental-vfx/holy-column.png", kind: "vfx_sheet", family: "light", tags: ["light", "awakening"], ...approved },
      { id: "hit_spark", label: "Hit Spark", path: "assets/effects/elemental-vfx/hit-spark.png", kind: "vfx_sheet", family: "impact", tags: ["impact", "hit"], ...approved }
    ],
    tilesets: [
      { id: "four_seasons_tileset", label: "Four Seasons Tileset", path: "assets/stages/four-seasons/four-seasons-tileset.png", kind: "tileset", tags: ["stage", "platform"], ...approved }
    ],
    stageBackgrounds: [],
    weapons: [],
    items: [],
    fruitIcons: [],
    props: [],
    ui: []
  }
};

export default GENERATED_ASSET_CATALOG;
