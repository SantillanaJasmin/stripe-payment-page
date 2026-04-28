# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Stack

- **Ruby 4.0.3** / **Rails 8.1** with PostgreSQL 16
- **Node 25.9** / **Yarn** for JS bundling
- **Tailwind CSS v4** (via `@tailwindcss/cli`) + **esbuild** for JS
- **Hotwire** (Turbo + Stimulus) for frontend interactivity
- Asset pipeline: **Propshaft** (not Sprockets)
- Background jobs / caching / cable: **Solid Queue**, **Solid Cache**, **Solid Cable** (DB-backed)
- Deployment: **Kamal** (Docker-based)

## Development

### Local setup
```bash
bin/setup
```

### Running the dev server (Rails + JS + CSS watchers)
```bash
bin/dev
```
This uses `foreman` with `Procfile.dev` to run the Rails server (port 3000), `yarn build --watch`, and `yarn build:css --watch` concurrently.

### Docker Compose (alternative)
```bash
docker-compose up
```
Requires a `.env` file with `DATABASE_HOST`, `DATABASE_USERNAME`, `DATABASE_PASSWORD` (see `.env.example`).

## Commands

| Task | Command |
|---|---|
| Run all tests | `bin/rails test` |
| Run a single test file | `bin/rails test test/path/to/file_test.rb` |
| Run a single test by line | `bin/rails test test/path/to/file_test.rb:42` |
| Lint Ruby | `bin/rubocop` |
| Security audit (gems) | `bin/bundler-audit` |
| Security audit (code) | `bin/brakeman --quiet --no-pager` |
| Full CI suite | `bin/ci` |
| Build JS | `yarn build` |
| Build CSS | `yarn build:css` |

## Architecture

This is a freshly scaffolded Rails 8 app being built into a Stripe payment page. The application logic has not yet been added — routes, controllers, models, and views are all stubs at this point.

### Frontend
- JS entrypoint: `app/javascript/application.js` — imports Turbo and auto-registers Stimulus controllers from `app/javascript/controllers/`
- CSS entrypoint: `app/assets/stylesheets/application.tailwind.css` — compiled to `app/assets/builds/application.css`
- Built assets land in `app/assets/builds/` (managed by build scripts, not committed except for initial placeholders)

### Database
The database config reads connection params from `DATABASE_HOST`, `DATABASE_USERNAME`, and `DATABASE_PASSWORD` env vars. Production uses four separate databases for primary, cache, queue, and cable connections.

### CI
`bin/ci` runs: setup → RuboCop → bundler-audit → yarn audit → Brakeman → Rails tests → seed test. System tests are commented out but available via `bin/rails test:system`.
