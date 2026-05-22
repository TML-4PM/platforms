# T4H Platform Conventions

## Folder Structure

```
/app                    # Next.js App Router pages
/app/[domain]           # Per-tenant dynamic routing
/components             # Shared React components
/widgets                # Widget system (see below)
  /widgets/[name]/      # One folder per widget
    index.tsx           # Widget component
    schema.ts           # Props + data contract
    README.md           # What it does, what data it needs
/db                     # Database
  schema.sql            # Canonical table definitions
  migrations/           # Versioned migration files
  seeds/                # Seed data per tenant type
/ingestion              # Data ingestion engines
  INGESTION_MAP.json    # Registry of all sources
  /sources/[name]/      # One folder per source
    connector.ts        # Pull/push logic
    schema.ts           # Input shape
/outputs                # Output contracts
  OUTPUT_CONTRACTS.json # Registry of all outputs
  /sinks/[name]/        # One folder per sink
    emitter.ts          # Emit logic
    schema.ts           # Output shape
/tenants                # Per-tenant config
  /[tenant-slug]/
    config.json         # Branding, features, domains
    overrides/          # Component overrides
/lib                    # Utilities, hooks, helpers
/types                  # Global TypeScript types
```

## Naming Conventions
- Folders: `kebab-case`
- Components: `PascalCase.tsx`
- Utilities: `camelCase.ts`
- DB tables: `snake_case`
- JSON keys: `camelCase`
- Widget names: `kebab-case` matching folder name
- Tenant slugs: `kebab-case` matching domain prefix

## Widget Convention
Every widget MUST have:
1. `index.tsx` — renderable React component
2. `schema.ts` — Zod schema for props and data
3. `README.md` — human + machine description
4. Entry in `widgets/WIDGET_REGISTRY.json`

## Output Convention
Every output MUST:
1. Route through `the-pen` before any external sink
2. Be logged to `outputs/run_log` table
3. Have a defined contract in `OUTPUT_CONTRACTS.json`
4. Be sweepable (idempotent, replayable)

## Machine Rules
- A machine can fully reconstruct intent from: MANIFEST + schema.sql + WIDGET_REGISTRY + INGESTION_MAP + OUTPUT_CONTRACTS
- No implicit state. Everything declared.
- All config in JSON or TypeScript — no YAML except CI
