import { BuddyPolicy } from "./BuddyPolicy";

describe("BuddyPolicy", () => {
  it("should define valid types", () => {
    const policy: BuddyPolicy = { id: "1", rules: ["no-swearing"], constraints: {} };
    expect(policy.rules).toContain("no-swearing");
  });
});