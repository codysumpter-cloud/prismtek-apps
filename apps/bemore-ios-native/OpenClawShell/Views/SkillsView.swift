import SwiftUI

struct SkillsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var lastReceipt: OpenClawReceipt?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
                    headerCard

                    if let lastReceipt {
                        ActionReceiptCard(receipt: lastReceipt)
                    }

                    clawHubCard

                    if !appState.workspaceRuntime.builtInCapabilities.isEmpty {
                        builtInCapabilitiesCard
                    }

                    ForEach(appState.workspaceRuntime.executableSkills) { skill in
                        skillCard(skill)
                    }
                }
                .padding(.horizontal, BMOTheme.spacingMD)
                .padding(.bottom, BMOTheme.spacingXL)
            }
            .background(BMOTheme.backgroundPrimary)
            .navigationTitle("")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Skills")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                }
            }
            .toolbarBackground(BMOTheme.backgroundPrimary, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .onAppear { appState.workspaceRuntime.refreshMetadata() }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("BeMore Skills")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                StatusBadge(label: "\(appState.workspaceRuntime.executableSkills.count) executable", color: BMOTheme.accent)
            }
            Text("Skills are executable reusable abilities Buddy can learn, equip, and run. Built-in app/network tools are shown separately so Skills stays honest.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .bmoCard()
    }

    private var builtInCapabilitiesCard: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Built-in Tools (Not Skills)")
                    .font(.headline)
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                StatusBadge(label: "\(appState.workspaceRuntime.builtInCapabilities.count)", color: BMOTheme.success)
            }

            Text("These are native app/network capabilities available in this session. They are intentionally separated from executable skills.")
                .font(.caption)
                .foregroundColor(BMOTheme.textSecondary)

            ForEach(appState.workspaceRuntime.builtInCapabilities) { capability in
                HStack(alignment: .top, spacing: 8) {
                    Image(systemName: capability.ui.systemImage)
                        .foregroundColor(BMOTheme.accent)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(capability.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(BMOTheme.textPrimary)
                        Text(capability.description)
                            .font(.caption)
                            .foregroundColor(BMOTheme.textSecondary)
                    }
                }
            }
        }
        .bmoCard()
    }

    private func skillCard(_ skill: SkillManifest) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                Image(systemName: skill.ui.systemImage)
                    .font(.title3)
                    .foregroundColor(BMOTheme.accent)
                    .frame(width: 28)

                VStack(alignment: .leading, spacing: 6) {
                    HStack {
                        Text(skill.name)
                            .font(.headline)
                            .foregroundColor(BMOTheme.textPrimary)
                        Spacer()
                        StatusBadge(label: skill.enabled ? "Enabled" : "Disabled", color: skill.enabled ? BMOTheme.success : BMOTheme.warning)
                    }
                    Text(skill.description)
                        .font(.subheadline)
                        .foregroundColor(BMOTheme.textSecondary)
                    Text("\(skill.category) • \(skill.tags.joined(separator: ", "))")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                }
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(skill.permissions, id: \.self) { permission in
                        Text(permission)
                            .font(.caption2)
                            .foregroundColor(BMOTheme.accent)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(BMOTheme.accent.opacity(0.12))
                            .clipShape(Capsule())
                    }
                }
            }

            if skill.id == BuiltInSkillRegistry.pokemonTeamBuilderID {
                NavigationLink {
                    PokemonTeamBuilderView()
                } label: {
                    HStack {
                        Image(systemName: "arrow.right.circle.fill")
                        Text("Launch Team Builder")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BMOButtonStyle())
            } else {
                Button {
                    let input = skill.id == BuiltInSkillRegistry.artifactRebuilderID ? ["target": "all"] : ["request": "Run \(skill.name) from Skills."]
                    lastReceipt = appState.runSkill(id: skill.id, input: input)
                } label: {
                    HStack {
                        Image(systemName: "play.fill")
                        Text("Run Skill")
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
        .bmoCard()
    }

    private var clawHubCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Buddy Skill Hub")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Install starter skills into the BeMore workspace registry with real README, manifest, artifact, and receipt output.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "Local", color: BMOTheme.success)
            }

            ForEach(ClawHubCatalog.templates) { template in
                let installed = appState.workspaceRuntime.skills.contains(where: { $0.id == template.id })
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: template.systemImage)
                        .foregroundColor(BMOTheme.accent)
                        .frame(width: 24)
                    VStack(alignment: .leading, spacing: 4) {
                        Text(template.name)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(BMOTheme.textPrimary)
                        Text(template.description)
                            .font(.caption)
                            .foregroundColor(BMOTheme.textSecondary)
                    }
                    Spacer()
                    Button(installed ? "Installed" : "Install") {
                        lastReceipt = appState.installClawHubSkill(template)
                    }
                    .disabled(installed)
                    .buttonStyle(.bordered)
                }
            }
        }
        .bmoCard()
    }
}

struct PokemonTeamBuilderView: View {
    @EnvironmentObject private var appState: AppState
    @State private var goal = "Build a balanced team that can pivot safely and explain every slot."
    @State private var format = "Singles"
    @State private var strategy = "balanced offense"
    @State private var mustInclude = "Dragonite"
    @State private var avoid = ""
    @State private var manualTeam = ["", "", "", "", "", ""]
    @State private var editRequest = ""
    @State private var receipt: OpenClawReceipt?

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: BMOTheme.spacingMD) {
                header
                formCard
                manualEditorCard
                supervisionCard
                if let receipt {
                    ActionReceiptCard(receipt: receipt)
                    if let members = receipt.output["members"] {
                        analysisCard(members: members)
                    }
                }
            }
            .padding(.horizontal, BMOTheme.spacingMD)
            .padding(.bottom, BMOTheme.spacingXL)
        }
        .background(BMOTheme.backgroundPrimary)
        .navigationTitle("Pokemon Team Builder")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Flagship Skill")
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
            Text("Buddy-operated team building.")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(BMOTheme.textPrimary)
            Text("Your active Buddy can generate, edit, analyze, and save Pokemon teams. The phone build runs the local skill surface now; deeper runtime ownership stays in BeMore-stack.")
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
        }
        .bmoCard()
    }

    private var formCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            labeledField("Goal", text: $goal, placeholder: "Make a safe Singles team around Dragonite")

            Picker("Format", selection: $format) {
                Text("Singles").tag("Singles")
                Text("Doubles").tag("Doubles")
                Text("Story Run").tag("Story Run")
                Text("Draft League").tag("Draft League")
            }
            .pickerStyle(.segmented)

            labeledField("Strategy / theme", text: $strategy, placeholder: "rain balance, cute chaos, bulky offense")
            labeledField("Must include", text: $mustInclude, placeholder: "Pikachu, Gengar")
            labeledField("Avoid", text: $avoid, placeholder: "Legendaries, Charizard")
            labeledField("Buddy edit request", text: $editRequest, placeholder: "make this less weak to Electric")

            Button {
                runTeamBuilder()
            } label: {
                HStack {
                    Image(systemName: "square.and.arrow.down.fill")
                    Text("Generate and Save Team")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(BMOButtonStyle())

            HStack {
                Button("Less weak to Electric") {
                    editRequest = "make this team less weak to Electric"
                    runTeamBuilder()
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))

                Button("Add bulky pivot") {
                    editRequest = "replace a slot with a bulky pivot"
                    runTeamBuilder()
                }
                .buttonStyle(BMOButtonStyle(isPrimary: false))
            }
        }
        .bmoCard()
    }

    private var manualEditorCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Manual Team Editing")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Seed the six slots yourself, then ask Buddy to analyze or revise the team. Blank slots are filled by the skill.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "Editable", color: BMOTheme.accent)
            }

            ForEach(manualTeam.indices, id: \.self) { index in
                labeledField("Slot \(index + 1)", text: $manualTeam[index], placeholder: index == 0 ? "Dragonite" : "Optional Pokemon")
            }

            Button("Analyze / Save Current Slots") {
                if editRequest.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    editRequest = "analyze this team and recommend improvements"
                }
                runTeamBuilder()
            }
            .buttonStyle(BMOButtonStyle(isPrimary: false))
        }
        .bmoCard()
    }

    private var supervisionCard: some View {
        let actions = appState.workspaceRuntime.recentActions
            .filter { $0.kind == .skillRun || $0.kind == .workspaceWrite }
            .prefix(4)

        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Workbench Supervision")
                        .font(.headline)
                        .foregroundColor(BMOTheme.textPrimary)
                    Text("Receipts and artifacts are the source of truth. If Buddy says it saved a team, it should appear here and in Artifacts.")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textSecondary)
                }
                Spacer()
                StatusBadge(label: "\(actions.count) recent", color: BMOTheme.success)
            }

            if actions.isEmpty {
                Text("No supervised skill actions yet.")
                    .font(.subheadline)
                    .foregroundColor(BMOTheme.textSecondary)
            } else {
                ForEach(Array(actions)) { action in
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(action.title)
                                .font(.caption.weight(.semibold))
                                .foregroundColor(BMOTheme.textPrimary)
                            Spacer()
                            StatusBadge(label: action.status.label, color: action.status.color)
                        }
                        Text(action.output["summary"] ?? action.error ?? action.source)
                            .font(.caption)
                            .foregroundColor(BMOTheme.textSecondary)
                    }
                    .padding(10)
                    .background(BMOTheme.backgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
                }
            }
        }
        .bmoCard()
    }

    private func analysisCard(members: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Saved roster")
                .font(.headline)
                .foregroundColor(BMOTheme.textPrimary)
            Text(members)
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)
            Text("Open Artifacts to inspect the saved JSON and Markdown team files.")
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
            if let coverage = receipt?.output["coverage"] {
                Divider().overlay(BMOTheme.divider)
                Text("Coverage")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BMOTheme.textPrimary)
                Text(coverage)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
            if let recommendation = receipt?.output["recommendation"] {
                Text(recommendation)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
            if let strategy = receipt?.output["strategy"] {
                Divider().overlay(BMOTheme.divider)
                Text("Battle strategy")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BMOTheme.textPrimary)
                Text(strategy)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
            if let rationale = receipt?.output["rationale"] {
                Divider().overlay(BMOTheme.divider)
                Text("Why these picks")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BMOTheme.textPrimary)
                Text(rationale)
                    .font(.caption)
                    .foregroundColor(BMOTheme.textSecondary)
            }
        }
        .bmoCard()
    }

    private func runTeamBuilder() {
        appState.workspaceRuntime.refreshMetadata()
        receipt = appState.runSkill(
            id: BuiltInSkillRegistry.pokemonTeamBuilderID,
            input: [
                "goal": goal,
                "format": format,
                "strategy": strategy,
                "mustInclude": mustInclude,
                "avoid": avoid,
                "existingTeam": manualTeam.joined(separator: ", "),
                "editRequest": editRequest
            ]
        )
        if let members = receipt?.output["members"] {
            let parsed = members.split(separator: ",").map { String($0).trimmingCharacters(in: .whitespacesAndNewlines) }
            manualTeam = (parsed + Array(repeating: "", count: max(0, 6 - parsed.count))).prefix(6).map { $0 }
        }
    }

    private func labeledField(_ title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.caption)
                .foregroundColor(BMOTheme.textTertiary)
            TextField(placeholder, text: text)
                .textFieldStyle(.plain)
                .foregroundColor(BMOTheme.textPrimary)
                .padding(12)
                .background(BMOTheme.backgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: BMOTheme.radiusSmall, style: .continuous))
        }
    }
}

struct ActionReceiptCard: View {
    let receipt: OpenClawReceipt

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(receipt.title)
                    .font(.headline)
                    .foregroundColor(BMOTheme.textPrimary)
                Spacer()
                StatusBadge(label: receipt.status.label, color: receipt.status.color)
            }

            Text(ReceiptFormatter.confirmedSummary(for: receipt))
                .font(.subheadline)
                .foregroundColor(BMOTheme.textSecondary)

            if !receipt.artifacts.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Artifacts")
                        .font(.caption)
                        .foregroundColor(BMOTheme.textTertiary)
                    ForEach(receipt.artifacts, id: \.self) { artifact in
                        Text(artifact)
                            .font(.caption)
                            .foregroundColor(BMOTheme.accent)
                    }
                }
            }
        }
        .bmoCard()
    }
}
