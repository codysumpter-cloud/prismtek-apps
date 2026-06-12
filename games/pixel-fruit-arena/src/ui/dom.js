import { masteryFor } from "../fruits/fruits.js";

export function renderHud(node, snapshot, fruits) {
  node.innerHTML = snapshot.fighters.map((f) => {
    const fruit = fruits[f.fruitId];
    const style = titleCase(f.character.combat_style || "duelist");
    return `<article class="hud-card" style="--fruit:${fruit.color}">
      <strong>${escapeHtml(f.character.name || f.id)}</strong>
      <span>${fruit.icon} ${fruit.name} | ${style}</span>
      <b>${f.stocks} stocks</b>
      <meter min="0" max="100" value="${f.awakening}"></meter>
      <small>${Math.round(f.damage)}% | M${Math.round(masteryFor(f.character, f.fruitId))}</small>
    </article>`;
  }).join("");
}

export function renderMenu(node, props) {
  const winner = props.mode === "results" ? props.winnerName || props.profile.name : "";
  node.innerHTML = `
    <div class="menu-content">
      <header>
        <h1>Pixel Fruit Arena</h1>
        <p>Local platform fighting prototype</p>
      </header>
      ${props.mode === "results" ? `<h2>Results</h2><p>${escapeHtml(winner)} survived the arena.</p>` : ""}
      <nav class="menu-actions">
        <button data-solo="true">Fight CPU</button>
        <button data-start="2">2P Local</button>
        <button data-start="3">3P Match</button>
        <button data-start="4">4P Match</button>
        <button data-mode="creator">Creator</button>
        <button data-mode="fruits">Fruits</button>
        <button data-install ${props.canInstall ? "" : "disabled"}>Install App</button>
      </nav>
      ${props.mode === "creator" ? creator(props) : ""}
      ${props.mode === "fruits" ? fruits(props) : ""}
      <footer>Keyboard P1: arrows, / . , RShift, Enter. P2: WASD, F G H, LShift, T. Controllers: left stick, face buttons, shoulders, start. Local 3P/4P uses connected controllers or simple CPU placeholders for extra slots.</footer>
    </div>`;
  node.querySelectorAll("[data-solo]").forEach((button) => button.addEventListener("click", () => props.onStart(2, { cpuGuests: true })));
  node.querySelectorAll("[data-start]").forEach((button) => button.addEventListener("click", () => props.onStart(Number(button.dataset.start))));
  node.querySelectorAll("[data-mode]").forEach((button) => button.addEventListener("click", () => props.onMode(button.dataset.mode)));
  node.querySelectorAll("[data-equip]").forEach((button) => button.addEventListener("click", () => props.onEquip(button.dataset.equip)));
  node.querySelector("[data-install]")?.addEventListener("click", () => props.onInstall?.());
  const name = node.querySelector("[data-name]");
  if (name) name.addEventListener("input", (event) => props.onName(event.target.value));
  node.querySelectorAll("input[data-appearance]").forEach((input) => input.addEventListener("input", (event) => props.onAppearance(input.dataset.appearance, event.target.value)));
  node.querySelectorAll("button[data-appearance]").forEach((button) => button.addEventListener("click", () => props.onAppearance(button.dataset.appearance, button.dataset.value)));
  node.querySelectorAll("[data-character-option]").forEach((button) => button.addEventListener("click", () => props.onCharacterOption(button.dataset.characterOption, button.dataset.value)));
}

function creator({ profile, cosmetics, combatStyles }) {
  return `<section class="creator">
    <label>Name <input data-name value="${escapeHtml(profile.name)}" maxlength="18"></label>
    ${choice("Body", "sprite_key", cosmetics.spriteKeys, profile.sprite_key, { pink: "Imp", owlet: "Owlet", dude: "Dude" })}
    ${appearanceChoice("Hair Style", "hairStyle", cosmetics.hairStyles, profile.appearance.hairStyle)}
    ${styleChoice(profile, combatStyles)}
    ${color("Hair", "hairColor", cosmetics.hairColors, profile.appearance.hairColor)}
    ${color("Skin", "skinTone", cosmetics.skinTones, profile.appearance.skinTone)}
    ${color("Outfit", "outfitPrimary", cosmetics.outfitColors, profile.appearance.outfitPrimary)}
    ${color("Trim", "outfitSecondary", cosmetics.accessoryColors, profile.appearance.outfitSecondary)}
    ${color("Accessory", "accessoryColor", cosmetics.accessoryColors, profile.appearance.accessoryColor)}
  </section>`;
}

function choice(label, key, values, current, names = {}) {
  return `<fieldset class="choice-grid"><legend>${label}</legend>${values.map((value) => `<button class="choice-button ${value === current ? "is-selected" : ""}" data-character-option="${key}" data-value="${value}" type="button">${escapeHtml(names[value] || value)}</button>`).join("")}</fieldset>`;
}

function appearanceChoice(label, key, values, current) {
  return `<fieldset class="choice-grid"><legend>${label}</legend>${values.map((value) => `<button class="choice-button ${value === current ? "is-selected" : ""}" data-appearance="${key}" data-value="${value}" type="button">${escapeHtml(value)}</button>`).join("")}</fieldset>`;
}

function styleChoice(profile, combatStyles) {
  return `<fieldset class="choice-grid wide"><legend>Style</legend>${Object.values(combatStyles).map((style) => `<button class="choice-button style-choice ${style.id === profile.combat_style ? "is-selected" : ""}" data-character-option="combat_style" data-value="${style.id}" type="button"><strong>${escapeHtml(style.name)}</strong><small>${escapeHtml(style.summary)}</small></button>`).join("")}</fieldset>`;
}

function color(label, key, values, current) {
  return `<fieldset><legend>${label}</legend>${values.map((value) => `<input data-appearance="${key}" type="radio" name="${key}" value="${value}" ${value === current ? "checked" : ""} style="--swatch:${value}" title="${value}">`).join("")}</fieldset>`;
}

function fruits({ profile, fruits }) {
  return `<section class="fruit-grid">${Object.values(fruits).map((fruit) => `<article class="fruit-card" style="--fruit:${fruit.color}">
    <h2>${fruit.name}</h2>
    <p>${fruit.abilities.map((a) => a.name).join(" | ")}</p>
    <strong>${fruit.awakening}</strong>
    <small>Mastery ${Math.round(masteryFor(profile, fruit.id))}</small>
    <button data-equip="${fruit.id}">${profile.equipped_fruit === fruit.id ? "Equipped" : "Equip"}</button>
  </article>`).join("")}</section>`;
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;" }[c]));
}

function titleCase(value) {
  return String(value).replace(/_/g, " ").replace(/\b\w/g, (letter) => letter.toUpperCase());
}
