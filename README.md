# Prismtek Platform Monorepo

Production-grade OpenClaw/NemoClaw-powered application platform with Enterprise App Factory and sandboxed runtime.

## Architecture

This is a monorepo managed by **Turbo** and **npm Workspaces**.

- `apps/web`: Vite + React frontend (React 19, Tailwind CSS, Framer Motion).
- `apps/api`: Express.js backend (Node.js, TypeScript).
- `packages/core`: Shared types and utilities.
- `packages/app-factory`: Scaffolding engine plus imported prototype apps.
- `packages/sandbox`: Logic for managing isolated Docker containers.

## Prerequisites

- Node.js 18+
- Docker & Docker Compose
- PostgreSQL & Redis (included in docker-compose)

## Getting Started

1.  **Install dependencies**:
    ```bash
    npm install
    ```

2.  **Configure environment**:
    ```bash
    cp .env.example .env
    # Fill in your API keys and configuration
    ```

3.  **Run development environment**:
    ```bash
    # Using Turbo (runs all apps in parallel)
    npm run dev

    # Or using Docker Compose
    docker-compose up
    ```

4.  **Build for production**:
    ```bash
    npm run build
    ```

## Project Structure

```
/prismtek-monorepo
  /apps
    /web (Vite frontend)
    /api (Express backend)
  /packages
    /core (Shared types)
    /app-factory
      /apps (imported app-factory prototypes)
      apps.manifest.json
    /sandbox (Sandbox logic)
```

## Imported App Factory Prototypes

The repo now includes imported prototypes from `~/Desktop/app factory` under:

- `packages/app-factory/apps/`
- `packages/app-factory/apps.manifest.json`
- `packages/app-factory/README.md`

Imported apps currently include:

- `ai-edge-gallery`
- `cosmic-flow`
- `function-call-kitchen`
- `gemini-runner`
- `gemini-slingshot`
- `image-to-voxel-art`
- `infinite-heroes`
- `infogenius`
- `lumina-festival`
- `massive-multiplayer-laser-tag`
- `multiplayer-neon-snake`
- `svg-generator`
- `synthwave-space`
- `type-motion`
- `voxel-toy-box`
- `voxel-toy-box-2`

## Key Features

- **Auth + Rate Limiting**: API protection and session control.
- **Sandboxed Runtime**: Isolated Docker containers for safe code execution.
- **Enterprise App Factory**: Scaffolding production-grade apps from templates and imported prototypes.
- **Cross-Platform**: Responsive web platform for desktop and mobile.
- **OpenClaw Integration**: Support for OpenClaw/NemoClaw-powered workflows.

## License

Apache-2.0
