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
