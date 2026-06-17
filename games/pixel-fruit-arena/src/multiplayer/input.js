// Input devices emit device-tagged actions; main.js routes devices to player
// slots via the lobby's device assignments.

const KB1_HOLDS = {
  ArrowLeft: { type: "move", value: -1 },
  ArrowRight: { type: "move", value: 1 }
};
const KB1_TAPS = {
  ArrowUp: { type: "jump" },
  Slash: { type: "attack", index: 0 },
  Period: { type: "attack", index: 1 },
  Comma: { type: "attack", index: 2 },
  ShiftRight: { type: "dodge" },
  ControlRight: { type: "haki" },
  Enter: { type: "awaken" }
};
const KB2_HOLDS = {
  KeyA: { type: "move", value: -1 },
  KeyD: { type: "move", value: 1 }
};
const KB2_TAPS = {
  KeyW: { type: "jump" },
  KeyF: { type: "attack", index: 0 },
  KeyG: { type: "attack", index: 1 },
  KeyH: { type: "attack", index: 2 },
  ShiftLeft: { type: "dodge" },
  KeyQ: { type: "haki" },
  KeyT: { type: "awaken" }
};
// Held vertical aim for directional attack modifiers (up/down variants).
const KB1_AIM = { ArrowUp: -1, ArrowDown: 1 };
const KB2_AIM = { KeyW: -1, KeyS: 1 };

export const DEVICE_LABELS = {
  kb1: "Keyboard 1 (Arrows)",
  kb2: "Keyboard 2 (WASD)",
  pad0: "Controller 1",
  pad1: "Controller 2",
  pad2: "Controller 3",
  pad3: "Controller 4",
  cpu: "CPU"
};

export class KeyboardInput {
  constructor() {
    this.down = new Set();
    this.queue = [];
    window.addEventListener("keydown", (event) => {
      if (event.target instanceof HTMLInputElement) return;
      const tap = KB1_TAPS[event.code] ? { device: "kb1", ...KB1_TAPS[event.code] }
        : KB2_TAPS[event.code] ? { device: "kb2", ...KB2_TAPS[event.code] }
        : event.code === "Escape" ? { device: "kb1", type: "menu" }
        : null;
      if (tap || KB1_HOLDS[event.code] || KB2_HOLDS[event.code] || KB1_AIM[event.code] || KB2_AIM[event.code]) event.preventDefault();
      if (tap && !this.down.has(event.code)) this.queue.push(tap);
      this.down.add(event.code);
    });
    window.addEventListener("keyup", (event) => {
      this.down.delete(event.code);
    });
  }

  read() {
    const actions = [...this.queue];
    this.queue.length = 0;
    for (const [code, action] of Object.entries(KB1_HOLDS)) {
      if (this.down.has(code)) actions.push({ device: "kb1", ...action });
    }
    for (const [code, action] of Object.entries(KB2_HOLDS)) {
      if (this.down.has(code)) actions.push({ device: "kb2", ...action });
    }
    for (const [code, value] of Object.entries(KB1_AIM)) {
      if (this.down.has(code)) actions.push({ device: "kb1", type: "aim", value });
    }
    for (const [code, value] of Object.entries(KB2_AIM)) {
      if (this.down.has(code)) actions.push({ device: "kb2", type: "aim", value });
    }
    return actions;
  }
}

// Standard-mapping gamepad buttons:
// 0=A 1=B 2=X 3=Y 4=LB 5=RB 6=LT 9=Start 12=Up 13=Down 14=Left 15=Right
export class GamepadInput {
  constructor() {
    this.prev = new Map();
  }

  connected() {
    return Array.from(navigator.getGamepads?.() || []).filter(Boolean);
  }

  read() {
    const actions = [];
    for (const pad of navigator.getGamepads?.() || []) {
      if (!pad) continue;
      const device = `pad${pad.index}`;
      const axis = Math.abs(pad.axes[0]) > 0.3 ? Math.sign(pad.axes[0]) : 0;
      const dpadAxis = this.pressed(pad, 14) ? -1 : this.pressed(pad, 15) ? 1 : 0;
      const move = axis || dpadAxis;
      if (move) actions.push({ device, type: "move", value: move });
      const axisY = Math.abs(pad.axes[1]) > 0.4 ? Math.sign(pad.axes[1]) : 0;
      const dpadY = this.pressed(pad, 12) ? -1 : this.pressed(pad, 13) ? 1 : 0;
      const aim = axisY || dpadY;
      if (aim) actions.push({ device, type: "aim", value: aim });
      this.edge(pad, 0, () => actions.push({ device, type: "jump" }));
      this.edge(pad, 2, () => actions.push({ device, type: "attack", index: 0 }));
      this.edge(pad, 3, () => actions.push({ device, type: "attack", index: 1 }));
      this.edge(pad, 1, () => actions.push({ device, type: "attack", index: 2 }));
      this.edge(pad, 4, () => actions.push({ device, type: "dodge" }));
      this.edge(pad, 6, () => actions.push({ device, type: "haki" }));
      this.edge(pad, 5, () => actions.push({ device, type: "awaken" }));
      this.edge(pad, 9, () => actions.push({ device, type: "menu" }));
    }
    return actions;
  }

  // Menu navigation actions, independent of fight actions. Any connected pad
  // can drive menu focus; A confirms, B goes back.
  readNav() {
    const nav = [];
    for (const pad of navigator.getGamepads?.() || []) {
      if (!pad) continue;
      const device = `pad${pad.index}`;
      this.edge(pad, 12, () => nav.push({ device, type: "nav", dir: "up" }), "nav");
      this.edge(pad, 13, () => nav.push({ device, type: "nav", dir: "down" }), "nav");
      this.edge(pad, 14, () => nav.push({ device, type: "nav", dir: "left" }), "nav");
      this.edge(pad, 15, () => nav.push({ device, type: "nav", dir: "right" }), "nav");
      this.axisEdge(pad, 1, -1, () => nav.push({ device, type: "nav", dir: "up" }));
      this.axisEdge(pad, 1, 1, () => nav.push({ device, type: "nav", dir: "down" }));
      this.axisEdge(pad, 0, -1, () => nav.push({ device, type: "nav", dir: "left" }));
      this.axisEdge(pad, 0, 1, () => nav.push({ device, type: "nav", dir: "right" }));
      this.edge(pad, 0, () => nav.push({ device, type: "nav", dir: "confirm" }), "nav");
      this.edge(pad, 1, () => nav.push({ device, type: "nav", dir: "back" }), "nav");
      this.edge(pad, 9, () => nav.push({ device, type: "nav", dir: "start" }), "nav");
    }
    return nav;
  }

  pressed(pad, button) {
    return Boolean(pad.buttons[button]?.pressed);
  }

  edge(pad, button, fn, ns = "fight") {
    const key = `${ns}:${pad.index}:${button}`;
    const pressed = this.pressed(pad, button);
    if (pressed && !this.prev.get(key)) fn();
    this.prev.set(key, pressed);
  }

  axisEdge(pad, axis, sign, fn) {
    const key = `axis:${pad.index}:${axis}:${sign}`;
    const active = Math.sign(pad.axes[axis] || 0) === sign && Math.abs(pad.axes[axis]) > 0.55;
    if (active && !this.prev.get(key)) fn();
    this.prev.set(key, active);
  }
}

// Routes device-tagged actions to player slots using lobby assignments.
export function routeActions(actions, assignments) {
  const routed = [];
  for (const action of actions) {
    const slot = assignments[action.device];
    if (slot === undefined || slot === null) continue;
    routed.push({ ...action, slot });
  }
  return routed;
}

export function buildAssignments(playerDevices) {
  // playerDevices: array of device ids chosen per slot in the lobby.
  const assignments = {};
  playerDevices.forEach((device, slot) => {
    if (device && device !== "cpu" && !(device in assignments)) assignments[device] = slot;
  });
  return assignments;
}
