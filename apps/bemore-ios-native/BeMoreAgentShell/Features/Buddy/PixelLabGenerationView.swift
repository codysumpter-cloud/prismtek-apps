import SwiftUI

struct PixelLabGenerationView: View {
    let linkedAccountStore: LinkedAccountStore
    
    @State private var prompt: String = ""
    @State private var generatedImage: UIImage?
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var showSaveDialog = false
    @State private var savedVariantID: String?
    
    // Generation settings
    @State private var width: Int = 64
    @State private var height: Int = 64
    @State private var selectedStyle: PixelLabStyle = .classic
    
    enum PixelLabStyle: String, CaseIterable {
        case classic = "classic"
        case modern = "modern"
        case retro = "retro"
        
        var displayName: String {
            switch self {
            case .classic: return "Classic 8-bit"
            case .modern: return "Modern Pixel"
            case .retro: return "Retro Game"
            }
        }
    }
    
    var hasToken: Bool {
        linkedAccountStore.record(for: .pixelLab).isLinked
    }
    
    var token: String? {
        linkedAccountStore.record(for: .pixelLab).accessToken
    }
    
    var body: some View {
        NavigationView {
            Form {
                if !hasToken {
                    Section {
                        HStack {
                            Image(systemName: "exclamationmark.triangle")
                                .foregroundColor(BMOTheme.warning)
                            Text("Link your PixelLab account first")
                                .foregroundColor(BMOTheme.warning)
                        }
                        
                        NavigationLink("Go to Settings") {
                            LinkedAccountSettingsView(
                                linkedAccountStore: linkedAccountStore
                            )
                        }
                    }
                }
                
                Section("Describe Your Buddy") {
                    TextEditor(text: $prompt)
                        .frame(minHeight: 80)
                        .overlay(
                            Group {
                                if prompt.isEmpty {
                                    Text("e.g., cute blue robot with headphones, pixel art style")
                                        .foregroundColor(.gray)
                                        .padding(8)
                                }
                            }, alignment: .topLeading
                        )
                    
                    HStack {
                        Text("Style")
                        Spacer()
                        Picker("Style", selection: $selectedStyle) {
                            ForEach(PixelLabStyle.allCases, id: \.self) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                        .pickerStyle(.menu)
                    }
                    
                    HStack {
                        Text("Size")
                        Spacer()
                        Picker("Size", selection: $width) {
                            Text("32x32").tag(32)
                            Text("64x64").tag(64)
                            Text("128x128").tag(128)
                        }
                        .pickerStyle(.segmented)
                        .onChange(of: width) { newWidth in
                            height = newWidth
                        }
                    }
                }
                
                Section {
                    Button(action: generateImage) {
                        HStack {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle())
                            }
                            Text(isGenerating ? "Generating..." : "Generate Pixel Art")
                        }
                    }
                    .disabled(!hasToken || prompt.isEmpty || isGenerating)
                    .frame(maxWidth: .infinity)
                }
                
                if let error = errorMessage {
                    Section {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                
                if let image = generatedImage {
                    Section("Preview") {
                        HStack {
                            Spacer()
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: 200, maxHeight: 200)
                                .cornerRadius(8)
                            Spacer()
                        }
                        
                        Button("Use as Buddy Appearance") {
                            showSaveDialog = true
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            }
            .navigationTitle("Pixel Art Generator")
            .navigationBarTitleDisplayMode(.inline)
            .alert("Save Pixel Art", isPresented: $showSaveDialog) {
                TextField("Variant ID", text: Binding(
                    get: { savedVariantID ?? "" },
                    set: { savedVariantID = $0 }
                ))
                Button("Cancel", role: .cancel) {}
                Button("Save") {
                    saveGeneratedImage()
                }
            } message: {
                Text("Enter a unique ID for this pixel art.")
            }
        }
    }
    
    private func generateImage() {
        guard let token = token else { return }
        
        isGenerating = true
        errorMessage = nil
        generatedImage = nil
        
        Task {
            do {
                let imageData = try await PixelLabService.shared.generatePixelArt(
                    prompt: prompt,
                    width: width,
                    height: height,
                    style: selectedStyle.rawValue,
                    accessToken: token
                )
                
                if let uiImage = UIImage(data: imageData) {
                    await MainActor.run {
                        generatedImage = uiImage
                        isGenerating = false
                    }
                } else {
                    await MainActor.run {
                        errorMessage = "Could not load generated image"
                        isGenerating = false
                    }
                }
            } catch PixelLabError.noToken {
                await MainActor.run {
                    errorMessage = "No PixelLab token found"
                    isGenerating = false
                }
            } catch let PixelLabError.requestFailed(code, message) {
                await MainActor.run {
                    errorMessage = "API Error \(code): \(message ?? "Unknown error")"
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to generate: \(error.localizedDescription)"
                    isGenerating = false
                }
            }
        }
    }
    
    private func saveGeneratedImage() {
        guard let image = generatedImage,
              let variantID = savedVariantID?.trimmingCharacters(in: .whitespacesAndNewlines),
              !variantID.isEmpty else { return }
        
        // Save to app's pixel art directory
        let pixelDir = Paths.stateDirectory.appendingPathComponent("pixel-assets")
        try? FileManager.default.createDirectory(at: pixelDir, withIntermediateDirectories: true)
        
        let fileURL = pixelDir.appendingPathComponent("\(variantID).png")
        
        if let pngData = image.pngData() {
            try? pngData.write(to: fileURL)
        }
        
        // The variant ID can now be used in BuddyAppearanceEditorDraft.pixelVariantID
        showSaveDialog = false
    }
}
