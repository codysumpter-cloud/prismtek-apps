import { masteryFor } from "../fruits/fruits.js";
import { DEVICE_LABELS } from "../multiplayer/input.js";

const BODY_NAMES = { pink: "Imp", owlet: "Owlet", dude: "Dude" };

export function fruitIcon(fruit, size = 26) {
  return `<svg class="fruit-icon" width="${size}" height="${size}" viewBox="0 0 16 16" aria-hidden="true" shape-rendering="crispEdges">
    <rect x="7" y="1" width="2" height="2" fill="#5b3926"/>
    <rect x="9" y="0" width="3" height="2" fill="#2dd36f"/>
    <rect x="3" y="3" width="10" height="2" fill="${fruit.color}"/>
    <rect x="2" y="5" width="12" height="7" fill="${fruit.color}"/>
    <rect x="3" y="12" width="10" height="2" fill="${fruit.color}"/>
    <rect x="4" y="5" width="2" height="2" fill="rgba(255,255,255,.55)"/>
    <rect x="7" y="6" width="4" height="1" fill="rgba(0,0,0,.35)"/>
    <rect x="6" y="7" width="1" height="3" fill="rgba(0,0,0,.35)"/>
    <rect x="7" y="10" width="3" height="1" fill="rgba(0,0,0,.35)"/>
    <rect x="10" y="8" width="1" height="2" fill="rgba(0,0,0,.35)"/>
    <rect x="8" y="8" width="1" height="1" fill="rgba(0,0,0,.35)"/>
  </svg>`;
}

export function renderHud(node, snapshot, fruits) {
  node.innerHTML = snapshot.fighters.map((f) => {
    const fruit = fruits[f.fruitId];
    const style = titleCase(f.character.combat_style || "duelist");
    const health = Math.max(0, Math.round(f.health ?? 100));
    const damage = Math.round(f.damage || 0);
    const haki = Math.round(f.haki || 0);
    return `<article class="hud-card ${f.awakened > 0 ? "is-awakened" : ""} ${f.hakiGuard > 0 ? "is-haki" : ""}" style="--fruit:${fruit.color};--health:${health}%;--haki:${haki}%">
      <strong>${escapeHtml(f.character.name || f.id)}</strong>
      <span>${fruitIcon(fruit, 14)} ${fruit.name} | ${style}</span>
      <b>${snapshot.training && f.dummy ? "DUMMY" : `${f.stocks} stocks`}</b>
      <div class="hud-bars" aria-label="health, awakening, and haki meters">
        <meter class="health-meter" min="0" max="100" value="${health}"></meter>
        <meter class="awakening-meter" min="0" max="100" value="${f.awakening}"></meter>
        <meter class="haki-meter" min="0" max="100" value="${haki}"></meter>
      </div>
      <small>${damage}% damage | ${health} HP | Haki ${haki}% | M${Math.round(masteryFor(f.character, f.fruitId))}</small>
    </article>`;
  }).join("");
}

export function renderMenu(node, props) {
  const screens = { menu: mainMenu, creator: creatorScreen, fruits: fruitsScreen, controls: controlsScreen, lobby: lobbyScreen, pause: pauseScreen, results: resultsScreen };
  const screen = screens[props.mode] || mainMenu;
  node.innerHTML = `<div class="menu-content" data-screen="${props.mode}">${screen(props)}</div>`;
  bind(node, props);
}

function mainMenu(props) {
  return `
    <header class="menu-header"><h1>Pixel Fruit Arena</h1><p>Local platform fighting prototype</p></header>
    <nav class="menu-actions main-nav">
      <button class="primary" data-open-lobby="2" data-cpu="true">Fight CPU</button>
      <button data-open-lobby="1" data-training="true">Training Room</button>
      <button data-open-lobby="2">2 Players</button><button data-open-lobby="3">3 Players</button><button data-open-lobby="4">4 Players</button>
    </nav>
    <nav class="menu-actions secondary-nav"><button data-mode="creator">Character Creator</button><button data-mode="fruits">Fruit Powers</button><button data-mode="controls">Controls</button><button data-install ${props.canInstall ? "" : "disabled"}>Install App</button></nav>
    <footer>${deviceSummary(props)} - Hold a direction with any attack for neutral, forward, back, up, and down variants.</footer>`;
}

function creatorScreen(props) {
  return `
    <header class="menu-header compact"><h2>Character Creator</h2><p>Your saved fighter - used as Player 1 everywhere.</p></header>
    <section class="creator">
      <label>Name <input data-name value="${escapeHtml(props.profile.name)}" maxlength="18"></label>
      ${choice("Body", "sprite_key", props.cosmetics.spriteKeys, props.profile.sprite_key, BODY_NAMES)}
      ${appearanceChoice("Hair Style", "hairStyle", props.cosmetics.hairStyles, props.profile.appearance.hairStyle)}
      ${styleChoice(props.profile.combat_style, props.combatStyles)}
      ${color("Hair", "hairColor", props.cosmetics.hairColors, props.profile.appearance.hairColor)}
      ${color("Skin", "skinTone", props.cosmetics.skinTones, props.profile.appearance.skinTone)}
      ${color("Outfit", "outfitPrimary", props.cosmetics.outfitColors, props.profile.appearance.outfitPrimary)}
      ${color("Trim", "outfitSecondary", props.cosmetics.accessoryColors, props.profile.appearance.outfitSecondary)}
      ${color("Accessory", "accessoryColor", props.cosmetics.accessoryColors, props.profile.appearance.accessoryColor)}
    </section><nav class="menu-actions"><button data-mode="menu" data-back>Back</button></nav>`;
}

function fruitsScreen(props) {
  return `
    <header class="menu-header compact"><h2>Fruit Powers</h2><p>Every fruit has three base moves, directional variants, and stronger awakened versions.</p></header>
    <section class="fruit-grid">${Object.values(props.fruits).map((fruit) => `<article class="fruit-card ${props.profile.equipped_fruit === fruit.id ? "is-equipped" : ""}" style="--fruit:${fruit.color}">
      <h3>${fruitIcon(fruit, 22)} ${fruit.name}</h3>
      <ol class="ability-list">${fruit.abilities.map((a, i) => `<li><b>${i + 1}</b> ${escapeHtml(a.name)} <small>${escapeHtml(titleCase(a.kind))}</small></li>`).join("")}</ol>
      <strong>Awakening: ${escapeHtml(fruit.awakening)}</strong>
      <small>${escapeHtml(fruit.awakeningEffect || "Awakening upgrades damage, range, cooldown, and hit pressure.")}</small>
      <small>Mastery ${Math.round(masteryFor(props.profile, fruit.id))}</small>
      <button data-equip="${fruit.id}">${props.profile.equipped_fruit === fruit.id ? "Equipped" : "Equip"}</button>
    </article>`).join("")}</section>
    <nav class="menu-actions"><button data-mode="menu" data-back>Back</button></nav>`;
}

function controlsScreen() {
  return `
    <header class="menu-header compact"><h2>Controls</h2><p>Attacks 1, 2, 3 are your equipped fruit's three abilities.</p></header>
    <section class="controls-grid">
      <table class="controls-table"><caption>Keyboard - Player 1</caption><tr><td>Move</td><td><kbd>&larr;</kbd> <kbd>&rarr;</kbd></td></tr><tr><td>Jump / Double Jump</td><td><kbd>&uarr;</kbd></td></tr><tr><td>Attack 1 / 2 / 3</td><td><kbd>/</kbd> <kbd>.</kbd> <kbd>,</kbd></td></tr><tr><td>Dodge</td><td><kbd>Right Shift</kbd></td></tr><tr><td>Haki Guard</td><td><kbd>Right Ctrl</kbd></td></tr><tr><td>Awaken</td><td><kbd>Enter</kbd></td></tr><tr><td>Pause</td><td><kbd>Esc</kbd></td></tr></table>
      <table class="controls-table"><caption>Keyboard - Player 2</caption><tr><td>Move</td><td><kbd>A</kbd> <kbd>D</kbd></td></tr><tr><td>Jump / Double Jump</td><td><kbd>W</kbd></td></tr><tr><td>Attack 1 / 2 / 3</td><td><kbd>F</kbd> <kbd>G</kbd> <kbd>H</kbd></td></tr><tr><td>Dodge</td><td><kbd>Left Shift</kbd></td></tr><tr><td>Haki Guard</td><td><kbd>Q</kbd></td></tr><tr><td>Awaken</td><td><kbd>T</kbd></td></tr></table>
      <table class="controls-table"><caption>Attack Modifiers - hold a direction while attacking</caption><tr><td>Neutral</td><td>Standard attack</td></tr><tr><td>Forward</td><td>Stronger, longer reach, lunges in</td></tr><tr><td>Back</td><td>Quicker recovery, hops back, lighter hit</td></tr><tr><td>Up</td><td>Rising hit, launches skyward</td></tr><tr><td>Down</td><td>Low hit, spikes airborne foes and pins grounded ones</td></tr></table>
      <table class="controls-table"><caption>Controller - any player</caption><tr><td>Move / Aim</td><td>Left Stick / D-pad</td></tr><tr><td>Jump</td><td><kbd>A</kbd></td></tr><tr><td>Attack 1 / 2 / 3</td><td><kbd>X</kbd> <kbd>Y</kbd> <kbd>B</kbd></td></tr><tr><td>Dodge</td><td><kbd>LB</kbd></td></tr><tr><td>Haki Guard</td><td><kbd>LT</kbd></td></tr><tr><td>Awaken</td><td><kbd>RB</kbd></td></tr><tr><td>Pause</td><td><kbd>Start</kbd></td></tr></table>
    </section><nav class="menu-actions"><button data-mode="menu" data-back>Back</button></nav>`;
}

function lobbyScreen(props) {
  const lobby = props.lobby;
  const title = lobby.training ? "Training Room" : lobby.cpuGuests ? "Fight CPU" : `${lobby.playerCount} Player Battle`;
  return `<header class="menu-header compact"><h2>${title}</h2><p>Set up every fighter, then start the match.</p></header>
    <section class="stage-row"><span class="row-label">Stage</span>${Object.values(props.stages).map((stage) => `<button class="choice-button ${lobby.stageId === stage.id ? "is-selected" : ""}" data-stage="${stage.id}" type="button">${escapeHtml(stage.name)}</button>`).join("")}</section>
    <section class="lobby-grid players-${lobby.playerCount}">${lobby.players.slice(0, lobby.playerCount).map((player, slot) => playerCard(player, slot, props)).join("")}</section>
    <nav class="menu-actions"><button class="primary" data-begin-fight>Start ${lobby.training ? "Training" : "Fight"}</button><button data-mode="menu" data-back>Back</button></nav>
    <footer>Tip: Haki can guard or empower pressure. ${deviceSummary(props)}</footer>`;
}

function playerCard(player, slot, props) {
  const isCpu = player.device === "cpu";
  const fruit = props.fruits[player.fruitId];
  const deviceOptions = props.deviceOptions(slot);
  return `<article class="player-card" data-slot="${slot}" style="--fruit:${fruit.color}">
    <header><b>P${slot + 1}</b><input data-lobby-name="${slot}" value="${escapeHtml(player.name)}" maxlength="18" aria-label="Player ${slot + 1} name" ${isCpu ? "disabled" : ""}></header>
    <label class="device-row">Device<select data-lobby-device="${slot}">${deviceOptions.map((id) => `<option value="${id}" ${player.device === id ? "selected" : ""}>${DEVICE_LABELS[id] || id}</option>`).join("")}</select></label>
    ${lobbyChoice(slot, "Body", "sprite_key", props.cosmetics.spriteKeys, player.sprite_key, BODY_NAMES)}${lobbyChoice(slot, "Hair", "hairStyle", props.cosmetics.hairStyles, player.appearance.hairStyle)}
    ${lobbySwatches(slot, "Hair Color", "hairColor", props.cosmetics.hairColors, player.appearance.hairColor)}${lobbySwatches(slot, "Skin", "skinTone", props.cosmetics.skinTones, player.appearance.skinTone)}${lobbySwatches(slot, "Outfit", "outfitPrimary", props.cosmetics.outfitColors, player.appearance.outfitPrimary)}${lobbySwatches(slot, "Trim", "outfitSecondary", props.cosmetics.accessoryColors, player.appearance.outfitSecondary)}${lobbySwatches(slot, "Accessory", "accessoryColor", props.cosmetics.accessoryColors, player.appearance.accessoryColor)}
    ${lobbyChoice(slot, "Style", "combat_style", Object.keys(props.combatStyles), player.combat_style, Object.fromEntries(Object.values(props.combatStyles).map((s) => [s.id, s.name])))}
    <fieldset class="choice-grid fruit-row"><legend>Fruit Power</legend>${Object.values(props.fruits).map((f) => `<button class="choice-button fruit-choice ${player.fruitId === f.id ? "is-selected" : ""}" style="--fruit:${f.color}" data-lobby-fruit="${slot}" data-value="${f.id}" type="button" title="${escapeHtml(f.name)}: ${f.abilities.map((a) => a.name).join(", "))}">${fruitIcon(f, 20)}<span>${escapeHtml(f.name.replace(" Fruit", ""))}</span></button>`).join("")}</fieldset>
  </article>`;
}

function pauseScreen(props) { return `<header class="menu-header compact"><h2>Paused</h2></header><nav class="menu-actions column"><button class="primary" data-resume>Resume</button>${props.match?.training ? `<button data-toggle-hitboxes>${props.showHitboxes ? "Hide" : "Show"} Hitboxes</button>` : ""}<button data-mode="controls">Controls</button><button data-quit>Quit to Menu</button></nav>`; }
function resultsScreen(props) { return `<header class="menu-header"><h2>Results</h2><p><b>${escapeHtml(props.winnerName || "No one")}</b> survived the arena.</p></header><nav class="menu-actions"><button class="primary" data-rematch>Rematch</button><button data-quit data-back>Back to Menu</button></nav>`; }
function deviceSummary(props) { const pads = props.connectedPads || 0; return `${pads} controller${pads === 1 ? "" : "s"} connected.`; }
function choice(label, key, values, current, names = {}) { return `<fieldset class="choice-grid"><legend>${label}</legend>${values.map((value) => `<button class="choice-button ${value === current ? "is-selected" : ""}" data-character-option="${key}" data-value="${value}" type="button">${escapeHtml(names[value] || value)}</button>`).join("")}</fieldset>`; }
function appearanceChoice(label, key, values, current) { return `<fieldset class="choice-grid"><legend>${label}</legend>${values.map((value) => `<button class="choice-button ${value === current ? "is-selected" : ""}" data-appearance="${key}" data-value="${value}" type="button">${escapeHtml(value)}</button>`).join("")}</fieldset>`; }
function styleChoice(current, combatStyles) { return `<fieldset class="choice-grid wide"><legend>Style</legend>${Object.values(combatStyles).map((style) => `<button class="choice-button style-choice ${style.id === current ? "is-selected" : ""}" data-character-option="combat_style" data-value="${style.id}" type="button"><strong>${escapeHtml(style.name)}</strong><small>${escapeHtml(style.summary)}</small></button>`).join("")}</fieldset>`; }
function color(label, key, values, current) { return `<fieldset><legend>${label}</legend>${values.map((value) => `<input data-appearance="${key}" type="radio" name="${key}" value="${value}" ${value === current ? "checked" : ""} style="--swatch:${value}" title="${value}">`).join("")}</fieldset>`; }
function lobbyChoice(slot, label, key, values, current, names = {}) { return `<fieldset class="choice-grid"><legend>${label}</legend>${values.map((value) => `<button class="choice-button ${value === current ? "is-selected" : ""}" data-lobby-option="${slot}" data-key="${key}" data-value="${value}" type="button">${escapeHtml(names[value] || value)}</button>`).join("")}</fieldset>`; }
function lobbySwatches(slot, label, key, values, current) { return `<fieldset class="swatch-row"><legend>${label}</legend>${values.map((value) => `<button class="swatch ${value === current ? "is-selected" : ""}" data-lobby-option="${slot}" data-key="${key}" data-value="${value}" style="--swatch:${value}" type="button" title="${value}" aria-label="${label} ${value}"></button>`).join("")}</fieldset>`; }

function bind(node, props) {
  node.querySelectorAll("[data-open-lobby]").forEach((button) => button.addEventListener("click", () => props.onOpenLobby(Number(button.dataset.openLobby), { cpuGuests: button.dataset.cpu === "true", training: button.dataset.training === "true" })));
  node.querySelectorAll("[data-mode]").forEach((button) => button.addEventListener("click", () => props.onMode(button.dataset.mode)));
  node.querySelectorAll("[data-equip]").forEach((button) => button.addEventListener("click", () => props.onEquip(button.dataset.equip)));
  node.querySelector("[data-install]")?.addEventListener("click", () => props.onInstall?.());
  node.querySelector("[data-begin-fight]")?.addEventListener("click", () => props.onBeginFight());
  node.querySelector("[data-resume]")?.addEventListener("click", () => props.onResume());
  node.querySelector("[data-quit]")?.addEventListener("click", () => props.onQuit());
  node.querySelector("[data-rematch]")?.addEventListener("click", () => props.onRematch());
  node.querySelector("[data-toggle-hitboxes]")?.addEventListener("click", () => props.onToggleHitboxes());
  node.querySelectorAll("[data-stage]").forEach((button) => button.addEventListener("click", () => props.onStage(button.dataset.stage)));
  const name = node.querySelector("[data-name]");
  if (name) name.addEventListener("input", (event) => props.onName(event.target.value));
  node.querySelectorAll("input[data-appearance]").forEach((input) => input.addEventListener("input", () => props.onAppearance(input.dataset.appearance, input.value)));
  node.querySelectorAll("button[data-appearance]").forEach((button) => button.addEventListener("click", () => props.onAppearance(button.dataset.appearance, button.dataset.value)));
  node.querySelectorAll("[data-character-option]").forEach((button) => button.addEventListener("click", () => props.onCharacterOption(button.dataset.characterOption, button.dataset.value)));
  node.querySelectorAll("[data-lobby-name]").forEach((input) => input.addEventListener("input", () => props.onLobbyChange(Number(input.dataset.lobbyName), "name", input.value)));
  node.querySelectorAll("[data-lobby-device]").forEach((select) => select.addEventListener("change", () => props.onLobbyChange(Number(select.dataset.lobbyDevice), "device", select.value)));
  node.querySelectorAll("[data-lobby-option]").forEach((button) => button.addEventListener("click", () => props.onLobbyChange(Number(button.dataset.lobbyOption), button.dataset.key, button.dataset.value)));
  node.querySelectorAll("[data-lobby-fruit]").forEach((button) => button.addEventListener("click", () => props.onLobbyChange(Number(button.dataset.lobbyFruit), "fruitId", button.dataset.value)));
}

function escapeHtml(value) { return String(value).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;" }[c])); }
function titleCase(value) { return String(value).replace(/_/g, " ").replace(/\b\w/g, (letter) => letter.toUpperCase()); }
