export type BuddyTrainingAction =
  | 'chat'
  | 'remember'
  | 'recall'
  | 'skill_used'
  | 'quest_completed'
  | 'test_passed'
  | 'doc_added'
  | 'code_reviewed'
  | 'memory_reviewed'
  | 'approval_handled';

export type BuddyEvolutionStage = 'seedling' | 'apprentice' | 'specialist' | 'guardian';

export interface BuddyTrainingStats {
  bond: number;
  focus: number;
  curiosity: number;
  discipline: number;
  creativity: number;
  reliability: number;
  autonomy: number;
}

export interface BuddyTrainingState {
  buddy_id: string;
  level: number;
  xp: number;
  lifetime_xp: number;
  sparks: number;
  snacks: number;
  stats: BuddyTrainingStats;
  achievements: string[];
  cosmetics: string[];
  evolution: BuddyEvolutionStage;
  last_action: string;
}

export interface BuddyTrainingDisplayModel {
  buddyId: string;
  levelLabel: string;
  xpLabel: string;
  evolutionLabel: string;
  resourceLabel: string;
  topStats: Array<{ name: keyof BuddyTrainingStats; value: number }>;
  achievements: string[];
  cosmetics: string[];
}

export const BUDDY_TRAINING_ACTIONS: readonly BuddyTrainingAction[] = [
  'chat',
  'remember',
  'recall',
  'skill_used',
  'quest_completed',
  'test_passed',
  'doc_added',
  'code_reviewed',
  'memory_reviewed',
  'approval_handled',
] as const;

export function toBuddyTrainingDisplayModel(state: BuddyTrainingState): BuddyTrainingDisplayModel {
  const topStats = Object.entries(state.stats)
    .map(([name, value]) => ({ name: name as keyof BuddyTrainingStats, value }))
    .sort((left, right) => right.value - left.value)
    .slice(0, 3);

  return {
    buddyId: state.buddy_id,
    levelLabel: `Level ${state.level}`,
    xpLabel: `${state.xp} XP`,
    evolutionLabel: state.evolution,
    resourceLabel: `${state.sparks} sparks · ${state.snacks} snacks`,
    topStats,
    achievements: [...state.achievements].sort(),
    cosmetics: [...state.cosmetics].sort(),
  };
}

export function isBuddyTrainingAction(value: string): value is BuddyTrainingAction {
  return BUDDY_TRAINING_ACTIONS.includes(value as BuddyTrainingAction);
}
