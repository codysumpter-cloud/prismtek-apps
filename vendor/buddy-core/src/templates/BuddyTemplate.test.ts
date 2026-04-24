import { BuddyTemplate, sanitizeBuddyTemplate } from "./BuddyTemplate";
import { sanitizeBuddyTemplate as sanitize } from "./sanitizeBuddyTemplate";

describe("BuddyTemplate", () => {
  it("should define valid types", () => {
    const template: BuddyTemplate = { id: "1", config: {}, owner: "test" };
    expect(template.id).toBe("1");
  });

  it("should sanitize templates", () => {
    const template = { id: "1", config: { secret: "leak" }, owner: "test" };
    const result = sanitize(template);
    expect(result.sanitized).toBe(true);
  });
});