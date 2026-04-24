import { useEffect, useMemo, useState, type ReactNode } from 'react';
import type { BuddyAppearanceProfile, BuddyAppearanceStudioDraft, BuddyPixelFrame } from '@prismtek/core';
import { GuidedBuddyStudioPanel } from './GuidedBuddyStudioPanel';

const API_ROOT = 'http://localhost:3001';
const FIELD_CLASS =
  'w-full rounded-2xl border border-white/10 bg-white/[0.04] px-4 py-3 text-sm text-white outline-none transition focus:border-emerald-300/40 focus:bg-white/[0.06]';

interface BuddyStudioViewProps {
  token: string;
}

interface ProviderConfig {
  enabled: boolean;
  mode: string;
  note?: string;
}

const DEFAULT_DRAFT: BuddyAppearanceStudioDraft = {
  buddyId: 'default-buddy',
  displayName: 'Buddy',
  archetype: 'companion',
  vibe: 'calm',
  paletteName: 'forest',
  silhouette: 'round',
  face: 'friendly',
  eyes: 'bright',
  expression: 'warm',
  accessories: [],
  animationPersonality: 'calm',
  outputMode: 'ascii',
};

async function authedFetch<T>(token: string, input: string, init?: RequestInit): Promise<T> {
  const response = await fetch(input, {
    ...init,
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${token}`,
      ...(init?.headers || {}),
    },
  });
  if (!response.ok) {
    throw new Error(await response.text());
  }
  return response.json();
}

function PixelPreview({ frame }: { frame?: BuddyPixelFrame }) {
  if (!frame) {
    return <div className="text-xs text-white/40">No pixel frame loaded.</div>;
  }

  return (
    <div
      className="grid gap-[1px] rounded-xl border border-white/10 bg-[#080808] p-2"
      style={{ gridTemplateColumns: `repeat(${frame.width}, minmax(0, 10px))` }}
    >
      {Array.from({ length: frame.width * frame.height }).map((_, index) => {
        const x = index % frame.width;
        const y = Math.floor(index / frame.width);
        const cell = frame.cells.find((item) => item.x === x && item.y === y);
        return (
          <div
            key={`${x}-${y}`}
            className="h-[10px] w-[10px] rounded-[2px]"
            style={{ backgroundColor: cell?.color || 'transparent' }}
          />
        );
      })}
    </div>
  );
}

export function BuddyStudioView({ token }: BuddyStudioViewProps) {
  const [draft, setDraft] = useState<BuddyAppearanceStudioDraft>(DEFAULT_DRAFT);
  const [profiles, setProfiles] = useState<BuddyAppearanceProfile[]>([]);
  const [providerConfig, setProviderConfig] = useState<ProviderConfig | null>(null);
  const [isGenerating, setIsGenerating] = useState(false);
  const [status, setStatus] = useState('Guided Buddy generation is ready.');
  const [error, setError] = useState<string | null>(null);

  const activeProfile = useMemo(
    () => profiles.find((profile) => profile.isDefault) || profiles[0] || null,
    [profiles],
  );

  const loadProfiles = async () => {
    const response = await authedFetch<{ profiles: BuddyAppearanceProfile[] }>(
      token,
      `${API_ROOT}/api/buddies/${draft.buddyId}/appearance-profiles`,
    );
    setProfiles(response.profiles || []);
  };

  useEffect(() => {
    authedFetch<{ providerConfig: ProviderConfig }>(token, `${API_ROOT}/api/buddy/appearance/flows`)
      .then((payload) => setProviderConfig(payload.providerConfig))
      .catch((requestError) => setError(String(requestError)));
  }, [token]);

  useEffect(() => {
    loadProfiles().catch((requestError) => setError(String(requestError)));
  }, [token, draft.buddyId]);

  const generateProfile = async () => {
    setIsGenerating(true);
    setError(null);
    try {
      const response = await authedFetch<{ profile: BuddyAppearanceProfile; warnings: string[]; generationNotes: string[] }>(
        token,
        `${API_ROOT}/api/buddies/${draft.buddyId}/appearance-profiles/generate`,
        {
          method: 'POST',
          body: JSON.stringify({ draft, makeDefault: true }),
        },
      );
      setProfiles((current) => [response.profile, ...current.filter((profile) => profile.id !== response.profile.id)]);
      setStatus(
        response.warnings.length
          ? response.warnings.join(' ')
          : response.generationNotes.join(' '),
      );
    } catch (requestError) {
      setError(String(requestError));
    } finally {
      setIsGenerating(false);
    }
  };

  const makeDefault = async (profileId: string) => {
    await authedFetch(token, `${API_ROOT}/api/buddies/${draft.buddyId}/appearance-profiles/${profileId}/default`, {
      method: 'POST',
    });
    await loadProfiles();
  };

  const duplicateProfile = async (profileId: string) => {
    await authedFetch(token, `${API_ROOT}/api/buddies/${draft.buddyId}/appearance-profiles/${profileId}/duplicate`, {
      method: 'POST',
    });
    await loadProfiles();
  };

  const idleAsciiFrame = activeProfile?.visualStateSet.ascii?.states.idle[0]?.content || '';
  const idlePixelFrame = activeProfile?.visualStateSet.pixel?.states.idle?.[0];

  return (
    <div className="space-y-8">
      <GuidedBuddyStudioPanel />

      <div className="grid gap-6 lg:grid-cols-[1.2fr_0.8fr]">
        <section className="rounded-3xl border border-white/10 bg-[#0f0f0f] p-6">
          <div className="mb-6 flex items-start justify-between gap-4">
            <div>
              <p className="text-xs uppercase tracking-[0.2em] text-white/40">Buddy Appearance Studio</p>
              <h2 className="mt-2 text-3xl font-bold">Create a reusable Buddy look</h2>
              <p className="mt-2 max-w-2xl text-sm text-white/50">
                Guided generation stays product-facing. Canonical posture and council behavior remain in `bmo-stack`.
              </p>
            </div>
            <div className="rounded-2xl border border-white/10 bg-white/5 px-4 py-3 text-sm text-white/60">
              PixelLab: {providerConfig?.enabled ? providerConfig.mode : 'optional / not configured'}
            </div>
          </div>

          <div className="grid gap-4 md:grid-cols-2">
            <Field label="Buddy ID">
              <input className={FIELD_CLASS} value={draft.buddyId} onChange={(event) => setDraft({ ...draft, buddyId: event.target.value })} />
            </Field>
            <Field label="Display name">
              <input className={FIELD_CLASS} value={draft.displayName} onChange={(event) => setDraft({ ...draft, displayName: event.target.value })} />
            </Field>
            <Field label="Archetype">
              <input className={FIELD_CLASS} value={draft.archetype} onChange={(event) => setDraft({ ...draft, archetype: event.target.value })} />
            </Field>
            <Field label="Vibe">
              <input className={FIELD_CLASS} value={draft.vibe} onChange={(event) => setDraft({ ...draft, vibe: event.target.value })} />
            </Field>
            <Field label="Palette">
              <select className={FIELD_CLASS} value={draft.paletteName} onChange={(event) => setDraft({ ...draft, paletteName: event.target.value })}>
                <option value="forest">Forest</option>
                <option value="candy">Candy</option>
                <option value="ocean">Ocean</option>
                <option value="ember">Ember</option>
                <option value="mono">Mono</option>
              </select>
            </Field>
            <Field label="Silhouette">
              <input className={FIELD_CLASS} value={draft.silhouette} onChange={(event) => setDraft({ ...draft, silhouette: event.target.value })} />
            </Field>
            <Field label="Face">
              <input className={FIELD_CLASS} value={draft.face} onChange={(event) => setDraft({ ...draft, face: event.target.value })} />
            </Field>
            <Field label="Eyes">
              <input className={FIELD_CLASS} value={draft.eyes} onChange={(event) => setDraft({ ...draft, eyes: event.target.value })} />
            </Field>
            <Field label="Expression">
              <input className={FIELD_CLASS} value={draft.expression} onChange={(event) => setDraft({ ...draft, expression: event.target.value })} />
            </Field>
            <Field label="Animation personality">
              <input
                className={FIELD_CLASS}
                value={draft.animationPersonality}
                onChange={(event) => setDraft({ ...draft, animationPersonality: event.target.value })}
              />
            </Field>
            <Field label="Accessories">
              <input
                className={FIELD_CLASS}
                value={draft.accessories.join(', ')}
                onChange={(event) =>
                  setDraft({
                    ...draft,
                    accessories: event.target.value
                      .split(',')
                      .map((value) => value.trim())
                      .filter(Boolean),
                  })
                }
              />
            </Field>
            <Field label="Output mode">
              <select
                className={FIELD_CLASS}
                value={draft.outputMode}
                onChange={(event) => setDraft({ ...draft, outputMode: event.target.value as BuddyAppearanceStudioDraft['outputMode'] })}
              >
                <option value="ascii">ASCII</option>
                <option value="pixel">Pixel</option>
                <option value="both">Both</option>
              </select>
            </Field>
          </div>

          <div className="mt-6 flex items-center gap-3">
            <button
              onClick={generateProfile}
              disabled={isGenerating}
              className="rounded-2xl bg-emerald-500 px-5 py-3 text-sm font-semibold text-black transition hover:bg-emerald-400 disabled:opacity-50"
            >
              {isGenerating ? 'Generating...' : 'Generate and Save'}
            </button>
            <p className="text-sm text-white/50">{status}</p>
          </div>
          {error ? <p className="mt-3 text-sm text-rose-300">{error}</p> : null}
        </section>

        <section className="rounded-3xl border border-white/10 bg-[#0f0f0f] p-6">
          <p className="text-xs uppercase tracking-[0.2em] text-white/40">Live Preview</p>
          <h3 className="mt-2 text-xl font-semibold">{activeProfile?.displayName || 'No profile yet'}</h3>
          <p className="mt-1 text-sm text-white/50">
            Default state preview inside the Buddy shell contract. Saved looks are reusable and switchable.
          </p>

          <div className="mt-6 space-y-5">
            <div className="rounded-2xl border border-emerald-400/20 bg-emerald-400/5 p-4">
              <p className="mb-2 text-xs uppercase tracking-[0.2em] text-emerald-200/60">ASCII</p>
              <pre className="overflow-auto rounded-xl bg-black/40 p-4 font-mono text-sm text-emerald-200">{idleAsciiFrame || 'Generate a profile to preview ASCII frames.'}</pre>
            </div>
            <div className="rounded-2xl border border-sky-400/20 bg-sky-400/5 p-4">
              <p className="mb-2 text-xs uppercase tracking-[0.2em] text-sky-100/60">Pixel</p>
              <PixelPreview frame={idlePixelFrame} />
            </div>
          </div>
        </section>
      </div>

      <section className="rounded-3xl border border-white/10 bg-[#0f0f0f] p-6">
        <div className="mb-4 flex items-center justify-between">
          <div>
            <p className="text-xs uppercase tracking-[0.2em] text-white/40">Saved Looks</p>
            <h3 className="mt-2 text-xl font-semibold">Switch, duplicate, and refine</h3>
          </div>
          <div className="text-sm text-white/50">{profiles.length} saved profile(s)</div>
        </div>

        <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-3">
          {profiles.map((profile) => (
            <article key={profile.id} className="rounded-2xl border border-white/10 bg-white/[0.03] p-4">
              <div className="flex items-center justify-between gap-3">
                <div>
                  <h4 className="font-semibold">{profile.displayName}</h4>
                  <p className="text-xs text-white/40">{profile.archetype} • {profile.vibe} • {profile.outputMode}</p>
                </div>
                {profile.isDefault ? (
                  <span className="rounded-full bg-emerald-400/15 px-3 py-1 text-xs text-emerald-200">Default</span>
                ) : null}
              </div>

              <pre className="mt-4 overflow-auto rounded-xl bg-black/40 p-3 font-mono text-xs text-emerald-200">
                {profile.visualStateSet.ascii?.states.idle[0]?.content || 'No ASCII frames'}
              </pre>

              <div className="mt-4 flex gap-2">
                <button className="rounded-xl border border-white/10 px-3 py-2 text-xs text-white/70" onClick={() => makeDefault(profile.id)}>
                  Make default
                </button>
                <button className="rounded-xl border border-white/10 px-3 py-2 text-xs text-white/70" onClick={() => duplicateProfile(profile.id)}>
                  Duplicate
                </button>
              </div>
            </article>
          ))}
          {!profiles.length ? <div className="rounded-2xl border border-dashed border-white/10 p-6 text-sm text-white/40">No saved Buddy looks yet.</div> : null}
        </div>
      </section>
    </div>
  );
}

function Field({ label, children }: { label: string; children: ReactNode }) {
  return (
    <label className="space-y-2">
      <span className="text-xs font-medium uppercase tracking-[0.18em] text-white/40">{label}</span>
      {children}
    </label>
  );
}
