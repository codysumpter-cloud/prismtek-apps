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

struct PixelStudioFrame: Codable, Hashable, Identifiable {
    var id: UUID
    var pixels: [String]

    init(id: UUID = UUID(), pixels: [String]) {
        self.id = id
        self.pixels = pixels
    }

    static func blank(size: Int) -> PixelStudioFrame {
        PixelStudioFrame(pixels: Array(repeating: "", count: max(1, size * size)))
    }
}

struct PixelStudioPaletteSwatch: Hashable, Identifiable {
    let hex: String

    var id: String { hex }
    var color: Color { Color(pixelStudioHex: hex) ?? .clear }

    static func make(from rawValue: String) -> [PixelStudioPaletteSwatch] {
        let components = rawValue
            .split(whereSeparator: { $0 == "," || $0 == "\n" })
            .map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }

        let normalized = components.compactMap(PixelStudioPaletteSwatch.normalize(hex:))
        let unique = Array(NSOrderedSet(array: normalized)) as? [String] ?? []
        let values = unique.isEmpty ? PixelStudioProject.defaultPalette : unique
        return values.map { PixelStudioPaletteSwatch(hex: $0) }
    }

    static func normalize(hex rawValue: String) -> String? {
        let trimmed = rawValue.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var value = trimmed.hasPrefix("#") ? String(trimmed.dropFirst()) : trimmed
        if value.count == 3 {
            value = value.map { String(repeating: $0, count: 2) }.joined()
        }

        let allowed = CharacterSet(charactersIn: "0123456789ABCDEFabcdef")
        guard value.count == 6, value.unicodeScalars.allSatisfy({ allowed.contains($0) }) else { return nil }
        return "#\(value.uppercased())"
    }
}

struct PixelStudioProject: Codable, Hashable {
    static let defaultPalette = ["#9EF0D0", "#2B7A78", "#17252A", "#FEF6E8"]

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
    var frames: [PixelStudioFrame]
    var activeFrameIndex: Int
    var selectedHex: String

    static let `default` = PixelStudioProject(
        title: "Buddy Sprite",
        author: "",
        concept: "A readable premium pixel buddy with one strong accent color.",
        canvasSize: 32,
        frameCount: 4,
        palette: defaultPalette.joined(separator: ", "),
        polishGoal: "Make the silhouette cleaner and the accent colors easier to read on mobile.",
        animationGoal: "Create a clean idle loop with one anticipation beat and a satisfying return to rest.",
        notes: "",
        lastUpdatedAt: .now,
        lastBuddyArtifact: nil,
        lastBuddySummary: nil,
        frames: Array(repeating: PixelStudioFrame.blank(size: 32), count: 4),
        activeFrameIndex: 0,
        selectedHex: "#17252A"
    )

    init(
        title: String,
        author: String,
        concept: String,
        canvasSize: Int,
        frameCount: Int,
        palette: String,
        polishGoal: String,
        animationGoal: String,
        notes: String,
        lastUpdatedAt: Date,
        lastBuddyArtifact: String?,
        lastBuddySummary: String?,
        frames: [PixelStudioFrame],
        activeFrameIndex: Int,
        selectedHex: String
    ) {
        self.title = title
        self.author = author
        self.concept = concept
        self.canvasSize = canvasSize
        self.frameCount = frameCount
        self.palette = palette
        self.polishGoal = polishGoal
        self.animationGoal = animationGoal
        self.notes = notes
        self.lastUpdatedAt = lastUpdatedAt
        self.lastBuddyArtifact = lastBuddyArtifact
        self.lastBuddySummary = lastBuddySummary
        self.frames = frames
        self.activeFrameIndex = activeFrameIndex
        self.selectedHex = selectedHex
    }

    private enum CodingKeys: String, CodingKey {
        case title
        case author
        case concept
        case canvasSize
        case frameCount
        case palette
        case polishGoal
        case animationGoal
        case notes
        case lastUpdatedAt
        case lastBuddyArtifact
        case lastBuddySummary
        case frames
        case activeFrameIndex
        case selectedHex
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        title = try container.decodeIfPresent(String.self, forKey: .title) ?? Self.default.title
        author = try container.decodeIfPresent(String.self, forKey: .author) ?? Self.default.author
        concept = try container.decodeIfPresent(String.self, forKey: .concept) ?? Self.default.concept
        canvasSize = try container.decodeIfPresent(Int.self, forKey: .canvasSize) ?? Self.default.canvasSize
        frameCount = try container.decodeIfPresent(Int.self, forKey: .frameCount) ?? Self.default.frameCount
        palette = try container.decodeIfPresent(String.self, forKey: .palette) ?? Self.default.palette
        polishGoal = try container.decodeIfPresent(String.self, forKey: .polishGoal) ?? Self.default.polishGoal
        animationGoal = try container.decodeIfPresent(String.self, forKey: .animationGoal) ?? Self.default.animationGoal
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? Self.default.notes
        lastUpdatedAt = try container.decodeIfPresent(Date.self, forKey: .lastUpdatedAt) ?? .now
        lastBuddyArtifact = try container.decodeIfPresent(String.self, forKey: .lastBuddyArtifact)
        lastBuddySummary = try container.decodeIfPresent(String.self, forKey: .lastBuddySummary)
        frames = try container.decodeIfPresent([PixelStudioFrame].self, forKey: .frames) ?? []
        activeFrameIndex = try container.decodeIfPresent(Int.self, forKey: .activeFrameIndex) ?? 0
        selectedHex = try container.decodeIfPresent(String.self, forKey: .selectedHex) ?? Self.default.selectedHex
    }

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

    var paletteSwatches: [PixelStudioPaletteSwatch] {
        PixelStudioPaletteSwatch.make(from: project.palette)
    }

    var activeFrame: PixelStudioFrame {
        let index = min(max(project.activeFrameIndex, 0), max(project.frames.count - 1, 0))
        return project.frames[index]
    }

    func load() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: Paths.pixelStudioProjectFile),
              var decoded = try? decoder.decode(PixelStudioProject.self, from: data) else {
            project = Self.normalized(.default)
            persist()
            return
        }

        decoded = Self.normalized(decoded)
        project = decoded
        persist()
    }

    func update(_ mutate: (inout PixelStudioProject) -> Void) {
        var next = project
        mutate(&next)
        next.lastUpdatedAt = .now
        next = Self.normalized(next)
        project = next
        persist()
    }

    func selectFrame(_ index: Int) {
        update { draft in
            draft.activeFrameIndex = min(max(index, 0), max(draft.frames.count - 1, 0))
        }
    }

    func selectColor(_ hex: String) {
        guard let normalized = PixelStudioPaletteSwatch.normalize(hex: hex) else { return }
        update { $0.selectedHex = normalized }
    }

    func paint(row: Int, column: Int, hex: String?) {
        update { draft in
            guard draft.canvasSize > 0,
                  row >= 0, row < draft.canvasSize,
                  column >= 0, column < draft.canvasSize,
                  draft.frames.indices.contains(draft.activeFrameIndex) else { return }

            let index = row * draft.canvasSize + column
            let normalized = hex.flatMap(PixelStudioPaletteSwatch.normalize(hex:)) ?? ""
            draft.frames[draft.activeFrameIndex].pixels[index] = normalized
        }
    }

    func clearActiveFrame() {
        update { draft in
            guard draft.frames.indices.contains(draft.activeFrameIndex) else { return }
            draft.frames[draft.activeFrameIndex] = PixelStudioFrame.blank(size: draft.canvasSize)
        }
    }

    func fillActiveFrame(with hex: String?) {
        update { draft in
            guard draft.frames.indices.contains(draft.activeFrameIndex) else { return }
            let normalized = hex.flatMap(PixelStudioPaletteSwatch.normalize(hex:)) ?? ""
            draft.frames[draft.activeFrameIndex].pixels = Array(repeating: normalized, count: draft.canvasSize * draft.canvasSize)
        }
    }

    func mirrorActiveFrame() {
        update { draft in
            guard draft.frames.indices.contains(draft.activeFrameIndex) else { return }
            let size = draft.canvasSize
            let source = draft.frames[draft.activeFrameIndex].pixels
            var mirrored = Array(repeating: "", count: size * size)
            for row in 0..<size {
                for column in 0..<size {
                    let sourceIndex = row * size + column
                    let targetIndex = row * size + (size - column - 1)
                    mirrored[targetIndex] = source[sourceIndex]
                }
            }
            draft.frames[draft.activeFrameIndex].pixels = mirrored
        }
    }

    func addFrame() {
        update { draft in
            let insertIndex = min(draft.activeFrameIndex + 1, draft.frames.count)
            draft.frames.insert(PixelStudioFrame.blank(size: draft.canvasSize), at: insertIndex)
            draft.activeFrameIndex = insertIndex
        }
    }

    func duplicateActiveFrame() {
        update { draft in
            guard draft.frames.indices.contains(draft.activeFrameIndex) else { return }
            let copy = PixelStudioFrame(pixels: draft.frames[draft.activeFrameIndex].pixels)
            let insertIndex = min(draft.activeFrameIndex + 1, draft.frames.count)
            draft.frames.insert(copy, at: insertIndex)
            draft.activeFrameIndex = insertIndex
        }
    }

    func removeActiveFrame() {
        update { draft in
            guard draft.frames.indices.contains(draft.activeFrameIndex), draft.frames.count > 1 else { return }
            draft.frames.remove(at: draft.activeFrameIndex)
            draft.activeFrameIndex = min(draft.activeFrameIndex, draft.frames.count - 1)
        }
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

    private static func normalized(_ input: PixelStudioProject) -> PixelStudioProject {
        var project = input
        project.canvasSize = max(1, project.canvasSize)
        let targetFrameCount = max(project.frameCount, 1)

        let swatches = PixelStudioPaletteSwatch.make(from: project.palette)
        project.palette = swatches.map(\.hex).joined(separator: ", ")
        let normalizedSelected = PixelStudioPaletteSwatch.normalize(hex: project.selectedHex)
        project.selectedHex = swatches.contains(where: { $0.hex == normalizedSelected }) ? (normalizedSelected ?? swatches.first?.hex ?? PixelStudioProject.default.selectedHex) : (swatches.first?.hex ?? PixelStudioProject.default.selectedHex)

        if project.frames.isEmpty {
            project.frames = Array(repeating: PixelStudioFrame.blank(size: project.canvasSize), count: targetFrameCount)
        }

        let pixelCount = project.canvasSize * project.canvasSize
        project.frames = project.frames.map { frame in
            var resized = frame
            if resized.pixels.count < pixelCount {
                resized.pixels += Array(repeating: "", count: pixelCount - resized.pixels.count)
            } else if resized.pixels.count > pixelCount {
                resized.pixels = Array(resized.pixels.prefix(pixelCount))
            }
            resized.pixels = resized.pixels.map { PixelStudioPaletteSwatch.normalize(hex: $0) ?? "" }
            return resized
        }

        if project.frames.count < targetFrameCount {
            project.frames += Array(repeating: PixelStudioFrame.blank(size: project.canvasSize), count: targetFrameCount - project.frames.count)
        } else if project.frames.count > targetFrameCount {
            project.frames = Array(project.frames.prefix(targetFrameCount))
        }

        project.frameCount = project.frames.count
        project.activeFrameIndex = min(max(project.activeFrameIndex, 0), project.frames.count - 1)
        return project
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
            return "Open the admin builder tool from prismtek.dev in the browser."
        case .missionControl:
            return "Open the website admin Mission Control surface in the browser."
        case .myAccount:
            return "Open user profiles and account surfaces in the browser."
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
    func runPixelStudioBuddyAction(_ action: PixelBuddyAction, request: String? = nil) -> BeMoreReceipt {
        let project = PixelStudioStore.shared.project
        let trimmedRequest = request?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !project.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return BeMoreReceipt(actionId: UUID(), status: .failed, title: action.title, summary: "Pixel Studio project missing", output: [:], artifacts: [], logs: [], error: "Open Studio and set up the active pixel project first.")
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
            let receipt = BeMoreReceipt(
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
            return BeMoreReceipt(actionId: UUID(), status: .failed, title: action.title, summary: "Could not create Buddy pixel artifact", output: [:], artifacts: [], logs: [], error: error.localizedDescription)
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

extension Color {
    init?(pixelStudioHex rawValue: String) {
        guard let normalized = PixelStudioPaletteSwatch.normalize(hex: rawValue) else { return nil }
        let value = String(normalized.dropFirst())
        guard let intValue = UInt64(value, radix: 16) else { return nil }
        let red = Double((intValue & 0xFF0000) >> 16) / 255.0
        let green = Double((intValue & 0x00FF00) >> 8) / 255.0
        let blue = Double(intValue & 0x0000FF) / 255.0
        self = Color(red: red, green: green, blue: blue)
    }
}
