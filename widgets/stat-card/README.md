# Widget: stat-card

**Category**: display  
**Status**: active  
**Folder**: `widgets/stat-card/`

## What it does
Renders a single KPI metric card. Shows a label, primary value, optional delta vs previous period, and optional sparkline trend.

## Data contract
```ts
{
  value: string | number   // required — main metric value
  label: string            // required — metric name
  delta?: number           // optional — % change vs prior period
  trend?: number[]         // optional — array of historical values for sparkline
  unit?: string            // optional — '%', '$', 'hrs', etc.
  icon?: string            // optional — Lucide icon name
}
```

## Where it gets data
- Direct prop injection from parent dashboard
- Or via `ingestion_records` table query filtered by `source` and `tenant_id`

## Machine note
This widget is safe to render with no data — shows skeleton state automatically.
