export const TRAINING_ARENA = {
  id: "training_arena",
  name: "Boxing Test Arena",
  theme: "boxing",
  size: { width: 960, height: 540 },
  bounds: { left: -190, right: 1150, top: -240, bottom: 730 },
  respawns: [
    { x: 330, y: 300 },
    { x: 630, y: 300 },
    { x: 430, y: 300 },
    { x: 530, y: 300 }
  ],
  platforms: [
    { x: 150, y: 430, w: 660, h: 40, type: "solid" },
    { x: 250, y: 300, w: 140, h: 18, type: "oneway" },
    { x: 570, y: 300, w: 140, h: 18, type: "oneway" }
  ],
  ring: {
    floor: { x: 150, y: 430, w: 660 },
    postLeft: { x: 160, y: 290 },
    postRight: { x: 784, y: 290 },
    ropeYs: [318, 352, 388]
  },
  ringOutZones: [
    { x: -260, y: -280, w: 80, h: 1060 },
    { x: 1140, y: -280, w: 80, h: 1060 },
    { x: -260, y: 710, w: 1480, h: 100 },
    { x: -260, y: -340, w: 1480, h: 100 }
  ]
};
