import type { ContentPack } from "./content";

export const starterContentPack: ContentPack = {
  manifest: {
    id: "legendsmmo-starter",
    name: "LegendsMMO Starter Pack",
    version: "0.1.0",
    author: "Prismtek",
    license: "Project-owned placeholder content",
  },
  moves: [
    { id: "spark-tap", name: "Spark Tap", element: "volt", power: 35, accuracy: 95, energyCost: 4, kind: "spirit" },
    { id: "leaf-jab", name: "Leaf Jab", element: "wild", power: 30, accuracy: 100, energyCost: 3, kind: "physical" },
    { id: "focus-hum", name: "Focus Hum", element: "mind", power: 0, accuracy: 100, energyCost: 2, kind: "status" },
  ],
  creatures: [
    {
      id: "budlit",
      name: "Budlit",
      description: "A tiny lantern spirit that follows friendly travelers.",
      elements: ["volt", "mind"],
      baseStats: { hp: 42, attack: 30, defense: 34, spirit: 48, speed: 44 },
      learnset: [
        { moveId: "spark-tap", level: 1 },
        { moveId: "focus-hum", level: 4 },
      ],
    },
    {
      id: "mossprout",
      name: "Mossprout",
      description: "A stubborn sprout that headbutts anything blocking the path.",
      elements: ["wild"],
      baseStats: { hp: 50, attack: 45, defense: 42, spirit: 25, speed: 28 },
      learnset: [{ moveId: "leaf-jab", level: 1 }],
    },
  ],
  items: [
    { id: "camp-snack", name: "Camp Snack", kind: "consumable", description: "Restores a small amount of HP." },
    { id: "trail-pass", name: "Trail Pass", kind: "key", description: "Proof that a trainer can enter starter trails." },
  ],
  maps: [
    {
      id: "starter-grove",
      name: "Starter Grove",
      width: 4,
      height: 4,
      tilesetId: "starter-tiles",
      layers: [
        {
          id: "ground",
          name: "Ground",
          tiles: [1, 1, 1, 1, 1, 2, 2, 1, 1, 2, 3, 1, 1, 1, 1, 1],
        },
      ],
      spawnPoints: [{ id: "player-start", x: 1, y: 2, facing: "down" }],
    },
  ],
};
