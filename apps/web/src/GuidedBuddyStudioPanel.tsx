import { useMemo, useState } from 'react';
import {
  DEFAULT_GUIDED_BUDDY_STUDIO_DRAFT,
  GUIDED_BUDDY_REPAIR_ACTION_LABELS,
  GUIDED_BUDDY_STUDIO_STEPS,
  buildGuidedBuddyStudioPreviewContract,
  mapGuidedBuddyDraftToAppearanceDraft,
  type BuddyAppearanceStudioDraft,
  type GuidedBuddyStage,
  type GuidedBuddyRenderMode,
} from '@prismtek/core';

const FIELD_CLASS =
  'w-full rounded-2xl border border-white/10 bg-white/[0.04] px-4 py-3 text-sm text-white outline-none transition focus:border-emerald-300/40 focus:bg-white/[0.06]';

interface GuidedBuddyStudioPanelProps {
  currentDraft: BuddyAppearanceStudioDraft;
  onApplyDraft: (draft: BuddyAppearanceStudioDraft) => void;
}

export function GuidedBuddyStudioPanel({ currentDraft, onApplyDraft }: GuidedBuddyStudioPanelProps) {
  const [draft, setDraft] = useState(DEFAULT_GUIDED_BUDDY_STUDIO_DRAFT);
  const contract = useMemo(() => buildGuidedBuddyStudioPreviewContract(draft), [draft]);
  const scorePercent = Math.round(contract.qualityScore.overall * 100);
  const mappedDraft = useMemo(() => mapGuidedBuddyDraftToAppearanceDraft(draft, currentDraft), [currentDraft, draft]);

  return (
    <section className="rounded-3xl border border-emerald-300/20 bg-emerald-300/[0.04] p-6">
      <div className="grid gap-6 xl:grid-cols-[1fr_0.9fr]">
        <div>
          <p className="text-xs uppercase tracking-[0.2em] text-emerald-100/50">Guided Builder V1</p>
          <h2 className="mt-2 text-2xl font-bold">Validated T-Rex ASCII + pixel buddies</h2>
          <p className="mt-2 max-w-3xl text-sm text-white/55">
            Start from guided choices, generate a preview candidate, then save only after normalization,
            validation, scoring, and compilation. Blank canvas stays advanced-only.
          </p>

          <div className="mt-5 grid gap-4 md:grid-cols-2">
            <label className="space-y-2">
              <span className="text-xs font-medium uppercase tracking-[0.18em] text-white/40">Species</span>
              <select className={FIELD_CLASS} value={draft.species} disabled>
                <option value="trex">T-Rex</option>
              </select>
            </label>
            <label className="space-y-2">
              <span className="text-xs font-medium uppercase tracking-[0.18em] text-white/40">Stage</span>
              <select
                className={FIELD_CLASS}
                value={draft.stage}
                onChange={(event) => setDraft({ ...draft, stage: event.target.value as GuidedBuddyStage })}
              >
                <option value="egg">Egg</option>
                <option value="baby">Baby</option>
              </select>
            </label>
            <label className="space-y-2">
              <span className="text-xs font-medium uppercase tracking-[0.18em] text-white/40">Render mode</span>
              <select
                className={FIELD_CLASS}
                value={draft.renderMode}
                onChange={(event) => setDraft({ ...draft, renderMode: event.target.value as GuidedBuddyRenderMode })}
              >
                <option value="ascii">ASCII</option>
                <option value="pixel">Pixel</option>
                <option value="both">Both</option>
              </select>
            </label>
            <label className="space-y-2">
              <span className="text-xs font-medium uppercase tracking-[0.18em] text-white/40">Palette</span>
              <select
                className={FIELD_CLASS}
                value={draft.paletteId}
                onChange={(event) =>
                  setDraft({ ...draft, paletteId: event.target.value as typeof draft.paletteId })
                }
              >
                <option value="mono-dino-v1">Mono dino</option>
                <option value="soft-pastel-v1">Soft pastel</option>
                <option value="arcade-bright-v1">Arcade bright</option>
              </select>
            </label>
          </div>

          <label className="mt-4 block space-y-2">
            <span className="text-xs font-medium uppercase tracking-[0.18em] text-white/40">Personality tags</span>
            <input
              className={FIELD_CLASS}
              value={draft.personalityTags.join(', ')}
              onChange={(event) =>
                setDraft({
                  ...draft,
                  personalityTags: event.target.value
                    .split(',')
                    .map((tag) => tag.trim())
                    .filter(Boolean),
                })
              }
            />
          </label>

          <div className="mt-5 grid gap-3 rounded-2xl border border-white/10 bg-black/20 p-4 text-sm text-white/60 md:grid-cols-2">
            <div>
              <span className="text-white/40">ASCII style pack</span>
              <p className="font-mono text-emerald-100">{draft.stylePackIds.ascii || 'not selected'}</p>
            </div>
            <div>
              <span className="text-white/40">Pixel style pack</span>
              <p className="font-mono text-emerald-100">{draft.stylePackIds.pixel || 'not selected'}</p>
            </div>
          </div>

          <div className="mt-5 rounded-2xl border border-white/10 bg-black/20 p-4">
            <p className="text-xs uppercase tracking-[0.2em] text-white/40">Mapped generation draft</p>
            <p className="mt-2 text-sm text-white/65">
              {mappedDraft.archetype} • {mappedDraft.outputMode} • {mappedDraft.paletteName}
            </p>
            <p className="mt-1 text-xs text-white/45">{mappedDraft.silhouette}</p>
            <button
              className="mt-4 rounded-2xl bg-emerald-500 px-4 py-2 text-sm font-semibold text-black transition hover:bg-emerald-400"
              onClick={() => onApplyDraft(mappedDraft)}
              type="button"
            >
              Apply guided choices to generator
            </button>
          </div>
        </div>

        <div className="space-y-4">
          <div className="rounded-2xl border border-white/10 bg-black/20 p-4">
            <div className="flex items-center justify-between gap-4">
              <div>
                <p className="text-xs uppercase tracking-[0.2em] text-white/40">Quality score</p>
                <p className="mt-1 text-4xl font-bold text-emerald-100">{scorePercent}</p>
              </div>
              <div className="text-right text-xs text-white/45">
                <p>Preview: {contract.canPreview ? 'enabled' : 'blocked'}</p>
                <p>Save: {contract.canSave ? 'enabled' : 'blocked'}</p>
              </div>
            </div>
            <div className="mt-4 grid gap-2 text-xs text-white/55">
              {Object.entries(contract.qualityScore)
                .filter(([key]) => key !== 'overall')
                .map(([key, value]) => (
                  <div key={key} className="flex items-center justify-between gap-3">
                    <span>{key}</span>
                    <span>{Math.round(value * 100)}</span>
                  </div>
                ))}
            </div>
          </div>

          <div className="rounded-2xl border border-white/10 bg-black/20 p-4">
            <p className="text-xs uppercase tracking-[0.2em] text-white/40">Validation gate</p>
            {contract.validationIssues.length ? (
              <ul className="mt-3 space-y-2 text-sm text-amber-100/80">
                {contract.validationIssues.map((issue) => (
                  <li key={issue.code}>{issue.level}: {issue.message}</li>
                ))}
              </ul>
            ) : (
              <p className="mt-3 text-sm text-emerald-100/75">No validation issues in the guided draft.</p>
            )}
            <p className="mt-3 text-xs text-white/45">{contract.saveGateReason}</p>
          </div>

          <div className="rounded-2xl border border-white/10 bg-black/20 p-4">
            <p className="text-xs uppercase tracking-[0.2em] text-white/40">One-tap repairs</p>
            <div className="mt-3 flex flex-wrap gap-2">
              {contract.repairActions.map((action) => (
                <button key={action} className="rounded-full border border-white/10 px-3 py-1.5 text-xs text-white/65" type="button">
                  {GUIDED_BUDDY_REPAIR_ACTION_LABELS[action]}
                </button>
              ))}
            </div>
          </div>
        </div>
      </div>

      <ol className="mt-6 grid gap-2 text-xs text-white/45 md:grid-cols-2 xl:grid-cols-5">
        {GUIDED_BUDDY_STUDIO_STEPS.map((step, index) => (
          <li key={step} className="rounded-2xl border border-white/10 bg-black/20 p-3">
            <span className="text-emerald-100/60">{index + 1}.</span> {step}
          </li>
        ))}
      </ol>
    </section>
  );
}
