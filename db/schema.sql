-- T4H White-Label Platform — Canonical Schema
-- All tables used across the platform and tenants
-- Last updated: 2026-05-22

-- ============================================================
-- TENANCY
-- ============================================================

CREATE TABLE IF NOT EXISTS tenants (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  slug          TEXT NOT NULL UNIQUE,
  name          TEXT NOT NULL,
  domain        TEXT UNIQUE,
  subdomain     TEXT UNIQUE,
  plan          TEXT NOT NULL DEFAULT 'free', -- free | pro | enterprise
  status        TEXT NOT NULL DEFAULT 'active', -- active | suspended | churned
  config        JSONB NOT NULL DEFAULT '{}',   -- branding, features, limits
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tenant_users (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  user_id       UUID NOT NULL,
  role          TEXT NOT NULL DEFAULT 'member', -- owner | admin | member | viewer
  invited_by    UUID,
  accepted_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- WIDGETS
-- ============================================================

CREATE TABLE IF NOT EXISTS widgets (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL UNIQUE,  -- kebab-case, matches /widgets/[name]
  version       TEXT NOT NULL DEFAULT '1.0.0',
  category      TEXT NOT NULL,         -- display | input | chart | map | feed | action
  description   TEXT,
  schema        JSONB NOT NULL DEFAULT '{}', -- props schema
  status        TEXT NOT NULL DEFAULT 'active', -- active | deprecated | experimental
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS tenant_widgets (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  widget_id     UUID NOT NULL REFERENCES widgets(id),
  enabled       BOOLEAN NOT NULL DEFAULT TRUE,
  config        JSONB NOT NULL DEFAULT '{}',
  position      INTEGER,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- INGESTION
-- ============================================================

CREATE TABLE IF NOT EXISTS ingestion_sources (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL UNIQUE,
  type          TEXT NOT NULL, -- webhook | poll | stream | upload | api
  connector     TEXT NOT NULL, -- folder name under /ingestion/sources/
  config        JSONB NOT NULL DEFAULT '{}',
  status        TEXT NOT NULL DEFAULT 'active',
  last_run_at   TIMESTAMPTZ,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS ingestion_runs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  source_id     UUID NOT NULL REFERENCES ingestion_sources(id),
  tenant_id     UUID REFERENCES tenants(id),
  status        TEXT NOT NULL, -- running | success | failed | partial
  records_in    INTEGER NOT NULL DEFAULT 0,
  records_out   INTEGER NOT NULL DEFAULT 0,
  errors        JSONB,
  started_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  finished_at   TIMESTAMPTZ
);

CREATE TABLE IF NOT EXISTS ingestion_records (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  run_id        UUID NOT NULL REFERENCES ingestion_runs(id),
  tenant_id     UUID REFERENCES tenants(id),
  source        TEXT NOT NULL,
  raw           JSONB NOT NULL,
  normalised    JSONB,
  routed_to     TEXT[],        -- which sinks received this
  status        TEXT NOT NULL DEFAULT 'pending', -- pending | routed | failed
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- OUTPUTS
-- ============================================================

CREATE TABLE IF NOT EXISTS output_sinks (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL UNIQUE,
  type          TEXT NOT NULL, -- webhook | db | file | email | queue | api
  emitter       TEXT NOT NULL, -- folder name under /outputs/sinks/
  config        JSONB NOT NULL DEFAULT '{}',
  status        TEXT NOT NULL DEFAULT 'active',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS output_runs (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  sink_id       UUID NOT NULL REFERENCES output_sinks(id),
  tenant_id     UUID REFERENCES tenants(id),
  source_run_id UUID REFERENCES ingestion_runs(id),
  status        TEXT NOT NULL, -- pending | sent | failed | swept
  payload       JSONB NOT NULL DEFAULT '{}',
  response      JSONB,
  swept_at      TIMESTAMPTZ,   -- when the-pen confirmed receipt
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- SWEEPER / THE-PEN SYNC
-- ============================================================

CREATE TABLE IF NOT EXISTS sweep_log (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  output_run_id UUID NOT NULL REFERENCES output_runs(id),
  tenant_id     UUID REFERENCES tenants(id),
  pen_event_id  TEXT,          -- the-pen's own event ID for correlation
  status        TEXT NOT NULL, -- received | acknowledged | failed
  payload       JSONB NOT NULL DEFAULT '{}',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- TEMPLATES
-- ============================================================

CREATE TABLE IF NOT EXISTS templates (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name          TEXT NOT NULL UNIQUE,
  slug          TEXT NOT NULL UNIQUE,
  type          TEXT NOT NULL, -- page | email | report | widget-set | onboarding
  content       JSONB NOT NULL DEFAULT '{}', -- serialised template body
  variables     JSONB NOT NULL DEFAULT '[]', -- [{key, type, required, default}]
  tenant_id     UUID REFERENCES tenants(id), -- NULL = global template
  status        TEXT NOT NULL DEFAULT 'active',
  version       TEXT NOT NULL DEFAULT '1.0.0',
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- AUDIT
-- ============================================================

CREATE TABLE IF NOT EXISTS audit_log (
  id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tenant_id     UUID REFERENCES tenants(id),
  actor_id      UUID,
  actor_type    TEXT NOT NULL DEFAULT 'user', -- user | system | agent | machine
  action        TEXT NOT NULL,
  resource_type TEXT NOT NULL,
  resource_id   TEXT,
  before        JSONB,
  after         JSONB,
  metadata      JSONB,
  created_at    TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- ============================================================
-- INDEXES
-- ============================================================

CREATE INDEX IF NOT EXISTS idx_tenant_users_tenant ON tenant_users(tenant_id);
CREATE INDEX IF NOT EXISTS idx_tenant_widgets_tenant ON tenant_widgets(tenant_id);
CREATE INDEX IF NOT EXISTS idx_ingestion_runs_source ON ingestion_runs(source_id);
CREATE INDEX IF NOT EXISTS idx_ingestion_records_run ON ingestion_records(run_id);
CREATE INDEX IF NOT EXISTS idx_output_runs_sink ON output_runs(sink_id);
CREATE INDEX IF NOT EXISTS idx_sweep_log_output ON sweep_log(output_run_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_tenant ON audit_log(tenant_id);
CREATE INDEX IF NOT EXISTS idx_audit_log_actor ON audit_log(actor_id);
