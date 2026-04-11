export type BuddyAnimationState = 'idle' | 'blink' | 'happy' | 'thinking' | 'working' | 'sleepy' | 'levelUp';

export type BuddyArchetype = 'companion' | 'prismo' | 'neptr';

export interface BuddyFrameSet {
  label: string;
  frames: Record<BuddyAnimationState, string[]>;
}

const frame = (lines: string[]) => lines.join('\n');

const companion: BuddyFrameSet = {
  label: 'Buddy',
  frames: {
    idle: [
      frame(['   /\\_/\\', '  ( o.o )', '  /| _ |\\', '   /   \\', '  _|   |_']),
      frame(['   /\\_/\\', '  ( o.o )', '  /| _ |\\', '   /   \\', '   |___|']),
    ],
    blink: [
      frame(['   /\\_/\\', '  ( -.- )', '  /| _ |\\', '   /   \\', '   |___|']),
    ],
    happy: [
      frame(['   /\\_/\\', '  ( ^.^ )', '  /| * |\\', '   / \\ \\', '  _| |_|']),
      frame(['  \\/\\_/\\/', '  ( ^o^ )', '  /| * |\\', '   / \\ \\', '  _| |_|']),
    ],
    thinking: [
      frame(['   /\\_/\\', '  ( o.o )  ?', '  /| _ |\\', '   /   \\', '   |___|']),
      frame(['   /\\_/\\', '  ( o_o )  ..', '  /| _ |\\', '   /   \\', '   |___|']),
    ],
    working: [
      frame(['   /\\_/\\', '  ( >.< )  #', '  /|[_]|\\', '   /   \\', '  _|   |_']),
      frame(['   /\\_/\\', '  ( >.< )  ##', '  /|[_]|\\', '   /   \\', '   |___|']),
    ],
    sleepy: [
      frame(['   /\\_/\\', '  ( -.- ) z', '  /| _ |\\', '   /   \\', '   |___|']),
      frame(['   /\\_/\\', '  ( -.- ) zz', '  /| _ |\\', '   /   \\', '  _|___|_']),
    ],
    levelUp: [
      frame(['  * /\\_/\\ *', '   ( ^.^ )', '  /|[*]|\\', '   / \\ \\', '  _| |_|']),
      frame([' **/\\_/\\**', '   ( ^o^ )', '  /|[*]|\\', '   / \\ \\', '  _| |_|']),
    ],
  },
};

const prismo: BuddyFrameSet = {
  label: 'Prismo',
  frames: {
    idle: [
      frame(['    .-.', '  <(o o)>', '   /| O |\\', '  /_|___|_\\', '    / \\']),
      frame(['    .-.', '  <(o o)>', '   /| O |\\', '  /_|___|_\\', '    \\ /']),
    ],
    blink: [
      frame(['    .-.', '  <(- -)>', '   /| O |\\', '  /_|___|_\\', '    \\ /']),
    ],
    happy: [
      frame(['  \\ .-. /', '  <(^ ^)>', '   /| O |\\', '  /_|___|_\\', '    \\ /']),
    ],
    thinking: [
      frame(['    .-.', '  <(o o)> ?', '   /| O |\\', '  /_|___|_\\', '    \\ /']),
    ],
    working: [
      frame(['    .-.', '  <(o o)> *', '   /| # |\\', '  /_|___|_\\', '    \\ /']),
      frame(['    .-.', '  <(o o)> **', '   /| # |\\', '  /_|___|_\\', '    / \\']),
    ],
    sleepy: [
      frame(['    .-.', '  <(- -)> z', '   /| O |\\', '  /_|___|_\\', '    \\ /']),
    ],
    levelUp: [
      frame([' ** .-. **', '  <(^ ^)>', '   /| @ |\\', '  /_|___|_\\', '    \\ /']),
    ],
  },
};

const neptr: BuddyFrameSet = {
  label: 'NEPTR',
  frames: {
    idle: [
      frame(['  [=====]', '  | o o |', '  |  ^  |', ' /|_____|\\', '   /_|_\\']),
      frame(['  [=====]', '  | o o |', '  |  ^  |', ' /|_____|\\', '   \\_|_/']),
    ],
    blink: [
      frame(['  [=====]', '  | - - |', '  |  ^  |', ' /|_____|\\', '   \\_|_/']),
    ],
    happy: [
      frame(['  [=====]', '  | ^ ^ |', '  | \\_/ |', ' /|_____|\\', '   \\_|_/']),
    ],
    thinking: [
      frame(['  [=====] ?', '  | o o |', '  |  ?  |', ' /|_____|\\', '   \\_|_/']),
    ],
    working: [
      frame(['  [=====] #', '  | > < |', '  |  =  |', ' /|_____|\\', '   /_|_\\']),
      frame(['  [=====] ##', '  | > < |', '  |  =  |', ' /|_____|\\', '   \\_|_/']),
    ],
    sleepy: [
      frame(['  [=====] z', '  | - - |', '  |  _  |', ' /|_____|\\', '   \\_|_/']),
    ],
    levelUp: [
      frame([' *[=====]*', '  | ^ ^ |', '  | \\_/ |', ' /|__*__|\\', '   \\_|_/']),
    ],
  },
};

const registry: Record<BuddyArchetype, BuddyFrameSet> = {companion, prismo, neptr};

export function getBuddyFrame(archetype: BuddyArchetype, state: BuddyAnimationState, tick: number): string {
  const frameSet = registry[archetype] ?? registry.companion;
  const frames = frameSet.frames[state] ?? frameSet.frames.idle;
  return frames[tick % frames.length] ?? frames[0] ?? '';
}

export function getBuddyLabel(archetype: BuddyArchetype): string {
  return registry[archetype]?.label ?? registry.companion.label;
}
