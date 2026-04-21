import SwiftUI
import Foundation

extension Paths {
    static var pixelStudioCanvasFile: URL { stateDirectory.appendingPathComponent("pixel-studio-canvas.json") }
}

struct PixelStudioCanvasFrame: Identifiable, Codable, Hashable {
    var id: String
    var pixels: [String]
}

struct PixelStudioCanvasDocument: Codable, Hashable {
    var canvasSize: Int
    var palette: [String]
    var currentColor: String
    var selectedFrameID: String
    var frames: [PixelStudioCanvasFrame]
    var lastUpdatedAt: Date

    static let `default` = PixelStudioCanvasDocument(
        canvasSize: 32,
        palette: ["#9EF0D0", "#2B7A78", "#17252A", "#FEF6E8"],
        currentColor: "#9EF0D0",
        selectedFrameID: "frame-1",
        frames: [PixelStudioCanvasFrame(id: "frame-1", pixels: Array(repeating: "", count: 32 * 32))],
        lastUpdatedAt: .now
    )
}

@MainActor
final class PixelStudioCanvasStore: ObservableObject {
    static let shared = PixelStudioCanvasStore()

    @Published var document: PixelStudioCanvasDocument = .default

    private init() {
        load()
    }

    var selectedFrame: PixelStudioCanvasFrame? {
        document.frames.first(where: { $0.id == document.selectedFrameID }) ?? document.frames.first
    }

    func load() {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        guard let data = try? Data(contentsOf: Paths.pixelStudioCanvasFile),
              let decoded = try? decoder.decode(PixelStudioCanvasDocument.self, from: data) else {
            document = .default
            return
        }
        document = decoded
        sanitize()
    }

    func sync(with project: PixelStudioProject) {
        let palette = parsedPalette(from: project.palette)
        let size = max(8, project.canvasSize)
        let frameCount = max(1, project.frameCount)
        var changed = false

        if document.canvasSize != size {
            document.canvasSize = size
            document.frames = document.frames.map { frame in
                PixelStudioCanvasFrame(id: frame.id, pixels: resizedPixels(frame.pixels, from: inferredOldSize(frame.pixels), to: size))
            }
            changed = true
        }

        if palette.isEmpty == false && document.palette != palette {
            document.palette = palette
            if document.currentColor.isEmpty || palette.contains(document.currentColor) == false {
                document.currentColor = palette.first ?? "#000000"
            }
            changed = true
        }

        while document.frames.count < frameCount {
            document.frames.append(PixelStudioCanvasFrame(id: "frame-\(document.frames.count + 1)", pixels: Array(repeating: "", count: size * size)))
            changed = true
        }
        if document.frames.count > frameCount {
            document.frames = Array(document.frames.prefix(frameCount))
            changed = true
        }
        if document.frames.isEmpty {
            document.frames = [PixelStudioCanvasFrame(id: "frame-1", pixels: Array(repeating: "", count: size * size))]
            changed = true
        }
        if document.frames.contains(where: { $0.id == document.selectedFrameID }) == false {
            document.selectedFrameID = document.frames.first?.id ?? "frame-1"
            changed = true
        }

        if changed {
            touchAndPersist()
        }
    }

    func selectFrame(_ id: String) {
        document.selectedFrameID = id
        touchAndPersist()
    }

    func setPixel(index: Int, color: String) {
        guard let frameIndex = document.frames.firstIndex(where: { $0.id == document.selectedFrameID }),
              index >= 0,
              index < document.frames[frameIndex].pixels.count else { return }
        document.frames[frameIndex].pixels[index] = color
        touchAndPersist()
    }

    func clearPixel(index: Int) {
        setPixel(index: index, color: "")
    }

    func clearFrame() {
        guard let frameIndex = document.frames.firstIndex(where: { $0.id == document.selectedFrameID }) else { return }
        document.frames[frameIndex].pixels = Array(repeating: "", count: document.canvasSize * document.canvasSize)
        touchAndPersist()
    }

    func duplicateSelectedFrame() {
        guard let frame = selectedFrame else { return }
        let copy = PixelStudioCanvasFrame(id: "frame-\(document.frames.count + 1)", pixels: frame.pixels)
        document.frames.append(copy)
        document.selectedFrameID = copy.id
        touchAndPersist()
    }

    func addBlankFrame() {
        let frame = PixelStudioCanvasFrame(id: "frame-\(document.frames.count + 1)", pixels: Array(repeating: "", count: document.canvasSize * document.canvasSize))
        document.frames.append(frame)
        document.selectedFrameID = frame.id
        touchAndPersist()
    }

    func removeSelectedFrame() {
        guard document.frames.count > 1,
              let frameIndex = document.frames.firstIndex(where: { $0.id == document.selectedFrameID }) else { return }
        document.frames.remove(at: frameIndex)
        document.selectedFrameID = document.frames[max(0, min(frameIndex, document.frames.count - 1))].id
        touchAndPersist()
    }

    func setCurrentColor(_ color: String) {
        document.currentColor = color
        touchAndPersist()
    }

    private func parsedPalette(from raw: String) -> [String] {
        raw.split(separator: ",")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { $0.isEmpty == false }
    }

    private func inferredOldSize(_ pixels: [String]) -> Int {
        let root = Int(Double(pixels.count).squareRoot())
        return max(1, root)
    }

    private func resizedPixels(_ pixels: [String], from oldSize: Int, to newSize: Int) -> [String] {
        guard oldSize != newSize, oldSize > 0 else { return Array(pixels.prefix(newSize * newSize)) + Array(repeating: "", count: max(0, (newSize * newSize) - pixels.count)) }
        var next = Array(repeating: "", count: newSize * newSize)
        for y in 0..<newSize {
            for x in 0..<newSize {
                let sourceX = min(oldSize - 1, Int(Double(x) * Double(oldSize) / Double(newSize)))
                let sourceY = min(oldSize - 1, Int(Double(y) * Double(oldSize) / Double(newSize)))
                let sourceIndex = sourceY * oldSize + sourceX
                let destinationIndex = y * newSize + x
                if sourceIndex < pixels.count {
                    next[destinationIndex] = pixels[sourceIndex]
                }
            }
        }
        return next
    }

    private func sanitize() {
        if document.frames.isEmpty {
            document.frames = [PixelStudioCanvasFrame(id: "frame-1", pixels: Array(repeating: "", count: document.canvasSize * document.canvasSize))]
        }
        if document.palette.isEmpty {
            document.palette = ["#9EF0D0", "#2B7A78", "#17252A", "#FEF6E8"]
        }
        if document.currentColor.isEmpty {
            document.currentColor = document.palette.first ?? "#000000"
        }
        if document.frames.contains(where: { $0.id == document.selectedFrameID }) == false {
            document.selectedFrameID = document.frames.first?.id ?? "frame-1"
        }
        persist()
    }

    private func touchAndPersist() {
        document.lastUpdatedAt = .now
        persist()
    }

    private func persist() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let data = try encoder.encode(document)
            try data.write(to: Paths.pixelStudioCanvasFile, options: [.atomic])
        } catch {}
    }
}

struct PixelStudioNativeCanvasView: View {
    @ObservedObject private var projectStore = PixelStudioStore.shared
    @ObservedObject private var canvasStore = PixelStudioCanvasStore.shared

    private var cellSize: CGFloat {
        switch canvasStore.document.canvasSize {
        case ...16: return 14
        case ...24: return 11
        case ...32: return 9
        case ...48: return 6
        default: return 4
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Native Pixel Canvas")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Draw frames locally on iPhone, then use Buddy to finish, improve, or animate from the same project.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "\(canvasStore.document.frames.count) frames", color: BMOTheme.accent)
            }

            paletteStrip
            canvasToolbar
            frameTimeline
            canvasGrid
        }
        .onAppear {
            canvasStore.sync(with: projectStore.project)
        }
        .onChange(of: projectStore.project.canvasSize) { _ in
            canvasStore.sync(with: projectStore.project)
        }
        .onChange(of: projectStore.project.frameCount) { _ in
            canvasStore.sync(with: projectStore.project)
        }
        .onChange(of: projectStore.project.palette) { _ in
            canvasStore.sync(with: projectStore.project)
        }
    }

    private var paletteStrip: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(canvasStore.document.palette, id: \.self) { color in
                    Button {
                        canvasStore.setCurrentColor(color)
                    } label: {
                        RoundedRectangle(cornerRadius: 8, style: .continuous)
                            .fill(Color(hex: color))
                            .frame(width: 32, height: 32)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .stroke(canvasStore.document.currentColor == color ? BMOTheme.textPrimary : BMOTheme.divider, lineWidth: 2)
                            )
                    }
                    .buttonStyle(.plain)
                }
                Button("Eraser") {
                    canvasStore.setCurrentColor("")
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
    }

    private var canvasToolbar: some View {
        HStack(spacing: 8) {
            Button("New Frame") { canvasStore.addBlankFrame() }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            Button("Duplicate") { canvasStore.duplicateSelectedFrame() }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            Button("Clear") { canvasStore.clearFrame() }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            Button("Delete") { canvasStore.removeSelectedFrame() }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
                .disabled(canvasStore.document.frames.count <= 1)
        }
    }

    private var frameTimeline: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                ForEach(Array(canvasStore.document.frames.enumerated()), id: \.element.id) { index, frame in
                    Button {
                        canvasStore.selectFrame(frame.id)
                    } label: {
                        VStack(spacing: 6) {
                            PixelFrameThumbnailView(size: canvasStore.document.canvasSize, pixels: frame.pixels)
                            Text("F\(index + 1)")
                                .font(.caption2)
                                .foregroundColor(BMOTheme.textSecondary)
                        }
                        .padding(8)
                        .background(canvasStore.document.selectedFrameID == frame.id ? BMOTheme.backgroundCardHover : BMOTheme.backgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var canvasGrid: some View {
        ScrollView([.horizontal, .vertical], showsIndicators: true) {
            VStack(spacing: 1) {
                ForEach(0..<canvasStore.document.canvasSize, id: \.self) { row in
                    HStack(spacing: 1) {
                        ForEach(0..<canvasStore.document.canvasSize, id: \.self) { column in
                            let index = (row * canvasStore.document.canvasSize) + column
                            let pixel = canvasStore.selectedFrame?.pixels[index] ?? ""
                            Rectangle()
                                .fill(pixel.isEmpty ? BMOTheme.backgroundPrimary : Color(hex: pixel))
                                .frame(width: cellSize, height: cellSize)
                                .overlay(Rectangle().stroke(BMOTheme.divider.opacity(0.35), lineWidth: 0.5))
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    if canvasStore.document.currentColor.isEmpty {
                                        canvasStore.clearPixel(index: index)
                                    } else {
                                        canvasStore.setPixel(index: index, color: canvasStore.document.currentColor)
                                    }
                                }
                        }
                    }
                }
            }
            .padding(6)
            .background(BMOTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
        }
        .frame(minHeight: 300)
    }
}

private struct PixelFrameThumbnailView: View {
    let size: Int
    let pixels: [String]

    private var thumbnailSize: CGFloat { 48 }

    var body: some View {
        let cell = max(2, thumbnailSize / CGFloat(max(1, min(size, 16))))
        VStack(spacing: 0) {
            ForEach(0..<min(size, 16), id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<min(size, 16), id: \.self) { column in
                        let sourceX = min(size - 1, Int(Double(column) * Double(size) / Double(min(size, 16))))
                        let sourceY = min(size - 1, Int(Double(row) * Double(size) / Double(min(size, 16))))
                        let index = (sourceY * size) + sourceX
                        let pixel = index < pixels.count ? pixels[index] : ""
                        Rectangle()
                            .fill(pixel.isEmpty ? BMOTheme.backgroundPrimary : Color(hex: pixel))
                            .frame(width: cell, height: cell)
                    }
                }
            }
        }
        .padding(4)
        .background(BMOTheme.backgroundPrimary)
        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private extension Color {
    init(hex: String) {
        let sanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var value: UInt64 = 0
        Scanner(string: sanitized).scanHexInt64(&value)
        let red, green, blue: Double
        switch sanitized.count {
        case 6:
            red = Double((value >> 16) & 0xFF) / 255.0
            green = Double((value >> 8) & 0xFF) / 255.0
            blue = Double(value & 0xFF) / 255.0
        default:
            red = 0.5
            green = 0.5
            blue = 0.5
        }
        self.init(.sRGB, red: red, green: green, blue: blue, opacity: 1)
    }
}
