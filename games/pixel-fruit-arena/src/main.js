import { FRUITS } from "./fruits/fruits.js";
import { STAGES, stageFor } from "./stages/stages.js";
import { createCharacter, COSMETICS } from "./characters/characterCreator.js";
import { COMBAT_STYLES } from "./combat/combatStyles.js";
import { createMatch } from "./systems/matchSystem.js";
import { KeyboardInput, GamepadInput, routeActions, buildAssignments } from "./multiplayer/input.js";
import { Renderer } from "./ui/renderer.js";
import { renderHud, renderMenu } from "./ui/dom.js";
import "./systems/runtimeConfig.js";

const canvas = document.querySelector("#game");
const hud = document.querySelector("#hud");
const menu = document.querySelector("#menu");
const gameWrap = document.querySelector("#gameWrap");
const screenButton = document.querySelector("#screenButton");
const deviceStatus = document.querySelector("#deviceStatus");
const renderer = new Renderer(canvas);
const keyboard = new KeyboardInput();
const gamepads = new GamepadInput();

const saveKey = "prismtek.pixelFruitArena.profile";
const guestsKey = "prismtek.pixelFruitArena.guests";
const fruitIds = Object.keys(FRUITS);

const profile = normalizeProfile(safeLoad(saveKey) || createCharacter({
  name: "Prism Runner",
  spriteKey: "male_basic",
  combatStyle: "duelist",
  appearance: {
    hairStyle: "crest",
    clothingStyle: "runner",
    hairColor: "#5ee7ff",
    skinTone: "#8d563f",
    outfitPrimary: "#26344f",
    outfitSecondary: "#f4c542",
    accessoryColor: "#ef476f"
  },
  ownedFruits: fruitIds,
  equippedFruit: "flame"
}));

let mode = "menu";
let prevScreen = "menu";
let lastWinnerName = "";
let deferredInstall = null;
let serviceWorkerReady = false;
let match = null;
let assignments = {};
let showHitboxes = false;

const lobby = { playerCount: 2, stageId: "sky_ruins", training: false, cpuGuests: false, players: buildLobbyPlayers() };
registerPortableRuntime();

function safeLoad(key) {
  try { return JSON.parse(localStorage.getItem(key) || "null"); }
  catch { localStorage.removeItem(key); return null; }
}

function normalizeProfile(p) {
  p.owned_fruits ||= fruitIds;
  p.equipped_fruit ||= p.equippedFruit || p.owned_fruits[0] || "flame";
  p.fruit_mastery ||= Object.fromEntries(p.owned_fruits.map((id) => [id, 0]));
  p.sprite_key ||= "male_basic";
  p.combat_style ||= "duelist";
  p.appearance = { ...COSMETICS.presets[0], ...(p.appearance || {}) };
  p.appearance.clothingStyle ||= p.appearance.outfitStyle || "runner";
  return p;
}
function persistProfile() { localStorage.setItem(saveKey, JSON.stringify(profile)); }
function persistGuests() { localStorage.setItem(guestsKey, JSON.stringify(lobby.players.slice(1))); }

function buildLobbyPlayers() {
  const savedGuests = safeLoad(guestsKey) || [];
  const players = [lobbyPlayerFromProfile()];
  for (let slot = 1; slot < 4; slot += 1) {
    const saved = savedGuests[slot - 1];
    players.push(normalizeLobbyPlayer(saved ? { ...defaultGuest(slot), ...saved } : defaultGuest(slot), slot));
  }
  return players;
}

function normalizeLobbyPlayer(player, slot = 0) {
  player.sprite_key ||= slot % 2 === 0 ? "male_basic" : "female_basic";
  player.combat_style ||= COSMETICS.combatStyles[slot % COSMETICS.combatStyles.length];
  player.appearance = { ...COSMETICS.presets[slot % COSMETICS.presets.length], ...(player.appearance || {}) };
  player.appearance.clothingStyle ||= player.appearance.outfitStyle || COSMETICS.presets[slot % COSMETICS.presets.length].clothingStyle || "runner";
  return player;
}

function lobbyPlayerFromProfile() {
  return { device: "kb1", name: profile.name, sprite_key: profile.sprite_key, combat_style: profile.combat_style, fruitId: profile.equipped_fruit, appearance: { ...profile.appearance } };
}
function defaultGuest(slot) {
  const spriteKeys = ["male_basic", "female_basic", "dude", "owlet"];
  return { device: "cpu", name: `P${slot + 1} Guest`, sprite_key: spriteKeys[slot % spriteKeys.length], combat_style: COSMETICS.combatStyles[slot % COSMETICS.combatStyles.length], fruitId: fruitIds[slot % fruitIds.length], appearance: { ...COSMETICS.presets[slot % COSMETICS.presets.length] } };
}

function openLobby(playerCount, options = {}) {
  lobby.playerCount = playerCount;
  lobby.training = Boolean(options.training);
  lobby.cpuGuests = Boolean(options.cpuGuests);
  lobby.players[0] = lobbyPlayerFromProfile();
  const pads = gamepads.connected();
  for (let slot = 1; slot < lobby.playerCount; slot += 1) {
    const player = normalizeLobbyPlayer(lobby.players[slot], slot);
    if (lobby.cpuGuests) { player.device = "cpu"; player.name = `${FRUITS[player.fruitId].name.replace(" Fruit", "")} CPU`; }
    else if (player.device === "cpu") {
      const candidates = ["kb2", "pad0", "pad1", "pad2", "pad3"].filter((id) => deviceConnected(id, pads) && !deviceTaken(id, slot));
      player.device = candidates[0] || "cpu";
    }
  }
  mode = "lobby"; menu.hidden = false; updateMenu();
}
function deviceConnected(id, pads = gamepads.connected()) { return id === "kb1" || id === "kb2" || id === "cpu" ? true : pads.some((pad) => `pad${pad.index}` === id); }
function deviceTaken(id, exceptSlot) { return id === "cpu" ? false : lobby.players.slice(0, lobby.playerCount).some((player, slot) => slot !== exceptSlot && player.device === id); }
function deviceOptions(slot) { const pads = gamepads.connected(); const ids = ["kb1", "kb2", ...pads.map((pad) => `pad${pad.index}`), "cpu"]; const current = lobby.players[slot].device; if (!ids.includes(current)) ids.unshift(current); return ids; }

function beginFight() {
  const count = lobby.playerCount;
  const players = [];
  for (let slot = 0; slot < count; slot += 1) {
    const config = normalizeLobbyPlayer(lobby.players[slot], slot);
    const isCpu = config.device === "cpu";
    const character = slot === 0 ? syncProfileFromLobby() : createCharacter({ name: config.name, spriteKey: config.sprite_key, combatStyle: config.combat_style, appearance: { ...config.appearance }, ownedFruits: fruitIds, equippedFruit: config.fruitId, cpu: isCpu });
    players.push({ slot, character, fruitId: config.fruitId });
  }
  if (lobby.training) {
    const dummy = createCharacter({ name: "Training Dummy", spriteKey: "female_basic", combatStyle: "guardian", ownedFruits: fruitIds, equippedFruit: "rubber", cpu: true });
    dummy.dummy = true;
    players.push({ slot: players.length, character: dummy, fruitId: "rubber" });
  }
  assignments = buildAssignments(lobby.players.slice(0, count).map((p) => p.device));
  showHitboxes = lobby.training;
  match = createMatch({ stage: stageFor(lobby.stageId), players, fruits: FRUITS, training: lobby.training });
  persistGuests(); mode = "fight"; menu.hidden = true;
}
function syncProfileFromLobby() { const c = normalizeLobbyPlayer(lobby.players[0], 0); profile.name = c.name || "Prism Runner"; profile.sprite_key = c.sprite_key; profile.combat_style = c.combat_style; profile.appearance = { ...c.appearance }; profile.equipped_fruit = c.fruitId; profile.fruit_mastery[c.fruitId] ||= 0; persistProfile(); return profile; }
function quitToMenu() { match = null; mode = "menu"; menu.hidden = false; updateMenu(); }

function updateMenu() {
  renderMenu(menu, {
    mode, profile, lobby, match, showHitboxes, winnerName: lastWinnerName, fruits: FRUITS, stages: STAGES, cosmetics: COSMETICS, combatStyles: COMBAT_STYLES, canInstall: Boolean(deferredInstall), connectedPads: gamepads.connected().length, deviceOptions, onOpenLobby: openLobby,
    onStage: (stageId) => { lobby.stageId = stageId; updateMenu(); },
    onLobbyChange: (slot, key, value) => {
      const player = lobby.players[slot]; if (!player) return;
      if (key === "name") { player.name = value.slice(0, 18); if (slot === 0) { profile.name = player.name || "Prism Runner"; persistProfile(); } else persistGuests(); return; }
      if (key === "device") { const other = lobby.players.slice(0, lobby.playerCount).findIndex((p, i) => i !== slot && p.device === value); if (other >= 0 && value !== "cpu") lobby.players[other].device = player.device; player.device = value; }
      else if (key === "fruitId") player.fruitId = value;
      else if (key === "sprite_key" || key === "combat_style") player[key] = value;
      else player.appearance[key] = value;
      if (slot === 0) syncProfileFromLobby(); else persistGuests(); updateMenu();
    },
    onBeginFight: beginFight,
    onResume: () => { mode = "fight"; menu.hidden = true; },
    onQuit: quitToMenu,
    onRematch: beginFight,
    onToggleHitboxes: () => { showHitboxes = !showHitboxes; updateMenu(); },
    onEquip: (fruitId) => { profile.equipped_fruit = fruitId; if (!profile.owned_fruits.includes(fruitId)) profile.owned_fruits.push(fruitId); profile.fruit_mastery[fruitId] ||= 0; persistProfile(); updateMenu(); },
    onName: (name) => { profile.name = name.slice(0, 18) || "Prism Runner"; persistProfile(); },
    onAppearance: (key, value) => { profile.appearance[key] = value; persistProfile(); updateMenu(); },
    onCharacterOption: (key, value) => { profile[key] = value; persistProfile(); updateMenu(); },
    onMode: (nextMode) => { if (nextMode === "controls") prevScreen = mode; if (nextMode === "menu" && prevScreen === "pause" && mode === "controls") { prevScreen = "menu"; mode = "pause"; } else mode = nextMode; menu.hidden = false; updateMenu(); },
    onInstall: promptInstall
  });
}

function handleNav(dir) {
  const content = menu.querySelector(".menu-content"); if (!content) return;
  if (dir === "start" && mode === "lobby") { beginFight(); return; }
  if (dir === "back") { (content.querySelector("[data-back]") || content.querySelector("[data-resume]"))?.click(); return; }
  const focusables = Array.from(content.querySelectorAll("button:not([disabled]), select, input[type=radio]")).filter((el) => el.offsetParent !== null);
  if (!focusables.length) return;
  const active = document.activeElement;
  if (!focusables.includes(active)) { focusables[0].focus(); return; }
  if (dir === "confirm") { active instanceof HTMLSelectElement ? (active.selectedIndex = (active.selectedIndex + 1) % active.options.length, active.dispatchEvent(new Event("change", { bubbles: true }))) : active.click(); return; }
  if (active instanceof HTMLSelectElement && (dir === "left" || dir === "right")) { const step = dir === "right" ? 1 : -1; active.selectedIndex = (active.selectedIndex + step + active.options.length) % active.options.length; active.dispatchEvent(new Event("change", { bubbles: true })); return; }
  nearestInDirection(active, focusables, dir)?.focus();
}
function nearestInDirection(from, candidates, dir) { const r = from.getBoundingClientRect(); const cx = r.left + r.width / 2; const cy = r.top + r.height / 2; let best = null; let bestScore = Infinity; for (const el of candidates) { if (el === from) continue; const er = el.getBoundingClientRect(); const dx = er.left + er.width / 2 - cx; const dy = er.top + er.height / 2 - cy; const forward = dir === "up" ? -dy : dir === "down" ? dy : dir === "left" ? -dx : dx; const sideways = dir === "up" || dir === "down" ? Math.abs(dx) : Math.abs(dy); if (forward < 4) continue; const score = forward + sideways * 2.5; if (score < bestScore) { bestScore = score; best = el; } } return best; }
function promptInstall() { if (!deferredInstall) return; deferredInstall.prompt(); deferredInstall.userChoice.finally(() => { deferredInstall = null; updateMenu(); }); }
function registerPortableRuntime() { if ("serviceWorker" in navigator) navigator.serviceWorker.register("./sw.js").then(() => { serviceWorkerReady = true; renderDeviceStatus(); }).catch(() => renderDeviceStatus()); window.addEventListener("beforeinstallprompt", (event) => { event.preventDefault(); deferredInstall = event; updateMenu(); renderDeviceStatus(); }); screenButton?.addEventListener("click", () => document.fullscreenElement ? document.exitFullscreen?.() : gameWrap?.requestFullscreen?.()); window.addEventListener("gamepadconnected", () => { renderDeviceStatus(); if (mode !== "fight") updateMenu(); }); window.addEventListener("gamepaddisconnected", () => { renderDeviceStatus(); if (mode !== "fight") updateMenu(); }); window.addEventListener("resize", renderDeviceStatus); renderDeviceStatus(); }
function renderDeviceStatus() { if (!deviceStatus) return; const pads = gamepads.connected(); const installState = deferredInstall ? "Install ready" : "Install via browser menu"; const offlineState = serviceWorkerReady ? "Offline cache ready" : "Offline cache pending"; deviceStatus.textContent = `${pads.length} controller${pads.length === 1 ? "" : "s"} | ${offlineState} | ${installState}`; }

let last = performance.now();
function frame(now) {
  const dt = Math.min(0.033, (now - last) / 1000); last = now;
  const rawActions = [...keyboard.read(), ...gamepads.read()];
  if (rawActions.some((a) => a.type === "menu")) { if (mode === "fight") { mode = "pause"; menu.hidden = false; updateMenu(); } else if (mode === "pause") { mode = "fight"; menu.hidden = true; } }
  if (mode === "fight" && match) { const actions = routeActions(rawActions, assignments); match.update(dt, actions); if (match.isComplete()) { lastWinnerName = match.winner()?.character.name || "No one"; mode = "results"; menu.hidden = false; updateMenu(); } }
  else for (const nav of gamepads.readNav()) handleNav(nav.dir);
  if (match) { const snapshot = match.snapshot(); renderer.draw(snapshot, mode, { showHitboxes: showHitboxes && (match.training || mode === "pause") }); renderHud(hud, snapshot, FRUITS); } else { renderer.draw(emptySnapshot(), mode, {}); hud.innerHTML = ""; }
  requestAnimationFrame(frame);
}
function emptySnapshot() { return { stage: stageFor(lobby.stageId), fighters: [], effects: [], events: [], elapsed: performance.now() / 1000 }; }
updateMenu(); requestAnimationFrame(frame);
