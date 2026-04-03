/**
 * @license
 * SPDX-License-Identifier: Apache-2.0
*/

/**
 * 100 Tools Kitchen App - Constants and Types
 */

import { Type } from '@google/genai';

// ============================================================================
// Types
// ============================================================================

export interface Ingredient {
  name: string;
  emoji: string;
}

export interface KitchenAction {
  name: string;           // Function name (alphanumeric + underscores)
  displayName: string;    // Human-readable name
  emoji: string;
}

export interface CombinationResult {
  result_name: string;
  emoji: string;
}

export interface TimelineEntry {
  id: string;
  timestamp: Date;
  // Text from model response (shown above/below action)
  text?: string;
  // Action from function call
  action?: string;
  ingredients?: string[];
  result?: Ingredient | null;  // null when loading
}

export type OrderDifficulty = 'easy' | 'intermediate' | 'difficult';

export interface Order {
  id: string;
  name: string;
  emoji: string;
  difficulty: OrderDifficulty;
  status: 'not_started' | 'in_progress' | 'completed' | 'failed';
  servedDish?: string;  // What was actually served (for failed orders)
}

export interface VerificationResult {
  matches: boolean;
  confidence: number;
  explanation: string;
}

export const EXAMPLE_ORDERS: Order[] = [
  { id: 'order-1', name: 'Fried Eggs', emoji: '🍳', difficulty: 'easy', status: 'not_started' },
  { id: 'order-2', name: 'Tonkotsu Ramen', emoji: '🍜', difficulty: 'intermediate', status: 'not_started' },
  { id: 'order-3', name: 'Itek Tim', emoji: '🍲', difficulty: 'difficult', status: 'not_started' },
];

// ============================================================================
// Helper Functions
// ============================================================================

/** Sanitize action name for function declarations: "deep fry" → "deep_fry" */
export function sanitizeName(name: string): string {
  return name.replace(/\s+/g, '_').replace(/[^a-zA-Z0-9_]/g, '');
}

/** Create KitchenAction from simple tool definition */
function createAction(name: string, emoji: string): KitchenAction {
  return {
    name: sanitizeName(name),
    displayName: name,
    emoji,
  };
}

// ============================================================================
// Cooking Actions
// ============================================================================

export const COOKING_ACTIONS: KitchenAction[] = [
  // Basic Cooking Methods
  createAction('fry', '🍳'), createAction('boil', '🫧'), createAction('bake', '🥯'),
  createAction('saute', '🥘'), createAction('grill', '🥩'), createAction('steam', '🥟'),
  createAction('roast', '🍗'), createAction('simmer', '🍲'), createAction('broil', '🌡️'),
  createAction('poach', '🥚'), createAction('braise', '🥘'), createAction('stew', '🍲'),
  createAction('sear', '🍳'), createAction('deep fry', '🍟'),
  createAction('sous vide', '🛁'), createAction('air fry', '🌬️'), createAction('microwave', '☢️'),
  createAction('wok', '🥡'), createAction('char', '🔥'), createAction('torch', '🔥'),
  createAction('plancha', '🔥'), createAction('sweat', '💦'), createAction('parboil', '🫧'),

  // Preparation Methods
  createAction('chop', '🔪'), createAction('dice', '🔪'), createAction('slice', '🔪'),
  createAction('mince', '🔪'), createAction('julienne', '🔪'), createAction('grate', '🧀'),
  createAction('peel', '🥔'), createAction('core', '🍎'), createAction('pit', '🥑'),
  createAction('trim', '✂️'), createAction('clean', '🧽'), createAction('wash', '💧'),

  // Mixing & Combining
  createAction('mix', '🥣'), createAction('whisk', '🥄'), createAction('stir', '🥄'),
  createAction('fold', '🥄'), createAction('beat', '🥄'), createAction('whip', '🥄'),
  createAction('blend', '🌪️'), createAction('combine', '🥣'), createAction('toss', '🥗'),

  // Seasoning & Flavoring
  createAction('marinate', '🍖'), createAction('brine', '🧂'),
  createAction('cure', '🥓'), createAction('smoke', '💨'), createAction('pickle', '🥒'),
  createAction('ferment', '🫙'), createAction('infuse', '🍵'), createAction('steep', '🫖'),

  // Advanced Techniques
  createAction('caramelize', '🍯'), createAction('flambe', '🔥'), createAction('reduce', '🍲'),
  createAction('emulsify', '🥄'), createAction('temper', '🍫'), createAction('proof', '🍞'),
  createAction('rise', '🍞'), createAction('rest', '⏰'), createAction('chill', '❄️'),
  createAction('freeze', '🧊'), createAction('thaw', '💧'), createAction('melt', '🫠'),
  createAction('clarify', '✨'), createAction('deglaze', '🍷'), createAction('velvet', '🥢'),
  createAction('age', '🥩'),

  // Baking & Pastry
  createAction('knead', '🍞'), createAction('roll', '🥖'), createAction('sift', '🌨️'),
  createAction('grease', '🧈'), createAction('dust', '🌨️'), createAction('glaze', '🍩'),
  createAction('pipe', '🧁'), createAction('score', '🔪'), createAction('batter', '🥛'),
  createAction('bread', '🍞'),

  // Other Techniques
  createAction('strain', '💧'), createAction('mash', '🥔'),
  createAction('puree', '🥣'), createAction('crush', '🔨'), createAction('grind', '⚙️'),
  createAction('shred', '🧀'), createAction('zest', '🍋'), createAction('juice', '🍊'),
  createAction('baste', '🥄'), createAction('blanch', '🥦'), createAction('pull', '🧲'),

  // Prep
  createAction('tenderize', '🔨'), createAction('stuff', '🦃'),
  createAction('wrap', '🌯'), createAction('skewer', '🍢'), createAction('crack', '🥚'),
  createAction('flatten', '🔨'), createAction('debone', '🦴'), createAction('fillet', '🐟'),
  createAction('garnish', '🌿'),

  // Serving/Finishing
  createAction('serve', '🍽️'), createAction('pass', '🏳️'),
];

// ============================================================================
// Starting Ingredients 
// ============================================================================

export const STARTING_INGREDIENTS: Ingredient[] = [
  // Proteins
  { name: 'chicken', emoji: '🐔' }, { name: 'beef', emoji: '🥩' }, { name: 'pork', emoji: '🐷' },
  { name: 'fish', emoji: '🐟' }, { name: 'salmon', emoji: '🍣' }, { name: 'shrimp', emoji: '🦐' },
  { name: 'eggs', emoji: '🥚' }, { name: 'tofu', emoji: '🧈' }, { name: 'beans', emoji: '🫘' },
  { name: 'lentils', emoji: '🫘' }, { name: 'turkey', emoji: '🦃' }, { name: 'lamb', emoji: '🐑' },
  { name: 'duck', emoji: '🦆' },

  // Dairy
  { name: 'milk', emoji: '🥛' }, { name: 'butter', emoji: '🧈' }, { name: 'cheese', emoji: '🧀' },
  { name: 'cream', emoji: '🥛' }, { name: 'yogurt', emoji: '🥛' }, { name: 'sour cream', emoji: '🥛' },
  { name: 'mozzarella', emoji: '🧀' }, { name: 'parmesan', emoji: '🧀' }, { name: 'cheddar', emoji: '🧀' },

  // Grains & Starches
  { name: 'flour', emoji: '🌾' }, { name: 'rice', emoji: '🍚' }, { name: 'pasta', emoji: '🍝' },
  { name: 'bread', emoji: '🍞' }, { name: 'oats', emoji: '🌾' },
  { name: 'barley', emoji: '🌾' }, { name: 'wheat', emoji: '🌾' }, { name: 'corn', emoji: '🌽' },
  { name: 'potatoes', emoji: '🥔' }, { name: 'sweet potato', emoji: '🍠' }, { name: 'noodles', emoji: '🍜' },

  // Herbs & Spices
  { name: 'basil', emoji: '🌿' }, { name: 'oregano', emoji: '🌿' }, { name: 'thyme', emoji: '🌿' },
  { name: 'rosemary', emoji: '🌿' }, { name: 'parsley', emoji: '🌿' }, { name: 'cilantro', emoji: '🌿' },
  { name: 'salt', emoji: '🧂' }, { name: 'pepper', emoji: '🌶️' }, { name: 'paprika', emoji: '🌶️' },
  { name: 'cumin', emoji: '🌶️' }, { name: 'cinnamon', emoji: '🌶️' }, { name: 'vanilla', emoji: '🌿' },

  // Pantry Staples
  { name: 'olive oil', emoji: '🫒' }, { name: 'vegetable oil', emoji: '🛢️' }, { name: 'vinegar', emoji: '🍶' },
  { name: 'soy sauce', emoji: '🍶' }, { name: 'honey', emoji: '🍯' }, { name: 'maple syrup', emoji: '🍯' },

  // Baking
  { name: 'sugar', emoji: '🍯' }, { name: 'baking soda', emoji: '🥄' }, { name: 'yeast', emoji: '🍞' },
  { name: 'vanilla extract', emoji: '🌿' }, { name: 'cocoa powder', emoji: '☕' }, { name: 'chocolate', emoji: '🍫' },

  // Nuts & Seeds
  { name: 'almonds', emoji: '🌰' }, { name: 'walnuts', emoji: '🌰' }, { name: 'pecans', emoji: '🌰' },
  { name: 'peanuts', emoji: '🥜' }, { name: 'cashews', emoji: '🌰' }, { name: 'pine nuts', emoji: '🌰' },
  { name: 'sesame seeds', emoji: '🌰' },

  // Liquids
  { name: 'water', emoji: '💧' }, { name: 'broth', emoji: '🍲' }, { name: 'wine', emoji: '🍷' },
  { name: 'beer', emoji: '🍺' }, { name: 'coconut milk', emoji: '🥥' }, { name: 'almond milk', emoji: '🌰' },

  // Fruits
  { name: 'lemon', emoji: '🍋' }, { name: 'lime', emoji: '🍋' }, { name: 'orange', emoji: '🍊' },
  { name: 'apple', emoji: '🍎' }, { name: 'banana', emoji: '🍌' }, { name: 'strawberry', emoji: '🍓' },
  { name: 'blueberry', emoji: '🫐' }, { name: 'grape', emoji: '🍇' }, { name: 'pineapple', emoji: '🍍' },
  { name: 'mango', emoji: '🥭' }, { name: 'peach', emoji: '🍑' }, { name: 'cherry', emoji: '🍒' },

  // Vegetables
  { name: 'onion', emoji: '🧅' }, { name: 'garlic', emoji: '🧄' }, { name: 'tomato', emoji: '🍅' },
  { name: 'carrot', emoji: '🥕' }, { name: 'celery', emoji: '🥬' }, { name: 'bell pepper', emoji: '🫑' },
  { name: 'mushroom', emoji: '🍄' }, { name: 'spinach', emoji: '🥬' }, { name: 'lettuce', emoji: '🥬' },
  { name: 'broccoli', emoji: '🥦' }, { name: 'cauliflower', emoji: '🥦' }, { name: 'cabbage', emoji: '🥬' },
  { name: 'zucchini', emoji: '🥒' }, { name: 'cucumber', emoji: '🥒' }, { name: 'eggplant', emoji: '🍆' },
  { name: 'avocado', emoji: '🥑' }, { name: 'jalapeño', emoji: '🌶️' }, { name: 'ginger', emoji: '🫚' },
];

// ============================================================================
// Preselected Ingredients
// ============================================================================

export const PRESELECTED_INGREDIENTS = [];

// ============================================================================
// Combination Agent Configuration
// ============================================================================

export const COMBINATION_SYSTEM_INSTRUCTION = `You are a cooking result generator. Given a cooking action and ingredients, 
determine what dish or prepared item results from this combination.

Return a JSON object with:
- result_name: The name of the resulting dish or item (1-3 words)
- emoji: A single emoji that represents the result

Be creative but realistic. The result should make culinary sense.`;

export const COMBINATION_RESPONSE_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    result_name: { type: Type.STRING },
    emoji: { type: Type.STRING }
  },
  required: ['result_name', 'emoji']
};

// ============================================================================
// Verification Agent Configuration
// ============================================================================

export const VERIFICATION_SYSTEM_INSTRUCTION = `You are a food verification assistant. 
Given an order name and a served dish name, determine if they match semantically.
Use your broad knowledge of foods of the world to make your decision.

The match should be flexible - for example:
- "Pad Thai" matches "pad thai", "thai stir-fried noodles", "peanut noodles"
- "Beef Bourguignon" matches "beef bourguignon", "french beef stew", "burgundy beef"
- "Caesar Salad" matches "caesar salad", "romaine with caesar dressing", "classic caesar"

Return a JSON object with:
- matches: true if the dishes are semantically the same, false otherwise
- confidence: a number from 0 to 1 indicating your confidence
- explanation: a brief explanation of your reasoning`;

export const VERIFICATION_RESPONSE_SCHEMA = {
  type: Type.OBJECT,
  properties: {
    matches: { type: Type.BOOLEAN },
    confidence: { type: Type.NUMBER },
    explanation: { type: Type.STRING }
  },
  required: ['matches', 'confidence', 'explanation']
};

// ============================================================================
// Cooking Agent Configuration (Phase 2)
// ============================================================================

/** Generate function declarations for all cooking actions */
export function generateCookingTools() {
  const functionDeclarations = COOKING_ACTIONS.map(action => {
    // Special case for 'serve' action - different parameter schema
    if (action.name === 'serve') {
      return {
        name: 'serve',
        description: `${action.emoji} Serve a dish from the current inventory. The dish parameter must be an exact item name from the inventory.`,
        parameters: {
          type: Type.OBJECT,
          properties: {
            dish: {
              type: Type.STRING,
              description: 'Name of dish being served (must be an exact item name from inventory)'
            }
          },
          required: ['dish']
        }
      };
    }

    // Special case for 'pass' action - give up on an order
    if (action.name === 'pass') {
      return {
        name: 'pass',
        description: `${action.emoji} Pass on the current challenge. Use this after trying to serve the dish with available ingredients or tools (at least 3 times).`,
        parameters: {
          type: Type.OBJECT,
          properties: {},
          required: []
        }
      };
    }

    // Standard cooking action
    return {
      name: action.name,
      description: `${action.emoji} Apply the '${action.displayName}' cooking technique.`,
      parameters: {
        type: Type.OBJECT,
        properties: {
          ingredients: {
            type: Type.ARRAY,
            items: { type: Type.STRING },
            description: 'Ingredient names (must exist in inventory)'
          }
        },
        required: ['ingredients']
      }
    };
  });

  // Return as Tool[] format
  return [{ functionDeclarations }] as any;
}

/** Build Cooking Agent system instruction with current inventory */
export function buildCookingAgentSystemInstruction(inventory: Ingredient[]): string {
  const actionList = COOKING_ACTIONS.map(a => `${a.emoji} ${a.name}()`).join(', ');
  const inventoryList = inventory.map(i => `${i.emoji} ${i.name}`).join(', ');

  return `You are a creative chef assistant that can prepare any dish using cooking actions.

**Available Cooking Actions:**
${actionList}

**Your Task:**
When the user requests a dish, plan and execute cooking steps using function calls. 
Explain your reasoning in one short sentence, then call a cooking function. 

**CRITICAL: ONE FUNCTION CALL PER TURN**
You MUST call exactly ONE function per response. After each function call, 
wait for the result before calling the next function.

**Important Rules:**
- Only use ingredients that exist in the current inventory
- Each cooking action produces new items added to inventory
- Call serve() when the target dish is ready. I then confirm with a friendly message!
- If serve() returns a success, confirm with a friendly message!
- If serve() returns a failure, explain why and try again!
- Call pass() if you cannot complete the order with the available ingredients or tools. This gives up on the current order.

**Current Inventory:**
${inventoryList}

Be creative but realistic about cooking steps!`;
}
