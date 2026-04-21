import SwiftUI

private enum PixelStudioTool: String, CaseIterable, Identifiable {
    case brush
    case eraser

    var id: String { rawValue }

    var title: String {
        switch self {
        case .brush: return "Brush"
        case .eraser: return "Eraser"
        }
    }

    var systemImage: String {
        switch self {
        case .brush: return "paintbrush.fill"
        case .eraser: return "eraser.fill"
        }
    }
}

struct PixelStudioSurfaceView: View {
    @ObservedObject var store: PixelStudioStore
    @State private var selectedTool: PixelStudioTool = .brush
    @State private var showsGrid = true

    var body: some View {
        VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Native Pixel Canvas")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Sketch sprites and frame loops directly inside the app again. This is the core native pixel workflow, not a browser shell.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "\(store.project.frameCount) frames", color: BMOTheme.success)
            }

            previewPanel
            frameStrip
            toolBar
            paletteBar
            canvasEditor
            footer
        }
    }

    private var previewPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Current frame preview")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                Text("Frame \(store.project.activeFrameIndex + 1)")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }

            HStack(spacing: BMOTheme.spacingMD) {
                PixelStudioPreviewGrid(
                    pixels: store.activeFrame.pixels,
                    canvasSize: store.project.canvasSize,
                    showsGrid: false,
                    background: BMOTheme.backgroundPrimary
                )
                .frame(width: 132, height: 132)
                .background(BMOTheme.backgroundPrimary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    metricRow(label: "Canvas", value: "\(store.project.canvasSize)x\(store.project.canvasSize)")
                    metricRow(label: "Palette", value: "\(store.paletteSwatches.count) colors")
                    metricRow(label: "Tool", value: selectedTool.title)
                    metricRow(label: "Ink", value: selectedTool == .brush ? store.project.selectedHex : "Transparent")
                }
            }
            .padding(BMOTheme.spacingMD)
            .background(BMOTheme.backgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
        }
    }

    private var frameStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Frames")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                Text("Tap to switch")
                    .font(.caption2)
                    .foregroundColor(BMOTheme.textTertiary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(store.project.frames.enumerated()), id: \.element.id) { index, frame in
                        Button {
                            store.selectFrame(index)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                PixelStudioPreviewGrid(
                                    pixels: frame.pixels,
                                    canvasSize: store.project.canvasSize,
                                    showsGrid: false,
                                    background: BMOTheme.backgroundPrimary
                                )
                                .frame(width: 72, height: 72)
                                .background(BMOTheme.backgroundPrimary)
                                .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                                Text("Frame \(index + 1)")
                                    .font(.caption2.weight(.semibold))
                                    .foregroundColor(BMOTheme.textPrimary)
                            }
                            .padding(8)
                            .background(index == store.project.activeFrameIndex ? BMOTheme.backgroundCardHover : BMOTheme.backgroundSecondary)
                            .overlay(
                                RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous)
                                    .stroke(index == store.project.activeFrameIndex ? BMOTheme.accent : .clear, lineWidth: 1)
                            )
                            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var toolBar: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Tools")
                .font(.subheadline.weight(.semibold))
                .foregroundColor(BMOTheme.textPrimary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(PixelStudioTool.allCases) { tool in
                        smallToggleButton(
                            title: tool.title,
                            systemImage: tool.systemImage,
                            isSelected: selectedTool == tool
                        ) {
                            selectedTool = tool
                        }
                    }

                    smallToggleButton(
                        title: showsGrid ? "Grid On" : "Grid Off",
                        systemImage: showsGrid ? "grid" : "square",
                        isSelected: showsGrid
                    ) {
                        showsGrid.toggle()
                    }
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    actionPill("New Frame", systemImage: "plus.rectangle.on.rectangle") { store.addFrame() }
                    actionPill("Duplicate", systemImage: "plus.square.on.square") { store.duplicateActiveFrame() }
                    actionPill("Mirror", systemImage: "flip.horizontal") { store.mirrorActiveFrame() }
                    actionPill("Fill", systemImage: "paintbrush.pointed.fill") {
                        store.fillActiveFrame(with: selectedTool == .brush ? store.project.selectedHex : nil)
                    }
                    actionPill("Clear", systemImage: "trash", roleColor: BMOTheme.warning) { store.clearActiveFrame() }
                    actionPill("Delete Frame", systemImage: "minus.square", roleColor: BMOTheme.error) { store.removeActiveFrame() }
                }
            }
        }
    }

    private var paletteBar: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Palette")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                Text("Edit the palette string above to add or swap colors.")
                    .font(.caption2)
                    .foregroundColor(BMOTheme.textTertiary)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(store.paletteSwatches) { swatch in
                        Button {
                            selectedTool = .brush
                            store.selectColor(swatch.hex)
                        } label: {
                            VStack(spacing: 6) {
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .fill(swatch.color)
                                    .frame(width: 44, height: 44)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                                            .stroke(store.project.selectedHex == swatch.hex ? BMOTheme.accent : Color.white.opacity(0.12), lineWidth: 2)
                                    )
                                Text(swatch.hex)
                                    .font(.caption2.monospaced())
                                    .foregroundColor(BMOTheme.textSecondary)
                            }
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
    }

    private var canvasEditor: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("Canvas")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                Text(selectedTool == .brush ? "Painting with \(store.project.selectedHex)" : "Eraser active")
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }

            PixelStudioInteractiveGrid(
                pixels: store.activeFrame.pixels,
                canvasSize: store.project.canvasSize,
                showsGrid: showsGrid,
                background: BMOTheme.backgroundPrimary
            ) { row, column in
                switch selectedTool {
                case .brush:
                    store.paint(row: row, column: column, hex: store.project.selectedHex)
                case .eraser:
                    store.paint(row: row, column: column, hex: nil)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 360)
            .background(BMOTheme.backgroundPrimary)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium, style: .continuous))
        }
    }

    private var footer: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("What’s live right now")
                .font(.caption.weight(.semibold))
                .foregroundColor(BMOTheme.textTertiary)
            Text("Brush, eraser, palette swaps, frame switching, duplicate, mirror, fill, clear, and small animation blocking are native in Studio now.")
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
        }
    }

    private func metricRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
            Spacer()
            Text(value)
                .font(.caption.weight(.semibold))
                .foregroundColor(BMOTheme.textPrimary)
        }
    }

    private func smallToggleButton(title: String, systemImage: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.caption.weight(.semibold))
            .foregroundColor(isSelected ? BMOTheme.backgroundPrimary : BMOTheme.textPrimary)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(isSelected ? BMOTheme.accent : BMOTheme.backgroundSecondary)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    private func actionPill(_ title: String, systemImage: String, roleColor: Color = BMOTheme.accent, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: systemImage)
                Text(title)
            }
            .font(.caption.weight(.semibold))
            .foregroundColor(roleColor)
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(roleColor.opacity(0.12))
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

private struct PixelStudioInteractiveGrid: View {
    let pixels: [String]
    let canvasSize: Int
    let showsGrid: Bool
    let background: Color
    let onPaint: (Int, Int) -> Void

    @State private var lastPaintedIndex: Int?

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let cellSize = side / CGFloat(max(canvasSize, 1))

            PixelStudioPreviewGrid(
                pixels: pixels,
                canvasSize: canvasSize,
                showsGrid: showsGrid,
                background: background
            )
            .frame(width: side, height: side)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let point = CGPoint(
                            x: min(max(value.location.x, 0), side - 1),
                            y: min(max(value.location.y, 0), side - 1)
                        )
                        let column = min(max(Int(point.x / max(cellSize, 1)), 0), canvasSize - 1)
                        let row = min(max(Int(point.y / max(cellSize, 1)), 0), canvasSize - 1)
                        let index = row * canvasSize + column
                        guard lastPaintedIndex != index else { return }
                        lastPaintedIndex = index
                        onPaint(row, column)
                    }
                    .onEnded { _ in
                        lastPaintedIndex = nil
                    }
            )
        }
    }
}

private struct PixelStudioPreviewGrid: View {
    let pixels: [String]
    let canvasSize: Int
    let showsGrid: Bool
    let background: Color

    var body: some View {
        GeometryReader { geometry in
            let side = min(geometry.size.width, geometry.size.height)
            let cellSize = side / CGFloat(max(canvasSize, 1))

            VStack(spacing: 0) {
                ForEach(0..<canvasSize, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<canvasSize, id: \.self) { column in
                            let index = row * canvasSize + column
                            Rectangle()
                                .fill(fillColor(for: index))
                                .overlay(
                                    Rectangle()
                                        .stroke(showsGrid ? Color.white.opacity(0.08) : .clear, lineWidth: 0.5)
                                )
                                .frame(width: cellSize, height: cellSize)
                        }
                    }
                }
            }
            .frame(width: side, height: side, alignment: .topLeading)
            .background(background)
        }
        .aspectRatio(1, contentMode: .fit)
    }

    private func fillColor(for index: Int) -> Color {
        guard pixels.indices.contains(index), !pixels[index].isEmpty else {
            return checkerColor(for: index)
        }
        return Color(pixelStudioHex: pixels[index]) ?? checkerColor(for: index)
    }

    private func checkerColor(for index: Int) -> Color {
        let row = index / max(canvasSize, 1)
        let column = index % max(canvasSize, 1)
        let isDark = (row + column).isMultiple(of: 2)
        return isDark ? Color.white.opacity(0.04) : Color.white.opacity(0.08)
    }
}
