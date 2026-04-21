import Foundation
import SwiftUI

extension Paths {
    static var pixelStudioProjectFile: URL { stateDirectory.appendingPathComponent("pixel-studio-project.json") }
}

enum PixelBuddyAction: String, CaseIterable, Codable, Hashable, Identifiable {
    case finish
    case improve
    case animate

    var id: String { rawValue }

    var title: String {
        switch self {
        case .finish: return "Finish Pass"
        case .improve: return "Improve Readability"
        case .animate: return "Animation Plan"
        }
    }

    var systemImage: String {
        switch self {
        case .finish: return "wand.and.stars"
        case .improve: return "eye"
        case .animate: return "sparkles.tv"
        }
    }

    var artifactLabel: String {
        switch self {
        case .finish: return "finish-pass"
        case .improve: return "improve-pass"
        case .animate: return "animation-plan"
        }
    }
}

struct PixelStudioProject: Codable, Hashable {
    var title: String
    var author: String
    var concept: String
    var canvasSize: Int
    var frameCount: Int
    var palette: String
    var polishGoal: String
    var animationGoal: String
    var notes: String
    var lastUpdatedAt: Date
    var lastBuddyArtifact: String?
    var lastBuddySummary: String?

    static let `default` = PixelStudioProject(
        title: "Buddy Sprite",
        author: "",
        concept: "A readable premium pixel buddy with one strong accent color.",
        canvasSize: 32,
        frameCount: 4,
        palette: "#9EF0D0, #2B7A78, #17252A, #FEF6E8",
        polishGoal: "Make the silhouette cleaner and the accent colors easier to read on mobile.",
        animationGoal: "Create a clean idle loop with one anticipation beat and a satisfying return to rest.",
        notes: "",
        lastUpdatedAt: .now,
        lastBuddyArtifact: nil,
        lastBuddySummary: nil
    )

    var safeSlug: String {
        let raw = title.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let allowed = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-"))
        let slug = raw
            .replacingOccurrences(of: " ", with: "-")
            .unicodeScalars
            .map { allowed.contains($0) ? Character($0) : "-" }
            .reduce(into: "") { $0.append($1) }
            .replacingOccurrences(of: "--", with: "-")
            .trimmingCharacters(in: CharacterSet(charactersIn: "-"))
        return slug.isEmpty ? "buddy-sprite" : slug
    }
}

@MainActor
final class PixelStudioStore: ObservableObject {
    static let shared = PixelStudioStore()

    @Published var project: PixelStudioProject = .default

    private init() {
        load()
    }

    func load() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: Paths.pixelStudioProjectFile),
              let decoded = try? decoder.decode(PixelStudioProject.self, from: data) else {
            project = .default
            return
        }
        project = decoded
    }

    func update(_ mutate: (inout PixelStudioProject) -> Void) {
        var next = project
        mutate(&next)
        next.lastUpdatedAt = .now
        project = next
        persist()
    }

    func markBuddyArtifact(path: String, summary: String) {
        update {
            $0.lastBuddyArtifact = path
            $0.lastBuddySummary = summary
        }
    }

    func persist() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(project)
            try data.write(to: Paths.pixelStudioProjectFile, options: [.atomic])
        } catch {}
    }
}

enum BeMoreWebFeatureRoute: String, CaseIterable, Hashable, Identifiable {
    case pixelStudio
    case builderStudio
    case missionControl
    case myAccount

    var id: String { rawValue }

    var title: String {
        switch self {
        case .pixelStudio: return "Pixel Studio"
        case .builderStudio: return "Builder Studio"
        case .missionControl: return "Mission Control"
        case .myAccount: return "Profiles"
        }
    }

    var path: String {
        switch self {
        case .pixelStudio: return "/pixel-studio/"
        case .builderStudio: return "/builder-studio/"
        case .missionControl: return "/mission-control-web/"
        case .myAccount: return "/my-account/"
        }
    }

    var systemImage: String {
        switch self {
        case .pixelStudio: return "square.grid.3x3.fill"
        case .builderStudio: return "square.3.stack.3d.fill"
        case .missionControl: return "slider.horizontal.3"
        case .myAccount: return "person.crop.circle"
        }
    }

    var summary: String {
        switch self {
        case .pixelStudio:
            return "Draw sprites, frame loops, export, and use Buddy as a pixel-art copilot."
        case .builderStudio:
            return "Open the admin builder tool from prismtek.dev inside the app shell."
        case .missionControl:
            return "Open the website admin Mission Control surface inside the app shell."
        case .myAccount:
            return "Open user profiles and account surfaces from the website inside the app shell."
        }
    }

    func resolvedURL(stackConfig: StackConfig) -> URL? {
        let rawBase = stackConfig.gatewayURL.trimmingCharacters(in: .whitespacesAndNewlines)
        let base = rawBase.isEmpty ? "https://prismtek.dev" : rawBase
        guard var components = URLComponents(string: base) else { return nil }
        if components.scheme == nil {
            components.scheme = "https"
        }
        components.path = path
        components.query = nil
        components.fragment = nil
        return components.url
    }
}

@MainActor
extension AppState {
    func runPixelStudioBuddyAction(_ action: PixelBuddyAction, request: String? = nil) -> OpenClawReceipt {
        let project = PixelStudioStore.shared.project
        let trimmedRequest = request?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !project.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return OpenClawReceipt(actionId: UUID(), status: .failed, title: action.title, summary: "Pixel Studio project missing", output: [:], artifacts: [], logs: [], error: "Open Studio and set up the active pixel project first.")
        }

        let slug = project.safeSlug
        let timestamp = Self.pixelArtifactTimestamp.string(from: .now)
        let uniqueSuffix = UUID().uuidString.prefix(8)
        let briefPath = "pixel-studio/\(slug)/project-brief.json"
        let artifactPath = "pixel-studio/\(slug)/buddy-\(action.artifactLabel)-\(timestamp)-\(uniqueSuffix).md"

        let brief: [String: Any] = [
            "title": project.title,
            "author": project.author,
            "concept": project.concept,
            "canvasSize": project.canvasSize,
            "frameCount": project.frameCount,
            "palette": project.palette,
            "polishGoal": project.polishGoal,
            "animationGoal": project.animationGoal,
            "notes": project.notes,
            "lastUpdatedAt": ISO8601DateFormatter().string(from: project.lastUpdatedAt)
        ]

        do {
            let briefData = try JSONSerialization.data(withJSONObject: brief, options: [.prettyPrinted, .sortedKeys])
            let briefString = String(data: briefData, encoding: .utf8) ?? "{}"
            _ = try workspaceRuntime.writeFile(briefPath, content: briefString, source: "pixel.project")

            let markdown = pixelArtifactMarkdown(for: action, project: project, request: trimmedRequest)
            _ = try workspaceRuntime.writeFile(artifactPath, content: markdown, source: "pixel.buddy")

            let summary = pixelSummary(for: action, project: project)
            PixelStudioStore.shared.markBuddyArtifact(path: artifactPath, summary: summary)
            let receipt = OpenClawReceipt(
                actionId: UUID(),
                status: .persisted,
                title: action.title,
                summary: summary,
                output: [
                    "project": project.title,
                    "artifactPath": artifactPath,
                    "briefPath": briefPath,
                    "summary": summary
                ],
                artifacts: [briefPath, artifactPath],
                logs: [],
                error: nil
            )
            chatStore.messages.append(ChatMessage(role: .system, content: ReceiptFormatter.confirmedSummary(for: receipt)))
            chatStore.persist()
            return receipt
        } catch {
            return OpenClawReceipt(actionId: UUID(), status: .failed, title: action.title, summary: "Could not create Buddy pixel artifact", output: [:], artifacts: [], logs: [], error: error.localizedDescription)
        }
    }

    private static let pixelArtifactTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        return formatter
    }()

    private func pixelSummary(for action: PixelBuddyAction, project: PixelStudioProject) -> String {
        switch action {
        case .finish:
            return "Prepared a Buddy finish pass for \(project.title)."
        case .improve:
            return "Prepared a Buddy readability and improvement pass for \(project.title)."
        case .animate:
            return "Prepared a Buddy animation plan for \(project.title)."
        }
    }

    private func pixelArtifactMarkdown(for action: PixelBuddyAction, project: PixelStudioProject, request: String) -> String {
        let extra = request.isEmpty ? "" : "\nExtra request from chat: \(request)\n"
        switch action {
        case .finish:
            return """
            # Buddy Finish Pass — \(project.title)

            Canvas: \(project.canvasSize)x\(project.canvasSize)
            Current frame count: \(project.frameCount)
            Palette: \(project.palette)
            Concept: \(project.concept)
            Polish goal: \(project.polishGoal)
            \(extra)
            ## Keep
            - Preserve the main silhouette first so the sprite still reads at thumbnail size.
            - Keep one hero accent color and one reliable shadow color.
            - Avoid replacing every color at once; tighten contrast before adding detail.

            ## Finish pass
            1. Clean the outer silhouette and remove single-pixel bumps that do not support the pose.
            2. Strengthen one focal area only: face, visor, charm, or weapon.
            3. Push highlight clusters onto top-facing planes instead of scattering isolated bright pixels.
            4. Merge noisy midtones where they do not improve readability.
            5. Re-check the sprite at 1x size before exporting.

            ## Mobile readability check
            - Distinguish head, torso, and prop with value contrast, not just hue shifts.
            - Keep the darkest outline color off large interior clusters unless it is deliberate.
            - Make sure the accent color still reads against dark and light backgrounds.

            ## Final export checklist
            - Export a clean still PNG.
            - Export a sprite sheet once the idle loop timing is stable.
            - Save the final palette in project notes so Buddy can reuse it later.
            """
        case .improve:
            return """
            # Buddy Improvement Pass — \(project.title)

            Canvas: \(project.canvasSize)x\(project.canvasSize)
            Current frame count: \(project.frameCount)
            Palette: \(project.palette)
            Concept: \(project.concept)
            Notes: \(project.notes)
            \(extra)
            ## Improvement targets
            - Make the silhouette easier to recognize in one glance.
            - Reduce palette ambiguity between midtone and shadow roles.
            - Reserve detail for the face, emblem, or motion cue.

            ## Specific changes to try
            1. Test one cleaner contour around the head and shoulders.
            2. Increase contrast between the primary body mass and the accent prop.
            3. Remove any lone pixels that do not connect to a readable form.
            4. Use a simpler shadow band underneath the main form rather than checkerboard noise.
            5. Re-check color balance by temporarily viewing the sprite in grayscale.

            ## Palette advice
            - Keep 1 dark anchor, 1 midtone body color, 1 highlight, and 1 accent as the minimum stable set.
            - If the accent color is already strong, do not add a second competing accent without purpose.

            ## Game-ready notes
            - Prioritize the idle pose first.
            - Make the strongest shape changes happen on frame 2 or 3, not all at once.
            - Keep hitbox-facing edges readable and stable between frames.
            """
        case .animate:
            let frameCount = max(4, project.frameCount)
            return """
            # Buddy Animation Plan — \(project.title)

            Canvas: \(project.canvasSize)x\(project.canvasSize)
            Planned frames: \(frameCount)
            Animation goal: \(project.animationGoal)
            Concept: \(project.concept)
            \(extra)
            ## Loop structure
            - Frame 1: neutral readable base pose
            - Frame 2: anticipation shift (lean, blink start, cape lift, or hover rise)
            - Frame 3: motion peak / accent beat
            - Frame 4: settle back toward the base silhouette
            - Optional frames 5+ should smooth the return, not introduce a new pose family.

            ## Timing suggestion
            - Hold frame 1 slightly longer than the others.
            - Use the shortest timing on the peak motion frame.
            - Return to the neutral pose with a clean easing step instead of a hard snap.

            ## Motion polish
            - Animate the largest readable masses first: body, head, cape, tail, glow, or held item.
            - Let secondary details trail the main action by one beat.
            - Do not move every part every frame; stillness makes motion feel intentional.

            ## Export prep
            - Keep frame names consistent.
            - Check the loop against a dark and light background.
            - Export the sprite sheet after the idle loop reads cleanly at 1x.
            """
        }
    }
}
