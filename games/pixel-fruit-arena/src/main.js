import { FRUITS } from "./fruits/fruits.js";
import { SKY_RUINS } from "./stages/skyRuins.js";
import { createCharacter, COSMETICS } from "./characters/characterCreator.js";
import { createMatch } from "./systems/matchSystem.js";
import { KeyboardInput, GamepadInput } from "./multiplayer/input.js";
import { Renderer } from "./ui/renderer.js";
import { renderHud, renderMenu } from "./ui/dom.js";
import "./systems/runtimeConfig.js";

const canvas = document.querySelector("#game");
const hud = document.querySelector("#hud");
const menu = document.querySelector("#menu");
const renderer = new Renderer(canvas, SKY_RUINS);
const keyboard = new KeyboardInput();
const gamepads = new GamepadInput();

const saveKey = "prismtek.pixelFruitArena.profile";
const stored = JSON.parse(localStorage.getItem(saveKey) || "null");
const profile = stored || createCharacter({
  name: "Prism Runner",
  appearance: {
    hairStyle: "crest",
    hairColor: "#5ee7ff",
    skinTone: "#8d563f",
    outfitPrimary: "#26344f",
    outfitSecondary: "#f4c542",
    accessoryColor: "#ef476f"
  },
  ownedFruits: Object.keys(FRUITS),
  equippedFruit: "flame"
});
profile.owned_fruits ||= Object.keys(FRUITS);
profile.equipped_fruit ||= profile.equippedFruit || profile.owned_fruits[0] || "flame";
profile.fruit_mastery ||= Object.fromEntries(profile.owned_fruits.map((fruitId) => [fruitId, 0]));

let mode = "menu";
let match = createMatch({
  stage: SKY_RUINS,
  players: [
    { slot: 0, character: profile, fruitId: profile.equipped_fruit },
    { slot: 1, character: createCharacter({ name: "Volt Guest", ownedFruits: Object.keys(FRUITS), equippedFruit: "volt" }), fruitId: "volt" }
  ],
  fruits: FRUITS
});

function persistProfile() {
  localStorage.setItem(saveKey, JSON.stringify(profile));
}

function startMatch(playerCount = 2) {
  const fruitIds = Object.keys(FRUITS);
  const players = Array.from({ length: playerCount }, (_, index) => ({
    slot: index,
    character: index === 0 ? profile : createCharacter({
      name: `P${index + 1} Guest`,
      appearance: COSMETICS.presets[index % COSMETICS.presets.length],
      ownedFruits: fruitIds,
      equippedFruit: fruitIds[index % fruitIds.length]
    }),
    fruitId: index === 0 ? profile.equipped_fruit : fruitIds[index % fruitIds.length]
  }));
  match = createMatch({ stage: SKY_RUINS, players, fruits: FRUITS });
  mode = "fight";
  menu.hidden = true;
}

function openMenu(nextMode = "menu") {
  mode = nextMode;
  menu.hidden = false;
}

function updateMenu() {
  renderMenu(menu, {
    mode,
    profile,
    fruits: FRUITS,
    cosmetics: COSMETICS,
    onStart: startMatch,
    onEquip: (fruitId) => {
      profile.equipped_fruit = fruitId;
      if (!profile.owned_fruits.includes(fruitId)) profile.owned_fruits.push(fruitId);
      profile.fruit_mastery[fruitId] ||= 0;
      persistProfile();
      updateMenu();
    },
    onName: (name) => {
      profile.name = name.slice(0, 18) || "Prism Runner";
      persistProfile();
    },
    onAppearance: (key, value) => {
      profile.appearance[key] = value;
      persistProfile();
    },
    onMode: openMenu
  });
}

let last = performance.now();
function frame(now) {
  const dt = Math.min(0.033, (now - last) / 1000);
  last = now;

  const actions = [...keyboard.read(), ...gamepads.read()];
  if (actions.some((a) => a.type === "menu")) {
    openMenu(mode === "fight" ? "pause" : "menu");
    updateMenu();
  }

  if (mode === "fight") {
    match.update(dt, actions);
    if (match.isComplete()) {
      mode = "results";
      menu.hidden = false;
      updateMenu();
    }
  }

  renderer.draw(match.snapshot(), mode);
  renderHud(hud, match.snapshot(), FRUITS);
  requestAnimationFrame(frame);
}

updateMenu();
requestAnimationFrame(frame);
