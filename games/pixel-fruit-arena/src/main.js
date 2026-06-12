import { FRUITS } from "./fruits/fruits.js";
import { SKY_RUINS } from "./stages/skyRuins.js";
import { createCharacter, COSMETICS } from "./characters/characterCreator.js";
import { COMBAT_STYLES } from "./combat/combatStyles.js";
import { createMatch } from "./systems/matchSystem.js";
import { KeyboardInput, GamepadInput } from "./multiplayer/input.js";
import { Renderer } from "./ui/renderer.js";
import { renderHud, renderMenu } from "./ui/dom.js";
import "./systems/runtimeConfig.js";

const canvas = document.querySelector("#game");
const hud = document.querySelector("#hud");
const menu = document.querySelector("#menu");
const gameWrap = document.querySelector("#gameWrap");
const screenButton = document.querySelector("#screenButton");
const deviceStatus = document.querySelector("#deviceStatus");
const renderer = new Renderer(canvas, SKY_RUINS);
const keyboard = new KeyboardInput();
const gamepads = new GamepadInput();

const saveKey = "prismtek.pixelFruitArena.profile";
const stored = safeLoadProfile();
const profile = stored || createCharacter({
  name: "Prism Runner",
  spriteKey: "pink",
  combatStyle: "duelist",
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
profile.sprite_key ||= "pink";
profile.combat_style ||= "duelist";

let mode = "menu";
let lastWinnerName = "";
let deferredInstall = null;
let serviceWorkerReady = false;
let match = createMatch({
  stage: SKY_RUINS,
  players: [
    { slot: 0, character: profile, fruitId: profile.equipped_fruit },
    { slot: 1, character: createCharacter({ name: "Volt CPU", spriteKey: "owlet", ownedFruits: Object.keys(FRUITS), equippedFruit: "volt", cpu: true }), fruitId: "volt" }
  ],
  fruits: FRUITS
});

registerPortableRuntime();

function safeLoadProfile() {
  try {
    return JSON.parse(localStorage.getItem(saveKey) || "null");
  } catch {
    localStorage.removeItem(saveKey);
    return null;
  }
}

function persistProfile() {
  localStorage.setItem(saveKey, JSON.stringify(profile));
}

function startMatch(playerCount = 2, options = {}) {
  const fruitIds = Object.keys(FRUITS);
  const spriteKeys = ["pink", "owlet", "dude", "pink"];
  const players = Array.from({ length: playerCount }, (_, index) => ({
    slot: index,
    character: index === 0 ? profile : createCharacter({
      name: `P${index + 1} Guest`,
      ...(options.cpuGuests ? { name: `${FRUITS[fruitIds[index % fruitIds.length]].name.replace(" Fruit", "")} CPU` } : {}),
      spriteKey: spriteKeys[index % spriteKeys.length],
      combatStyle: COSMETICS.combatStyles[index % COSMETICS.combatStyles.length],
      appearance: COSMETICS.presets[index % COSMETICS.presets.length],
      ownedFruits: fruitIds,
      equippedFruit: fruitIds[index % fruitIds.length],
      cpu: Boolean(options.cpuGuests)
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
    winnerName: lastWinnerName,
    fruits: FRUITS,
    cosmetics: COSMETICS,
    combatStyles: COMBAT_STYLES,
    canInstall: Boolean(deferredInstall),
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
      updateMenu();
    },
    onCharacterOption: (key, value) => {
      profile[key] = value;
      persistProfile();
      updateMenu();
    },
    onMode: (nextMode) => {
      openMenu(nextMode);
      updateMenu();
    },
    onInstall: promptInstall
  });
}

function promptInstall() {
  if (!deferredInstall) return;
  deferredInstall.prompt();
  deferredInstall.userChoice.finally(() => {
    deferredInstall = null;
    updateMenu();
  });
}

function registerPortableRuntime() {
  if ("serviceWorker" in navigator) {
    navigator.serviceWorker.register("./sw.js").then(() => {
      serviceWorkerReady = true;
      renderDeviceStatus();
    }).catch(() => renderDeviceStatus());
  }

  window.addEventListener("beforeinstallprompt", (event) => {
    event.preventDefault();
    deferredInstall = event;
    updateMenu();
    renderDeviceStatus();
  });

  screenButton?.addEventListener("click", () => {
    if (document.fullscreenElement) {
      document.exitFullscreen?.();
    } else {
      gameWrap?.requestFullscreen?.();
    }
  });

  window.addEventListener("gamepadconnected", renderDeviceStatus);
  window.addEventListener("gamepaddisconnected", renderDeviceStatus);
  window.addEventListener("resize", renderDeviceStatus);
  renderDeviceStatus();
}

function renderDeviceStatus() {
  if (!deviceStatus) return;
  const pads = Array.from(navigator.getGamepads?.() || []).filter(Boolean);
  const installState = deferredInstall ? "Install ready" : "Install via browser menu";
  const offlineState = serviceWorkerReady ? "Offline cache ready" : "Offline cache pending";
  const shape = `${Math.round(window.innerWidth)}x${Math.round(window.innerHeight)}`;
  deviceStatus.textContent = `${pads.length} controller${pads.length === 1 ? "" : "s"} | ${offlineState} | ${installState} | ${shape}`;
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
      lastWinnerName = match.winner()?.character.name || "No one";
      mode = "results";
      menu.hidden = false;
      updateMenu();
    }
  }

  renderer.draw(match.snapshot(), mode);
  renderHud(hud, match.snapshot(), FRUITS);
  renderDeviceStatus();
  requestAnimationFrame(frame);
}

updateMenu();
requestAnimationFrame(frame);
