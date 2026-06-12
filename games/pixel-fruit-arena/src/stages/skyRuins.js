export const SKY_RUINS = {
  id: "sky_ruins",
  name: "Sky Ruins Arena",
  size: { width: 960, height: 540 },
  bounds: { left: -170, right: 1130, top: -220, bottom: 720 },
  respawns: [
    { x: 300, y: 230 },
    { x: 660, y: 230 },
    { x: 420, y: 150 },
    { x: 540, y: 150 }
  ],
  platforms: [
    { x: 220, y: 410, w: 520, h: 34, type: "solid" },
    { x: 120, y: 310, w: 180, h: 22, type: "oneway" },
    { x: 660, y: 310, w: 180, h: 22, type: "oneway" },
    { x: 390, y: 225, w: 180, h: 20, type: "oneway" }
  ],
  ringOutZones: [
    { x: -240, y: -260, w: 80, h: 1040 },
    { x: 1120, y: -260, w: 80, h: 1040 },
    { x: -240, y: 700, w: 1440, h: 100 },
    { x: -240, y: -320, w: 1440, h: 100 }
  ]
};
