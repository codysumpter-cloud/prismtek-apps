export const CHARACTER_SPRITES = {
  pink: {
    name: "Prism Imp",
    frameWidth: 32,
    frameHeight: 32,
    scale: 2,
    animations: {
      idle: { src: "assets/characters/tiny-hero/pink/idle_4.png", frames: 4, fps: 7, loop: true },
      walk: { src: "assets/characters/tiny-hero/pink/walk_6.png", frames: 6, fps: 10, loop: true },
      run: { src: "assets/characters/tiny-hero/pink/run_6.png", frames: 6, fps: 13, loop: true },
      jump: { src: "assets/characters/tiny-hero/pink/jump_8.png", frames: 8, fps: 11, loop: false },
      fall: { src: "assets/characters/tiny-hero/pink/jump_8.png", frames: 8, fps: 11, loop: false },
      attack: { src: "assets/characters/tiny-hero/pink/attack1_4.png", frames: 4, fps: 15, loop: false },
      special: { src: "assets/characters/tiny-hero/pink/attack2_6.png", frames: 6, fps: 13, loop: false },
      hurt: { src: "assets/characters/tiny-hero/pink/hurt_4.png", frames: 4, fps: 10, loop: false },
      knockout: { src: "assets/characters/tiny-hero/pink/death_8.png", frames: 8, fps: 10, loop: false },
      victory: { src: "assets/characters/tiny-hero/pink/idle_4.png", frames: 4, fps: 7, loop: true }
    }
  },
  owlet: {
    name: "Prism Owlet",
    frameWidth: 32,
    frameHeight: 32,
    scale: 2,
    animations: {
      idle: { src: "assets/characters/tiny-hero/owlet/idle_4.png", frames: 4, fps: 7, loop: true },
      walk: { src: "assets/characters/tiny-hero/owlet/walk_6.png", frames: 6, fps: 10, loop: true },
      run: { src: "assets/characters/tiny-hero/owlet/run_6.png", frames: 6, fps: 13, loop: true },
      jump: { src: "assets/characters/tiny-hero/owlet/jump_8.png", frames: 8, fps: 11, loop: false },
      fall: { src: "assets/characters/tiny-hero/owlet/jump_8.png", frames: 8, fps: 11, loop: false },
      attack: { src: "assets/characters/tiny-hero/owlet/attack1_4.png", frames: 4, fps: 15, loop: false },
      special: { src: "assets/characters/tiny-hero/owlet/attack2_6.png", frames: 6, fps: 13, loop: false },
      hurt: { src: "assets/characters/tiny-hero/owlet/hurt_4.png", frames: 4, fps: 10, loop: false },
      knockout: { src: "assets/characters/tiny-hero/owlet/death_8.png", frames: 8, fps: 10, loop: false },
      victory: { src: "assets/characters/tiny-hero/owlet/idle_4.png", frames: 4, fps: 7, loop: true }
    }
  },
  dude: {
    name: "Prism Dude",
    frameWidth: 32,
    frameHeight: 32,
    scale: 2,
    animations: {
      idle: { src: "assets/characters/tiny-hero/dude/idle_4.png", frames: 4, fps: 7, loop: true },
      walk: { src: "assets/characters/tiny-hero/dude/walk_6.png", frames: 6, fps: 10, loop: true },
      run: { src: "assets/characters/tiny-hero/dude/run_6.png", frames: 6, fps: 13, loop: true },
      jump: { src: "assets/characters/tiny-hero/dude/jump_8.png", frames: 8, fps: 11, loop: false },
      fall: { src: "assets/characters/tiny-hero/dude/jump_8.png", frames: 8, fps: 11, loop: false },
      attack: { src: "assets/characters/tiny-hero/dude/attack1_4.png", frames: 4, fps: 15, loop: false },
      special: { src: "assets/characters/tiny-hero/dude/attack2_6.png", frames: 6, fps: 13, loop: false },
      hurt: { src: "assets/characters/tiny-hero/dude/hurt_4.png", frames: 4, fps: 10, loop: false },
      knockout: { src: "assets/characters/tiny-hero/dude/death_8.png", frames: 8, fps: 10, loop: false },
      victory: { src: "assets/characters/tiny-hero/dude/idle_4.png", frames: 4, fps: 7, loop: true }
    }
  }
};

export const STAGE_ART = {
  skyRuins: {
    tileset: "assets/stages/four-seasons/four-seasons-tileset.png",
    platformTile: { x: 80, y: 0, w: 16, h: 16 },
    platformCap: { x: 96, y: 0, w: 16, h: 16 },
    stoneTile: { x: 80, y: 32, w: 16, h: 16 },
    vine: { x: 0, y: 48, w: 16, h: 32 },
    fruitTiles: [
      { x: 112, y: 160, w: 16, h: 16 },
      { x: 128, y: 160, w: 16, h: 16 },
      { x: 144, y: 160, w: 16, h: 16 },
      { x: 160, y: 160, w: 16, h: 16 }
    ]
  }
};

const effectRoot = "assets/effects/elemental-vfx";

export const VFX_SHEETS = {
  firebolt: { src: `${effectRoot}/firebolt.png`, frameWidth: 48, frameHeight: 48, frames: 11, columns: 11, fps: 20, scale: 2.05, offsetX: 76, offsetY: -8 },
  fireBreathHit: { src: `${effectRoot}/fire-breath-hit.png`, frameWidth: 48, frameHeight: 48, frames: 5, columns: 5, fps: 18, scale: 2.1, offsetX: 44, offsetY: -10 },
  fireExplosion: { src: `${effectRoot}/fire-explosion.png`, frameWidth: 48, frameHeight: 48, frames: 18, columns: 18, fps: 26, scale: 2.35, offsetX: 42, offsetY: -8 },
  iceHit: { src: `${effectRoot}/ice-hit.png`, frameWidth: 48, frameHeight: 32, frames: 8, columns: 8, fps: 18, scale: 2.1, offsetX: 60, offsetY: -7 },
  iceStart: { src: `${effectRoot}/ice-start.png`, frameWidth: 48, frameHeight: 32, frames: 3, columns: 3, fps: 12, scale: 2.2, offsetX: 28, offsetY: -8 },
  iceActive: { src: `${effectRoot}/ice-active.png`, frameWidth: 32, frameHeight: 32, frames: 8, columns: 8, fps: 16, scale: 2.4, offsetX: 26, offsetY: -4 },
  thunderProjectile: { src: `${effectRoot}/thunder-projectile.png`, frameWidth: 32, frameHeight: 32, frames: 5, columns: 5, fps: 18, scale: 2.4, offsetX: 72, offsetY: -8 },
  thunderHit: { src: `${effectRoot}/thunder-hit.png`, frameWidth: 32, frameHeight: 32, frames: 6, columns: 6, fps: 22, scale: 2.5, offsetX: 40, offsetY: -8 },
  thunderBeam: { src: `${effectRoot}/thunder-beam.png`, frameWidth: 48, frameHeight: 48, frames: 16, columns: 16, fps: 26, scale: 2.4, offsetX: 82, offsetY: -8 },
  darkBurst: { src: `${effectRoot}/dark-burst.png`, frameWidth: 40, frameHeight: 32, frames: 17, columns: 10, fps: 22, scale: 2.7, offsetX: 34, offsetY: -8 },
  darkColumn: { src: `${effectRoot}/dark-column.png`, frameWidth: 48, frameHeight: 64, frames: 16, columns: 16, fps: 22, scale: 2.35, offsetX: 26, offsetY: -26 },
  earthProjectile: { src: `${effectRoot}/earth-projectile.png`, frameWidth: 32, frameHeight: 32, frames: 18, columns: 9, fps: 22, scale: 2.35, offsetX: 68, offsetY: -8 },
  earthImpact: { src: `${effectRoot}/earth-impact.png`, frameWidth: 48, frameHeight: 48, frames: 7, columns: 7, fps: 18, scale: 2.25, offsetX: 36, offsetY: -8 },
  earthRock: { src: `${effectRoot}/earth-rock.png`, frameWidth: 32, frameHeight: 32, frames: 27, columns: 9, fps: 20, scale: 2.2, offsetX: 54, offsetY: -8 },
  hitSpark: { src: `${effectRoot}/hit-spark.png`, frameWidth: 48, frameHeight: 48, frames: 7, columns: 7, fps: 22, scale: 1.95, offsetX: 26, offsetY: -8 },
  smearHorizontal: { src: `${effectRoot}/smear-horizontal.png`, frameWidth: 48, frameHeight: 48, frames: 5, columns: 5, fps: 22, scale: 1.85, offsetX: 46, offsetY: -8 },
  smearVertical: { src: `${effectRoot}/smear-vertical.png`, frameWidth: 48, frameHeight: 48, frames: 6, columns: 6, fps: 22, scale: 1.85, offsetX: 26, offsetY: -22 },
  woodHit: { src: `${effectRoot}/wood-hit.png`, frameWidth: 32, frameHeight: 32, frames: 7, columns: 7, fps: 18, scale: 2.35, offsetX: 32, offsetY: -6 },
  woodRepeat: { src: `${effectRoot}/wood-repeat.png`, frameWidth: 32, frameHeight: 32, frames: 8, columns: 8, fps: 16, scale: 2.25, offsetX: 30, offsetY: -6 },
  woodSpike: { src: `${effectRoot}/wood-spike.png`, frameWidth: 32, frameHeight: 32, frames: 14, columns: 14, fps: 20, scale: 2.25, offsetX: 54, offsetY: -6 },
  acidSplash: { src: `${effectRoot}/acid-splash.png`, frameWidth: 32, frameHeight: 32, frames: 16, columns: 16, fps: 20, scale: 2.35, offsetX: 48, offsetY: -6 },
  acidColumn: { src: `${effectRoot}/acid-column.png`, frameWidth: 56, frameHeight: 32, frames: 12, columns: 1, fps: 18, scale: 2.1, offsetX: 28, offsetY: -8 },
  holyImpact: { src: `${effectRoot}/holy-impact.png`, frameWidth: 32, frameHeight: 32, frames: 7, columns: 7, fps: 18, scale: 2.3, offsetX: 26, offsetY: -8 },
  holyColumn: { src: `${effectRoot}/holy-column.png`, frameWidth: 48, frameHeight: 48, frames: 16, columns: 16, fps: 20, scale: 2.15, offsetX: 28, offsetY: -22 }
};

export const ABILITY_VFX = {
  fireball: "firebolt",
  flame_dash: "smearHorizontal",
  burning_uppercut: "fireExplosion",
  ice_spike: "iceHit",
  freeze_field: "iceActive",
  ice_slide: "iceStart",
  lightning_bolt: "thunderBeam",
  blink_dash: "thunderProjectile",
  chain_shock: "thunderHit",
  pull_field: "darkBurst",
  shadow_burst: "darkColumn",
  null_zone: "darkBurst",
  stretch_punch: "smearHorizontal",
  bounce_jump: "smearVertical",
  giant_fist: "hitSpark",
  pull: "earthProjectile",
  slam: "earthImpact",
  float_strike: "earthRock",
  hit: "hitSpark",
  awakening: "holyColumn"
};
