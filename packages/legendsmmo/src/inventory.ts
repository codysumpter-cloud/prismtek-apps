import type { LegendsId } from "./content";

export interface InventoryStack {
  itemId: LegendsId;
  quantity: number;
}

export interface InventoryState {
  currency: number;
  stacks: InventoryStack[];
}

export function addItem(inventory: InventoryState, itemId: LegendsId, quantity = 1): InventoryState {
  if (quantity <= 0) throw new Error("Quantity must be positive.");
  const existing = inventory.stacks.find((stack) => stack.itemId === itemId);
  if (!existing) {
    return { ...inventory, stacks: [...inventory.stacks, { itemId, quantity }] };
  }
  return {
    ...inventory,
    stacks: inventory.stacks.map((stack) =>
      stack.itemId === itemId ? { ...stack, quantity: stack.quantity + quantity } : stack,
    ),
  };
}

export function removeItem(inventory: InventoryState, itemId: LegendsId, quantity = 1): InventoryState {
  if (quantity <= 0) throw new Error("Quantity must be positive.");
  const existing = inventory.stacks.find((stack) => stack.itemId === itemId);
  if (!existing || existing.quantity < quantity) throw new Error(`Not enough ${itemId}.`);

  return {
    ...inventory,
    stacks: inventory.stacks
      .map((stack) => (stack.itemId === itemId ? { ...stack, quantity: stack.quantity - quantity } : stack))
      .filter((stack) => stack.quantity > 0),
  };
}

export function addCurrency(inventory: InventoryState, amount: number): InventoryState {
  if (amount < 0) throw new Error("Use spendCurrency for negative currency changes.");
  return { ...inventory, currency: inventory.currency + amount };
}

export function spendCurrency(inventory: InventoryState, amount: number): InventoryState {
  if (amount < 0) throw new Error("Amount must be positive.");
  if (inventory.currency < amount) throw new Error("Not enough currency.");
  return { ...inventory, currency: inventory.currency - amount };
}
