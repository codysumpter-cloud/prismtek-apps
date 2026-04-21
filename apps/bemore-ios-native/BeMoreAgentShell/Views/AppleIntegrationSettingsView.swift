import EventKit
import MessageUI
import SwiftUI

struct AppleIntegrationSettingsSectionView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.openURL) private var openURL
    @State private var remindersStatus: EKAuthorizationStatus = EKEventStore.authorizationStatus(for: .reminder)

    var body: some View {
        Section("Apple Integration") {
            integrationRow(
                title: "Reminders",
                detail: remindersDetail,
                status: remindersLabel,
                color: remindersColor
            ) {
                Task {
                    _ = try? await BuddyAppleIntegrationService().requestRemindersAccessIfNeeded()
                    remindersStatus = EKEventStore.authorizationStatus(for: .reminder)
                }
            }

            integrationRow(
                title: "Messages",
                detail: "BeMore can open the native Messages composer with a drafted message when this device supports SMS/iMessage compose.",
                status: BuddyMessageComposer.canSendText ? "Available" : "Unavailable",
                color: BuddyMessageComposer.canSendText ? BMOTheme.success : BMOTheme.warning,
                buttonTitle: nil,
                action: nil
            )

            integrationRow(
                title: "Notes",
                detail: "iPhone does not expose a public Notes write API. BeMore now uses the native share sheet / export path for note drafts instead of pretending there is a hidden permission.",
                status: "Share sheet",
                color: BMOTheme.accent,
                buttonTitle: nil,
                action: nil
            )

            integrationRow(
                title: "Siri / Shortcuts",
                detail: "BeMore ships an App Shortcut for teaching Buddy planning and optionally creating a reminder. There is no separate in-app permission toggle for this.",
                status: "Installed",
                color: BMOTheme.success,
                buttonTitle: "Open Shortcuts"
            ) {
                if let url = URL(string: "shortcuts://") {
                    openURL(url)
                }
            }

            Button("Open iPhone App Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    openURL(url)
                }
            }
            .foregroundColor(BMOTheme.accent)
            .listRowBackground(BMOTheme.backgroundCard)

            Text("Only Reminders has a real iOS permission prompt here. Messages compose depends on device capability, Notes uses share/export because Apple does not provide a direct Notes API, and Siri Shortcuts appear through the app’s App Intents support.")
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)
                .listRowBackground(BMOTheme.backgroundCard)
        }
        .onAppear {
            remindersStatus = EKEventStore.authorizationStatus(for: .reminder)
        }
    }

    private var remindersLabel: String {
        switch remindersStatus {
        case .fullAccess, .authorized: return "Allowed"
        case .writeOnly: return "Write only"
        case .denied, .restricted: return "Blocked"
        case .notDetermined: return "Not asked"
        @unknown default: return "Unknown"
        }
    }

    private var remindersColor: Color {
        switch remindersStatus {
        case .fullAccess, .authorized, .writeOnly: return BMOTheme.success
        case .notDetermined: return BMOTheme.warning
        case .denied, .restricted: return BMOTheme.error
        @unknown default: return BMOTheme.warning
        }
    }

    private var remindersDetail: String {
        switch remindersStatus {
        case .fullAccess, .authorized, .writeOnly:
            return "BeMore can create real Reminders directly from Buddy plans and follow-up flows."
        case .denied, .restricted:
            return "Reminders access is blocked. Open iPhone Settings if you want BeMore to create reminders directly."
        case .notDetermined:
            return "BeMore can request Reminders access the first time you enable it here or try creating a reminder from Buddy."
        @unknown default:
            return "Reminder capability state is unknown."
        }
    }

    private func integrationRow(
        title: String,
        detail: String,
        status: String,
        color: Color,
        buttonTitle: String? = "Enable",
        action: (() -> Void)?
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text(detail)
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                Text(status)
                    .font(.caption)
                    .foregroundColor(color)
            }
            if let buttonTitle, let action {
                Button(buttonTitle, action: action)
                    .buttonStyle(.bordered)
            }
        }
        .listRowBackground(BMOTheme.backgroundCard)
    }
}
