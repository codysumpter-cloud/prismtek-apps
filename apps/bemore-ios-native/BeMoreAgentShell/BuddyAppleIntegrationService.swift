import EventKit
import Foundation

enum BuddyAppleIntegrationError: LocalizedError {
    case reminderAccessDenied
    case remindersUnavailable

    var errorDescription: String? {
        switch self {
        case .reminderAccessDenied:
            return "Reminders access is not available yet. Allow Reminders access, then try again."
        case .remindersUnavailable:
            return "This device does not have a writable default Reminders list."
        }
    }
}

struct BuddyAppleIntegrationService {
    private let eventStore = EKEventStore()

    func createReminder(title: String, notes: String?, dueDate: Date?) async throws -> String {
        let granted = try await requestRemindersAccessIfNeeded()
        guard granted else {
            throw BuddyAppleIntegrationError.reminderAccessDenied
        }
        guard let calendar = eventStore.defaultCalendarForNewReminders() else {
            throw BuddyAppleIntegrationError.remindersUnavailable
        }

        let reminder = EKReminder(eventStore: eventStore)
        reminder.title = title
        reminder.notes = notes
        reminder.calendar = calendar

        if let dueDate {
            reminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: dueDate)
        }

        try eventStore.save(reminder, commit: true)
        return reminder.calendarItemIdentifier
    }

    func remindersAuthorizationStatus() -> EKAuthorizationStatus {
        EKEventStore.authorizationStatus(for: .reminder)
    }

    func requestRemindersAccessIfNeeded() async throws -> Bool {
        let status = remindersAuthorizationStatus()
        switch status {
        case .fullAccess, .authorized, .writeOnly:
            return true
        case .denied, .restricted:
            return false
        case .notDetermined:
            if #available(iOS 17.0, macOS 14.0, *) {
                return try await eventStore.requestFullAccessToReminders()
            }
            return try await withCheckedThrowingContinuation { continuation in
                eventStore.requestAccess(to: .reminder) { granted, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: granted)
                    }
                }
            }
        @unknown default:
            return false
        }
    }
}
