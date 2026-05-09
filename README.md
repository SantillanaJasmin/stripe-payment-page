# Pay-by-Link Payment Application

A modern Rails 8 application for creating and managing payment links with Stripe integration. Built with Hotwire (Turbo & Stimulus), Tailwind CSS, and PostgreSQL.

## Features

- **Payment Links**: Generate unique payment links with configurable line items
- **Stripe Integration**: Secure payment processing with Stripe Elements
- **Surcharge Calculation**: Automatic surcharge computation based on card issuing country
- **Real-time Updates**: Interactive UI powered by Hotwire Turbo and Stimulus
- **Responsive Design**: Tailwind CSS for modern, mobile-friendly interface

## Prerequisites

- **Ruby**: 3.3+ (see `.ruby-version`)
- **Node.js**: 18+ (see `.node-version`)
- **Docker** & **Docker Compose**: For containerized development
- **PostgreSQL**: 15+ (runs in Docker container)
- **Stripe Account**: For payment processing (get API keys from Stripe Dashboard)

## Getting Started

### 1. Clone the Repository

```bash
git clone <repository-url>
cd stripe-payment-page
```

### 2. Configure Environment Variables

Copy `.env.example` to `.env` and update with your values:
- `DATABASE_HOST`, `DATABASE_USERNAME`, `DATABASE_PASSWORD`
- Stripe keys: `STRIPE_PUBLIC_KEY`, `STRIPE_SECRET_KEY`

### 3. Build and Run

For detailed setup commands (Docker build, dependencies, migrations, database seeding), see the [Setup](CLAUDE.md#setup) section in [CLAUDE.md](CLAUDE.md).

Start the application:

```bash
docker compose up
```

The application will be available at **http://localhost:3000**

See [CLAUDE.md](CLAUDE.md#database-operations) for database operations and [CLAUDE.md](CLAUDE.md#run-the-application) for complete command reference.

## Architecture

See [CLAUDE.md](CLAUDE.md) for detailed architecture information including:
- **Domain Model**: PaymentLink attributes and surcharge calculation matrix
- **Frontend Architecture**: JavaScript and CSS entry points
- **Stripe Elements**: Payment UI components
- **Payment Processing**: Confirmation flow via `OnlinePaymentsController`
- **Database Configuration**: Multi-database setup for production

### Surcharge Computation

The application calculates transaction surcharges based on card issuing country. For details on the surcharge formula and Stripe fee structure, see [Affonso's Stripe Fee Calculator for Australia](https://affonso.io/resources/stripe-fee-calculator/australia).

### Tech Stack

- **Framework**: Rails 8.1
- **Database**: PostgreSQL
- **Frontend**: Hotwire (Turbo + Stimulus)
- **Styling**: Tailwind CSS
- **Payments**: Stripe
- **Build Tools**: esbuild, @tailwindcss/cli
<!-- - **Deployment**: Kamal (Docker-ready) -->

## Development

See [CLAUDE.md](CLAUDE.md) for comprehensive development guidance including build commands, troubleshooting, and detailed architecture notes.

### Stripe MCP Integration

For enhanced development with Claude Code, install the [Stripe MCP for Claude Code](https://marketplace.stripe.com/apps/mcp-claude-code). This integration enables:
- Direct access to Stripe API documentation and resources
- Real-time Stripe dashboard data queries
- Streamlined debugging of payment-related issues

This is particularly useful when working on payment confirmation flows and surcharge calculations.

<!-- ## Testing

Run the test suite:

```bash
docker compose exec web rails test
```

For comprehensive CI setup (RuboCop, bundler-audit, Brakeman, system tests), see the `bin/ci` script documented in [CLAUDE.md](CLAUDE.md).

## Deployment

This application is configured for deployment with [Kamal](https://kamal-deploy.org/). Configuration is in `.kamal/`. -->

## Troubleshooting

**Port already in use**: If port 3000 is in use, modify the `docker-compose.yml` port mapping.

**Database connection error**: Ensure `.env` has correct `DATABASE_*` variables and the database service is running (`docker compose logs db`).

**Assets not loading**: Rebuild assets with `docker compose exec web yarn build && docker compose exec web yarn build:css`.

## Support

For issues with Stripe integration, see [Stripe Documentation](https://stripe.com/docs).

For Rails/Docker questions, refer to [Rails Guides](https://guides.rubyonrails.org/) and [Docker Compose Documentation](https://docs.docker.com/compose/).
