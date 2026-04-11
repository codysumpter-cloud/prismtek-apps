# BeMore CLI

Product-owned command line for the BeMore Mac runtime.

```bash
npm --workspace @prismtek/bemore-cli run dev -- runtime status
npm --workspace @prismtek/bemore-cli run dev -- workspace open /Users/prismtek/code/prismtek-apps
npm --workspace @prismtek/bemore-cli run dev -- files list --json
npm --workspace @prismtek/bemore-cli run dev -- run "git status --short" --wait
```

Set `BEMORE_RUNTIME_URL` to target another BeMore runtime endpoint.
