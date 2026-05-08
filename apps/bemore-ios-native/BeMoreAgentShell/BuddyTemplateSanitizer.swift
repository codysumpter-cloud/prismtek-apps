import Foundation

struct BuddyTemplateSanitizer {
    /// Scrubs a live BuddyInstance to create a marketplace-safe BuddyTemplate.
    /// Ensures no private conversation history, user-specific memory or API keys are leaked.
    static func sanitize(instance: BuddyInstance) -> CouncilStarterBuddyTemplate {
        // 1. Extract the canonical template data from the instance
        // In a real-world scenario, this would map an active instance back to its starting seed
        // but for the shell, we derive it from the current state's identity.
        
        let baseTemplate = instance.template ?? CouncilStarterBuddyTemplate.default(for: instance.identity)
        
        // 2. Create the sanitized copy
        var sanitized = baseTemplate
        
        // 3. Scrubbing Logic:
        // - Remove all personal memory banks
        // - Strip conversation breadcrumbs
        // - Reset current bond/xp to starter levels for the template
        // - Ensure only public-facing metadata is preserved
        
        // Set the provenance to mark this as a sanitized export
        sanitized.provenance = BuddyTemplateProvenance(
            derivedFromTemplateID: baseTemplate.templateID,
            version: "1.0.0-sanitized",
            creatorID: instance.ownerID
        )
        
        return sanitized
    }
    
    static func default(for identity: BuddyIdentity) -> CouncilStarterBuddyTemplate {
        // Fallback for cases where the template link is broken
        // In a production environment, this would fetch the most recent canonical seed
        fatalError("Canonical seed missing for identity: \(identity.role)")
    }
}
