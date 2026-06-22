import { createCharacter } from "./characterCreator.js";

const STYLE_BY_HAIR = {
  "purple-bob": "bob",
  "teal-short": "bob",
  "brown-low-taper": "low_taper",
  "orange-swept": "normal_hair",
  "white-mop": "normal_hair"
};

const STYLE_BY_OUTFIT = {
  "starter-blue-hoodie": "blue_hoodie",
  "prismcade-teal-suit": "arcade_jacket",
  "arcade-orange-fit": "jacket",
  "shadow-runner-fit": "runner"
};

function fallbackColor(recipe, slot, key, fallback = "#f7f7ff") {
  return recipe.partRefs?.[slot]?.fallback?.[key] || fallback;
}

export function appearanceFromPrismcadeRecipe(recipe = {}) {
  const slots = recipe.slots || {};
  return {
    hairStyle: STYLE_BY_HAIR[slots.hair] || "bob",
    clothingStyle: STYLE_BY_OUTFIT[slots.outfit] || "runner",
    hairColor: fallbackColor(recipe, "hair", "color", "#7d4bd6"),
    skinTone: fallbackColor(recipe, "skinTone", "color", "#e7ae78"),
    outfitPrimary: fallbackColor(recipe, "outfit", "primary", "#2bb7d8"),
    outfitSecondary: fallbackColor(recipe, "outfit", "secondary", "#1d4e6f"),
    accessoryColor: slots.accessory === "tiny-crown" ? "#ffd166" : "#72ddf7",
    prismcadeCreatorSlots: { ...slots }
  };
}

export function createPixelFruitArenaCharacterFromPrismcadeRecipe(recipe = {}, overrides = {}) {
  const manifest = overrides.manifest || {};
  const character = createCharacter({
    name: overrides.name || recipe.displayName || "Prismcade Creator",
    spriteKey: overrides.spriteKey || manifest.pixelFruitArena?.spriteKey || "female_basic",
    combatStyle: overrides.combatStyle || manifest.pixelFruitArena?.combatStyle || "duelist",
    ownedFruits: overrides.ownedFruits || [manifest.pixelFruitArena?.starterFruit || "flame"],
    equippedFruit: overrides.equippedFruit || manifest.pixelFruitArena?.starterFruit || "flame",
    appearance: {
      ...appearanceFromPrismcadeRecipe(recipe),
      ...(overrides.appearance || {})
    }
  });
  return {
    ...character,
    prismcade_creator: {
      recipe_id: recipe.id,
      source_pack_id: recipe.sourcePackId,
      source_pack_status: recipe.sourcePackStatus,
      manifest_id: manifest.id || null,
      public_playable: Boolean(manifest.publicPlayable)
    }
  };
}

export function createPixelFruitArenaCharacterFromPrismcadeManifest(manifest = {}, recipe = {}, overrides = {}) {
  return createPixelFruitArenaCharacterFromPrismcadeRecipe(recipe, { ...overrides, manifest });
}
