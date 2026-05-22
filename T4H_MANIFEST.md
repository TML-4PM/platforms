# T4H White-Label Platform — Machine Manifest

> This file is the machine entry point. Any agent, pipeline, or automation picking up this repo starts here.

## Identity
- **Repo**: `TML-4PM/platforms` (forked from `vercel/platforms`)
- **Owner**: Tech4Humanity / Troy Latter
- **Purpose**: White-label multi-tenant SaaS shell for T4H product portfolio
- **Stack**: Next.js App Router, TypeScript, Prisma, Vercel Edge, Supabase

## Machine Pickup Protocol
1. Read `T4H_MANIFEST.md` (this file)
2. Read `db/schema.sql` — all canonical tables
3. Read `widgets/WIDGET_REGISTRY.json` — all registered widgets
4. Read `ingestion/INGESTION_MAP.json` — all data sources and their routing
5. Read `outputs/OUTPUT_CONTRACTS.json` — what comes out, where it goes
6. Check `CONVENTIONS.md` for folder structure and naming rules

## Repos This Feeds Into
- `TML-4PM/the-pen` — universal intake gate (all outputs route here first)
- `TML-4PM/mcp-command-centre` — orchestration layer
- `TML-4PM/ai4tradies` — first white-label tenant
- `TML-4PM/holo-org` — second white-label tenant

## Template Lifecycle
```
INGEST → SORT → RENDER (widgets) → OUTPUT → SWEEP (the-pen) → PERSIST (Supabase)
```

## Status
- [ ] DB tables created
- [ ] Widget registry populated
- [ ] Ingestion map defined
- [ ] Output contracts defined
- [ ] First tenant (ai4tradies) configured
- [ ] CI/CD wired to the-pen
