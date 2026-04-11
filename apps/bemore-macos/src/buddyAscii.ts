export type BuddyAnimationState = 'idle' | 'blink' | 'happy' | 'thinking' | 'working' | 'sleepy' | 'levelUp' | 'needsAttention';

export type BuddyArchetype = 'prism' | 'moe' | 'scout';

export interface BuddyFrameSet {
  label: string;
  frames: Record<BuddyAnimationState, string[]>;
}

const frame = (lines: string[]) => lines.join('\n');

const prism: BuddyFrameSet = {
  label: 'Prism',
  frames: {
    idle: [
      frame(['    /\\', '  < o  o >', '  /|  v |\\', ' /_|____|_\\', '   /_  _\\']),
      frame(['    /\\', '  < o  o >', '  /|  v |\\', ' /_|____|_\\', '   \\_  _/']),
    ],
    blink: [
      frame(['    /\\', '  < -  - >', '  /|  v |\\', ' /_|____|_\\', '   \\_  _/']),
    ],
    happy: [
      frame(['  \\ /\\ /', '  < ^  ^ >', '  /|  * |\\', ' /_|____|_\\', '    /  \\']),
      frame([' *  /\\  *', '  < ^  o >', '  /|  * |\\', ' /_|____|_\\', '    \\  /']),
    ],
    thinking: [
      frame(['    /\\   ?', '  < o  o >', '  /|  ? |\\', ' /_|____|_\\', '    /  \\']),
      frame(['    /\\  ..', '  < o  O >', '  /|  ? |\\', ' /_|____|_\\', '    \\  /']),
    ],
    working: [
      frame(['    /\\  #', '  < >  < >', '  /| [ ]|\\', ' /_|____|_\\', '   /_  _\\']),
      frame(['    /\\  ##', '  < >  < >', '  /| [*]|\\', ' /_|____|_\\', '   \\_  _/']),
    ],
    sleepy: [
      frame(['    /\\   z', '  < -  - >', '  /|  . |\\', ' /_|____|_\\', '    /__\\']),
      frame(['    /\\  zz', '  < -  - >', '  /|  . |\\', ' /_|____|_\\', '   _/  \\_']),
    ],
    levelUp: [
      frame([' ** /\\ **', '  < ^  ^ >', '  /|{*}|\\', ' /_|____|_\\', '    /  \\']),
      frame(['*** /\\ ***', '  < ^  o >', '  /|{*}|\\', ' /_|____|_\\', '    \\  /']),
    ],
    needsAttention: [
      frame([' !  /\\  !', '  < o  o >', '  /|  ! |\\', ' /_|____|_\\', '    /  \\']),
      frame([' !! /\\ !!', '  < O  o >', '  /|  ! |\\', ' /_|____|_\\', '    \\  /']),
    ],
  },
};

const moe: BuddyFrameSet = {
  label: 'Moe',
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
    needsAttention: [
      frame([' !! .-. !!', '  <(o o)>', '   /| ! |\\', '  /_|___|_\\', '    / \\']),
    ],
  },
};

const scout: BuddyFrameSet = {
  label: 'Scout',
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
    needsAttention: [
      frame([' ![=====]!', '  | o O |', '  |  !  |', ' /|_____|\\', '   /_|_\\']),
    ],
  },
};

const registry: Record<BuddyArchetype, BuddyFrameSet> = {prism, moe, scout};

export function getBuddyFrame(archetype: BuddyArchetype, state: BuddyAnimationState, tick: number): string {
  const frameSet = registry[archetype] ?? registry.prism;
  const frames = frameSet.frames[state] ?? frameSet.frames.idle;
  return frames[tick % frames.length] ?? frames[0] ?? '';
}

export function getBuddyLabel(archetype: BuddyArchetype): string {
  return registry[archetype]?.label ?? registry.prism.label;
}
