# Supabase Local Development

This project uses Supabase CLI for local development, allowing you to develop and test without needing a remote Supabase project.

## Quick Start

```bash
# Start the local Supabase stack (PostgreSQL, Auth, Storage, etc.)
supabase start

# Check status
supabase status

# Stop when done
supabase stop
```

## Local Development URLs

When running `supabase start`, you'll have access to:

- **API URL**: http://127.0.0.1:54321
- **Studio URL**: http://127.0.0.1:54323 (Web-based database management)
- **Mailpit URL**: http://127.0.0.1:54324 (Email testing for auth flows)
- **Database URL**: postgresql://postgres:postgres@127.0.0.1:54322/postgres

## Database Migrations

Create database migrations for schema changes:

```bash
# Create a new migration
supabase migration new <migration_name>

# This creates a file in: supabase/migrations/

# Apply migrations
supabase db reset  # Resets and applies all migrations
```

## Configuration

The Supabase configuration is stored in `supabase/config.toml`. You can customize:
- Port numbers
- Authentication settings
- Storage settings
- Database settings

## Environment Variables

The `.env` file is already configured with local development credentials:

```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=<local-anon-key>
```

## Useful Commands

```bash
# View logs
supabase start --debug

# Reset database (destroys all data)
supabase db reset

# Generate TypeScript types from your database schema
supabase gen types typescript --local > lib/core/data/database.types.ts

# Push local changes to remote (when you have a cloud project)
supabase db push

# Pull remote changes to local
supabase db pull
```

## Studio (Database UI)

Access the Supabase Studio at http://127.0.0.1:54323 to:
- View and edit data in tables
- Run SQL queries
- Manage authentication users
- Configure storage buckets
- View logs and performance metrics

## Seed Data

To populate your local database with test data:

1. Create a seed file: `supabase/seed.sql`
2. Add your INSERT statements
3. Run: `supabase db reset` (applies migrations + seed)

Example seed file:
```sql
-- Insert test users
INSERT INTO auth.users (id, email) VALUES
  ('00000000-0000-0000-0000-000000000001', 'test@example.com');

-- Insert test notes
INSERT INTO notes (user_id, title, content) VALUES
  ('00000000-0000-0000-0000-000000000001', 'Test Note', 'This is a test note');
```

## Production Deployment

When ready to deploy:

1. Create a Supabase project at https://supabase.com
2. Link your local project: `supabase link --project-ref <project-id>`
3. Push your migrations: `supabase db push`
4. Update `.env` with production credentials

## Troubleshooting

**Port already in use:**
```bash
supabase stop
# Or stop all instances
supabase stop --all
```

**Database connection issues:**
```bash
# Check Docker containers are running
docker ps | grep supabase

# Restart Supabase
supabase stop
supabase start
```

**Reset everything:**
```bash
supabase stop
supabase db reset
```

## Learn More

- [Supabase CLI Documentation](https://supabase.com/docs/guides/cli)
- [Local Development Guide](https://supabase.com/docs/guides/cli/local-development)
- [Database Migrations](https://supabase.com/docs/guides/cli/local-development#database-migrations)
