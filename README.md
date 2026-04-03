# Prismtek Platform Monorepo

Production-grade OpenClaw/NemoClaw-powered application platform with Enterprise App Factory and sandboxed runtime.

## Architecture

This is a monorepo managed by **Turbo** and **npm Workspaces**.

- `apps/web`: Next.js frontend (React 19, Tailwind CSS, Framer Motion).
- `apps/api`: Express.js backend (Node.js, TypeScript).
- `packages/core`: Shared types and utilities.
- `packages/app-factory`: Scaffolding engine for generating applications.
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
    /web (Next.js frontend)
    /api (Express backend)
  /packages
    /core (Shared types)
    /app-factory (App Factory logic)
    /sandbox (Sandbox logic)
  /docker (Dockerfile for sandboxes)
  /templates (App Factory templates)
```

## Key Features

- **Secure Auth**: Firebase-powered authentication.
- **Sandboxed Runtime**: Isolated Docker containers for safe code execution.
- **Enterprise App Factory**: Scaffolding production-grade apps from templates.
- **Cross-Platform**: Responsive PWA for mobile and desktop.
- **OpenClaw Integration**: Full support for OpenClaw/NemoClaw agents.

## License

Apache-2.0
