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
docker compose build web
docker compose restart web
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

Run the migration command if there are new db migration files

## Architecture

### Domain Model
`PaymentLink` model consists of the ff. attributes:
| name | type | purpose |
|------|----------|---------|
| line_items | json | stores the item breakdown (ex. `{ name: 'Item 1', quantity: 1, amount: 25.00 }` )
| token | alphanumeric string | unique id that distinguishes transactions from one another |
| surcharge | decimal | extra fee on top of the total `line_items` amount; computed based on the card's issuing country  |
| total_amount_paid | decimal | gross amount of total `line_items` amount with surcharge |
| payment_intent_id | string | unique identifier for retrieving checkout attempt details |

Surcharge is computed with the ff. matrix:
| Issuing country | Formula |
|-----------------|---------|
| Australia (AU) | total `line_items` amount + (total `line_items` amount * 0.0175) + 0.30 |
| Non-AU accounts | total `line_items` amount + (total `line_items` amount * 0.0175) + 0.30 + (total `line_items` amount * 0.035)

### Frontend
- JS entrypoint: `app/javascript/application.js` — imports Turbo and auto-registers Stimulus controllers from `app/javascript/controllers/`
- CSS entrypoint: `app/assets/stylesheets/application.tailwind.css` — compiled to `app/assets/builds/application.css`
- Built assets land in `app/assets/builds/` (managed by build scripts, not committed except for initial placeholders)

### Stripe Elements
Pre-built UI components that are used to capture card details 

### Payment Confirmation
Payment processing is handled by `app/controllers/online_payments_controller.rb` -> `confirm` route.

### Database
The database config reads connection params from `DATABASE_HOST`, `DATABASE_USERNAME`, and `DATABASE_PASSWORD` env vars. Production uses four separate databases for primary, cache, queue, and cable connections.

### CI
`bin/ci` runs: setup → RuboCop → bundler-audit → yarn audit → Brakeman → Rails tests → seed test. System tests are commented out but available via `bin/rails test:system`.
