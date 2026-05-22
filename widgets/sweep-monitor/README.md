# Widget: sweep-monitor

**Category**: display  
**Status**: active  
**Folder**: `widgets/sweep-monitor/`

## What it does
Answers the question: **"Did the output get swept?"**

Shows a live table of recent output runs and their sweep status — whether `the-pen` has confirmed receipt. Highlights pending (unsent), swept (confirmed), and failed (error) states.

## Data contract
```ts
{
  sweepLog: Array<{
    id: string
    output_run_id: string
    status: 'received' | 'acknowledged' | 'failed'
    pen_event_id?: string
    created_at: string
  }>
  tenantId?: string        // filter to one tenant
  autoRefresh?: boolean    // poll every 30s if true
}
```

## Where the data goes
All outputs flow:
```
Output emitted → output_runs table → the-pen webhook → sweep_log table → this widget reads sweep_log
```

## Machine note
This is the **observability surface** for the output pipeline. If `the-pen` is down, this widget will show a growing list of `pending` items — that is the signal to investigate.
