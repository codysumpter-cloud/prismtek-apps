import { GAME } from './config.js';
import { loadFruits, fruitById } from '../fruits/fruitRegistry.js';
import { loadStage } from '../stages/stageRegistry.js';
import { loadDefaultProfile, equipFruit, updateAppearance } from '../characters/characterCreator.js';
import { createMatch, stepMatch } from '../combat/combatState.js';
import { createInputManager, pollGamepads } from '../multiplayer/input.js';
import { drawEffects, drawPlayer, drawStage } from '../ui/render.js';

export async function bootGame(root) {
  const [fruits, stage] = await Promise.all([loadFruits(), loadStage()]);
  const profile = await loadDefaultProfile(fruits);
  const input = createInputManager(window);
  const state = { screen: 'menu', fruits, stage, profile, localPlayers: 2, match: null, input };
  render(root, state);
}

function render(root, state) {
  const screens = {
    menu: renderMenu,
    creator: renderCreator,
    fruits: renderFruitSelect,
    setup: renderSetup,
    match: renderMatch,
    results: renderResults,
  };
  root.innerHTML = '';
  root.appendChild(screens[state.screen](state, () => render(root, state)));
}

function panel(title, body) {
  const wrap = el('section', 'panel');
  wrap.append(el('h1', '', title), body);
  return wrap;
}

function renderMenu(state, refresh) {
  const body = el('div', 'grid two');
  body.append(card('Playable MVP', 'Create a custom brawler, equip modular Mystic Fruit powers, and fight on Sky Ruins Arena.'), card('Reference safety', 'Uploaded GIFs are reference-only development inputs and are never shipped or committed as permanent assets.'));
  body.append(button('Character Creator', () => nav(state, refresh, 'creator')));
  body.append(button('Fruit Selection', () => nav(state, refresh, 'fruits')));
  body.append(button('Local Match Setup', () => nav(state, refresh, 'setup')));
  body.append(button('Quick Start Battle', () => { start(state); nav(state, refresh, 'match'); }));
  return panel('Pixel Fruit Arena', body);
}

function renderCreator(state, refresh) {
  const a = state.profile.appearance;
  const body = el('div', 'grid two');
  body.append(field('Name', state.profile.name, (value) => { state.profile.name = value; }));
  body.append(selectField('Hair Style', ['tuft', 'cap', 'bob', 'spike'], a.hairStyle, (value) => updateAppearance(state.profile, { hairStyle: value })));
  body.append(colorField('Hair Color', a.hairColor, (value) => updateAppearance(state.profile, { hairColor: value })));
  body.append(colorField('Skin Tone', a.skinTone, (value) => updateAppearance(state.profile, { skinTone: value })));
  body.append(colorField('Outfit Primary', a.outfitPrimary, (value) => updateAppearance(state.profile, { outfitPrimary: value })));
  body.append(colorField('Outfit Secondary', a.outfitSecondary, (value) => updateAppearance(state.profile, { outfitSecondary: value })));
  body.append(colorField('Accessory Color', a.accessoryColor, (value) => updateAppearance(state.profile, { accessoryColor: value })));
  body.append(card('Modular identity', 'Character appearance and fruit equipment are stored separately so powers can switch without changing identity.'));
  body.append(button('Back', () => nav(state, refresh, 'menu')));
  return panel('Character Creator', body);
}

function renderFruitSelect(state, refresh) {
  const body = el('div', 'grid');
  for (const fruit of state.fruits) {
    const item = el('article', 'card fruit-card');
    item.style.setProperty('--fruit', fruit.color);
    item.innerHTML = `<h2>${fruit.name}</h2><p class="muted">Awakening: ${fruit.awakening}</p><p>Mastery: ${state.profile.mastery[fruit.id] ?? 0}</p><ul>${fruit.abilities.map((a) => `<li>${a.name}</li>`).join('')}</ul>`;
    item.append(button(state.profile.equipped_fruit === fruit.id ? 'Equipped' : 'Equip', () => { equipFruit(state.profile, fruit.id); refresh(); }));
    body.append(item);
  }
  body.append(button('Back', () => nav(state, refresh, 'menu')));
  return panel('Fruit Selection', body);
}

function renderSetup(state, refresh) {
  const body = el('div', 'grid');
  body.append(card('Stage', `${state.stage.name}: multiple platforms, ring-out zones, respawn points, and a simple wind-rune hazard.`));
  const select = selectField('Local Players', ['1', '2', '3', '4'], String(state.localPlayers), (value) => { state.localPlayers = Number(value); });
  body.append(select);
  body.append(card('Input', 'Keyboard: P1 WASD + J/K/L/;/Shift/I. P2 arrows + numpad. Controllers map left stick, face buttons, shoulders, and trigger awakening.'));
  body.append(button('Start Match', () => { start(state); nav(state, refresh, 'match'); }));
  body.append(button('Back', () => nav(state, refresh, 'menu')));
  return panel('Local Match Setup', body);
}

function renderMatch(state, refresh) {
  const body = el('div', 'grid');
  const hud = el('div', 'hud');
  const canvas = document.createElement('canvas');
  canvas.width = GAME.width;
  canvas.height = GAME.height;
  body.append(hud, canvas, controls(state));
  const node = panel('Arena HUD', body);
  const ctx = canvas.getContext('2d');
  let last = performance.now();
  function frame(now) {
    if (state.screen !== 'match') return;
    const dt = Math.min(0.033, (now - last) / 1000);
    last = now;
    pollGamepads(state.input);
    stepMatch(state.match, state.fruits, state.input.snapshot(), dt);
    drawStage(ctx, state.stage);
    drawEffects(ctx, state.match, state.fruits);
    for (const player of state.match.players) drawPlayer(ctx, player, state.fruits);
    hud.innerHTML = state.match.players.map((p) => hudCard(p, fruitById(state.fruits, p.fruitId))).join('');
    if (state.match.results) { state.screen = 'results'; refresh(); return; }
    requestAnimationFrame(frame);
  }
  requestAnimationFrame(frame);
  return node;
}

function renderResults(state, refresh) {
  const body = el('div', 'grid');
  const rows = state.match.results.map((player, index) => `${index + 1}. ${player.name} — ${player.stocks} stocks, ${Math.round(player.damage)}%`).join('<br>');
  body.append(card('Results', rows));
  body.append(button('Run it back', () => { start(state); nav(state, refresh, 'match'); }));
  body.append(button('Main Menu', () => nav(state, refresh, 'menu')));
  return panel('Results Screen', body);
}

function controls(state) {
  const wrap = el('div', 'controls');
  const actions = ['left', 'right', 'jump', 'attack', 'special1', 'special2', 'special3', 'dodge', 'awaken'];
  const row = el('div', 'row');
  for (const action of actions) {
    const b = button(action, () => {});
    b.addEventListener('pointerdown', () => state.input.press(1, action));
    b.addEventListener('pointerup', () => state.input.release(1, action));
    b.addEventListener('pointerleave', () => state.input.release(1, action));
    row.append(b);
  }
  wrap.append(row);
  return wrap;
}

function start(state) {
  state.match = createMatch(state.profile, state.fruits, state.stage, state.localPlayers);
}

function hudCard(player, fruit) {
  const meter = Math.round(player.awakening);
  return `<article class="card" style="--accent:${fruit.color}"><strong>${player.name}</strong><br><span class="muted">${fruit.name}</span><br>${Math.round(player.damage)}% · ${player.stocks} stocks<div class="meter"><div class="fill" style="width:${meter}%"></div></div><small>${player.status}</small></article>`;
}

function nav(state, refresh, screen) {
  state.screen = screen;
  refresh();
}

function card(title, text) {
  const node = el('article', 'card');
  node.innerHTML = `<h2>${title}</h2><p>${text}</p>`;
  return node;
}

function field(label, value, onInput) {
  const wrap = el('label', 'card');
  wrap.innerHTML = `<span>${label}</span>`;
  const input = document.createElement('input');
  input.value = value;
  input.addEventListener('input', () => onInput(input.value));
  wrap.append(input);
  return wrap;
}

function colorField(label, value, onInput) {
  const wrap = field(label, value, onInput);
  wrap.querySelector('input').type = 'color';
  return wrap;
}

function selectField(label, values, value, onInput) {
  const wrap = el('label', 'card');
  wrap.innerHTML = `<span>${label}</span>`;
  const select = document.createElement('select');
  for (const optionValue of values) {
    const option = document.createElement('option');
    option.value = optionValue;
    option.textContent = optionValue;
    option.selected = optionValue === value;
    select.append(option);
  }
  select.addEventListener('change', () => onInput(select.value));
  wrap.append(select);
  return wrap;
}

function button(text, action) {
  const node = document.createElement('button');
  node.type = 'button';
  node.textContent = text;
  node.addEventListener('click', action);
  return node;
}

function el(tag, className = '', text = '') {
  const node = document.createElement(tag);
  if (className) node.className = className;
  if (text) node.textContent = text;
  return node;
}
