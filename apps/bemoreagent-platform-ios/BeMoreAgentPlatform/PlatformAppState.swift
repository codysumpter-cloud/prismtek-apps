import Foundation
import SwiftUI

@MainActor
final class PlatformAppState: ObservableObject {
    @Published var providerStore = ProviderStore()
    @Published var workspaces: [WorkspaceRecord] = []
    @Published var jobs: [GenerationJob] = []
    @Published var sessions: [SandboxSessionRecord] = []
    @Published var billing = BillingSnapshot.unavailable
    @Published var admin = AdminSnapshot.unavailable
    @Published var runtime = RuntimeSummary.unconfigured

    func bootstrap() {
        providerStore.load()
        workspaces = PlatformPersistence.load([WorkspaceRecord].self, from: PlatformPaths.workspacesFile) ?? []
        jobs = PlatformPersistence.load([GenerationJob].self, from: PlatformPaths.jobsFile) ?? []
        sessions = PlatformPersistence.load([SandboxSessionRecord].self, from: PlatformPaths.sessionsFile) ?? []

        billing = BillingSnapshot(
            currentUsageUSD: 0,
            softLimitUSD: 0,
            activeSandboxes: sessions.filter { $0.status == "running" }.count,
            maxSandboxes: 0,
            planName: "Not connected"
        )
        admin = AdminSnapshot(
            totalUsers: 0,
            activeSessions: sessions.filter { $0.status == "running" }.count,
            generationJobs: jobs.count,
            systemHealth: "Not connected"
        )
        refreshRuntimeSummary()
    }

    func refreshRuntimeSummary() {
        if let connected = providerStore.accounts.first(where: { $0.isEnabled }) {
            runtime = RuntimeSummary(mode: "Hybrid-ready", activeProvider: connected.provider.displayName, activeModel: connected.modelSlug, notes: "Provider connection saved locally. Real network execution still needs request validation on device.")
        } else {
            runtime = .unconfigured
        }
    }

    func addWorkspace(name: String, repoURL: String) {
        guard !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        workspaces.insert(WorkspaceRecord(name: name, repoURL: repoURL, syncStatus: repoURL.isEmpty ? "local" : "linked", lastSyncedAt: nil), at: 0)
        persistWorkspaces()
    }

    func syncWorkspace(_ workspace: WorkspaceRecord) {
        guard let index = workspaces.firstIndex(where: { $0.id == workspace.id }) else { return }
        workspaces[index].syncStatus = workspaces[index].repoURL.isEmpty ? "local" : "syncing"
        workspaces[index].lastSyncedAt = .now
        persistWorkspaces()
    }

    func deleteWorkspace(_ workspace: WorkspaceRecord) {
        workspaces.removeAll { $0.id == workspace.id }
        persistWorkspaces()
    }

    func enqueueGeneration(description: String, templateName: String, target: String, modelSlug: String) {
        guard !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let job = GenerationJob(description: description, templateName: templateName, target: target, modelSlug: modelSlug, status: .queued, progress: 0.0)
        jobs.insert(job, at: 0)
        persistJobs()
    }

    func launchSandbox(for workspaceName: String) {
        guard !workspaceName.isEmpty else { return }
        sessions.insert(SandboxSessionRecord(workspaceName: workspaceName, status: "unavailable", connectURL: "No sandbox backend is connected on this device.", expiresAt: .now), at: 0)
        persistSessions()
    }

    func terminateSandbox(_ session: SandboxSessionRecord) {
        sessions.removeAll { $0.id == session.id }
        persistSessions()
    }

    func useCloudModel(from provider: ProviderKind, modelSlug: String) {
        let account = providerStore.account(for: provider)
        guard account.isEnabled else {
            providerStore.lastError = "Connect \(provider.displayName) before using cloud models."
            return
        }
        runtime = RuntimeSummary(mode: "Cloud", activeProvider: provider.displayName, activeModel: modelSlug, notes: "Cloud model selected. Real request execution still needs provider-specific validation on-device.")
    }

    private func persistWorkspaces() {
        try? PlatformPersistence.save(workspaces, to: PlatformPaths.workspacesFile)
    }

    private func persistJobs() {
        try? PlatformPersistence.save(jobs, to: PlatformPaths.jobsFile)
    }

    private func persistSessions() {
        try? PlatformPersistence.save(sessions, to: PlatformPaths.sessionsFile)
    }
}
