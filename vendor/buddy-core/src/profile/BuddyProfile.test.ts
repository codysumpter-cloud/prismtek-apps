import { BuddyProfile } from "./BuddyProfile";

describe("BuddyProfile", () => {
  it("should define valid types", () => {
    const profile: BuddyProfile = { id: "1", name: "Test", version: "1.0", metadata: {} };
    expect(profile.id).toBe("1");
  });
});