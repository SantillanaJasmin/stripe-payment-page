# CLAUDE.md

Pay-by-Link application built using Rails 8 bundled with Hotwire, Tailwind and Stripe elements for payment collection.

## Development

Run and build project using Docker and docker-compose. For macOS users with Colima tool to run Docker containers, use `docker compose <action>`.

### Setup
Requires a `.env` file with `DATABASE_HOST`, `DATABASE_USERNAME`, `DATABASE_PASSWORD` (see `.env.example`).

```bash
docker compose build # Build all services defined in docker-compose.yml
docker compose build <service> # Build a specific service
```

If there are changes in `Gemfile`, run
```bash
docker compose exec web bundle install
docker compose exec build web
```

### Run the application
```bash
docker compose up
```

### Database Operations
| Action | Command |
|--------|---------|
| Run migrations | `docker compose exec web rails db:migrate` |
| Seed the DB | `docker compose exec web rails db:seed` |

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
