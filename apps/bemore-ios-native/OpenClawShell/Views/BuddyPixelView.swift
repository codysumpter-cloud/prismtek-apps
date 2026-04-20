import SwiftUI

struct BuddyPixelView: View {
    var buddy: BuddyInstance?
    var template: CouncilStarterBuddyTemplate?
    let mood: BuddyAnimationMood
    var compact = false
    
    @State private var animationOffset: CGFloat = 0
    @State private var glowOpacity: Double = 0.5
    
    var body: some View {
        ZStack {
            // Background Glow
            Circle()
                .fill(paletteAccent.opacity(0.3))
                .frame(width: compact ? 60 : 100, height: compact ? 60 : 100)
                .blur(radius: 20)
                .opacity(glowOpacity)
            
            // Main Buddy Visual
            VStack(spacing: 0) {
                Image(systemName: symbolForMood)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: compact ? 30 : 50, height: compact ? 30 : 50)
                    .foregroundColor(paletteAccent)
                    .shadow(color: paletteAccent.opacity(0.5), radius: 5, x: 0, y: 2)
                    .offset(y: animationOffset)
                
                if !compact {
                    Text(moodLabel)
                        .font(.caption2.bold().monospaced())
                        .foregroundColor(paletteAccent.opacity(0.8))
                        .padding(.top, 4)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(compact ? 12 : 24)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
        .onAppear {
            startAnimations()
        }
    }
    
    private var symbolForMood: String {
        switch mood {
        case .idle: return "face.smiling"
        case .happy: return "sparkles"
        case .thinking: return "brain"
        case .working: return "hammer.fill"
        case .sleepy: return "moon.stars.fill"
        case .levelUp: return "crown.fill"
        case .needsAttention: return "exclamationmark.triangle.fill"
        }
    }
    
    private var moodLabel: String {
        switch mood {
        case .idle: return "IDLE"
        case .happy: return "HAPPY"
        case .thinking: return "THINKING"
        case .working: return "WORKING"
        case .sleepy: return "SLEEPY"
        case .levelUp: return "LEVEL UP"
        case .needsAttention: return "ATTENTION"
        }
    }
    
    private var paletteAccent: Color {
        BuddyPaletteDisplay.color(for: buddy?.identity.palette ?? templatePaletteID)
    }
    
    private var templatePaletteID: String {
        template.map { CouncilBuddyIdentityCatalog.identity(for: $0).palette } ?? "mint_cream"
    }
    
    private func startAnimations() {
        // Floating animation
        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
            animationOffset = -5
        }
        
        // Pulsing glow
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            glowOpacity = 0.8
        }
    }
}

// Reuse the Palette Display from BuddyAsciiView to keep it consistent
private enum BuddyPaletteDisplay {
    static func color(for paletteID: String) -> Color {
        switch paletteID {
        case "sky_navy": return Color(red: 0.49, green: 0.78, blue: 0.99)
        case "peach_brown": return Color(red: 1.0, green: 0.78, blue: 0.65)
        case "purple_gold": return Color(red: 0.78, green: 0.64, blue: 1.0)
        case "black_neon": return Color(red: 0.22, green: 1.0, blue: 0.53)
        case "rose_white": return Color(red: 0.95, green: 0.55, blue: 0.69)
        case "forest_moss": return Color(red: 0.55, green: 0.68, blue: 0.35)
        case "aqua_teal": return Color(red: 0.45, green: 0.95, blue: 0.91)
        case "red_charcoal": return Color(red: 0.82, green: 0.29, blue: 0.36)
        case "yellow_cocoa": return Color(red: 0.96, green: 0.83, blue: 0.37)
        default: return Color(red: 0.56, green: 0.85, blue: 0.78)
        }
    }
}
