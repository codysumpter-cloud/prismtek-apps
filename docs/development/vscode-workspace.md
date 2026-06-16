# VS Code workspace

Prismtek-apps is meant to open as one usable VS Code workspace from local VS Code, VS Code for the Web, GitHub web editor, and mobile handoff flows.

## Fast open links

- VS Code for the Web: `https://vscode.dev/github/codysumpter-cloud/prismtek-apps`
- GitHub web editor: `https://github.dev/codysumpter-cloud/prismtek-apps`
- Local clone: `https://github.com/codysumpter-cloud/prismtek-apps.git`

On iPhone/iPad, open one of the web-editor links from ChatGPT, GitHub, Safari, or a pinned note. Sign in to GitHub when prompted, then use Source Control to commit to a branch.

## Local VS Code

```bash
git clone https://github.com/codysumpter-cloud/prismtek-apps.git
cd prismtek-apps
code prismtek-apps.code-workspace
```

Install dependencies and run the workspace doctor:

```bash
npm install
npm run workspace:doctor
```

## VS Code tasks

The committed `.vscode/tasks.json` exposes common actions through **Terminal > Run Task**:

- `Prismtek: install dependencies`
- `Prismtek: workspace doctor`
- `Prismtek: lint`
- `Prismtek: build`
- `Prismtek: validate games`
- `Prismtek: validate platforms`
- `Prismtek: validate references`
- `Prismtek: validate integrations`
- `Game: Pixel Fruit Arena test`
- `Game: Pixel Fruit Arena package ZIP`
- `Game: TamerNet package ZIP`
- `Game: Spin Street Showdown test`
- `Game: Spin Street Showdown package ZIP`

## Mobile/cloud expectations

VS Code for the Web and GitHub web editor are great for code review, docs, small edits, branch creation, and GitHub commits. They do not replace a full local terminal for native Apple builds, DS builds, RGDS device tests, or anything that needs local toolchains.

## Safety boundaries

- Do not commit `.env` files, credentials, tokens, local model files, generated build outputs, or private machine paths.
- Do not commit `.external/`, `.prismtek-tools/`, `third_party/local/`, `node_modules/`, `dist/`, or `build/`.
- Do not claim a task is verified on RGDS, Steam Deck, Windows, macOS, Linux, iOS, or DS unless there is a real runtime/device receipt.
