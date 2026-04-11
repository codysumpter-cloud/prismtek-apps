# GitHub Automation in Prismtek Apps

This document explains the repository automation enabled in `prismtek-apps` and how it should be used.

## Current automation

### 1. CI pull request checks

The repository includes a lightweight CI workflow that runs on pull requests and key branch pushes.

It validates:
- key repo files exist
- npm dependencies install cleanly
- the web app typecheck step passes
- shared package typecheck steps pass
- the repo build completes

Workflow file:
- `.github/workflows/ci.yml`

### 2. CodeQL security scanning

The repository includes a CodeQL workflow focused on JavaScript/TypeScript and GitHub Actions.

It runs on:
- pull requests
- pushes to `main`
- a weekly schedule

Workflow file:
- `.github/workflows/codeql.yml`

### 3. Planner-v3 issue-to-PR automation

The issue-to-PR path is planner-v3 only.

It:
- listens for the `autonomy:execute` label
- generates a scoped plan comment
- can open a draft PR with a bounded autonomy packet when execution is enabled
- does not make speculative code edits by default

Related files:
- `.github/workflows/issue-to-pr-v3.yml`
- `.github/autonomy/execution-policy.json`
- `scripts/github-issue-planner-v3.py`
- `scripts/github-autonomy-selftest.py`
- `scripts/github-builtin-autonomy-executor.sh`
- `scripts/github-neptr-verify.sh`

Repo variable required to enable scaffold execution:
- `PRISMTEK_AUTONOMY_EXECUTION_ENABLED=true`

### 4. Cosmic Owl caretaker

The caretaker workflow checks repository health and opens a maintenance issue when attention is needed.

Related files:
- `.github/workflows/github-caretaker.yml`
- `scripts/github-maintenance-report.sh`

### 5. Moe repair worker

Moe is the bounded GitHub repair worker that prepares draft PRs from explicit change scripts.

Related files:
- `.github/workflows/moe-repair.yml`
- `scripts/moe-open-pr.sh`

### 6. Dependabot

Dependabot is configured to keep npm and GitHub Actions dependencies fresh.

Config file:
- `.github/dependabot.yml`

## Deliberately not moved here yet

### Workspace sync on merge

Workspace sync is still a self-hosted runtime concern and should remain outside `prismtek-apps` until there is a real product-owned runner and workspace sync story for this repo.

### BeMore iOS release automation

The working iOS validate/TestFlight path is still owned by `bmo-stack` until the actual iOS project is re-homed into this repo and proven here.

## Recommended repository settings

For best results, enable a ruleset or branch protection on `main` that requires:
- pull requests before merge
- required status checks
- the `ci / validate` check
- the `codeql / Analyze (javascript-typescript)` check
- the `codeql / Analyze (actions)` check

Recommended additional settings:
- require conversation resolution before merge
- optionally require at least one approving review

Private CodeQL note:
- GitHub rejected CodeQL upload on this private repo with `Advanced security has not been purchased`.
- `codeql.yml` now uses a preflight and skips analysis unless the repo can upload code scanning results or `ENABLE_PRIVATE_CODEQL=true` is set after Advanced Security is available.

## Why this matters

These automations make `prismtek-apps` more durable by catching broken repo changes early, surfacing workflow and code scanning issues, keeping dependency drift under control, and providing bounded issue-to-PR and repair paths.
