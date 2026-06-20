import SwiftUI
import Combine

/// Pomodoro (25/5) + count-up focus timer. Drives buddy running/jumping states and XP.
struct FocusTimerView: View {
    @EnvironmentObject var appState: AppState

    enum Mode: String, CaseIterable, Identifiable {
        case pomodoro = "Pomodoro"
        case countUp = "Count Up"
        var id: String { rawValue }
    }

    enum Phase { case focus, breakTime }

    @State private var mode: Mode = .pomodoro
    @State private var phase: Phase = .focus
    @State private var isRunning = false
    @State private var elapsed: TimeInterval = 0
    @State private var timer: AnyCancellable?

    private let focusLength: TimeInterval = 25 * 60
    private let breakLength: TimeInterval = 5 * 60

    private var target: TimeInterval { phase == .focus ? focusLength : breakLength }

    private var displaySeconds: TimeInterval {
        switch mode {
        case .pomodoro: return max(0, target - elapsed)
        case .countUp: return elapsed
        }
    }

    var body: some View {
        VStack(spacing: 16) {
            Picker("Mode", selection: $mode) {
                ForEach(Mode.allCases) { Text($0.rawValue).tag($0) }
            }
            .pickerStyle(.segmented)
            .onChange(of: mode) { _, _ in reset() }

            if mode == .pomodoro {
                Text(phase == .focus ? "Focus" : "Break")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(phase == .focus ? Color.green : Color.blue)
            }

            Text(timeString(displaySeconds))
                .font(.system(size: 52, weight: .bold, design: .rounded))
                .monospacedDigit()

            HStack(spacing: 12) {
                Button(isRunning ? "Pause" : "Start") { toggle() }
                    .buttonStyle(.borderedProminent)
                Button("Reset") { reset() }
                    .buttonStyle(.bordered)
            }

            Text("Level \(appState.progression.level)  •  \(appState.progression.focusSessions) sessions")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .onDisappear { timer?.cancel() }
    }

    private func toggle() {
        isRunning.toggle()
        if isRunning {
            appState.timerStarted()
            timer = Timer.publish(every: 1, on: .main, in: .common)
                .autoconnect()
                .sink { _ in tick() }
        } else {
            appState.timerPaused()
            timer?.cancel()
        }
    }

    private func tick() {
        elapsed += 1
        if mode == .pomodoro && elapsed >= target {
            if phase == .focus {
                appState.focusSessionCompleted()
                phase = .breakTime
            } else {
                phase = .focus
            }
            elapsed = 0
        }
    }

    private func reset() {
        isRunning = false
        timer?.cancel()
        elapsed = 0
        phase = .focus
        appState.timerReset()
    }

    private func timeString(_ t: TimeInterval) -> String {
        let total = Int(t)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }
}
