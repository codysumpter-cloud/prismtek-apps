# BeMore CLI

Product-owned command line for the BeMore Mac runtime.

```bash
npm --workspace @prismtek/bemore-cli run dev -- runtime status
npm --workspace @prismtek/bemore-cli run dev -- workspace open /Users/prismtek/code/prismtek-apps
npm --workspace @prismtek/bemore-cli run dev -- files list --json
npm --workspace @prismtek/bemore-cli run dev -- run "git status --short" --wait
npm --workspace @prismtek/bemore-cli run dev -- tasks delegate TASK_ID "Inspect failure" --command git status --short
npm --workspace @prismtek/bemore-cli run dev -- patches preview "README edit" --file README.md --before "old" --after "new"
npm --workspace @prismtek/bemore-cli run dev -- patches apply PATCH_ID
npm --workspace @prismtek/bemore-cli run dev -- tasks retry TASK_ID
```

Set `BEMORE_RUNTIME_URL` to target another BeMore runtime endpoint.

The runtime reports a workspace-bound sandbox session via `bemore runtime sandbox`. That session
blocks known-destructive command patterns, enforces workspace path boundaries, applies command
timeouts, and caps captured output. It is process-level containment on the Mac, not VM isolation.
