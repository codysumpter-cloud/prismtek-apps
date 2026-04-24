import { BuddyMemory } from "./BuddyMemory";

describe("BuddyMemory", () => {
  it("should define valid types", () => {
    const memory: BuddyMemory = { id: "1", content: "test", importance: 5, tags: [] };
    expect(memory.content).toBe("test");
  });
});