import Foundation
import SwiftUI

@MainActor
final class PlatformAppState: ObservableObject {
    @Published var providerStore = ProviderStore()
    @Published var workspaces: [WorkspaceRecord] = []
    @Published var jobs: [GenerationJob] = []
    @Published var sessions: [SandboxSessionRecord] = []
    private let apiService = PlatformApiService()
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
        
        Task {
            do {
                let response = try await apiService.enqueueGeneration(description: description, templateId: templateName, target: target, modelId: modelSlug)
                if let jobId = response["id"] as? String {
                    // Start polling for status
                    while true {
                        try await Task.sleep(nanoseconds: 2 * 1_000_000_000)
                        let statusUpdate = try await apiService.getJobStatus(jobId: jobId)
                        
                        if let statusStr = statusUpdate["status"] as? String,
                           let progress = statusUpdate["progress"] as? Double,
                           let index = jobs.firstIndex(where: { $0.description == description && $0.templateName == templateName }) {
                            
                            let status: GenerationJob.Status = statusStr == "completed" ? .completed : (statusStr == "failed" ? .failed : .processing)
                            jobs[index].status = status
                            jobs[index].progress = progress
                            persistJobs()
                            
                            if status == .completed || status == .failed { break }
                        } else {
                            break
                        }
                    }
                }
            } catch {
                print("Generation API failed: \(error)")
                if let index = jobs.firstIndex(where: { $0.description == description && $0.templateName == templateName }) {
                    jobs[index].status = .failed
                    persistJobs()
                }
            }
        }
    }

    func launchSandbox(for workspaceName: String) {
        guard !workspaceName.isEmpty else { return }
        
        let session = SandboxSessionRecord(workspaceName: workspaceName, status: \"launching\", connectURL: \"Connecting to backend...\", expiresAt: .now)
        sessions.insert(session, at: 0)
        persistSessions()
        
        Task {
            do {
                let response = try await apiService.launchSandbox(workspaceId: workspaceName)
                if let url = response[\"url\"] as? String,
                   let expiresAtStr = response[\"expiresAt\"] as? String,
                   let expiresAt = ISO8601DateFormatter().date(from: expiresAtStr),
                   let index = sessions.firstIndex(where: { $0.workspaceName == workspaceName }) {
                    
                    sessions[index].status = \"running\"
                    sessions[index].connectURL = url
                    sessions[index].expiresAt = expiresAt
                    persistSessions()
                }
            } catch {
                print(\"Sandbox API failed: \\(error)\")
                if let index = sessions.firstIndex(where: { $0.workspaceName == workspaceName }) {
                    sessions[index].status = \"failed\"
                    sessions[index].connectURL = \"Failed to launch sandbox: \\(error.localizedDescription)\"
                    persistSessions()
                }
            }
        }
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
