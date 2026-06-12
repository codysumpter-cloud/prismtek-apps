export function createInputManager(target = window) {
  const state = {};
  const bindings = {
    KeyA: [1, 'left'], KeyD: [1, 'right'], KeyW: [1, 'jump'], KeyJ: [1, 'attack'], KeyK: [1, 'special1'], KeyL: [1, 'special2'], Semicolon: [1, 'special3'], ShiftLeft: [1, 'dodge'], KeyI: [1, 'awaken'],
    ArrowLeft: [2, 'left'], ArrowRight: [2, 'right'], ArrowUp: [2, 'jump'], Numpad1: [2, 'attack'], Numpad2: [2, 'special1'], Numpad3: [2, 'special2'], Numpad4: [2, 'special3'], Numpad0: [2, 'dodge'], Numpad5: [2, 'awaken'],
  };

  function set(code, value) {
    const binding = bindings[code];
    if (!binding) return;
    const [slot, action] = binding;
    state[slot] ??= {};
    state[slot][action] = value;
  }

  target.addEventListener('keydown', (event) => set(event.code, true));
  target.addEventListener('keyup', (event) => set(event.code, false));

  return {
    state,
    press(slot, action) {
      state[slot] ??= {};
      state[slot][action] = true;
    },
    release(slot, action) {
      state[slot] ??= {};
      state[slot][action] = false;
    },
    snapshot() {
      return JSON.parse(JSON.stringify(state));
    },
  };
}

export function pollGamepads(input) {
  const pads = navigator.getGamepads?.() ?? [];
  for (let index = 0; index < Math.min(4, pads.length); index += 1) {
    const pad = pads[index];
    if (!pad) continue;
    const slot = index + 1;
    input.state[slot] ??= {};
    input.state[slot].left = pad.axes[0] < -0.35;
    input.state[slot].right = pad.axes[0] > 0.35;
    input.state[slot].jump = pad.buttons[0]?.pressed;
    input.state[slot].attack = pad.buttons[2]?.pressed;
    input.state[slot].special1 = pad.buttons[1]?.pressed;
    input.state[slot].special2 = pad.buttons[3]?.pressed;
    input.state[slot].special3 = pad.buttons[5]?.pressed;
    input.state[slot].dodge = pad.buttons[4]?.pressed;
    input.state[slot].awaken = pad.buttons[7]?.pressed;
  }
}
