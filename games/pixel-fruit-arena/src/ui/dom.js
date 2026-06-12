import { masteryFor } from "../fruits/fruits.js";

export function renderHud(node, snapshot, fruits) {
  node.innerHTML = snapshot.fighters.map((f) => {
    const fruit = fruits[f.fruitId];
    return `<article class="hud-card" style="--fruit:${fruit.color}">
      <strong>${escapeHtml(f.character.name || f.id)}</strong>
      <span>${fruit.icon} ${fruit.name}</span>
      <b>${f.stocks} stocks</b>
      <meter min="0" max="100" value="${f.awakening}"></meter>
      <small>${Math.round(f.damage)}% · M${Math.round(masteryFor(f.character, f.fruitId))}</small>
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
  node.querySelectorAll("[data-appearance]").forEach((input) => input.addEventListener("input", (event) => props.onAppearance(input.dataset.appearance, event.target.value)));
}

function creator({ profile, cosmetics }) {
  return `<section class="creator">
    <label>Name <input data-name value="${escapeHtml(profile.name)}" maxlength="18"></label>
    ${color("Hair", "hairColor", cosmetics.hairColors, profile.appearance.hairColor)}
    ${color("Skin", "skinTone", cosmetics.skinTones, profile.appearance.skinTone)}
    ${color("Outfit", "outfitPrimary", cosmetics.outfitColors, profile.appearance.outfitPrimary)}
    ${color("Trim", "outfitSecondary", cosmetics.accessoryColors, profile.appearance.outfitSecondary)}
    ${color("Accessory", "accessoryColor", cosmetics.accessoryColors, profile.appearance.accessoryColor)}
  </section>`;
}

function color(label, key, values, current) {
  return `<fieldset><legend>${label}</legend>${values.map((value) => `<input data-appearance="${key}" type="radio" name="${key}" value="${value}" ${value === current ? "checked" : ""} style="--swatch:${value}" title="${value}">`).join("")}</fieldset>`;
}

function fruits({ profile, fruits }) {
  return `<section class="fruit-grid">${Object.values(fruits).map((fruit) => `<article class="fruit-card" style="--fruit:${fruit.color}">
    <h2>${fruit.name}</h2>
    <p>${fruit.abilities.map((a) => a.name).join(" · ")}</p>
    <strong>${fruit.awakening}</strong>
    <small>Mastery ${Math.round(masteryFor(profile, fruit.id))}</small>
    <button data-equip="${fruit.id}">${profile.equipped_fruit === fruit.id ? "Equipped" : "Equip"}</button>
  </article>`).join("")}</section>`;
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", "\"": "&quot;", "'": "&#39;" }[c]));
}
