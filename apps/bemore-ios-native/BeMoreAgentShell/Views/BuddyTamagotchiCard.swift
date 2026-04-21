import SwiftUI

struct BuddyTamagotchiCard: View {
    let instance: BuddyInstance
    let passiveState: BuddyPassiveState
    let onFeed: () -> Void
    let onPlay: () -> Void
    let onTrain: () -> Void
    let onCheckIn: () -> Void
    
    private var metrics: BuddyTamagotchiMetrics {
        BuddyTamagotchiMetrics(from: passiveState)
    }
    
    private var suggestion: TamagotchiSuggestion {
        BuddyTamagotchiEngine.getSuggestedAction(for: passiveState)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with mood and streak
            HStack {
                Image(systemName: metrics.moodIcon)
                    .font(.title2)
                    .foregroundColor(colorFor(metrics.moodColor))
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(instance.displayName)
                        .font(.headline)
                    
                    HStack(spacing: 6) {
                        Text(passiveState.mood.capitalized)
                            .font(.subheadline)
                            .foregroundColor(colorFor(metrics.moodColor))
                        
                        if passiveState.streakDays > 0 {
                            Text("• \(passiveState.streakDays) day streak 🔥")
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                StatusBadge(label: metrics.statusBadge, color: colorFor(metrics.moodColor))
            }
            
            // Energy and Attention bars
            VStack(spacing: 12) {
                StatBarView(
                    label: "Energy",
                    value: passiveState.energy,
                    icon: "bolt.fill",
                    color: passiveState.energy < 30 ? .red : (passiveState.energy < 60 ? .orange : .green)
                )
                
                StatBarView(
                    label: "Attention",
                    value: passiveState.attention,
                    icon: "eye.fill",
                    color: passiveState.attention < 40 ? .blue : .cyan
                )
            }
            
            // Suggestion banner
            if case .urgent(let message) = suggestion {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(message)
                        .font(.caption.weight(.semibold))
                }
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 8))
            } else {
                HStack {
                    Image(systemName: "lightbulb.fill")
                    Text(suggestion.message)
                        .font(.caption)
                }
                .foregroundColor(BMOTheme.textSecondary)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(BMOTheme.backgroundCard)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(BMOTheme.divider, lineWidth: 1)
                )
            }
            
            // Action buttons
            HStack(spacing: 12) {
                ActionButton(
                    icon: "fork.knife",
                    label: "Feed",
                    color: .orange,
                    action: onFeed
                )
                
                ActionButton(
                    icon: "gamecontroller.fill",
                    label: "Play",
                    color: .purple,
                    action: onPlay
                )
                
                ActionButton(
                    icon: "dumbbell.fill",
                    label: "Train",
                    color: .blue,
                    action: onTrain
                )
                
                ActionButton(
                    icon: "checkmark.circle.fill",
                    label: "Check In",
                    color: .green,
                    action: onCheckIn
                )
            }
        }
        .padding(16)
        .background(BMOTheme.backgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusLarge))
        .overlay(
            RoundedRectangle(cornerRadius: BMOTheme.radiusLarge)
                .stroke(BMOTheme.divider, lineWidth: 1)
        )
    }
    
    private func colorFor(_ name: String) -> Color {
        switch name {
        case "accent": return BMOTheme.accent
        case "success": return BMOTheme.success
        case "warning": return BMOTheme.warning
        case "error": return BMOTheme.error
        case "neutral": return BMOTheme.textSecondary
        default: return BMOTheme.accent
        }
    }
}

struct StatBarView: View {
    let label: String
    let value: Int
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(label)
                    .font(.caption.weight(.medium))
                Spacer()
                Text("\(value)%")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(color)
            }
            
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / 100, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct ActionButton: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.title3)
                Text(label)
                    .font(.caption.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(color)
            .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusMedium))
        }
        .buttonStyle(.plain)
    }
}

struct BuddyDailyRhythmView: View {
    let rhythm: BuddyDailyRhythm
    let suggestion: TamagotchiSuggestion
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Today's Rhythm")
                .font(.headline)
            
            HStack(spacing: 16) {
                RhythmPill(
                    icon: "sunrise.fill",
                    label: "Morning",
                    active: rhythm.morningCheckIn,
                    color: .orange
                )
                
                RhythmPill(
                    icon: "sunset.fill",
                    label: "Evening",
                    active: rhythm.eveningWindDown,
                    color: .purple
                )
                
                RhythmPill(
                    icon: "dumbbell.fill",
                    label: "Training",
                    active: rhythm.trainingSessionsToday > 0,
                    color: .blue
                )
            }
            
            if rhythm.dailyGoalMet {
                HStack {
                    Image(systemName: "checkmark.seal.fill")
                    Text("Daily goal complete!")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(BMOTheme.backgroundCard)
        .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusLarge))
    }
}

struct RhythmPill: View {
    let icon: String
    let label: String
    let active: Bool
    let color: Color
    
    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
            Text(label)
        }
        .font(.caption.weight(.medium))
        .foregroundColor(active ? .white : BMOTheme.textTertiary)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(active ? color : BMOTheme.backgroundSecondary)
        .clipShape(Capsule())
    }
}

// MARK: - Store Integration

extension BuddyProfileStore {
    func getPassiveState(for instance: BuddyInstance) -> BuddyPassiveState {
        let state = BuddyPassiveState.load(for: instance.instanceId)
        return BuddyTamagotchiEngine.calculateCurrentPassiveState(
            for: instance,
            currentState: state,
            now: .now
        )
    }
    
    func performCareAction(_ action: CareActionType, on instance: BuddyInstance) -> BuddyCareResult {
        var passiveState = getPassiveState(for: instance)
        var instanceCopy = instance
        var rhythm = BuddyTamagotchiEngine.getDailyRhythm(for: instance, passiveState: passiveState)
        
        let result: BuddyCareResult
        switch action {
        case .feed:
            result = BuddyTamagotchiEngine.feed(instance: &instanceCopy, passiveState: &passiveState)
        case .play:
            result = BuddyTamagotchiEngine.play(instance: &instanceCopy, passiveState: &passiveState)
        case .train:
            // Get current focus for training
            let focus = instance.state.currentFocus ?? "general"
            result = BuddyTamagotchiEngine.train(instance: &instanceCopy, passiveState: &passiveState, skillFocus: focus)
        case .checkIn:
            result = BuddyTamagotchiEngine.checkIn(instance: &instanceCopy, passiveState: &passiveState, rhythm: &rhythm)
        }
        
        // Save updated state
        passiveState.save(for: instance.instanceId)
        
        // Notify observers
        objectWillChange.send()
        
        return result
    }
}

enum CareActionType {
    case feed, play, train, checkIn
}
