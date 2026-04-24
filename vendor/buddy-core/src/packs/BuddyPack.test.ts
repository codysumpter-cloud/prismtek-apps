import { BuddyPack } from "./BuddyPack";

describe("BuddyPack", () => {
  it("should define valid types", () => {
    const pack: BuddyPack = { id: "1", version: "1.0", capabilities: [] };
    expect(pack.version).toBe("1.0");
  });
});