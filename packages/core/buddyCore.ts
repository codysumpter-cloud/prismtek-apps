export * from './buddyPersonalization';
export * from './buddyPersonalizationEngine';

import {
  defaultBuddyAppearance,
  defaultBuddyBehavior,
  materializeBuddyGeneration,
} from './buddyPersonalizationEngine';
import { BuddyGenerationResult } from './buddyPersonalization';

export function buildDefaultAsciiBuddyPreview(displayName = 'Buddy'): BuddyGenerationResult {
  return materializeBuddyGeneration({
    renderMode: 'ascii',
    guidedPromptAnswers: {
      role: 'companion',
      mood: 'friendly',
      shape: 'round',
      accessory: 'none',
      style: 'warm',
    },
    appearance: {
      ...defaultBuddyAppearance('ascii'),
      displayName,
    },
    behavior: defaultBuddyBehavior('balanced'),
  });
}

export function buildDefaultPixelBuddyPreview(displayName = 'Buddy'): BuddyGenerationResult {
  return materializeBuddyGeneration({
    renderMode: 'pixel',
    guidedPromptAnswers: {
      role: 'companion',
      palette: 'forest',
      body: 'blob',
      accessory: 'none',
      energy: 'lively',
    },
    appearance: {
      ...defaultBuddyAppearance('pixel'),
      displayName,
    },
    behavior: defaultBuddyBehavior('expressive'),
  });
}
