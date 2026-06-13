export const COSMETICS = {
  hairStyles: ["crest", "bob", "spikes", "cap", "long", "ponytail", "mohawk", "hood"],
  clothingStyles: ["runner", "jacket", "hoodie", "armor", "robe", "skirt", "gi", "coat"],
  spriteKeys: ["male_basic", "female_basic", "pink", "owlet", "dude"],
  combatStyles: ["duelist", "brawler", "striker", "ranger", "guardian", "trickster"],
  hairColors: ["#5ee7ff", "#f15bb5", "#f4c542", "#2dd36f", "#f7f7ff", "#1b1f3b", "#7f5539", "#ffafcc"],
  skinTones: ["#5b3926", "#8d563f", "#b97855", "#d8a17c", "#f1c6a8"],
  outfitColors: ["#26344f", "#28536b", "#512d6d", "#1f7a5c", "#8f2d56", "#111827", "#7a2434", "#e8e0cf"],
  accessoryColors: ["#ef476f", "#ffd166", "#06d6a0", "#72ddf7", "#f7f7ff", "#adb5bd"],
  presets: [
    { hairStyle: "crest", clothingStyle: "runner", hairColor: "#5ee7ff", skinTone: "#8d563f", outfitPrimary: "#26344f", outfitSecondary: "#f4c542", accessoryColor: "#ef476f" },
    { hairStyle: "spikes", clothingStyle: "jacket", hairColor: "#f4c542", skinTone: "#b97855", outfitPrimary: "#512d6d", outfitSecondary: "#72ddf7", accessoryColor: "#06d6a0" },
    { hairStyle: "bob", clothingStyle: "skirt", hairColor: "#f15bb5", skinTone: "#d8a17c", outfitPrimary: "#1f7a5c", outfitSecondary: "#f7f7ff", accessoryColor: "#ffd166" },
    { hairStyle: "cap", clothingStyle: "hoodie", hairColor: "#2dd36f", skinTone: "#5b3926", outfitPrimary: "#8f2d56", outfitSecondary: "#28536b", accessoryColor: "#72ddf7" }
  ]
};

export function createCharacter(overrides = {}) {
  const owned = overrides.ownedFruits || overrides.owned_fruits || ["flame"];
  const appearance = { ...COSMETICS.presets[0], ...(overrides.appearance || {}) };
  appearance.clothingStyle ||= appearance.outfitStyle || "runner";
  return {
    name: overrides.name || "",
    appearance,
    owned_fruits: [...owned],
    equipped_fruit: overrides.equippedFruit || overrides.equipped_fruit || owned[0] || "flame",
    fruit_mastery: Object.fromEntries(owned.map((fruitId) => [fruitId, 0])),
    cosmetics_unlocked: ["starter"],
    stats: { wins: 0, ringouts: 0 },
    sprite_key: overrides.spriteKey || overrides.sprite_key || "male_basic",
    combat_style: overrides.combatStyle || overrides.combat_style || "duelist",
    cpu: Boolean(overrides.cpu)
  };
}
