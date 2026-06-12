const keyMap = {
  ArrowLeft: { slot: 0, type: "move", value: -1 },
  ArrowRight: { slot: 0, type: "move", value: 1 },
  KeyA: { slot: 1, type: "move", value: -1 },
  KeyD: { slot: 1, type: "move", value: 1 }
};

const taps = {
  ArrowUp: { slot: 0, type: "jump" },
  Slash: { slot: 0, type: "attack", index: 0 },
  Period: { slot: 0, type: "attack", index: 1 },
  Comma: { slot: 0, type: "attack", index: 2 },
  ShiftRight: { slot: 0, type: "dodge" },
  Enter: { slot: 0, type: "awaken" },
  KeyW: { slot: 1, type: "jump" },
  KeyF: { slot: 1, type: "attack", index: 0 },
  KeyG: { slot: 1, type: "attack", index: 1 },
  KeyH: { slot: 1, type: "attack", index: 2 },
  ShiftLeft: { slot: 1, type: "dodge" },
  KeyT: { slot: 1, type: "awaken" },
  Escape: { slot: 0, type: "menu" }
};

export class KeyboardInput {
  constructor() {
    this.down = new Set();
    this.queue = [];
    window.addEventListener("keydown", (event) => {
      if (!this.down.has(event.code) && taps[event.code]) this.queue.push(taps[event.code]);
      this.down.add(event.code);
    });
    window.addEventListener("keyup", (event) => this.down.delete(event.code));
  }

  read() {
    const actions = [...this.queue];
    this.queue.length = 0;
    for (const [code, action] of Object.entries(keyMap)) {
      if (this.down.has(code)) actions.push(action);
    }
    return actions;
  }
}

export class GamepadInput {
  constructor() {
    this.prev = new Map();
  }

  read() {
    const actions = [];
    for (const pad of navigator.getGamepads?.() || []) {
      if (!pad) continue;
      const slot = Math.min(3, pad.index);
      const axis = Math.abs(pad.axes[0]) > 0.25 ? Math.sign(pad.axes[0]) : 0;
      if (axis) actions.push({ slot, type: "move", value: axis });
      this.edge(pad, 0, () => actions.push({ slot, type: "jump" }));
      this.edge(pad, 1, () => actions.push({ slot, type: "attack", index: 0 }));
      this.edge(pad, 2, () => actions.push({ slot, type: "attack", index: 1 }));
      this.edge(pad, 3, () => actions.push({ slot, type: "attack", index: 2 }));
      this.edge(pad, 4, () => actions.push({ slot, type: "dodge" }));
      this.edge(pad, 5, () => actions.push({ slot, type: "awaken" }));
      this.edge(pad, 9, () => actions.push({ slot, type: "menu" }));
    }
    return actions;
  }

  edge(pad, button, fn) {
    const key = `${pad.index}:${button}`;
    const pressed = Boolean(pad.buttons[button]?.pressed);
    if (pressed && !this.prev.get(key)) fn();
    this.prev.set(key, pressed);
  }
}
