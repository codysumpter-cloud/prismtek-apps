export const COSMETICS = {
  hairStyles: ["crest", "bob", "spikes", "cap"],
  hairColors: ["#5ee7ff", "#f15bb5", "#f4c542", "#2dd36f", "#f7f7ff"],
  skinTones: ["#5b3926", "#8d563f", "#b97855", "#d8a17c", "#f1c6a8"],
  outfitColors: ["#26344f", "#28536b", "#512d6d", "#1f7a5c", "#8f2d56"],
  accessoryColors: ["#ef476f", "#ffd166", "#06d6a0", "#72ddf7", "#f7f7ff"],
  presets: [
    { hairStyle: "crest", hairColor: "#5ee7ff", skinTone: "#8d563f", outfitPrimary: "#26344f", outfitSecondary: "#f4c542", accessoryColor: "#ef476f" },
    { hairStyle: "spikes", hairColor: "#f4c542", skinTone: "#b97855", outfitPrimary: "#512d6d", outfitSecondary: "#72ddf7", accessoryColor: "#06d6a0" },
    { hairStyle: "bob", hairColor: "#f15bb5", skinTone: "#d8a17c", outfitPrimary: "#1f7a5c", outfitSecondary: "#f7f7ff", accessoryColor: "#ffd166" },
    { hairStyle: "cap", hairColor: "#2dd36f", skinTone: "#5b3926", outfitPrimary: "#8f2d56", outfitSecondary: "#28536b", accessoryColor: "#72ddf7" }
  ]
};

export function createCharacter(overrides = {}) {
  const owned = overrides.ownedFruits || overrides.owned_fruits || ["flame"];
  return {
    name: overrides.name || "",
    appearance: { ...COSMETICS.presets[0], ...(overrides.appearance || {}) },
    owned_fruits: [...owned],
    equipped_fruit: overrides.equippedFruit || overrides.equipped_fruit || owned[0] || "flame",
    fruit_mastery: Object.fromEntries(owned.map((fruitId) => [fruitId, 0])),
    cosmetics_unlocked: ["starter"],
    stats: { wins: 0, ringouts: 0 }
  };
}
